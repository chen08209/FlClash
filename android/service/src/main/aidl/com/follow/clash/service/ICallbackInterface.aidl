// ICallbackInterface.aidl
package com.follow.clash.service;

interface ICallbackInterface {
    oneway void onResult(in byte[] data,in boolean isSuccess);
}