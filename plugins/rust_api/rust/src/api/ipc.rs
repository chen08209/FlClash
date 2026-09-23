use crate::frb_generated::StreamSink;
use crate::ipc;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;

#[frb]
pub fn restart_ipc_server(name: String, sink: StreamSink<Vec<u8>, SseCodec>) -> Result<(), String> {
    ipc::restart_server(name, sink)
}

#[frb]
pub fn stop_ipc_server() -> Result<(), String> {
    ipc::stop_server()
}

#[frb]
pub fn send_ipc_message(data: Vec<u8>) -> Result<(), String> {
    ipc::send_message(data)
}
