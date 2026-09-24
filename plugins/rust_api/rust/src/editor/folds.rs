use crate::api::editor::RustFoldRange;
use ropey::Rope;

pub fn compute_all(rope: &Rope) -> Vec<RustFoldRange> {
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
