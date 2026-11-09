import 'package:fl_clash/ui/icons/app_glyphs.dart';
import 'package:prism_ui/icons/glyph.dart';
import 'package:prism_ui/null_status.dart';

/// The illustrations of FlClash's empty pages.
enum NullStatusIllustration implements Illustration {
  data,
  logs,
  proxies,
  profile,
  scripts,
  rules,
  connections,
  requests,
  dns,
  ntp,
  sniffer,
  tun,
  wifi,
  apps,
  icons,
  fonts,
  permission,
  camera,
  error;

  @override
  Glyph get glyph => switch (this) {
    data => AppGlyphs.resources,
    logs => AppGlyphs.logs,
    proxies => AppGlyphs.proxies,
    profile => AppGlyphs.profiles,
    scripts => AppGlyphs.code,
    rules => AppGlyphs.rules,
    connections => AppGlyphs.connections,
    requests => AppGlyphs.requests,
    dns => AppGlyphs.dns,
    ntp => AppGlyphs.clock,
    sniffer => AppGlyphs.eye,
    tun => AppGlyphs.vpn,
    wifi => AppGlyphs.wifi,
    apps => AppGlyphs.appsList,
    icons => AppGlyphs.iconTile,
    fonts => AppGlyphs.font,
    permission => AppGlyphs.lock,
    camera => AppGlyphs.camera,
    error => AppGlyphs.error,
  };

  @override
  bool get isError => this == error;
}
