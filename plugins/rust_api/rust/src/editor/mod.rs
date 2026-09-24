//! Derived from the Rust backend of code_forge 10.14.0
//! (https://github.com/heckmon/code_forge), MIT License, Copyright (c) 2025
//! Athul A S; the full notice is in plugins/code_forge/LICENSE.

mod buffer;
mod folds;
mod guides;
mod words;

pub use buffer::Buffer;
pub use folds::{compute_all as compute_folds, find_matching_bracket};
pub use guides::compute_viewport as compute_guides;
pub use words::extract as extract_words;
