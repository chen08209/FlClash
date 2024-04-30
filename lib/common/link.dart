import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';

typedef InstallConfigCallBack = void Function(String url);

class LinkManager {
  static LinkManager? _instance;
  late AppLinks _appLinks;
  StreamSubscription? subscription;

  LinkManager._internal() {
    _appLinks = AppLinks();
  }

  initAppLinksListen(installConfigCallBack) async {
    debugPrint("initAppLinksListen");
    destroy();
    subscription = _appLinks.allUriLinkStream.listen(
      (uri) {
        debugPrint('onAppLink: $uri');
        if (uri.host == 'install-config') {
          final parameters = uri.queryParameters;
          final url = parameters['url'];
          if (url != null) {
            installConfigCallBack(url);
          }
        }
      },
    );
  }


  destroy(){
    if (subscription != null) {
      subscription?.cancel();
      subscription = null;
    }
  }

  factory LinkManager() {
    _instance ??= LinkManager._internal();
    return _instance!;
  }
}

final linkManager = LinkManager();
