use std::cell::Cell;
use std::ffi::c_void;
use std::ptr::null_mut;
use windows_sys::core::{GUID, HRESULT};
use windows_sys::Win32::Foundation::HWND;
use windows_sys::Win32::System::Com::{CoCreateInstance, CLSCTX_INPROC_SERVER};

const CLSID_TASKBAR_LIST: GUID = GUID::from_u128(0x56fd_f344_fd6d_11d0_958a_0060_97c9_a090);
const IID_ITASKBAR_LIST: GUID = GUID::from_u128(0x56fd_f342_fd6d_11d0_958a_0060_97c9_a090);

#[repr(C)]
struct TaskbarListVtbl {
    query_interface: usize,
    add_ref: usize,
    release: usize,
    hr_init: unsafe extern "system" fn(*mut TaskbarList) -> HRESULT,
    add_tab: unsafe extern "system" fn(*mut TaskbarList, HWND) -> HRESULT,
    delete_tab: unsafe extern "system" fn(*mut TaskbarList, HWND) -> HRESULT,
}

#[repr(C)]
struct TaskbarList {
    vtbl: *const TaskbarListVtbl,
}

thread_local! {
    static TASKBAR: Cell<*mut TaskbarList> = const { Cell::new(null_mut()) };
}

fn taskbar() -> Result<*mut TaskbarList, String> {
    TASKBAR.with(|cached| {
        if !cached.get().is_null() {
            return Ok(cached.get());
        }
        let mut instance: *mut c_void = null_mut();
        let created = unsafe {
            CoCreateInstance(
                &CLSID_TASKBAR_LIST,
                null_mut(),
                CLSCTX_INPROC_SERVER,
                &IID_ITASKBAR_LIST,
                &mut instance,
            )
        };
        if created < 0 || instance.is_null() {
            return Err(format!("ITaskbarList is unavailable: {created:#x}"));
        }
        let list = instance.cast::<TaskbarList>();
        unsafe { ((*(*list).vtbl).hr_init)(list) };
        cached.set(list);
        Ok(list)
    })
}

pub fn set_tab(window: HWND, shown: bool) -> Result<(), String> {
    let list = taskbar()?;
    unsafe {
        let vtbl = &*(*list).vtbl;
        if shown {
            (vtbl.add_tab)(list, window);
        } else {
            (vtbl.delete_tab)(list, window);
        }
    }
    Ok(())
}
