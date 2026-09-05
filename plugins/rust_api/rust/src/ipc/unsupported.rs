use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;

// Android loads the Core in-process; these entry points exist only so that one
// set of bindings serves every platform.
const UNSUPPORTED: &str = "IPC server is not available on this platform";

pub fn restart_server(_name: String, _sink: StreamSink<Vec<u8>, SseCodec>) -> Result<(), String> {
    Err(UNSUPPORTED.into())
}

pub fn stop_server() -> Result<(), String> {
    Ok(())
}

pub fn send_message(_data: Vec<u8>) -> Result<(), String> {
    Err(UNSUPPORTED.into())
}
