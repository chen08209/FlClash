// IRemoteInterface.aidl
package com.follow.clash.service;

import com.follow.clash.service.ICallbackInterface;
import com.follow.clash.service.models.VpnOptions;
import com.follow.clash.service.models.NotificationParams;

interface IRemoteInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
    void syncVpnOptions(in VpnOptions options);
    void updateNotificationParams(in NotificationParams params);
}