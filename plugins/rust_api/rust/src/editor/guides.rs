use super::buffer::line_without_break;
use crate::api::editor::GuideBlock;
use ropey::{Rope, RopeSlice};

const SCAN_BACK_LIMIT: usize = 500;

pub fn compute_viewport(
    rope: &Rope,
    first_visible: usize,
    last_visible: usize,
    tab_size: usize,
) -> Vec<GuideBlock> {
    let total_lines = rope.len_lines();

    if total_lines == 0 {
        return Vec::new();
    }

    let first = first_visible.min(total_lines.saturating_sub(1));
    let last = last_visible.min(total_lines.saturating_sub(1));
    let scan_start = first.saturating_sub(SCAN_BACK_LIMIT);
    // Nothing below the viewport is drawn, so a block still open at the
    // horizon is reported as ending there instead of scanning the document.
    let horizon = (last + 2).min(total_lines);

    let mut blocks: Vec<GuideBlock> = Vec::new();

    for line_idx in scan_start..=last {
        let line_slice = rope.line(line_idx);
        let mut line_len = content_len(&line_slice);

        while line_len > 0 && line_slice.char(line_len - 1).is_whitespace() {
            line_len -= 1;
        }

        if line_len == 0 {
            continue;
        }

        let last_char = line_slice.char(line_len - 1);
        let opening_tag_name = extract_opening_tag_name(&line_slice.slice(..line_len).to_string());
        let ends_with_bracket = matches!(last_char, '{' | '(' | '[' | ':');
        if !ends_with_bracket && opening_tag_name.is_none() {
            continue;
        }

        let leading_cols = leading_columns(&line_slice, line_len, tab_size);
        let indent_level = leading_cols.checked_div(tab_size).unwrap_or(0);

        let mut end_line: usize = line_idx + 1;

        if matches!(last_char, '{' | '(' | '[') {
            let bracket_pos = rope.line_to_char(line_idx) + line_len - 1;
            let limit = rope.line_to_char(horizon);
            if let Some(match_pos) = find_matching_bracket_forward(rope, bracket_pos, limit) {
                end_line = rope.char_to_line(match_pos) + 1;
            }
        } else if let Some(tag_name) = opening_tag_name {
            if let Some(match_line) =
                find_matching_closing_tag_line(rope, line_idx, &tag_name, horizon)
            {
                end_line = match_line + 1;
            }
        }

        if end_line <= line_idx + 1 {
            let mut scan = line_idx + 1;
            let mut last_valid = line_idx;
            while scan < horizon {
                let line_slice = rope.line(scan);
                let nl_len = content_len(&line_slice);
                if is_blank(&line_slice, nl_len) {
                    scan += 1;
                    continue;
                }
                if leading_columns(&line_slice, nl_len, tab_size) <= leading_cols {
                    break;
                }
                last_valid = scan;
                scan += 1;
            }
            end_line = if scan == horizon && horizon < total_lines {
                horizon
            } else {
                last_valid + 1
            };
        }

        if end_line <= line_idx + 1 {
            continue;
        }

        let would_pass = ((line_idx + 1)..(end_line.saturating_sub(1).min(horizon))).any(|check| {
            let cl_slice = rope.line(check);
            let cl_len = content_len(&cl_slice);
            !is_blank(&cl_slice, cl_len)
                && leading_columns(&cl_slice, cl_len, tab_size) <= leading_cols
        });

        if would_pass {
            continue;
        }

        blocks.push(GuideBlock {
            start_line: line_idx as i32,
            end_line: end_line as i32,
            indent_level: indent_level as i32,
            leading_spaces: leading_cols as i32,
        });
    }

    blocks
}

fn content_len(line: &RopeSlice) -> usize {
    let mut len = line.len_chars();
    if len >= 2 && line.char(len - 1) == '\n' && line.char(len - 2) == '\r' {
        len -= 2;
    }
    if len >= 1 && line.char(len - 1) == '\n' {
        len -= 1;
    }
    len
}

fn is_blank(line: &RopeSlice, len: usize) -> bool {
    (0..len).all(|i| line.char(i).is_whitespace())
}

fn leading_columns(line: &RopeSlice, len: usize, tab_size: usize) -> usize {
    let mut cols: usize = 0;
    for i in 0..len {
        match line.char(i) {
            ' ' => cols += 1,
            '\t' if tab_size > 0 => cols += tab_size - cols % tab_size,
            '\t' => cols += 1,
            _ => break,
        }
    }
    cols
}

fn find_matching_bracket_forward(
    rope: &Rope,
    open_offset: usize,
    limit_char: usize,
) -> Option<usize> {
    let open = rope.char(open_offset);
    let close = match open {
        '{' => '}',
        '[' => ']',
        '(' => ')',
        _ => return None,
    };
    let mut depth = 1;
    for (i, ch) in rope.chars_at(open_offset + 1).enumerate() {
        let idx = open_offset + 1 + i;
        if idx >= limit_char {
            break;
        }
        if ch == open {
            depth += 1;
        } else if ch == close {
            depth -= 1;
            if depth == 0 {
                return Some(idx);
            }
        }
    }
    None
}

fn extract_opening_tag_name(line: &str) -> Option<String> {
    let trimmed = line.trim_end();
    if !trimmed.ends_with('>') || trimmed.ends_with("/>") || trimmed.ends_with("-->") {
        return None;
    }

    let start = trimmed.find('<')?;
    let mut chars = trimmed[start + 1..].chars();
    let first = chars.next()?;
    if !first.is_ascii_alphabetic() {
        return None;
    }

    let mut name = String::new();
    name.push(first);
    for ch in chars {
        if ch.is_ascii_alphanumeric() || matches!(ch, ':' | '_' | '-') {
            name.push(ch);
        } else {
            break;
        }
    }

    Some(name)
}

fn find_matching_closing_tag_line(
    rope: &Rope,
    start_line: usize,
    tag_name: &str,
    limit_line: usize,
) -> Option<usize> {
    let mut depth = 1usize;
    let end = rope.len_lines().min(limit_line);

    for line_idx in (start_line + 1)..end {
        let line_str = line_without_break(rope, line_idx);
        let trimmed = line_str.trim();
        if trimmed.is_empty() {
            continue;
        }

        if contains_same_tag_opening(trimmed, tag_name) {
            depth += 1;
        }

        if contains_same_tag_closing(trimmed, tag_name) {
            depth = depth.saturating_sub(1);
            if depth == 0 {
                return Some(line_idx);
            }
        }
    }

    None
}

fn contains_same_tag_opening(line: &str, tag_name: &str) -> bool {
    let opening = format!("<{}", tag_name);
    line.contains(&opening) && !line.contains(&format!("</{}", tag_name)) && !line.ends_with("/>")
}

fn contains_same_tag_closing(line: &str, tag_name: &str) -> bool {
    line.contains(&format!("</{}", tag_name))
}
