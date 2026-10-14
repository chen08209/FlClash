use std::io;
use tokio::io::{AsyncRead, AsyncReadExt};

pub const MAX_FRAME_SIZE: usize = 64 * 1024 * 1024;
const HEADER_SIZE: usize = 4;

fn too_large() -> io::Error {
    io::Error::new(
        io::ErrorKind::InvalidData,
        format!("IPC frame exceeds {MAX_FRAME_SIZE} bytes"),
    )
}

/// Prefixes `payload` with its little-endian length, the layout `readFrame`
/// in `core/server.go` expects.
pub fn encode(payload: &[u8]) -> io::Result<Vec<u8>> {
    if payload.len() > MAX_FRAME_SIZE {
        return Err(too_large());
    }
    let mut frame = Vec::with_capacity(HEADER_SIZE + payload.len());
    frame.extend_from_slice(&(payload.len() as u32).to_le_bytes());
    frame.extend_from_slice(payload);
    Ok(frame)
}

pub async fn read(reader: &mut (impl AsyncRead + Unpin)) -> io::Result<Vec<u8>> {
    let mut header = [0; HEADER_SIZE];
    reader.read_exact(&mut header).await?;
    let len = u32::from_le_bytes(header) as usize;
    if len > MAX_FRAME_SIZE {
        return Err(too_large());
    }
    let mut payload = vec![0; len];
    reader.read_exact(&mut payload).await?;
    Ok(payload)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn read_all(bytes: &[u8]) -> io::Result<Vec<u8>> {
        let mut reader = bytes;
        tokio::runtime::Builder::new_current_thread()
            .build()
            .unwrap()
            .block_on(read(&mut reader))
    }

    #[test]
    fn a_frame_survives_an_encode_and_read_round_trip() {
        let frame = encode(b"hello").unwrap();

        assert_eq!(&frame[..HEADER_SIZE], [5, 0, 0, 0]);
        assert_eq!(read_all(&frame).unwrap(), b"hello");
    }

    #[test]
    fn an_empty_frame_is_a_frame() {
        assert_eq!(read_all(&encode(b"").unwrap()).unwrap(), b"");
    }

    #[test]
    fn a_truncated_frame_reads_as_end_of_stream() {
        let frame = encode(b"hello").unwrap();

        for len in [0, 2, HEADER_SIZE, frame.len() - 1] {
            assert_eq!(
                read_all(&frame[..len]).unwrap_err().kind(),
                io::ErrorKind::UnexpectedEof,
            );
        }
    }

    #[test]
    fn an_oversized_header_is_rejected_before_its_payload_is_read() {
        let header = (MAX_FRAME_SIZE as u32 + 1).to_le_bytes();

        assert_eq!(
            read_all(&header).unwrap_err().kind(),
            io::ErrorKind::InvalidData,
        );
    }

    #[test]
    fn an_oversized_payload_is_not_encoded() {
        let payload = vec![0; MAX_FRAME_SIZE + 1];

        assert_eq!(
            encode(&payload).unwrap_err().kind(),
            io::ErrorKind::InvalidData,
        );
    }
}
