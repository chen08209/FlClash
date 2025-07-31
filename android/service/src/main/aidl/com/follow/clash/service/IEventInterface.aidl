// IEventInterface.aidl
package com.follow.clash.service;

interface IEventInterface {
    oneway void onEvent(in String id, in byte[] data,in boolean isSuccess);
}