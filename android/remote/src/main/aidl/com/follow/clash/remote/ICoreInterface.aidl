// ICoreInterface.aidl
package com.follow.clash.remote;
import com.follow.clash.remote.ICallbackInterface;

interface ICoreInterface {
    void invokeAction(in String data, in ICallbackInterface callback);
}