import 'package:dio/dio.dart';
import 'package:curl_logger_dio_interceptor/curl_logger_dio_interceptor.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'dart:io';

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
        baseUrl: Env.data.apiBaseUrl + '/${UrlConstants.apiV4}',
        validateStatus: (status) => status! < 500,
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

    if (Env.dataUrlv4.contains(url)) {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    } else {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    }
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

    if (Env.dataUrlv4.contains(url)) {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    } else {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
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

    if (Env.dataUrlv4.contains(url)) {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    } else {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    }

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
              type: DioErrorType.connectTimeout,
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

    var newurl = url.split('?');
    if (Env.dataUrlv4.contains(newurl[0])) {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    } else {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    }

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
              type: DioErrorType.connectTimeout,
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

    if (Env.dataUrlv4.contains(url)) {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    } else {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    }

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
              type: DioErrorType.connectTimeout,
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

    if (Env.dataUrlv4.contains(url)) {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV3}';
    } else {
      _dio.options.baseUrl = Env.data.apiBaseUrl + '/${UrlConstants.apiV2}';
    }

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
              type: DioErrorType.connectTimeout,
              requestOptions: RequestOptions(path: url),
            ),
          );
      return _response;
    } on DioError {
      rethrow;
    }
  }
}
