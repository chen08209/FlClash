// ICallbackInterface.aidl
package com.follow.clash.service;

import com.follow.clash.service.IAckInterface;

interface ICallbackInterface {
    oneway void onResult(in byte[] data,in boolean isSuccess, in IAckInterface ack);
}