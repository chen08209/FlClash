use ropey::Rope;
use std::collections::HashSet;
use std::mem;

const MAX_WORDS: usize = 5_000;

// Mirrors plugins/code_forge/lib/code_forge/word_chars.dart, which decides the
// prefix these words are matched against.
const WORD_RANGES: [(char, char); 13] = [
    ('\u{30}', '\u{39}'),
    ('\u{41}', '\u{5A}'),
    ('\u{5F}', '\u{5F}'),
    ('\u{61}', '\u{7A}'),
    ('\u{0590}', '\u{05FF}'),
    ('\u{0600}', '\u{06FF}'),
    ('\u{08A0}', '\u{08FF}'),
    ('\u{3040}', '\u{309F}'),
    ('\u{30A0}', '\u{30FF}'),
    ('\u{3400}', '\u{4DBF}'),
    ('\u{4E00}', '\u{9FFF}'),
    ('\u{AC00}', '\u{D7AF}'),
    ('\u{F900}', '\u{FAFF}'),
];

fn is_word_char(ch: char) -> bool {
    WORD_RANGES
        .iter()
        .any(|&(from, to)| (from..=to).contains(&ch))
}

pub fn extract(rope: &Rope) -> Vec<String> {
    let mut words = HashSet::new();
    let mut current_word = String::new();
    let mut flush = |word: &mut String| {
        let starts_word = word.chars().next().is_some_and(|c| !c.is_ascii_digit());
        if starts_word && words.len() < MAX_WORDS {
            words.insert(mem::take(word));
        } else {
            word.clear();
        }
    };

    for ch in rope.chars() {
        if is_word_char(ch) {
            current_word.push(ch);
        } else if !current_word.is_empty() {
            flush(&mut current_word);
        }
    }
    flush(&mut current_word);

    words.into_iter().collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn sorted(text: &str) -> Vec<String> {
        let mut words = extract(&Rope::from_str(text));
        words.sort();
        words
    }

    #[test]
    fn words_follow_the_dart_word_chars() {
        assert_eq!(
            sorted("a1 1abc _x café 名前 8080"),
            ["_x", "a1", "caf", "名前"]
        );
    }
}
