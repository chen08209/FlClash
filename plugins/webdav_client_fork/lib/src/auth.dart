import 'dart:convert';
import 'utils.dart';

/// Auth type
enum AuthType {
  NoAuth,
  BasicAuth,
  DigestAuth,
}

/// Auth -----------------------------------
class Auth {
  /// username
  final String user;

  /// password
  final String pwd;

  const Auth({
    required String user,
    required String pwd,
  })  : this.user = user,
        this.pwd = pwd;

  /// Get auth type
  AuthType get type => AuthType.NoAuth;

  /// Get authorization data
  String? authorize(String method, String path) => null;
}

/// BasicAuth ------------------------------------
class BasicAuth extends Auth {
  const BasicAuth({
    required String user,
    required String pwd,
  }) : super(
          user: user,
          pwd: pwd,
        );

  @override
  AuthType get type => AuthType.BasicAuth;

  @override
  String authorize(String method, String path) {
    List<int> bytes = utf8.encode('${this.user}:${this.pwd}');
    return 'Basic ${base64Encode(bytes)}';
  }
}

// DigestAuth ----------------------------------
class DigestAuth extends Auth {
  DigestParts dParts;

  DigestAuth({
    required String user,
    required String pwd,
    required this.dParts,
  }) : super(
          user: user,
          pwd: pwd,
        );

  String? get nonce => this.dParts.parts['nonce'];

  String? get realm => this.dParts.parts['realm'];

  String? get qop => this.dParts.parts['qop'];

  String? get opaque => this.dParts.parts['opaque'];

  String? get algorithm => this.dParts.parts['algorithm'];

  String? get entityBody => this.dParts.parts['entityBody'];

  @override
  AuthType get type => AuthType.DigestAuth;

  @override
  String authorize(String method, String path) {
    this.dParts.uri = Uri.encodeFull(path);
    this.dParts.method = method;
    // Uri.encodeComponent fix not ascii
    return this._getDigestAuthorization();
  }

  String _getDigestAuthorization() {
    int nonceCount = 1;
    String cnonce = computeNonce();
    String ha1 = _computeHA1(nonceCount, cnonce);
    String ha2 = _computeHA2();
    String response = _computeResponse(ha1, ha2, nonceCount, cnonce);
    String authorization =
        'Digest username="${this.user}", realm="${this.realm}", nonce="${this.nonce}", uri="${this.dParts.uri}", nc=$nonceCount, cnonce="$cnonce", response="$response"';

    if (this.qop?.isNotEmpty == true) {
      authorization += ', qop=${this.qop}';
    }

    if (this.opaque?.isNotEmpty == true) {
      authorization += ', opaque=${this.opaque}';
    }

    return authorization;
  }

  //
  String _computeHA1(int nonceCount, String cnonce) {
    String? algorithm = this.algorithm;

    if (algorithm == 'MD5' || algorithm?.isEmpty != false) {
      return md5Hash('${this.user}:${this.realm}:${this.pwd}');
    } else if (algorithm == 'MD5-sess') {
      String md5Str = md5Hash('${this.user}:${this.realm}:${this.pwd}');
      return md5Hash('$md5Str:$nonceCount:$cnonce');
    }

    return '';
  }

  //
  String _computeHA2() {
    String? qop = this.qop;

    if (qop == 'auth' || qop?.isEmpty != false) {
      return md5Hash('${this.dParts.method}:${this.dParts.uri}');
    } else if (qop == 'auth-int' && this.entityBody?.isEmpty == false) {
      return md5Hash(
          '${this.dParts.method}:${this.dParts.uri}:${md5Hash(this.entityBody!)}');
    }

    return '';
  }

  //
  String _computeResponse(
      String ha1, String ha2, int nonceCount, String cnonce) {
    String? qop = this.qop;

    if (qop?.isEmpty != false) {
      return md5Hash('$ha1:${this.nonce}:$ha2');
    } else if (qop == 'auth' || qop == 'auth-int') {
      return md5Hash('$ha1:${this.nonce}:$nonceCount:$cnonce:$qop:$ha2');
    }

    return '';
  }
}

/// DigestParts
class DigestParts {
  String uri = '';
  String method = '';

  Map<String, String> parts = {
    'nonce': '',
    'realm': '',
    'qop': '',
    'opaque': '',
    'algorithm': '',
    'entityBody': '',
  };

  DigestParts(String? authHeader) {
    if (authHeader != null) {
      var keys = parts.keys;
      var list = authHeader.split(',');
      list.forEach((kv) {
        keys.forEach((k) {
          if (kv.contains(k)) {
            var index = kv.indexOf('=');
            if (kv.length - 1 > index) {
              parts[k] = trim(kv.substring(index + 1), '"');
            }
          }
        });
      });
    }
  }
}
