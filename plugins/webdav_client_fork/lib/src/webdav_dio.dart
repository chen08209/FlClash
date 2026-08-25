import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'adapter/adapter_stub.dart'
    if (dart.library.io) 'adapter/adapter_mobile.dart'
    if (dart.library.js) 'adapter/adapter_web.dart';

import 'package:dio/dio.dart';

import 'auth.dart';
import 'client.dart';
import 'utils.dart';

/// Wrapped http client
class WdDio with DioMixin implements Dio {
  // // Request config
  // BaseOptions? baseOptions;

  // Interceptors
  final List<Interceptor>? interceptorList;

  // debug
  final bool debug;

  WdDio({
    BaseOptions? options,
    this.interceptorList,
    this.debug = false,
  }) {
    this.options = options ?? BaseOptions();
    // 禁止重定向
    this.options.followRedirects = false;

    // 状态码错误视为成功
    this.options.validateStatus = (status) => true;

    httpClientAdapter = getAdapter();

    // 拦截器
    if (interceptorList != null) {
      for (var item in interceptorList!) {
        this.interceptors.add(item);
      }
    }

    // debug
    if (debug == true) {
      this.interceptors.add(LogInterceptor(responseBody: true));
    }
  }

  // methods-------------------------
  Future<Response<T>> req<T>(
    Client self,
    String method,
    String path, {
    dynamic data,
    Function(Options)? optionsHandler,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    // options
    Options options = Options(method: method);
    if (options.headers == null) {
      options.headers = {};
    }

    // 二次处理options
    if (optionsHandler != null) {
      optionsHandler(options);
    }

    // authorization
    String? str = self.auth.authorize(method, path);
    if (str != null) {
      options.headers?['authorization'] = str;
    }

    var resp = await this.requestUri<T>(
      Uri.parse(
          '${path.startsWith(RegExp(r'(http|https)://')) ? path : join(self.uri, path)}'),
      options: options,
      data: data,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
    );

    if (resp.statusCode == 401) {
      String? w3AHeader = resp.headers.value('www-authenticate');
      String? lowerW3AHeader = w3AHeader?.toLowerCase();

      // before is noAuth
      if (self.auth.type == AuthType.NoAuth) {
        // Digest
        if (lowerW3AHeader?.contains('digest') == true) {
          self.auth = DigestAuth(
              user: self.auth.user,
              pwd: self.auth.pwd,
              dParts: DigestParts(w3AHeader));
        }
        // Basic
        else if (lowerW3AHeader?.contains('basic') == true) {
          self.auth = BasicAuth(user: self.auth.user, pwd: self.auth.pwd);
        }
        // error
        else {
          throw newResponseError(resp);
        }
      }
      // before is digest and Nonce Lifetime is out
      else if (self.auth.type == AuthType.DigestAuth &&
          lowerW3AHeader?.contains('stale=true') == true) {
        self.auth = DigestAuth(
            user: self.auth.user,
            pwd: self.auth.pwd,
            dParts: DigestParts(w3AHeader));
      } else {
        throw newResponseError(resp);
      }

      // retry
      return this.req<T>(
        self,
        method,
        path,
        data: data,
        optionsHandler: optionsHandler,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } else if (resp.statusCode == 302) {
      // 文件位置被重定向到新路径
      if (resp.headers.map.containsKey('location')) {
        List<String>? list = resp.headers.map['location'];
        if (list != null && list.isNotEmpty) {
          String redirectPath = list[0];
          // retry
          return this.req<T>(
            self,
            method,
            redirectPath,
            data: data,
            optionsHandler: optionsHandler,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
            cancelToken: cancelToken,
          );
        }
      }
    }

    return resp;
  }

  // OPTIONS
  Future<Response> wdOptions(Client self, String path,
      {CancelToken? cancelToken}) {
    return this.req(self, 'OPTIONS', path,
        optionsHandler: (options) => options.headers?['depth'] = '0',
        cancelToken: cancelToken);
  }

  // // quota
  // Future<Response> wdQuota(Client self, String dataStr,
  //     {CancelToken cancelToken}) {
  //   return this.req(self, 'PROPFIND', '/', data: utf8.encode(dataStr),
  //       optionsHandler: (options) {
  //     options.headers['depth'] = '0';
  //     options.headers['accept'] = 'text/plain';
  //   }, cancelToken: cancelToken);
  // }

  // PROPFIND
  Future<Response> wdPropfind(
      Client self, String path, bool depth, String dataStr,
      {CancelToken? cancelToken}) async {
    var resp = await this.req(self, 'PROPFIND', path, data: dataStr,
        optionsHandler: (options) {
      options.headers?['depth'] = depth ? '1' : '0';
      options.headers?['content-type'] = 'application/xml;charset=UTF-8';
      options.headers?['accept'] = 'application/xml,text/xml';
      options.headers?['accept-charset'] = 'utf-8';
      options.headers?['accept-encoding'] = '';
    }, cancelToken: cancelToken);

    if (resp.statusCode != 207) {
      throw newResponseError(resp);
    }

    return resp;
  }

  /// MKCOL
  Future<Response> wdMkcol(Client self, String path,
      {CancelToken? cancelToken}) {
    return this.req(self, 'MKCOL', path, cancelToken: cancelToken);
  }

  /// DELETE
  Future<Response> wdDelete(Client self, String path,
      {CancelToken? cancelToken}) {
    return this.req(self, 'DELETE', path, cancelToken: cancelToken);
  }

  /// COPY OR MOVE
  Future<void> wdCopyMove(
      Client self, String oldPath, String newPath, bool isCopy, bool overwrite,
      {CancelToken? cancelToken}) async {
    var method = isCopy == true ? 'COPY' : 'MOVE';
    var resp = await this.req(self, method, oldPath, optionsHandler: (options) {
      options.headers?['destination'] = Uri.encodeFull(join(self.uri, newPath));
      options.headers?['overwrite'] = overwrite == true ? 'T' : 'F';
    }, cancelToken: cancelToken);

    var status = resp.statusCode;
    // TODO 207
    if (status == 201 || status == 204 || status == 207) {
      return;
    } else if (status == 409) {
      await this._createParent(self, newPath, cancelToken: cancelToken);
      return this.wdCopyMove(self, oldPath, newPath, isCopy, overwrite,
          cancelToken: cancelToken);
    } else {
      throw newResponseError(resp);
    }
  }

  /// create parent folder
  Future<void>? _createParent(Client self, String path,
      {CancelToken? cancelToken}) {
    var parentPath = path.substring(0, path.lastIndexOf('/') + 1);

    if (parentPath == '' || parentPath == '/') {
      return null;
    }
    return self.mkdirAll(parentPath, cancelToken);
  }

  /// read a file with bytes
  Future<List<int>> wdReadWithBytes(
    Client self,
    String path, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // fix auth error
    var pResp = await this.wdOptions(self, path, cancelToken: cancelToken);
    if (pResp.statusCode != 200) {
      throw newResponseError(pResp);
    }

    var resp = await this.req(
      self,
      'GET',
      path,
      optionsHandler: (options) => options.responseType = ResponseType.bytes,
      onReceiveProgress: onProgress,
      cancelToken: cancelToken,
    );
    if (resp.statusCode != 200) {
      if (resp.statusCode != null) {
        if (resp.statusCode! >= 300 && resp.statusCode! < 400) {
          return (await this.req(
            self,
            'GET',
            resp.headers["location"]!.first,
            optionsHandler: (options) =>
                options.responseType = ResponseType.bytes,
            onReceiveProgress: onProgress,
            cancelToken: cancelToken,
          ))
              .data;
        }
      }
      throw newResponseError(resp);
    }
    return resp.data;
  }

  /// read a file with stream
  Future<void> wdReadWithStream(
    Client self,
    String path,
    String savePath, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // fix auth error
    var pResp = await this.wdOptions(self, path, cancelToken: cancelToken);
    if (pResp.statusCode != 200) {
      throw newResponseError(pResp);
    }

    Response<ResponseBody> resp;

    // Reference Dio download
    // request
    try {
      resp = await this.req<ResponseBody>(
        self,
        'GET',
        path,
        optionsHandler: (options) => options.responseType = ResponseType.stream,
        // onReceiveProgress: onProgress,
        cancelToken: cancelToken,
      );
    } on DioError catch (e) {
      if (e.type == DioErrorType.badResponse) {
        if (e.response!.requestOptions.receiveDataWhenStatusError == true) {
          var res = await transformer.transformResponse(
            e.response!.requestOptions..responseType = ResponseType.json,
            e.response!.data as ResponseBody,
          );
          e.response!.data = res;
        } else {
          e.response!.data = null;
        }
      }
      rethrow;
    }
    if (resp.statusCode != 200) {
      throw newResponseError(resp);
    }

    resp.headers = Headers.fromMap(resp.data!.headers);

    //If directory (or file) doesn't exist yet, the entire method fails
    File file = File(savePath);
    file.createSync(recursive: true);

    var raf = file.openSync(mode: FileMode.write);

    //Create a Completer to notify the success/error state.
    var completer = Completer<Response>();
    var future = completer.future;
    var received = 0;

    // Stream<Uint8List>
    var stream = resp.data!.stream;
    var compressed = false;
    var total = 0;
    var contentEncoding = resp.headers.value(Headers.contentEncodingHeader);
    if (contentEncoding != null) {
      compressed = ['gzip', 'deflate', 'compress'].contains(contentEncoding);
    }
    if (compressed) {
      total = -1;
    } else {
      total =
          int.parse(resp.headers.value(Headers.contentLengthHeader) ?? '-1');
    }

    late StreamSubscription subscription;
    Future? asyncWrite;
    var closed = false;
    Future _closeAndDelete() async {
      if (!closed) {
        closed = true;
        await asyncWrite;
        await raf.close();
        await file.delete();
      }
    }

    subscription = stream.listen(
      (data) {
        subscription.pause();
        // Write file asynchronously
        asyncWrite = raf.writeFrom(data).then((_raf) {
          // Notify progress
          received += data.length;

          onProgress?.call(received, total);

          raf = _raf;
          if (cancelToken == null || !cancelToken.isCancelled) {
            subscription.resume();
          }
        }).catchError((err) async {
          try {
            await subscription.cancel();
          } finally {
            completer.completeError(DioError(
              requestOptions: resp.requestOptions,
              error: err,
            ));
          }
        });
      },
      onDone: () async {
        try {
          await asyncWrite;
          closed = true;
          await raf.close();
          completer.complete(resp);
        } catch (err) {
          completer.completeError(DioError(
            requestOptions: resp.requestOptions,
            error: err,
          ));
        }
      },
      onError: (e) async {
        try {
          await _closeAndDelete();
        } finally {
          completer.completeError(DioError(
            requestOptions: resp.requestOptions,
            error: e,
          ));
        }
      },
      cancelOnError: true,
    );

    // ignore: unawaited_futures
    cancelToken?.whenCancel.then((_) async {
      await subscription.cancel();
      await _closeAndDelete();
    });

    if (resp.requestOptions.receiveTimeout != null &&
        resp.requestOptions.receiveTimeout!
                .compareTo(Duration(milliseconds: 0)) >
            0) {
      future = future
          .timeout(resp.requestOptions.receiveTimeout!)
          .catchError((Object err) async {
        await subscription.cancel();
        await _closeAndDelete();
        if (err is TimeoutException) {
          throw DioError(
            requestOptions: resp.requestOptions,
            error:
                'Receiving data timeout[${resp.requestOptions.receiveTimeout}ms]',
            type: DioErrorType.receiveTimeout,
          );
        } else {
          throw err;
        }
      });
    }
    await DioMixin.listenCancelForAsyncTask(cancelToken, future);
  }

  /// write a file with bytes
  Future<void> wdWriteWithBytes(
    Client self,
    String path,
    Uint8List data, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // fix auth error
    var pResp = await this.wdOptions(self, path, cancelToken: cancelToken);
    if (pResp.statusCode != 200) {
      throw newResponseError(pResp);
    }

    // mkdir
    await this._createParent(self, path, cancelToken: cancelToken);

    var resp = await this.req(
      self,
      'PUT',
      path,
      data: Stream.fromIterable(data.map((e) => [e])),
      optionsHandler: (options) =>
          options.headers?['content-length'] = data.length,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
    var status = resp.statusCode;
    if (status == 200 || status == 201 || status == 204) {
      return;
    }
    throw newResponseError(resp);
  }

  /// write a file with stream
  Future<void> wdWriteWithStream(
    Client self,
    String path,
    Stream<List<int>> data,
    int length, {
    void Function(int count, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // fix auth error
    var pResp = await this.wdOptions(self, path, cancelToken: cancelToken);
    if (pResp.statusCode != 200) {
      throw newResponseError(pResp);
    }

    // mkdir
    await this._createParent(self, path, cancelToken: cancelToken);

    var resp = await this.req(
      self,
      'PUT',
      path,
      data: data,
      optionsHandler: (options) => options.headers?['content-length'] = length,
      onSendProgress: onProgress,
      cancelToken: cancelToken,
    );
    var status = resp.statusCode;
    if (status == 200 || status == 201 || status == 204) {
      return;
    }
    throw newResponseError(resp);
  }
}
