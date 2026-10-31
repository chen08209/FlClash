/// `bytes` as UTF-8, read in the charset `label` names. None for a label no
/// browser knows, or for bytes that are not in that charset unless `lossy`.
pub fn transcode_charset(bytes: Vec<u8>, label: String, lossy: bool) -> Option<Vec<u8>> {
    let encoding = encoding_rs::Encoding::for_label(label.as_bytes())?;
    let (text, _, had_errors) = encoding.decode(&bytes);
    if had_errors && !lossy {
        return None;
    }
    Some(text.into_owned().into_bytes())
}

#[cfg(test)]
mod tests {
    use super::transcode_charset;

    #[test]
    fn reads_the_charsets_a_label_names() {
        let gbk = vec![0xc4, 0xe3, 0xba, 0xc3];
        assert_eq!(
            transcode_charset(gbk, "GBK".into(), false),
            Some("你好".as_bytes().to_vec()),
        );
        let big5 = vec![0xa7, 0x41, 0xa6, 0x6e];
        assert_eq!(
            transcode_charset(big5, "big5".into(), false),
            Some("你好".as_bytes().to_vec()),
        );
    }

    #[test]
    fn refuses_an_unknown_label_and_bad_bytes_unless_lossy() {
        assert_eq!(transcode_charset(vec![0x61], "nope".into(), false), None);
        let cut = vec![0x61, 0xc4];
        assert_eq!(transcode_charset(cut.clone(), "gbk".into(), false), None);
        assert_eq!(
            transcode_charset(cut, "gbk".into(), true),
            Some("a\u{fffd}".as_bytes().to_vec()),
        );
    }
}
