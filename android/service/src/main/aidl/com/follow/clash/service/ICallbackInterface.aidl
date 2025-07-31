// ICallbackInterface.aidl
package com.follow.clash.service;

interface ICallbackInterface {
    void onResult(in byte[] result, boolean isSuccess);
}