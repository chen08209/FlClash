use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct NetworkState {
    pub wifi: bool,
    pub vpn: bool,
}

pub fn network_changes(sink: StreamSink<NetworkState, SseCodec>) {
    crate::network::listen(sink)
}
