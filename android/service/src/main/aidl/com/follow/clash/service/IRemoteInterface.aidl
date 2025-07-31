// IRemoteInterface.aidl
package com.follow.clash.service;

import com.follow.clash.service.ICallbackInterface;
import com.follow.clash.service.IMessageInterface;
import com.follow.clash.service.models.VpnOptions;
import com.follow.clash.service.models.NotificationParams;

interface IRemoteInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
    void updateNotificationParams(in NotificationParams params);
    void startService(in VpnOptions options,in boolean inApp);
    void stopService();
    void setMessageCallback(in IMessageInterface messageCallback);
}