// IRemoteInterface.aidl
package com.follow.clash.service;

import com.follow.clash.service.ICallbackInterface;
import com.follow.clash.service.IEventInterface;
import com.follow.clash.service.IResultInterface;
import com.follow.clash.service.models.VpnOptions;
import com.follow.clash.service.models.NotificationParams;

interface IRemoteInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
    void updateNotificationParams(in NotificationParams params);
    void startService(in VpnOptions options, in long runTime, in IResultInterface result);
    void stopService(in IResultInterface result);
    void setEventListener(in IEventInterface event);
    void setCrashlytics(in boolean enable);
    long getRunTime();
}