use std::collections::VecDeque;
use std::io;
use std::sync::{Mutex, MutexGuard, PoisonError};
use tokio::sync::Notify;

// Frames are control messages of a few KB, so this only fills up when the peer
// has stopped reading.
const MAX_PENDING_BYTES: usize = 16 * 1024 * 1024;

#[derive(Default)]
struct Queue {
    frames: VecDeque<Vec<u8>>,
    bytes: usize,
    open: bool,
}

/// Frames waiting for the connection's writer. `push` never blocks, so it can
/// be called from the Dart thread.
#[derive(Default)]
pub struct Outbox {
    queue: Mutex<Queue>,
    ready: Notify,
}

impl Outbox {
    pub fn open(&self) {
        *self.queue() = Queue {
            open: true,
            ..Queue::default()
        };
    }

    pub fn close(&self) {
        *self.queue() = Queue::default();
    }

    pub fn push(&self, frame: Vec<u8>) -> io::Result<()> {
        let mut queue = self.queue();
        if !queue.open {
            return Err(io::Error::new(
                io::ErrorKind::NotConnected,
                "IPC peer is not connected",
            ));
        }
        // An empty queue takes a frame of any size: refusing one that is larger
        // than the whole budget would refuse it forever.
        if queue.bytes > 0 && queue.bytes + frame.len() > MAX_PENDING_BYTES {
            return Err(io::Error::new(
                io::ErrorKind::WouldBlock,
                "IPC send queue is full",
            ));
        }
        queue.bytes += frame.len();
        queue.frames.push_back(frame);
        drop(queue);
        self.ready.notify_one();
        Ok(())
    }

    pub async fn next(&self) -> Vec<u8> {
        loop {
            if let Some(frame) = self.pop() {
                return frame;
            }
            self.ready.notified().await;
        }
    }

    fn pop(&self) -> Option<Vec<u8>> {
        let mut queue = self.queue();
        let frame = queue.frames.pop_front()?;
        queue.bytes -= frame.len();
        Some(frame)
    }

    fn queue(&self) -> MutexGuard<'_, Queue> {
        self.queue.lock().unwrap_or_else(PoisonError::into_inner)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::Arc;
    use std::time::Duration;

    fn open_outbox() -> Outbox {
        let outbox = Outbox::default();
        outbox.open();
        outbox
    }

    #[test]
    fn frames_leave_in_the_order_they_were_pushed() {
        let outbox = open_outbox();
        outbox.push(b"first".to_vec()).unwrap();
        outbox.push(b"second".to_vec()).unwrap();

        assert_eq!(outbox.pop().unwrap(), b"first");
        assert_eq!(outbox.pop().unwrap(), b"second");
        assert!(outbox.pop().is_none());
    }

    #[test]
    fn a_push_without_a_peer_is_refused() {
        let outbox = Outbox::default();

        assert_eq!(
            outbox.push(b"frame".to_vec()).unwrap_err().kind(),
            io::ErrorKind::NotConnected,
        );
    }

    #[test]
    fn closing_drops_what_the_last_peer_never_read() {
        let outbox = open_outbox();
        outbox.push(b"stale".to_vec()).unwrap();

        outbox.close();
        outbox.open();

        assert!(outbox.pop().is_none());
    }

    #[test]
    fn the_byte_budget_refuses_a_frame_that_does_not_fit() {
        let outbox = open_outbox();
        outbox.push(vec![0; MAX_PENDING_BYTES]).unwrap();

        assert_eq!(
            outbox.push(b"overflow".to_vec()).unwrap_err().kind(),
            io::ErrorKind::WouldBlock,
        );

        outbox.pop().unwrap();
        outbox.push(b"fits again".to_vec()).unwrap();
    }

    #[test]
    fn a_lone_frame_larger_than_the_budget_is_accepted() {
        let outbox = open_outbox();

        outbox.push(vec![0; MAX_PENDING_BYTES + 1]).unwrap();

        assert_eq!(outbox.pop().unwrap().len(), MAX_PENDING_BYTES + 1);
    }

    #[test]
    fn next_wakes_for_a_frame_pushed_from_another_thread() {
        let outbox = Arc::new(open_outbox());
        let producer = Arc::clone(&outbox);
        let pushed = std::thread::spawn(move || {
            std::thread::sleep(Duration::from_millis(20));
            producer.push(b"late".to_vec()).unwrap();
        });

        let frame = tokio::runtime::Builder::new_current_thread()
            .build()
            .unwrap()
            .block_on(outbox.next());

        pushed.join().unwrap();
        assert_eq!(frame, b"late");
    }
}
