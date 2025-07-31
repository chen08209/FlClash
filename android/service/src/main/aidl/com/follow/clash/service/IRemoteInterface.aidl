// IRemoteInterface.aidl
package com.follow.clash.service;

import com.follow.clash.service.ICallbackInterface;
import com.follow.clash.service.IEventInterface;
import com.follow.clash.service.IResultInterface;
import com.follow.clash.service.models.VpnOptions;
import com.follow.clash.service.models.NotificationParams;

interface IRemoteInterface {
    oneway void invokeAction(in String data, in ICallbackInterface callback);
    oneway void updateNotificationParams(in NotificationParams params);
    oneway void startService(in VpnOptions options, in IResultInterface result);
    oneway void stopService(in IResultInterface result);
    oneway void setEventListener(in IEventInterface event);
    oneway void setCrashlytics(in boolean enable);
}