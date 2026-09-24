use crate::api::editor::RustFoldRange;
use ropey::{Rope, RopeSlice};
use std::collections::HashMap;

// Mirrors the renderer's per-line fallback for small documents: a bracket
// fold, or for a line ending in ':' the run of deeper-indented lines after
// it, the smaller of the two when a line has both.
pub fn compute_all(rope: &Rope, tab_size: usize) -> Vec<RustFoldRange> {
    let mut ends: HashMap<i32, i32> = HashMap::new();
    for fold in bracket_folds(rope) {
        ends.entry(fold.start_line).or_insert(fold.end_line);
    }
    for fold in indent_folds(rope, tab_size) {
        ends.entry(fold.start_line)
            .and_modify(|end| *end = (*end).min(fold.end_line))
            .or_insert(fold.end_line);
    }
    let mut folds: Vec<RustFoldRange> = ends
        .into_iter()
        .map(|(start_line, end_line)| RustFoldRange {
            start_line,
            end_line,
        })
        .collect();
    folds.sort_by_key(|fold| fold.start_line);
    folds
}

fn bracket_folds(rope: &Rope) -> Vec<RustFoldRange> {
    let mut folds = Vec::new();
    let mut stack: Vec<(char, i32)> = Vec::new();
    let mut line_idx: i32 = 0;

    for ch in rope.chars() {
        if ch == '\n' {
            line_idx += 1;
        }
        if ch == '{' || ch == '[' || ch == '(' {
            stack.push((ch, line_idx));
        } else if ch == '}' || ch == ']' || ch == ')' {
            if let Some((open_ch, start_line)) = stack.pop() {
                let matches = matches!((open_ch, ch), ('{', '}') | ('[', ']') | ('(', ')'));
                if matches && start_line < line_idx {
                    folds.push(RustFoldRange {
                        start_line,
                        end_line: line_idx,
                    });
                }
            }
        }
    }
    folds
}

fn indent_folds(rope: &Rope, tab_size: usize) -> Vec<RustFoldRange> {
    let mut folds = Vec::new();
    let mut open: Vec<(usize, usize)> = Vec::new();
    let mut last_content = 0;
    for (line_idx, line) in rope.lines().enumerate() {
        let Some((indent, ends_with_colon)) = scan_line(line, tab_size) else {
            continue;
        };
        while let Some(&(start, start_indent)) = open.last() {
            if indent > start_indent {
                break;
            }
            open.pop();
            close(start, last_content, &mut folds);
        }
        if ends_with_colon {
            open.push((line_idx, indent));
        }
        last_content = line_idx;
    }
    for (start, _) in open {
        close(start, last_content, &mut folds);
    }
    folds
}

fn close(start: usize, end: usize, folds: &mut Vec<RustFoldRange>) {
    if end > start {
        folds.push(RustFoldRange {
            start_line: start as i32,
            end_line: end as i32,
        });
    }
}

// The leading indent in columns and whether the line ends in ':', or None
// for a blank line.
fn scan_line(line: RopeSlice, tab_size: usize) -> Option<(usize, bool)> {
    let mut indent = 0;
    let mut in_indent = true;
    let mut last = None;
    for ch in line.chars() {
        if in_indent {
            match ch {
                ' ' => indent += 1,
                '\t' if tab_size > 0 => indent += tab_size - indent % tab_size,
                '\t' => indent += 1,
                _ => in_indent = false,
            }
        }
        if !ch.is_whitespace() {
            last = Some(ch);
        }
    }
    last.map(|ch| (indent, ch == ':'))
}

pub fn find_matching_bracket(rope: &Rope, target_offset: usize) -> Option<usize> {
    let len = rope.len_chars();
    if target_offset >= len {
        return None;
    }

    let start_ch: char = rope.char(target_offset);

    let (matcher, search_forward) = match start_ch {
        '{' => ('}', true),
        '[' => (']', true),
        '(' => (')', true),
        '}' => ('{', false),
        ']' => ('[', false),
        ')' => ('(', false),
        _ => return None,
    };

    let mut depth = 1;

    if search_forward {
        for (i, ch) in rope.chars_at(target_offset + 1).enumerate() {
            let idx = target_offset + 1 + i;
            if idx >= len {
                break;
            }
            if ch == start_ch {
                depth += 1;
            } else if ch == matcher {
                depth -= 1;
                if depth == 0 {
                    return Some(idx);
                }
            }
        }
    } else {
        let mut idx = target_offset;
        while idx > 0 {
            idx -= 1;
            let ch = rope.char(idx);
            if ch == start_ch {
                depth += 1;
            } else if ch == matcher {
                depth -= 1;
                if depth == 0 {
                    return Some(idx);
                }
            }
        }
    }

    None
}

#[cfg(test)]
mod tests {
    use super::*;

    fn folds(text: &str) -> Vec<(i32, i32)> {
        compute_all(&Rope::from_str(text), 2)
            .into_iter()
            .map(|fold| (fold.start_line, fold.end_line))
            .collect()
    }

    #[test]
    fn a_key_folds_over_its_deeper_lines_across_blank_ones() {
        let text = "proxies:\n  - name: a\n    ws-opts:\n      path: /\n\n  - name: b\nrules:\n  - MATCH,DIRECT\n\n";
        assert_eq!(folds(text), [(0, 5), (2, 3), (6, 7)]);
    }

    #[test]
    fn a_key_without_deeper_lines_does_not_fold() {
        assert_eq!(folds("a:\nb: 1\nc:\n"), []);
    }

    #[test]
    fn a_line_with_both_keeps_the_smaller_fold() {
        assert_eq!(folds("f(a,\n  b:\n    c\n  d)\n"), [(0, 3), (1, 2)]);
        assert_eq!(folds("x: {\n  a: 1\n}\n"), [(0, 2)]);
    }
}
