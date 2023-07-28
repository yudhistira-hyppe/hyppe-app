import 'package:dio/dio.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/shared_preference_keys.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'dart:io';

import 'package:hyppe/core/services/shared_preference.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class ApiAction {
  late Dio _dio;

  ApiAction() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.data.apiBaseUrl + Env.data.versionApi,
        validateStatus: (status) => (status ?? 0) < 500,
      ),
    );

    if (!kReleaseMode) {
      _dio.interceptors.add(LogInterceptor(
        error: true,
        request: true,
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      ));
      // _dio.interceptors.add(CurlLoggerDioInte?rceptor(printOnSuccess: true));
      _dio.interceptors.add(HttpFormatter());
    }
  }

  Future<Response> postUploadProfile(
    String url, {
    dynamic data,
    String? token,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    responseType = ResponseType.json,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Map<String, dynamic> _headers = <String, dynamic>{};
    if (headers != null) headers.forEach((k, v) => _headers[k] = v);
    if (token != null) _headers['x-auth-token'] = token;

    // if (Env.dataUrlv4.contains(url)) {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    // } else {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    // }
    // if (Env.data.debug == true) {
    //   var sessionEndPoint = SharedPreference().readStorage(SpKeys.endPointTest);
    //   if (sessionEndPoint != null) {
    //     _dio.options.baseUrl = sessionEndPoint;
    //   }
    // }

    try {
      final _response = await _dio.post(
        url,
        options: Options(
          headers: _headers,
          responseType: responseType,
        ),
        data: data,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> postUploadContent(
    String url, {
    data,
    String? token,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    responseType = ResponseType.json,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    Map<String, dynamic> _headers = <String, dynamic>{};
    if (headers != null) headers.forEach((k, v) => _headers[k] = v);
    if (token != null) _headers['x-auth-token'] = token;

    // if (Env.data.debug == true) {
    //   var sessionEndPoint = SharedPreference().readStorage(SpKeys.endPointTest);
    //   if (sessionEndPoint != null) {
    //     _dio.options.baseUrl = sessionEndPoint;
    //   }
    // }

    if (url == UrlConstants.createuserposts) {
      if (Env.data.debug == true) {
        var sessionEndPoint = SharedPreference().readStorage(SpKeys.endPointTest);
        if (sessionEndPoint != null) {
          _dio.options.baseUrl = sessionEndPoint;
        }
        url = UrlConstants.stagingUploadBaseApi + Env.data.versionApi + UrlConstants.createuserposts;
      } else {
        // url = UrlConstants.stagingUploadBaseApi + Env.data.versionApi + UrlConstants.createuserposts;
        url = UrlConstants.productionUploadBaseApi + Env.data.versionApi + UrlConstants.createuserposts;
      }
    }

    try {
      final _response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: _headers,
          responseType: responseType,
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return _response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> post(
    String url, {
    data,
    String? token,
    Map<String, dynamic>? headers,
    responseType = ResponseType.json,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    String contentType = 'application/json',
  }) async {
    Map<String, dynamic> _headers = <String, dynamic>{};
    if (headers != null) headers.forEach((k, v) => _headers[k] = v);
    if (token != null) _headers['x-auth-token'] = token;
    _headers['Content-Type'] = contentType;

    // if (Env.dataUrlv4.contains(url)) {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    // } else {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    // }
    // if (Env.data.debug == true) {
    //   var sessionEndPoint = SharedPreference().readStorage(SpKeys.endPointTest);
    //   if (sessionEndPoint != null) {
    //     _dio.options.baseUrl = sessionEndPoint;
    //   }
    // }

    try {
      final _response = await _dio
          .post(
            url,
            data: data,
            options: Options(
              headers: _headers,
              responseType: responseType,
            ),
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
            cancelToken: cancelToken,
          )
          .timeout(
            const Duration(seconds: TIMEOUT_DURATION),
            onTimeout: () => throw DioError(
              type: DioErrorType.connectionTimeout,
              requestOptions: RequestOptions(path: url),
            ),
          );
      return _response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> get(
    String url, {
    String? token,
    Map<String, dynamic>? headers,
    responseType = ResponseType.json,
    ProgressCallback? onReceiveProgress,
  }) async {
    Map<String, dynamic> _headers = <String, dynamic>{};
    if (headers != null) headers.forEach((k, v) => _headers[k] = v);
    if (token != null) _headers['x-auth-token'] = token;

    // var newurl = url.split('?');
    // if (Env.dataUrlv4.contains(newurl[0])) {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    // } else {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    // }

    // if (Env.data.debug == true) {
    //   var sessionEndPoint = SharedPreference().readStorage(SpKeys.endPointTest);
    //   if (sessionEndPoint != null) {
    //     _dio.options.baseUrl = sessionEndPoint;
    //   }
    // }

    try {
      final _response = await _dio
          .get(
            url,
            options: Options(
              headers: _headers,
              responseType: responseType,
            ),
            onReceiveProgress: onReceiveProgress,
          )
          .timeout(
            const Duration(seconds: TIMEOUT_DURATION),
            onTimeout: () => throw DioError(
              type: DioErrorType.connectionTimeout,
              requestOptions: RequestOptions(path: url),
            ),
          );
      return _response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> delete(
    String url, {
    data,
    String? token,
    Map<String, dynamic>? headers,
    responseType = ResponseType.json,
    Map<String, dynamic>? queryParams,
    String contentType = 'application/json',
  }) async {
    Map<String, dynamic> _headers = <String, dynamic>{};

    if (headers != null) headers.forEach((k, v) => _headers[k] = v);
    if (token != null) _headers['x-auth-token'] = token;
    _headers['Content-Type'] = contentType;

    // if (Env.dataUrlv4.contains(url)) {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    // } else {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    // }
    // if (Env.data.debug == true) {
    //   var sessionEndPoint = SharedPreference().readStorage(SpKeys.endPointTest);
    //   if (sessionEndPoint != null) {
    //     _dio.options.baseUrl = sessionEndPoint;
    //   }
    // }

    try {
      final _response = await _dio
          .delete(
            url,
            data: data,
            options: Options(
              headers: _headers,
              responseType: responseType,
            ),
          )
          .timeout(
            const Duration(seconds: TIMEOUT_DURATION),
            onTimeout: () => throw DioError(
              type: DioErrorType.connectionTimeout,
              requestOptions: RequestOptions(path: url),
            ),
          );
      return _response;
    } on DioError {
      rethrow;
    }
  }

  Future<Response> download(
    String url,
    String path, {
    String? token,
    Map<String, dynamic>? headers,
    responseType = ResponseType.json,
    ProgressCallback? onReceiveProgress,
  }) async {
    Map<String, dynamic> _headers = <String, dynamic>{};

    if (headers != null) headers.forEach((k, v) => _headers[k] = v);
    if (token != null) _headers['x-auth-token'] = token;

    // if (Env.dataUrlv4.contains(url)) {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    // } else {
    //   _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    // }

    // if (Env.data.debug == true) {
    //   var sessionEndPoint = SharedPreference().readStorage(SpKeys.endPointTest);
    //   if (sessionEndPoint != null) {
    //     _dio.options.baseUrl = sessionEndPoint;
    //   }
    // }

    try {
      final _response = await _dio
          .download(
            url,
            path,
            options: Options(
              headers: _headers,
              responseType: responseType,
            ),
            onReceiveProgress: onReceiveProgress,
          )
          .timeout(
            const Duration(seconds: TIMEOUT_DURATION),
            onTimeout: () => throw DioError(
              type: DioErrorType.connectionTimeout,
              requestOptions: RequestOptions(path: url),
            ),
          );
      return _response;
    } on DioError {
      rethrow;
    }
  }
}
