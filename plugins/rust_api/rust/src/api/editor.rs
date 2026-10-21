use crate::editor::{self, Buffer, OpenError};
use flutter_rust_bridge::frb;

#[derive(Clone, Debug)]
pub struct RustFoldRange {
    pub start_line: i32,
    pub end_line: i32,
}

#[derive(Clone, Debug)]
pub struct GuideBlock {
    pub start_line: i32,
    pub end_line: i32,
    pub indent_level: i32,
    pub leading_spaces: i32,
}

#[derive(Debug)]
pub enum EditorOpenErrorKind {
    NotFound,
    NotUtf8,
    Unreadable,
}

#[derive(Debug)]
pub struct EditorOpenError {
    pub kind: EditorOpenErrorKind,
    pub message: String,
}

impl From<OpenError> for EditorOpenError {
    fn from(error: OpenError) -> Self {
        let (kind, message) = match error {
            OpenError::NotFound(message) => (EditorOpenErrorKind::NotFound, message),
            OpenError::NotUtf8(message) => (EditorOpenErrorKind::NotUtf8, message),
            OpenError::Unreadable(message) => (EditorOpenErrorKind::Unreadable, message),
        };
        Self { kind, message }
    }
}

#[frb(opaque)]
pub struct RopeBridge {
    buffer: Buffer,
}

impl RopeBridge {
    #[frb(sync)]
    pub fn create(initial_text: String) -> Self {
        Self {
            buffer: Buffer::new(&initial_text),
        }
    }

    pub fn open_file(path: String) -> Result<Self, EditorOpenError> {
        Ok(Self {
            buffer: Buffer::open_file(&path)?,
        })
    }

    pub fn from_utf8(bytes: Vec<u8>) -> Result<Self, EditorOpenError> {
        Ok(Self {
            buffer: Buffer::from_utf8(bytes)?,
        })
    }

    #[frb(sync)]
    pub fn snapshot(&self) -> Self {
        Self {
            buffer: self.buffer.copy(),
        }
    }

    pub fn utf8_bytes(&self) -> Vec<u8> {
        self.buffer.utf8_bytes()
    }

    #[frb(sync)]
    pub fn same_text(
        &self,
        original: &RopeBridge,
        splice_start: usize,
        splice_len: usize,
        splice_text: String,
    ) -> bool {
        self.buffer
            .same_text(&original.buffer, splice_start, splice_len, &splice_text)
    }

    #[frb(sync)]
    pub fn len_chars(&self) -> usize {
        self.buffer.len_chars()
    }

    #[frb(sync)]
    pub fn get_text(&self) -> String {
        self.buffer.text()
    }

    #[frb(sync)]
    pub fn insert(&self, char_idx: usize, text: String) {
        self.buffer.insert(char_idx, &text)
    }

    #[frb(sync)]
    pub fn remove(&self, start: usize, end: usize) {
        self.buffer.remove(start, end)
    }

    #[frb(sync)]
    pub fn slice(&self, start: usize, end: usize) -> String {
        self.buffer.slice(start, end)
    }

    #[frb(sync)]
    pub fn char_to_line(&self, char_idx: usize) -> usize {
        self.buffer.char_to_line(char_idx)
    }

    #[frb(sync)]
    pub fn line_to_char(&self, line_idx: usize) -> usize {
        self.buffer.line_to_char(line_idx)
    }

    #[frb(sync)]
    pub fn line(&self, line_idx: usize) -> String {
        self.buffer.line(line_idx)
    }

    #[frb(sync)]
    pub fn len_lines(&self) -> usize {
        self.buffer.len_lines()
    }

    #[frb(sync)]
    pub fn cached_lines_range(&self, start_line: usize, end_line: usize) -> Vec<String> {
        self.buffer.lines(start_line, end_line)
    }
}

pub fn folds_compute_all(rope: &RopeBridge, tab_size: usize) -> Vec<RustFoldRange> {
    editor::compute_folds(&rope.buffer.snapshot(), tab_size)
}

#[frb(sync)]
pub fn folds_find_matching_bracket(rope: &RopeBridge, target_offset: usize) -> Option<usize> {
    editor::find_matching_bracket(&rope.buffer.rope(), target_offset)
}

#[frb(sync)]
pub fn guides_compute_viewport(
    rope: &RopeBridge,
    first_visible: usize,
    last_visible: usize,
    tab_size: usize,
) -> Vec<GuideBlock> {
    editor::compute_guides(&rope.buffer.rope(), first_visible, last_visible, tab_size)
}

pub fn words_extract(rope: &RopeBridge) -> Vec<String> {
    editor::extract_words(&rope.buffer.snapshot())
}
