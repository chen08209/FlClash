use crate::frb_generated::StreamSink;
use crate::ipc;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;

pub enum IpcEventKind {
    Connected,
    Message,
    Disconnected,
    Failed,
}

pub struct IpcEvent {
    pub kind: IpcEventKind,
    pub pid: Option<u32>,
    pub payload: Vec<u8>,
    pub error: Option<String>,
}

fn bridge(event: ipc::Event) -> IpcEvent {
    let (kind, pid, payload, error) = match event {
        ipc::Event::Connected { pid } => (IpcEventKind::Connected, pid, Vec::new(), None),
        ipc::Event::Message(payload) => (IpcEventKind::Message, None, payload, None),
        ipc::Event::Disconnected { error } => (IpcEventKind::Disconnected, None, Vec::new(), error),
        ipc::Event::Failed(error) => (IpcEventKind::Failed, None, Vec::new(), Some(error)),
    };
    IpcEvent {
        kind,
        pid,
        payload,
        error,
    }
}

#[frb(opaque)]
pub struct IpcServer {
    server: ipc::Server,
}

impl IpcServer {
    pub fn bind(address: String) -> Result<IpcServer, String> {
        let server = ipc::Server::bind(address).map_err(|error| error.to_string())?;
        Ok(Self { server })
    }

    pub fn events(&self, sink: StreamSink<IpcEvent, SseCodec>) {
        self.server
            .events(Box::new(move |event| sink.add(bridge(event)).is_ok()));
    }

    #[frb(sync)]
    pub fn send(&self, message: Vec<u8>) -> Result<(), String> {
        self.server
            .send(&message)
            .map_err(|error| error.to_string())
    }

    pub fn close(&self) {
        self.server.close();
    }
}
