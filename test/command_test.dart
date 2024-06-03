// ignore_for_file: avoid_print

void main() async {
  String input = """
您
<details markdown=1><summary>All changes from v0.8.5 to the latest commit:</summary>


(unreleased)
------------
- Fix submit error. [chen08209]
- Add WebDAV. [chen08209]

  add Auto check updates

  Optimize more details
- Optimize delayTest. [chen08209]
- Upgrade flutter version. [chen08209]
- Update kernel Add import profile via QR code image. [chen08209]
- Add compatibility mode and adapt clash scheme. [chen08209]
- Update Version. [chen08209]
- Reconstruction application proxy logic. [chen08209]
- Fix Tab destroy error. [chen08209]
- Optimize repeat healthcheck. [chen08209]
- Optimize Direct mode ui. [chen08209]
- Optimize Healthcheck. [chen08209]
- Remove proxies position animation, improve performance Add Telegram
  Link. [chen08209]
- Update healthcheck policy. [chen08209]
- New Check URLTest. [chen08209]
- Fix the problem of invalid auto-selection. [chen08209]
- New Async UpdateConfig. [chen08209]
- Add changeProfileDebounce. [chen08209]
- Update Workflow. [chen08209]
- Fix ChangeProfile block. [chen08209]
- Fix Release Message Error. [chen08209]
- Update Selector 2. [chen08209]
- Update Version. [chen08209]
- Fix Proxies Select Error. [chen08209]
- Fix the problem that the proxy group is empty in global mode.
  [chen08209]
- Fix the problem that the proxy group is empty in global mode.
  [chen08209]
- Add ProxyProvider2. [chen08209]
- Add ProxyProvider. [chen08209]
- Update Version. [chen08209]
- Update ProxyGroup Sort. [chen08209]
- Fix Android quickStart VpnService some problems. [chen08209]
- Update version. [chen08209]
- Set Android notification low importance. [chen08209]
- Fix the issue that VpnService can't be closed correctly in special
  cases. [chen08209]
- Fix the problem that TileService is not destroyed correctly in some
  cases. [chen08209]

  Adjust tab animation defaults
- Add Telegram in README_zh_CN.md. [chen08209]
- Add Telegram. [chen08209]
""";
  const pattern = r'- (.+?)\. \[.+?\]';
  final regex = RegExp(pattern);

  for (final match in regex.allMatches(input)) {
    final change = match.group(1);
    print(change);
  }
}

