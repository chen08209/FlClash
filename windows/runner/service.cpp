#include <windows.h>
#include <tchar.h>
#include <string>

#define SERVICE_NAME _T("MyService")

SERVICE_STATUS        g_ServiceStatus = {0};
SERVICE_STATUS_HANDLE g_StatusHandle = NULL;
HANDLE                g_ServiceStopEvent = INVALID_HANDLE_VALUE;

VOID WINAPI ServiceMain(DWORD argc, LPTSTR *argv);
VOID WINAPI ServiceCtrlHandler(DWORD);
DWORD WINAPI ServiceWorkerThread(LPVOID lpParam);

int _tmain(int argc, TCHAR *argv[])
{
    SERVICE_TABLE_ENTRY ServiceTable[] =
    {
        {SERVICE_NAME, (LPSERVICE_MAIN_FUNCTION) ServiceMain},
        {NULL, NULL}
    };

    if (StartServiceCtrlDispatcher(ServiceTable) == FALSE)
    {
        return GetLastError();
    }

    return 0;
}

VOID WINAPI ServiceMain(DWORD argc, LPTSTR *argv)
{
    DWORD Status = E_FAIL;

    g_StatusHandle = RegisterServiceCtrlHandler(SERVICE_NAME, ServiceCtrlHandler);

    if (g_StatusHandle == NULL)
    {
        goto EXIT;
    }

    ZeroMemory(&g_ServiceStatus, sizeof(g_ServiceStatus));
    g_ServiceStatus.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    g_ServiceStatus.dwControlsAccepted = SERVICE_ACCEPT_STOP;
    g_ServiceStatus.dwCurrentState = SERVICE_START_PENDING;
    g_ServiceStatus.dwWin32ExitCode = 0;
    g_ServiceStatus.dwServiceSpecificExitCode = 0;
    g_ServiceStatus.dwCheckPoint = 0;

    if (SetServiceStatus(g_StatusHandle, &g_ServiceStatus) == FALSE)
    {
        OutputDebugString(_T("My Service: ServiceMain: SetServiceStatus returned error"));
    }

    g_ServiceStopEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
    if (g_ServiceStopEvent == NULL)
    {
        g_ServiceStatus.dwControlsAccepted = 0;
        g_ServiceStatus.dwCurrentState = SERVICE_STOPPED;
        g_ServiceStatus.dwWin32ExitCode = GetLastError();
        g_ServiceStatus.dwCheckPoint = 1;

        if (SetServiceStatus(g_StatusHandle, &g_ServiceStatus) == FALSE)
        {
            OutputDebugString(_T("My Service: ServiceMain: SetServiceStatus returned error"));
        }
        goto EXIT;
    }

    g_ServiceStatus.dwCurrentState = SERVICE_RUNNING;
    g_ServiceStatus.dwCheckPoint = 0;
    g_ServiceStatus.dwWaitHint = 0;

    if (SetServiceStatus(g_StatusHandle, &g_ServiceStatus) == FALSE)
    {
        OutputDebugString(_T("My Service: ServiceMain: SetServiceStatus returned error"));
    }

    HANDLE hThread = CreateThread(NULL, 0, ServiceWorkerThread, NULL, 0, NULL);

    WaitForSingleObject(hThread, INFINITE);

    CloseHandle(g_ServiceStopEvent);

    g_ServiceStatus.dwCurrentState = SERVICE_STOPPED;
    g_ServiceStatus.dwCheckPoint = 3;

    if (SetServiceStatus(g_StatusHandle, &g_ServiceStatus) == FALSE)
    {
        OutputDebugString(_T("My Service: ServiceMain: SetServiceStatus returned error"));
    }

EXIT:
    return;
}

VOID WINAPI ServiceCtrlHandler(DWORD CtrlCode)
{
    switch(CtrlCode)
    {
        case SERVICE_CONTROL_STOP:
            if (g_ServiceStatus.dwCurrentState != SERVICE_RUNNING)
                break;

            g_ServiceStatus.dwControlsAccepted = 0;
            g_ServiceStatus.dwCurrentState = SERVICE_STOP_PENDING;
            g_ServiceStatus.dwWin32ExitCode = 0;
            g_ServiceStatus.dwCheckPoint = 4;

            if (SetServiceStatus(g_StatusHandle, &g_ServiceStatus) == FALSE)
            {
                OutputDebugString(_T("My Service: ServiceCtrlHandler: SetServiceStatus returned error"));
            }

            SetEvent(g_ServiceStopEvent);
            break;

        default:
            break;
    }
}

DWORD WINAPI ServiceWorkerThread(LPVOID lpParam)
{
    while(WaitForSingleObject(g_ServiceStopEvent, 0) != WAIT_OBJECT_0)
    {
        STARTUPINFO si;
        PROCESS_INFORMATION pi;

        ZeroMemory(&si, sizeof(si));
        si.cb = sizeof(si);
        ZeroMemory(&pi, sizeof(pi));

        // 启动 "C:\path\to\your\executable.exe"
        if(!CreateProcess(NULL, _T("C:\\path\\to\\your\\executable.exe"), NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi))
        {
            OutputDebugString(_T("CreateProcess failed"));
        }

        // 等待进程结束
        WaitForSingleObject(pi.hProcess, INFINITE);

        // 关闭进程和线程句柄
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);

        // 每隔一段时间检查一次，这里设置为60秒
        Sleep(60000);
    }

    return ERROR_SUCCESS;
}