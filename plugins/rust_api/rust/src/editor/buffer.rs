use crate::api::editor::SelectionState;
use ropey::Rope;
use std::sync::{RwLock, RwLockReadGuard};

pub struct Buffer {
    rope: RwLock<Rope>,
    selection: RwLock<SelectionState>,
}

impl Buffer {
    pub fn new(initial_text: &str) -> Self {
        Self {
            rope: RwLock::new(Rope::from_str(initial_text)),
            selection: RwLock::new(SelectionState {
                base_offset: 0,
                extent_offset: 0,
            }),
        }
    }

    pub fn rope(&self) -> RwLockReadGuard<'_, Rope> {
        self.rope.read().unwrap()
    }

    /// Shares the tree instead of copying it, so a long scan need not hold the lock.
    pub fn snapshot(&self) -> Rope {
        self.rope().clone()
    }

    pub fn selection(&self) -> SelectionState {
        *self.selection.read().unwrap()
    }

    pub fn set_selection(&self, base_offset: usize, extent_offset: usize) {
        let len = self.rope().len_chars();
        *self.selection.write().unwrap() = SelectionState {
            base_offset: base_offset.min(len),
            extent_offset: extent_offset.min(len),
        };
    }

    pub fn replace_range_and_update_selection(
        &self,
        start: usize,
        end: usize,
        replacement: &str,
    ) -> SelectionState {
        let mut rope_write = self.rope.write().unwrap();
        let len = rope_write.len_chars();
        let safe_start = start.min(len);
        let safe_end = end.clamp(safe_start, len);

        if safe_start < safe_end {
            rope_write.remove(safe_start..safe_end);
        }
        if !replacement.is_empty() {
            rope_write.insert(safe_start, replacement);
        }

        let caret = safe_start + replacement.chars().count();
        let new_selection = SelectionState {
            base_offset: caret,
            extent_offset: caret,
        };
        *self.selection.write().unwrap() = new_selection;
        new_selection
    }

    pub fn len_chars(&self) -> usize {
        self.rope().len_chars()
    }

    pub fn text(&self) -> String {
        self.rope().to_string()
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

    pub fn char_at(&self, position: usize) -> String {
        let rope = self.rope();
        if position >= rope.len_chars() {
            return String::new();
        }
        rope.char(position).to_string()
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

    #[test]
    fn edits_out_of_bounds_are_clamped() {
        let buffer = Buffer::new("abc");
        buffer.insert(10, "d");
        buffer.remove(2, 10);
        buffer.remove(3, 1);
        assert_eq!(buffer.text(), "ab");
    }
}
