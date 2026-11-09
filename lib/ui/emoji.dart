/// Emoji in a string: flags, keycaps, and pictographs with their modifiers,
/// presentation selectors, tags and joined parts.
final emojiPattern = RegExp(
  // ignore: valid_regexps
  r'\p{RI}\p{RI}'
  r'|[#*0-9]️?⃣'
  r'|\p{Emoji}(?<![#*0-9])'
  r'(?:\p{EMod}|️⃣?|[\u{E0020}-\u{E007E}]+\u{E007F})?'
  r'(?:‍\p{Emoji}(?:\p{EMod}|️⃣?|[\u{E0020}-\u{E007E}]+\u{E007F})?)*',
  unicode: true,
);
