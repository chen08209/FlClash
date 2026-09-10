use std::io::{self, Read, Write};
use std::thread;
use std::time::Duration;

pub const TYPE_READY: u8 = 0x00;
pub const TYPE_CONNECTED: u8 = 0x01;
pub const TYPE_DISCONNECTED: u8 = 0x02;
pub const TYPE_DATA: u8 = 0x03;
pub const TYPE_ERROR: u8 = 0x04;

pub const MAX_FRAME_SIZE: usize = 64 * 1024 * 1024;
pub const IO_POLL_INTERVAL: Duration = Duration::from_millis(20);
const MIN_WRITE_BACKOFF: Duration = Duration::from_millis(1);

pub fn make_frame(ty: u8, payload: &[u8]) -> Vec<u8> {
    let mut frame = Vec::with_capacity(1 + payload.len());
    frame.push(ty);
    frame.extend_from_slice(payload);
    frame
}

pub fn validate_frame_len(len: usize) -> io::Result<u32> {
    if len > MAX_FRAME_SIZE {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            format!("IPC frame exceeds {MAX_FRAME_SIZE} bytes"),
        ));
    }
    u32::try_from(len)
        .map_err(|_| io::Error::new(io::ErrorKind::InvalidData, "IPC frame is too large"))
}

pub fn is_expected_disconnect_error(error: &io::Error) -> bool {
    matches!(
        error.kind(),
        io::ErrorKind::UnexpectedEof | io::ErrorKind::ConnectionReset | io::ErrorKind::BrokenPipe
    )
}

#[cfg(any(windows, test))]
fn normalize_windows_pipe_write(result: io::Result<usize>) -> io::Result<usize> {
    match result {
        Ok(0) => Err(io::ErrorKind::WouldBlock.into()),
        result => result,
    }
}

fn write_all_interruptible(
    writer: &mut impl Write,
    mut data: &[u8],
    is_running: &impl Fn() -> bool,
) -> io::Result<()> {
    let mut backoff = MIN_WRITE_BACKOFF;
    while !data.is_empty() {
        if !is_running() {
            return Err(io::Error::new(
                io::ErrorKind::Interrupted,
                "IPC connection stopped",
            ));
        }
        let result = writer.write(data);
        #[cfg(windows)]
        let result = normalize_windows_pipe_write(result);
        match result {
            Ok(0) => return Err(io::ErrorKind::WriteZero.into()),
            Ok(written) => {
                data = &data[written..];
                backoff = MIN_WRITE_BACKOFF;
            }
            Err(e) if e.kind() == io::ErrorKind::Interrupted => continue,
            Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
                // A Windows PIPE_NOWAIT handle reports a full buffer through a
                // zero-byte write, and every frame costs two writes. A flat
                // 20ms wait there parks the whole queue behind one frame, so
                // back off from 1ms instead.
                thread::sleep(backoff);
                backoff = (backoff * 2).min(IO_POLL_INTERVAL);
            }
            Err(e) => return Err(e),
        }
    }
    Ok(())
}

pub fn write_frame(
    writer: &mut impl Write,
    data: &[u8],
    is_running: &impl Fn() -> bool,
) -> io::Result<()> {
    let len = validate_frame_len(data.len())?;
    write_all_interruptible(writer, &len.to_le_bytes(), is_running)?;
    write_all_interruptible(writer, data, is_running)
}

#[derive(Default)]
pub struct FrameReader {
    header: [u8; 4],
    header_read: usize,
    payload: Vec<u8>,
    payload_read: usize,
}

impl FrameReader {
    pub fn poll(&mut self, reader: &mut impl Read) -> io::Result<Option<Vec<u8>>> {
        loop {
            if self.header_read < self.header.len() {
                match reader.read(&mut self.header[self.header_read..]) {
                    Ok(0) => return Err(io::ErrorKind::UnexpectedEof.into()),
                    Ok(read) => self.header_read += read,
                    Err(e) if e.kind() == io::ErrorKind::Interrupted => continue,
                    Err(e) if e.kind() == io::ErrorKind::WouldBlock => return Ok(None),
                    Err(e) => return Err(e),
                }
                if self.header_read < self.header.len() {
                    continue;
                }

                let len = u32::from_le_bytes(self.header) as usize;
                validate_frame_len(len)?;
                if len == 0 {
                    self.reset();
                    return Ok(Some(Vec::new()));
                }
                self.payload = vec![0; len];
            }

            match reader.read(&mut self.payload[self.payload_read..]) {
                Ok(0) => return Err(io::ErrorKind::UnexpectedEof.into()),
                Ok(read) => self.payload_read += read,
                Err(e) if e.kind() == io::ErrorKind::Interrupted => continue,
                Err(e) if e.kind() == io::ErrorKind::WouldBlock => return Ok(None),
                Err(e) => return Err(e),
            }
            if self.payload_read == self.payload.len() {
                let payload = std::mem::take(&mut self.payload);
                self.reset();
                return Ok(Some(payload));
            }
        }
    }

    fn reset(&mut self) {
        self.header = [0; 4];
        self.header_read = 0;
        self.payload.clear();
        self.payload_read = 0;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::collections::VecDeque;
    use std::io::Cursor;

    enum ReadStep {
        Data(Vec<u8>),
        WouldBlock,
    }

    struct StepReader {
        steps: VecDeque<ReadStep>,
    }

    impl Read for StepReader {
        fn read(&mut self, buffer: &mut [u8]) -> io::Result<usize> {
            match self.steps.pop_front() {
                Some(ReadStep::Data(mut data)) => {
                    let read = data.len().min(buffer.len());
                    buffer[..read].copy_from_slice(&data[..read]);
                    if read < data.len() {
                        data.drain(..read);
                        self.steps.push_front(ReadStep::Data(data));
                    }
                    Ok(read)
                }
                Some(ReadStep::WouldBlock) => Err(io::ErrorKind::WouldBlock.into()),
                None => Ok(0),
            }
        }
    }

    #[test]
    fn frame_reader_reads_complete_frame() {
        let payload = b"hello";
        let mut bytes = (payload.len() as u32).to_le_bytes().to_vec();
        bytes.extend_from_slice(payload);
        let mut reader = Cursor::new(bytes);
        let mut frame_reader = FrameReader::default();

        assert_eq!(
            frame_reader.poll(&mut reader).unwrap(),
            Some(payload.to_vec())
        );
    }

    #[test]
    fn frame_reader_preserves_partial_nonblocking_reads() {
        let mut reader = StepReader {
            steps: VecDeque::from([
                ReadStep::Data(vec![5, 0]),
                ReadStep::WouldBlock,
                ReadStep::Data(vec![0, 0]),
                ReadStep::Data(b"he".to_vec()),
                ReadStep::WouldBlock,
                ReadStep::Data(b"llo".to_vec()),
            ]),
        };
        let mut frame_reader = FrameReader::default();

        assert_eq!(frame_reader.poll(&mut reader).unwrap(), None);
        assert_eq!(frame_reader.poll(&mut reader).unwrap(), None);
        assert_eq!(
            frame_reader.poll(&mut reader).unwrap(),
            Some(b"hello".to_vec())
        );
    }

    #[test]
    fn frame_reader_rejects_oversized_frame_before_allocation() {
        let len = (MAX_FRAME_SIZE as u32 + 1).to_le_bytes();
        let mut reader = Cursor::new(len);
        let mut frame_reader = FrameReader::default();

        assert_eq!(
            frame_reader.poll(&mut reader).unwrap_err().kind(),
            io::ErrorKind::InvalidData
        );
        assert!(frame_reader.payload.is_empty());
    }

    #[test]
    fn windows_zero_write_is_treated_as_pending() {
        assert_eq!(
            normalize_windows_pipe_write(Ok(0)).unwrap_err().kind(),
            io::ErrorKind::WouldBlock,
        );
        assert_eq!(normalize_windows_pipe_write(Ok(2)).unwrap(), 2);

        let error = io::Error::from(io::ErrorKind::BrokenPipe);
        assert_eq!(
            normalize_windows_pipe_write(Err(error)).unwrap_err().kind(),
            io::ErrorKind::BrokenPipe,
        );
    }

    #[test]
    fn write_backoff_starts_short_and_is_capped() {
        let mut backoff = MIN_WRITE_BACKOFF;
        assert_eq!(backoff, Duration::from_millis(1));
        for _ in 0..10 {
            backoff = (backoff * 2).min(IO_POLL_INTERVAL);
        }
        assert_eq!(backoff, IO_POLL_INTERVAL);
    }

    #[test]
    fn write_frame_stops_when_the_connection_is_gone() {
        let mut sink = Vec::new();

        assert_eq!(
            write_frame(&mut sink, b"payload", &|| false)
                .unwrap_err()
                .kind(),
            io::ErrorKind::Interrupted,
        );
        assert!(sink.is_empty());
    }

    #[test]
    fn expected_disconnect_errors_are_not_reported() {
        for kind in [
            io::ErrorKind::UnexpectedEof,
            io::ErrorKind::ConnectionReset,
            io::ErrorKind::BrokenPipe,
        ] {
            assert!(is_expected_disconnect_error(&io::Error::from(kind)));
        }
        assert!(!is_expected_disconnect_error(&io::Error::from(
            io::ErrorKind::InvalidData,
        )));
    }
}
