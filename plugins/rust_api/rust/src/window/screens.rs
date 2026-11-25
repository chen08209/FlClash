use futures_util::{Stream, StreamExt};

/// A dropped bus ends a signal, and the app must not stay out of sight until it restarts.
pub(super) async fn follow(readings: impl Stream<Item = bool>, mut set: impl FnMut(bool)) {
    let mut readings = std::pin::pin!(readings);
    while let Some(unseen) = readings.next().await {
        set(unseen);
    }
    set(false);
}

#[cfg(test)]
mod tests {
    use super::follow;
    use futures_util::stream;

    fn set_by(readings: &[bool]) -> Vec<bool> {
        let mut set = Vec::new();
        tokio::runtime::Builder::new_current_thread()
            .build()
            .unwrap()
            .block_on(follow(stream::iter(readings.to_vec()), |unseen| {
                set.push(unseen)
            }));
        set
    }

    #[test]
    fn a_signal_that_ends_while_the_screens_are_locked_counts_them_seen_again() {
        assert_eq!(set_by(&[false, true]), [false, true, false]);
    }

    #[test]
    fn a_signal_that_ends_before_any_reading_leaves_the_screens_seen() {
        assert_eq!(set_by(&[]), [false]);
    }
}
