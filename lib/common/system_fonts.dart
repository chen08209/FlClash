import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:win32/win32.dart' show GUID;

import 'print.dart';

@visibleForTesting
Future<List<String>> Function() systemFontFamiliesReader = () =>
    Isolate.run(_readSystemFontFamilies);

/// The font families the engine resolves by name on this host, each listed
/// through the API the engine itself matches names against.
Future<List<String>> loadSystemFontFamilies() async {
  try {
    return await systemFontFamiliesReader();
  } catch (e) {
    commonPrint.log('loadSystemFontFamilies: $e', logLevel: LogLevel.warning);
    return const [];
  }
}

List<String> _readSystemFontFamilies() {
  return sortFontFamilies(switch (Platform.operatingSystem) {
    'macos' => _coreTextFamilies(),
    'windows' => _directWriteFamilies(),
    'linux' => _fontconfigFamilies(),
    'android' => androidFontFamilies(
      File('/system/etc/fonts.xml').readAsStringSync(),
    ),
    _ => const <String>[],
  });
}

@visibleForTesting
List<String> sortFontFamilies(Iterable<String> families) {
  final unique = <String, String>{};
  for (final family in families) {
    final name = family.trim();
    if (name.isEmpty || name.startsWith('.')) {
      continue;
    }
    unique.putIfAbsent(name.toLowerCase(), () => name);
  }
  return unique.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

@visibleForTesting
List<String> androidFontFamilies(String fontsXml) => [
  for (final match in RegExp(
    r'<family\b[^>]*\bname="([^"]+)"',
  ).allMatches(fontsXml))
    match.group(1)!,
];

final class _CFRange extends Struct {
  @IntPtr()
  external int location;

  @IntPtr()
  external int length;
}

List<String> _coreTextFamilies() {
  final coreText = DynamicLibrary.open(
    '/System/Library/Frameworks/CoreText.framework/CoreText',
  );
  final coreFoundation = DynamicLibrary.open(
    '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation',
  );
  final copyFamilyNames = coreText
      .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
        'CTFontManagerCopyAvailableFontFamilyNames',
      );
  final arrayCount = coreFoundation
      .lookupFunction<
        IntPtr Function(Pointer<Void>),
        int Function(Pointer<Void>)
      >('CFArrayGetCount');
  final arrayValue = coreFoundation
      .lookupFunction<
        Pointer<Void> Function(Pointer<Void>, IntPtr),
        Pointer<Void> Function(Pointer<Void>, int)
      >('CFArrayGetValueAtIndex');
  final stringLength = coreFoundation
      .lookupFunction<
        IntPtr Function(Pointer<Void>),
        int Function(Pointer<Void>)
      >('CFStringGetLength');
  final stringCharacters = coreFoundation
      .lookupFunction<
        Void Function(Pointer<Void>, _CFRange, Pointer<Uint16>),
        void Function(Pointer<Void>, _CFRange, Pointer<Uint16>)
      >('CFStringGetCharacters');
  final release = coreFoundation
      .lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('CFRelease');

  String read(Pointer<Void> string, Arena arena) {
    final length = stringLength(string);
    final range = Struct.create<_CFRange>()
      ..location = 0
      ..length = length;
    final buffer = arena<Uint16>(length);
    stringCharacters(string, range, buffer);
    return buffer.cast<Utf16>().toDartString(length: length);
  }

  final names = copyFamilyNames();
  try {
    return using(
      (arena) => [
        for (var i = 0; i < arrayCount(names); i++)
          read(arrayValue(names, i), arena),
      ],
    );
  } finally {
    release(names);
  }
}

extension type const _ComObject(Pointer<Void> pointer) {
  Pointer<NativeFunction<T>> method<T extends Function>(int index) =>
      pointer.cast<Pointer<Pointer<NativeFunction<T>>>>().value[index];

  void release() => method<Uint32 Function(Pointer<Void>)>(
    2,
  ).asFunction<int Function(Pointer<Void>)>()(pointer);
}

typedef _GetObjectNative =
    Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>);
typedef _GetObject = int Function(Pointer<Void>, Pointer<Pointer<Void>>);
typedef _GetIndexedNative =
    Int32 Function(Pointer<Void>, Uint32, Pointer<Pointer<Void>>);
typedef _GetIndexed = int Function(Pointer<Void>, int, Pointer<Pointer<Void>>);

const _dwriteFactoryTypeShared = 0;

const _iidDWriteFactory = '{B859EE5A-D838-4B5B-A2E8-1ADC7D93DB48}';

void _check(int hresult, String call) {
  if (hresult < 0) {
    throw OSError(call, hresult);
  }
}

List<String> _directWriteFamilies() => using((arena) {
  final createFactory = DynamicLibrary.open('dwrite.dll')
      .lookupFunction<
        Int32 Function(Int32, Pointer<GUID>, Pointer<Pointer<Void>>),
        int Function(int, Pointer<GUID>, Pointer<Pointer<Void>>)
      >('DWriteCreateFactory');
  final out = arena<Pointer<Void>>();
  _check(
    createFactory(
      _dwriteFactoryTypeShared,
      GUID(_iidDWriteFactory).toNative(allocator: arena),
      out,
    ),
    'DWriteCreateFactory',
  );
  final factory = _ComObject(out.value);
  try {
    _check(
      factory
          .method<Int32 Function(Pointer<Void>, Pointer<Pointer<Void>>, Int32)>(
            3,
          )
          .asFunction<
            int Function(Pointer<Void>, Pointer<Pointer<Void>>, int)
          >()(factory.pointer, out, 0),
      'GetSystemFontCollection',
    );
    final collection = _ComObject(out.value);
    try {
      final count = collection
          .method<Uint32 Function(Pointer<Void>)>(3)
          .asFunction<int Function(Pointer<Void>)>()(collection.pointer);
      final family = collection
          .method<_GetIndexedNative>(4)
          .asFunction<_GetIndexed>();
      return [
        for (var i = 0; i < count; i++)
          if (family(collection.pointer, i, out) >= 0)
            ?_directWriteFamilyName(_ComObject(out.value), arena),
      ];
    } finally {
      collection.release();
    }
  } finally {
    factory.release();
  }
});

String? _directWriteFamilyName(_ComObject family, Arena arena) {
  try {
    final out = arena<Pointer<Void>>();
    final familyNames = family
        .method<_GetObjectNative>(6)
        .asFunction<_GetObject>();
    if (familyNames(family.pointer, out) < 0) {
      return null;
    }
    final names = _ComObject(out.value);
    try {
      final index = arena<Uint32>();
      final exists = arena<Int32>();
      final findLocale = names
          .method<
            Int32 Function(
              Pointer<Void>,
              Pointer<Utf16>,
              Pointer<Uint32>,
              Pointer<Int32>,
            )
          >(4)
          .asFunction<
            int Function(
              Pointer<Void>,
              Pointer<Utf16>,
              Pointer<Uint32>,
              Pointer<Int32>,
            )
          >();
      final found =
          findLocale(
                names.pointer,
                'en-us'.toNativeUtf16(allocator: arena),
                index,
                exists,
              ) >=
              0 &&
          exists.value != 0;
      final at = found ? index.value : 0;
      final length = arena<Uint32>();
      final stringLength = names
          .method<Int32 Function(Pointer<Void>, Uint32, Pointer<Uint32>)>(7)
          .asFunction<int Function(Pointer<Void>, int, Pointer<Uint32>)>();
      if (stringLength(names.pointer, at, length) < 0) {
        return null;
      }
      final size = length.value + 1;
      final buffer = arena<Uint16>(size);
      final string = names
          .method<
            Int32 Function(Pointer<Void>, Uint32, Pointer<Uint16>, Uint32)
          >(8)
          .asFunction<int Function(Pointer<Void>, int, Pointer<Uint16>, int)>();
      if (string(names.pointer, at, buffer, size) < 0) {
        return null;
      }
      return buffer.cast<Utf16>().toDartString(length: length.value);
    } finally {
      names.release();
    }
  } finally {
    family.release();
  }
}

final class _FcFontSet extends Struct {
  @Int32()
  external int nfont;

  @Int32()
  external int sfont;

  external Pointer<Pointer<Void>> fonts;
}

List<String> _fontconfigFamilies() => using((arena) {
  final fontconfig = DynamicLibrary.open('libfontconfig.so.1');
  final createPattern = fontconfig
      .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
        'FcPatternCreate',
      );
  final addBool = fontconfig
      .lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Utf8>, Int32),
        int Function(Pointer<Void>, Pointer<Utf8>, int)
      >('FcPatternAddBool');
  final createObjectSet = fontconfig
      .lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
        'FcObjectSetCreate',
      );
  final addObject = fontconfig
      .lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Utf8>),
        int Function(Pointer<Void>, Pointer<Utf8>)
      >('FcObjectSetAdd');
  final listFonts = fontconfig
      .lookupFunction<
        Pointer<_FcFontSet> Function(
          Pointer<Void>,
          Pointer<Void>,
          Pointer<Void>,
        ),
        Pointer<_FcFontSet> Function(
          Pointer<Void>,
          Pointer<Void>,
          Pointer<Void>,
        )
      >('FcFontList');
  final getString = fontconfig
      .lookupFunction<
        Int32 Function(
          Pointer<Void>,
          Pointer<Utf8>,
          Int32,
          Pointer<Pointer<Utf8>>,
        ),
        int Function(Pointer<Void>, Pointer<Utf8>, int, Pointer<Pointer<Utf8>>)
      >('FcPatternGetString');
  final destroyFontSet = fontconfig
      .lookupFunction<
        Void Function(Pointer<_FcFontSet>),
        void Function(Pointer<_FcFontSet>)
      >('FcFontSetDestroy');
  final destroyObjectSet = fontconfig
      .lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('FcObjectSetDestroy');
  final destroyPattern = fontconfig
      .lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
      >('FcPatternDestroy');

  final family = 'family'.toNativeUtf8(allocator: arena);
  final pattern = createPattern();
  final objectSet = createObjectSet();
  try {
    addBool(pattern, 'scalable'.toNativeUtf8(allocator: arena), 1);
    addObject(objectSet, family);
    final fontSet = listFonts(nullptr, pattern, objectSet);
    if (fontSet == nullptr) {
      return const <String>[];
    }
    try {
      final value = arena<Pointer<Utf8>>();
      final fonts = fontSet.ref.fonts;
      return [
        for (var i = 0; i < fontSet.ref.nfont; i++)
          if (getString(fonts[i], family, 0, value) == 0)
            value.value.toDartString(),
      ];
    } finally {
      destroyFontSet(fontSet);
    }
  } finally {
    destroyObjectSet(objectSet);
    destroyPattern(pattern);
  }
});
