use ropey::Rope;
use std::io::ErrorKind;
use std::sync::{RwLock, RwLockReadGuard};

pub struct Buffer {
    rope: RwLock<Rope>,
}

pub enum OpenError {
    NotFound(String),
    NotUtf8(String),
    Unreadable(String),
}

impl Buffer {
    pub fn new(initial_text: &str) -> Self {
        Self::from_rope(Rope::from_str(initial_text))
    }

    fn from_rope(rope: Rope) -> Self {
        Self {
            rope: RwLock::new(rope),
        }
    }

    pub fn open_file(path: &str) -> Result<Self, OpenError> {
        let bytes = std::fs::read(path).map_err(|error| match error.kind() {
            ErrorKind::NotFound => OpenError::NotFound(error.to_string()),
            _ => OpenError::Unreadable(error.to_string()),
        })?;
        Self::from_utf8(bytes)
    }

    /// Lines break at LF alone, so a CRLF pair comes in as LF.
    pub fn from_utf8(bytes: Vec<u8>) -> Result<Self, OpenError> {
        let text =
            String::from_utf8(bytes).map_err(|error| OpenError::NotUtf8(error.to_string()))?;
        let text = if text.contains('\r') {
            text.replace("\r\n", "\n")
        } else {
            text
        };
        Ok(Self::new(&text))
    }

    pub fn copy(&self) -> Self {
        Self::from_rope(self.snapshot())
    }

    pub fn rope(&self) -> RwLockReadGuard<'_, Rope> {
        self.rope.read().unwrap()
    }

    /// Shares the tree instead of copying it, so a long scan need not hold the lock.
    pub fn snapshot(&self) -> Rope {
        self.rope().clone()
    }

    pub fn len_chars(&self) -> usize {
        self.rope().len_chars()
    }

    pub fn text(&self) -> String {
        self.rope().to_string()
    }

    pub fn utf8_bytes(&self) -> Vec<u8> {
        let rope = self.snapshot();
        let mut bytes = Vec::with_capacity(rope.len_bytes());
        for chunk in rope.chunks() {
            bytes.extend_from_slice(chunk.as_bytes());
        }
        bytes
    }

    /// Whether this text, with `splice_len` chars from `splice_start` given
    /// way to `splice_text`, is the text of `original`.
    pub fn same_text(
        &self,
        original: &Buffer,
        splice_start: usize,
        splice_len: usize,
        splice_text: &str,
    ) -> bool {
        let rope = self.snapshot();
        let original = original.snapshot();
        let len = rope.len_chars();
        let start = splice_start.min(len);
        let removed_end = (start + splice_len).min(len);
        let inserted_end = start + splice_text.chars().count();
        if len - (removed_end - start) + (inserted_end - start) != original.len_chars() {
            return false;
        }
        rope.slice(..start) == original.slice(..start)
            && original.slice(start..inserted_end) == splice_text
            && rope.slice(removed_end..) == original.slice(inserted_end..)
    }

    pub fn insert(&self, char_idx: usize, text: &str) {
        let mut rope = self.rope.write().unwrap();
        let idx = char_idx.min(rope.len_chars());
        rope.insert(idx, text);
    }

    pub fn remove(&self, start: usize, end: usize) {
        let mut rope = self.rope.write().unwrap();
        let len = rope.len_chars();
        let start = start.min(len);
        rope.remove(start..end.clamp(start, len));
    }

    pub fn slice(&self, start: usize, end: usize) -> String {
        let rope = self.rope();
        let valid_start = start.min(rope.len_chars());
        let valid_end = end.max(valid_start).min(rope.len_chars());
        rope.slice(valid_start..valid_end).to_string()
    }

    pub fn char_to_line(&self, char_idx: usize) -> usize {
        let rope = self.rope();
        rope.char_to_line(char_idx.min(rope.len_chars()))
    }

    pub fn line_to_char(&self, line_idx: usize) -> usize {
        let rope = self.rope();
        rope.line_to_char(line_idx.min(rope.len_lines().saturating_sub(1)))
    }

    pub fn line(&self, line_idx: usize) -> String {
        let rope = self.rope();
        let valid_idx = line_idx.min(rope.len_lines().saturating_sub(1));
        line_without_break(&rope, valid_idx)
    }

    pub fn len_lines(&self) -> usize {
        self.rope().len_lines()
    }

    pub fn lines(&self, start_line: usize, end_line: usize) -> Vec<String> {
        let rope = self.rope();
        let total = rope.len_lines();
        let start = start_line.min(total);
        let end = end_line.min(total).max(start);
        (start..end)
            .map(|line_idx| line_without_break(&rope, line_idx))
            .collect()
    }
}

pub(super) fn line_without_break(rope: &Rope, line_idx: usize) -> String {
    let mut line = rope.line(line_idx).to_string();
    if line.ends_with("\r\n") {
        line.truncate(line.len() - 2);
    } else if line.ends_with('\n') {
        line.truncate(line.len() - 1);
    }
    line
}

#[cfg(test)]
mod tests {
    use super::*;

    fn open(bytes: &[u8]) -> String {
        match Buffer::from_utf8(bytes.to_vec()) {
            Ok(buffer) => buffer.text(),
            Err(_) => panic!("not opened"),
        }
    }

    #[test]
    fn opening_turns_crlf_into_lf_and_keeps_a_lone_cr() {
        assert_eq!(open(b"a: 1\r\nb: 2\r\n"), "a: 1\nb: 2\n");
        assert_eq!(open(b"a\rb"), "a\rb");
    }

    #[test]
    fn opening_refuses_text_that_is_not_utf8() {
        assert!(matches!(
            Buffer::from_utf8(vec![b'a', 0xff]),
            Err(OpenError::NotUtf8(_))
        ));
    }

    #[test]
    fn opening_a_missing_file_says_so() {
        let path = std::env::temp_dir().join("rust_api_missing_editor_file.yaml");
        assert!(matches!(
            Buffer::open_file(path.to_str().unwrap()),
            Err(OpenError::NotFound(_))
        ));
    }

    #[test]
    fn a_copy_keeps_its_text_when_the_buffer_changes() {
        let buffer = Buffer::new("a: 1");
        let copy = buffer.copy();
        buffer.insert(4, "0");
        assert_eq!(copy.text(), "a: 1");
        assert_eq!(buffer.text(), "a: 10");
    }

    #[test]
    fn utf8_bytes_hold_the_whole_text() {
        let text = "名: 値\n".repeat(5000);
        assert_eq!(Buffer::new(&text).utf8_bytes(), text.as_bytes());
    }

    #[test]
    fn same_text_compares_with_a_splice_applied() {
        let original = Buffer::new("a: 1\nb: 2\n");
        let buffer = original.copy();
        assert!(buffer.same_text(&original, 0, 0, ""));
        buffer.insert(3, "x");
        assert!(!buffer.same_text(&original, 0, 0, ""));
        assert!(buffer.same_text(&original, 3, 1, ""));
        assert!(buffer.same_text(&original, 0, 5, "a: 1"));
        assert!(!buffer.same_text(&original, 0, 5, "a: 2"));
        assert!(!buffer.same_text(&original, 0, 5, "a: 10"));
    }

    #[test]
    fn edits_out_of_bounds_are_clamped() {
        let buffer = Buffer::new("abc");
        buffer.insert(10, "d");
        buffer.remove(2, 10);
        buffer.remove(3, 1);
        assert_eq!(buffer.text(), "ab");
    }
}
