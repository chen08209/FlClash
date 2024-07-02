import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

typedef CreateServiceNative = IntPtr Function(
  IntPtr hSCManager,
  Pointer<Utf16> lpServiceName,
  Pointer<Utf16> lpDisplayName,
  Uint32 dwDesiredAccess,
  Uint32 dwServiceType,
  Uint32 dwStartType,
  Uint32 dwErrorControl,
  Pointer<Utf16> lpBinaryPathName,
  Pointer<Utf16> lpLoadOrderGroup,
  Pointer<Uint32> lpdwTagId,
  Pointer<Utf16> lpDependencies,
  Pointer<Utf16> lpServiceStartName,
  Pointer<Utf16> lpPassword,
);

typedef CreateServiceDart = int Function(
  int hSCManager,
  Pointer<Utf16> lpServiceName,
  Pointer<Utf16> lpDisplayName,
  int dwDesiredAccess,
  int dwServiceType,
  int dwStartType,
  int dwErrorControl,
  Pointer<Utf16> lpBinaryPathName,
  Pointer<Utf16> lpLoadOrderGroup,
  Pointer<Uint32> lpdwTagId,
  Pointer<Utf16> lpDependencies,
  Pointer<Utf16> lpServiceStartName,
  Pointer<Utf16> lpPassword,
);

const _SERVICE_ALL_ACCESS = 0xF003F;

const _SERVICE_WIN32_OWN_PROCESS = 0x00000010;

const _SERVICE_AUTO_START = 0x00000002;

const _SERVICE_ERROR_NORMAL = 0x00000001;

typedef GetLastErrorNative = Uint32 Function();
typedef GetLastErrorDart = int Function();

class Service {
  static Service? _instance;
  late DynamicLibrary _advapi32;

  Service._internal() {
    _advapi32 = DynamicLibrary.open('advapi32.dll');
  }

  factory Service() {
    _instance ??= Service._internal();
    return _instance!;
  }

  Future<void> createService() async {
    final int scManager = OpenSCManager(nullptr, nullptr, _SERVICE_ALL_ACCESS);
    if (scManager == 0) return;
    final serviceName = 'FlClash Service'.toNativeUtf16();
    final displayName = 'FlClash Service'.toNativeUtf16();
    final binaryPathName = "C:\\Application\\Clash.Verge_1.6.6_x64_portable\\resources\\clash-verge-service.exe".toNativeUtf16();
    final createService =
        _advapi32.lookupFunction<CreateServiceNative, CreateServiceDart>(
      'CreateServiceW',
    );
    final getLastError = DynamicLibrary.open('kernel32.dll')
        .lookupFunction<GetLastErrorNative, GetLastErrorDart>('GetLastError');

    final serviceHandle = createService(
      scManager,
      serviceName,
      displayName,
      _SERVICE_ALL_ACCESS,
      _SERVICE_WIN32_OWN_PROCESS,
      _SERVICE_AUTO_START,
      _SERVICE_ERROR_NORMAL,
      binaryPathName,
      nullptr,
      nullptr,
      nullptr,
      nullptr,
      nullptr,
    );

    print("serviceHandle $serviceHandle");

    final errorCode = GetLastError();
    print('Error code: $errorCode');

    final result = StartService(serviceHandle, 0, nullptr);

    if (result == 0) {
      print('Failed to start the service.');
    } else {
      print('Service started successfully.');
    }

    calloc.free(serviceName);
    calloc.free(displayName);
    calloc.free(binaryPathName);
  }
}

final service = Platform.isWindows ? Service() : null;
