const FONTS_XML: &str = "/system/etc/fonts.xml";

pub fn families() -> Result<Vec<String>, String> {
    let xml =
        std::fs::read_to_string(FONTS_XML).map_err(|error| format!("{FONTS_XML}: {error}"))?;
    Ok(named_families(&xml))
}

fn is_word(byte: u8) -> bool {
    byte.is_ascii_alphanumeric() || byte == b'_'
}

/// The `name` of every `<family>` element; an unnamed family is a fallback
/// for a language and cannot be picked by name.
fn named_families(xml: &str) -> Vec<String> {
    let mut names = Vec::new();
    let mut rest = xml;
    while let Some(start) = rest.find("<family") {
        rest = &rest[start + "<family".len()..];
        if rest.bytes().next().is_none_or(is_word) {
            continue;
        }
        let tag = &rest[..rest.find('>').unwrap_or(rest.len())];
        if let Some(name) = name_attribute(tag) {
            names.push(name.to_owned());
        }
    }
    names
}

fn name_attribute(tag: &str) -> Option<&str> {
    let bytes = tag.as_bytes();
    let mut from = 0;
    while let Some(at) = tag[from..].find("name=\"") {
        let at = from + at;
        let value = at + "name=\"".len();
        if at == 0 || !is_word(bytes[at - 1]) {
            let end = tag[value..].find('"')?;
            return (end > 0).then(|| &tag[value..value + end]);
        }
        from = value;
    }
    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn lists_the_named_families_of_a_fonts_xml() {
        let xml = r#"
<familyset version="23">
  <family name="sans-serif" varied="true">
    <font weight="400" style="normal">Roboto-Regular.ttf</font>
  </family>
  <alias name="arial" to="sans-serif" />
  <family lang="zh-Hans">
    <font weight="400" style="normal" index="2">NotoSansCJK-Regular.ttc</font>
  </family>
  <family
      name="serif-monospace">
    <font weight="400" style="normal">CutiveMono.ttf</font>
  </family>
  <family fallbackFor="serif" xname="no">
  </family>
</familyset>
"#;
        assert_eq!(named_families(xml), ["sans-serif", "serif-monospace"]);
    }
}
