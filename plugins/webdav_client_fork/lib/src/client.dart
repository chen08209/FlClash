import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'dart:io' as io;
import 'auth.dart';
import 'file.dart';
import 'utils.dart';
import 'webdav_dio.dart';
import 'xml.dart';

/// WebDav Client
class Client {
  /// WebDAV url
  final String uri;

  /// Wrapped http client
  WdDio c;

  /// Auth Mode (noAuth/basic/digest)
  Auth auth;

  /// debug
  bool debug;

  Client({
    required this.uri,
    required this.c,
    required this.auth,
    this.debug = false,
  });

  // methods--------------------------------

  /// Set the public request headers
  void setHeaders(Map<String, dynamic> headers) =>
      this.c.options.headers = headers;

  /// Set the connection server timeout time in milliseconds.
  void setConnectTimeout(int timeout) =>
      this.c.options.connectTimeout = Duration(milliseconds: timeout);

  /// Set send data timeout time in milliseconds.
  void setSendTimeout(int timeout) =>
      this.c.options.sendTimeout = Duration(milliseconds: timeout);

  /// Set transfer data time in milliseconds.
  void setReceiveTimeout(int timeout) =>
      this.c.options.receiveTimeout = Duration(milliseconds: timeout);

  /// Test whether the service can connect
  Future<void> ping([CancelToken? cancelToken]) async {
    var resp = await c.wdOptions(this, '/', cancelToken: cancelToken);
    if (resp.statusCode != 200) {
      throw newResponseError(resp);
    }
  }

  // Future<void> getQuota([CancelToken cancelToken]) async {
  //   var resp = await c.wdQuota(this, quotaXmlStr, cancelToken: cancelToken);
  //   print(resp);
  // }

  /// Read all files in a folder
  Future<List<File>> readDir(String path, [CancelToken? cancelToken]) async {
    path = fixSlashes(path);
    var resp = await this
        .c
        .wdPropfind(this, path, true, fileXmlStr, cancelToken: cancelToken);

    String str = resp.data;
    return WebdavXml.toFiles(path, str);
  }

  /// Read a single files properties
  Future<File> readProps(String path, [CancelToken? cancelToken]) async {
    path = fixSlashes(path);
    var resp = await this
        .c
        .wdPropfind(this, path, true, fileXmlStr, cancelToken: cancelToken);

    String str = resp.data;
    return WebdavXml.toFiles(path, str, skipSelf: false).first;
  }

  /// Create a folder
  Future<void> mkdir(String path, [CancelToken? cancelToken]) async {
    path = fixSlashes(path);
    var resp = await this.c.wdMkcol(this, path, cancelToken: cancelToken);
    var status = resp.statusCode;
    if (status != 201 && status != 405) {
      throw newResponseError(resp);
    }
  }

  /// Recursively create folders
  Future<void> mkdirAll(String path, [CancelToken? cancelToken]) async {
    path = fixSlashes(path);
    var resp = await this.c.wdMkcol(this, path, cancelToken: cancelToken);
    var status = resp.statusCode;
    if (status == 201 || status == 405) {
      return;
    } else if (status == 409) {
      var paths = path.split('/');
      var sub = '/';
      for (var e in paths) {
        if (e == '') {
          continue;
        }
        sub += e + '/';
        resp = await this.c.wdMkcol(this, sub, cancelToken: cancelToken);
        status = resp.statusCode;
        if (status != 201 && status != 405) {
          throw newResponseError(resp);
        }
      }
      return;
    }
    throw newResponseError(resp);
  }

  /// Remove a folder or file
  /// If you remove the folder, some webdav services require a '/' at the end of the path.
  Future<void> remove(String path, [CancelToken? cancelToken]) {
    return removeAll(path, cancelToken);
  }

  /// Remove files
  Future<void> removeAll(String path, [CancelToken? cancelToken]) async {
    var resp = await this.c.wdDelete(this, path, cancelToken: cancelToken);
    if (resp.statusCode == 200 ||
        resp.statusCode == 204 ||
        resp.statusCode == 404) {
      return;
    }
    throw newResponseError(resp);
  }

  /// Rename a folder or file
  /// If you rename the folder, some webdav services require a '/' at the end of the path.
  Future<void> rename(String oldPath, String newPath, bool overwrite,
      [CancelToken? cancelToken]) {
    return this.c.wdCopyMove(this, oldPath, newPath, false, overwrite);
  }

  /// Copy a file / folder from A to B
  /// If copied the folder (A > B), it will copy all the contents of folder A to folder B.
  /// Some webdav services have been tested and found to delete the original contents of the B folder!!!
  Future<void> copy(String oldPath, String newPath, bool overwrite,
      [CancelToken? cancelToken]) {
    return this.c.wdCopyMove(this, oldPath, newPath, true, overwrite);
  }

  /// Read the bytes of a file
  /// It is best not to open debug mode, otherwise the byte data is too large and the output results in IDE cards, 😄
  Future<List<int>> read(
    String path, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) {
    return this.c.wdReadWithBytes(
          this,
          path,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );
  }

  /// Read the bytes of a file with stream and write to a local file
  Future<void> read2File(
    String path,
    String savePath, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    await this.c.wdReadWithStream(
          this,
          path,
          savePath,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );
  }

  /// Write the bytes to remote path
  Future<void> write(
    String path,
    Uint8List data, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) {
    return this.c.wdWriteWithBytes(
          this,
          path,
          data,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );
  }

  /// Read local file stream and write to remote file
  Future<void> writeFromFile(
    String localFilePath,
    String path, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    var file = io.File(localFilePath);
    return this.c.wdWriteWithStream(
          this,
          path,
          file.openRead(),
          file.lengthSync(),
          onProgress: onProgress,
          cancelToken: cancelToken,
        );
  }
}

/// create new client
Client newClient(String uri,
    {String user = '', String password = '', bool debug = false}) {
  return Client(
    uri: fixSlash(uri),
    c: WdDio(debug: debug),
    auth: Auth(user: user, pwd: password),
    debug: debug,
  );
}
