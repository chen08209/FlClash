use std::ffi::c_void;
use std::mem::transmute_copy;
use std::ptr::{null_mut, NonNull};

use windows_sys::core::{BOOL, GUID, HRESULT};
use windows_sys::Win32::System::LibraryLoader::{GetProcAddress, LoadLibraryW};

const DWRITE_FACTORY_TYPE_SHARED: i32 = 0;
const IID_IDWRITE_FACTORY: GUID = GUID::from_u128(0xb859ee5a_d838_4b5b_a2e8_1adc7d93db48);

type CreateFactory = unsafe extern "system" fn(i32, *const GUID, *mut *mut c_void) -> HRESULT;
type GetObject = unsafe extern "system" fn(*mut c_void, *mut *mut c_void) -> HRESULT;

/// A COM interface called by vtable slot, so DirectWrite needs no binding crate.
struct Com(NonNull<*const *const c_void>);

impl Com {
    fn new(pointer: *mut c_void) -> Option<Self> {
        NonNull::new(pointer.cast()).map(Self)
    }

    fn raw(&self) -> *mut c_void {
        self.0.as_ptr().cast()
    }

    unsafe fn method<F: Copy>(&self, index: usize) -> F {
        unsafe { transmute_copy(&*(*self.0.as_ptr()).add(index)) }
    }

    unsafe fn object(&self, index: usize) -> Result<Com, HRESULT> {
        let mut out = null_mut();
        let hr = unsafe { self.method::<GetObject>(index)(self.raw(), &mut out) };
        if hr < 0 {
            return Err(hr);
        }
        Com::new(out).ok_or(hr)
    }
}

impl Drop for Com {
    fn drop(&mut self) {
        // SAFETY: slot 2 of every COM vtable is IUnknown::Release.
        unsafe {
            self.method::<unsafe extern "system" fn(*mut c_void) -> u32>(2)(self.raw());
        }
    }
}

fn wide(value: &str) -> Vec<u16> {
    value.encode_utf16().chain(std::iter::once(0)).collect()
}

pub fn families() -> Result<Vec<String>, String> {
    let dll = wide("dwrite.dll");
    // SAFETY: slots and signatures follow dwrite.h for each interface.
    unsafe {
        let module = LoadLibraryW(dll.as_ptr());
        if module.is_null() {
            return Err("dwrite.dll is not available".to_owned());
        }
        let create: CreateFactory = std::mem::transmute(
            GetProcAddress(module, c"DWriteCreateFactory".as_ptr().cast())
                .ok_or("DWriteCreateFactory is missing")?,
        );
        let mut out = null_mut();
        let hr = create(DWRITE_FACTORY_TYPE_SHARED, &IID_IDWRITE_FACTORY, &mut out);
        let factory = Com::new(out)
            .filter(|_| hr >= 0)
            .ok_or_else(|| format!("DWriteCreateFactory: {hr:#x}"))?;

        let get_collection: unsafe extern "system" fn(
            *mut c_void,
            *mut *mut c_void,
            BOOL,
        ) -> HRESULT = factory.method(3);
        let mut out = null_mut();
        let hr = get_collection(factory.raw(), &mut out, 0);
        let collection = Com::new(out)
            .filter(|_| hr >= 0)
            .ok_or_else(|| format!("GetSystemFontCollection: {hr:#x}"))?;

        let count =
            collection.method::<unsafe extern "system" fn(*mut c_void) -> u32>(3)(collection.raw());
        let family_at: unsafe extern "system" fn(*mut c_void, u32, *mut *mut c_void) -> HRESULT =
            collection.method(4);
        Ok((0..count)
            .filter_map(|index| {
                let mut out = null_mut();
                if family_at(collection.raw(), index, &mut out) < 0 {
                    return None;
                }
                family_name(&Com::new(out)?)
            })
            .collect())
    }
}

/// The en-us name, else the first; the engine matches any of them.
unsafe fn family_name(family: &Com) -> Option<String> {
    unsafe {
        let names = family.object(6).ok()?;
        let locale = wide("en-us");
        let mut index = 0u32;
        let mut exists: BOOL = 0;
        let find: unsafe extern "system" fn(
            *mut c_void,
            *const u16,
            *mut u32,
            *mut BOOL,
        ) -> HRESULT = names.method(4);
        let at = if find(names.raw(), locale.as_ptr(), &mut index, &mut exists) >= 0 && exists != 0
        {
            index
        } else {
            0
        };
        let mut length = 0u32;
        let string_length: unsafe extern "system" fn(*mut c_void, u32, *mut u32) -> HRESULT =
            names.method(7);
        if string_length(names.raw(), at, &mut length) < 0 {
            return None;
        }
        let mut buffer = vec![0u16; length as usize + 1];
        let string: unsafe extern "system" fn(*mut c_void, u32, *mut u16, u32) -> HRESULT =
            names.method(8);
        if string(names.raw(), at, buffer.as_mut_ptr(), length + 1) < 0 {
            return None;
        }
        String::from_utf16(&buffer[..length as usize]).ok()
    }
}
