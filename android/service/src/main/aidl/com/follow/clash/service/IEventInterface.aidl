// IEventInterface.aidl
package com.follow.clash.service;

import com.follow.clash.service.IAckInterface;

interface IEventInterface {
    oneway void onEvent(in String id, in byte[] data,in boolean isSuccess, in IAckInterface ack);
}