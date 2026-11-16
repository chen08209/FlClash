use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;

#[frb]
pub fn link_stream(sink: StreamSink<String, SseCodec>) {
    crate::window::listen_links(sink);
}
