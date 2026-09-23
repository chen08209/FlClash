#ifndef FLUTTER_PLUGIN_WINDOW_RUNNING_INSTANCE_H_
#define FLUTTER_PLUGIN_WINDOW_RUNNING_INSTANCE_H_

#include <windows.h>

namespace window {

UINT GetActivateMessage();

// Lets a lower-integrity relaunch post GetActivateMessage() to an elevated
// |root|; UIPI drops it otherwise.
void AllowActivateMessageThroughUipi(HWND root);

HWND FindRunningWindow();
void ActivateWindow(HWND window);

}  // namespace window

#endif  // FLUTTER_PLUGIN_WINDOW_RUNNING_INSTANCE_H_
