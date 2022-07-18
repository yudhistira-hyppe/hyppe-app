import 'package:dio/dio.dart';
import 'package:hyppe/core/config/env.dart';
import 'package:hyppe/core/config/url_constants.dart';
import 'package:hyppe/core/constants/status_code.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

class ApiAction {
  late Dio _dio;

  ApiAction() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Env.data.apiBaseUrl + '/${UrlConstants.apiV2}',
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
    if (url == UrlConstants.signUp || url == UrlConstants.verifyAccount) {
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
    if (url == UrlConstants.signUp || url == UrlConstants.verifyAccount) {
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
    String contentType = 'application/json',
  }) async {
    Map<String, dynamic> _headers = <String, dynamic>{};
    if (headers != null) headers.forEach((k, v) => _headers[k] = v);
    if (token != null) _headers['x-auth-token'] = token;
    _headers['Content-Type'] = contentType;

    if (url == UrlConstants.signUp || url == UrlConstants.verifyAccount || url == UrlConstants.getSearchPeople) {
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
    if (url == UrlConstants.signUp || url == UrlConstants.verifyAccount) {
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
    if (url == UrlConstants.signUp || url == UrlConstants.verifyAccount) {
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
    if (url == UrlConstants.signUp || url == UrlConstants.verifyAccount) {
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
