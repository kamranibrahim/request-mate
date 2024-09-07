import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:request_mate/src/interceptors/custom_interceptors.dart';
import 'package:request_mate/src/models/response_models.dart';
import 'package:request_mate/src/utilities/network_utils.dart';

class HttpService {
  static final Dio _dio = Dio();
  static String? _basePath;
  static Map<String, dynamic> _defaultHeaders = {};
  static bool usePreCheckFnHttpCalls = false;
  static bool? _showAPILogs;
  static Future<String> Function()? _tokenRefreshFn;

  // Initialize with interceptors
  static void initialize() {
    addInterceptor(CustomInterceptor(showAPILogs: _showAPILogs ?? false));
  }

  // Method to add an interceptor
  static void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  // Method to clear all interceptors
  static void clearInterceptors() {
    _dio.interceptors.clear();
  }

  // Setup method to configure global settings
  static void configure({
    required String basePath,
    Map<String, dynamic>? defaultHeaders,
    /// check expiry token, call your refresh token and return new token
    Future<String> Function()? tokenCheckAndRefreshFn,
    bool showLogs = false,
    /// connectTimeout in seconds
    int? connectTimeout,
    /// receiveTimeout in seconds
    int? receiveTimeout,
  }) {
    _basePath = basePath;
    _defaultHeaders = defaultHeaders ?? {};
    _tokenRefreshFn = tokenCheckAndRefreshFn;
    _showAPILogs = showLogs;

    _dio.options.connectTimeout = Duration(seconds: connectTimeout ?? 5);
    _dio.options.receiveTimeout = Duration(seconds: receiveTimeout ?? 5);
    initialize();
  }

  // Main request method
  static Future<dynamic> request(
      RequestMateType methodType,
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        dynamic data,
        CancelToken? cancelToken,
        Options? options,
        required String token,
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        bool? useTokenExpireFn,
        bool useTokenRefreshFn = true,
        bool? showLogs,
      }) async {
    final fullUrl = _buildFullUrl(endPoint, basePathOverride);

    headers = await _buildHeaders(headers, token, useTokenRefreshFn, tokenType);

    try {
      final response = await _dio.request(
        fullUrl,
        data: data,
        queryParameters: queryParams,
        options: options?.copyWith(method: methodType.value, headers: headers) ?? Options(method: methodType.value, headers: headers),
        cancelToken: cancelToken,
      );

      if (useDefaultResponse) {
        return _decodeResponse(response.data);
      } else {
        return response.data;
      }
    }  catch (e) {
      return _handleError(e);
    }
  }

  // GET method
  static Future<dynamic> get(
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        CancelToken? cancelToken,
        Options? options,
        required String token,
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        bool useTokenRefreshFn = true,
        bool? showLogs,
      }) async {
    return request(
      RequestMateType.get,
      endPoint,
      basePathOverride: basePathOverride,
      headers: headers,
      queryParams: queryParams,
      cancelToken: cancelToken,
      options: options,
      token: token,
      tokenType: tokenType,
      useDefaultResponse: useDefaultResponse,
      useTokenRefreshFn: useTokenRefreshFn,
      showLogs: showLogs,
    );
  }

  static Future<dynamic> post(
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        dynamic data,
        CancelToken? cancelToken,
        Options? options,
        required String token,
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        bool? useTokenExpireFn,
        bool useTokenRefreshFn = true,
        bool? showLogs,
      }) {
    return request(
      RequestMateType.post,
      endPoint,
      basePathOverride: basePathOverride,
      headers: headers,
      queryParams: queryParams,
      data: data,
      cancelToken: cancelToken,
      options: options,
      token: token,
      tokenType: tokenType,
      useDefaultResponse: useDefaultResponse,
      useTokenRefreshFn: useTokenRefreshFn,
      showLogs: showLogs,
    );
  }

  // PUT method
  static Future<dynamic> put(
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        dynamic data,
        CancelToken? cancelToken,
        Options? options,
        required String token,
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        bool? useTokenExpireFn,
        bool useTokenRefreshFn = true,
        bool? showLogs,
      }) {
    return request(
      RequestMateType.put,
      endPoint,
      basePathOverride: basePathOverride,
      headers: headers,
      queryParams: queryParams,
      data: data,
      cancelToken: cancelToken,
      options: options,
      token: token,
      tokenType: tokenType,
      useDefaultResponse: useDefaultResponse,
      useTokenRefreshFn: useTokenRefreshFn,
      showLogs: showLogs,
    );
  }

  // PATCH method
  static Future<dynamic> patch(
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        dynamic data,
        CancelToken? cancelToken,
        Options? options,
        required String token,
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        bool? useTokenExpireFn,
        bool useTokenRefreshFn = true,
        bool? showLogs,
      }) {
    return request(
      RequestMateType.patch,
      endPoint,
      basePathOverride: basePathOverride,
      headers: headers,
      queryParams: queryParams,
      data: data,
      cancelToken: cancelToken,
      options: options,
      token: token,
      tokenType: tokenType,
      useDefaultResponse: useDefaultResponse,
      useTokenRefreshFn: useTokenRefreshFn,
      showLogs: showLogs,
    );
  }

  // Multipart method
  static Future<dynamic> multipartRequest(
      String endPoint, {
        required Map<String, File> files,
        required Map<String, dynamic> bodyParams,
        String? filesKey,
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        CancelToken? cancelToken,
        Options? options,
        required String token,
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        bool? useTokenExpireFn,
        bool useTokenRefreshFn = true,
        bool? showLogs,
      }) async {
    final fullUrl = _buildFullUrl(endPoint, basePathOverride);

    if (files.isEmpty) {
      throw Exception("File list is empty");
    }

    if (bodyParams.isEmpty) {
      throw Exception("Body parameters are empty");
    }

    // Build headers
    headers = await _buildHeaders(headers, token, useTokenRefreshFn , tokenType);

    // Build FormData
    final formData = FormData();

    bodyParams.forEach((key, value) {
      formData.fields.add(MapEntry(key, value.toString()));
    });

    files.forEach((key, file) async {
      if (!await file.exists()) {
        throw Exception("File ${file.path} does not exist");
      }
      formData.files.add(MapEntry(key, await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last)));
    });

    try {
      final response = await Dio().request(
        fullUrl,
        data: formData,
        queryParameters: queryParams,
        options: options?.copyWith(
          method: 'POST',
          headers: headers,
        ) ?? Options(method: 'POST', headers: headers),
        cancelToken: cancelToken,
      );

      if (useDefaultResponse) {
        return _decodeResponse(response.data);
      } else {
        return response.data;
      }
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<dynamic> delete(
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        dynamic data,
        CancelToken? cancelToken,
        Options? options,
        required String token,
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        bool? useTokenExpireFn,
        bool useTokenRefreshFn = true,
        bool? showLogs,
      }) {
    return request(
      RequestMateType.delete,
      endPoint,
      basePathOverride: basePathOverride,
      headers: headers,
      queryParams: queryParams,
      data: data,
      cancelToken: cancelToken,
      options: options,
      token: token,
      tokenType: tokenType,
      useDefaultResponse: useDefaultResponse,
      useTokenRefreshFn: useTokenRefreshFn,
      showLogs: showLogs,
    );
  }


  static Future<String> _refreshToken(String token) async {
    if(_tokenRefreshFn == null) return token;
    final newToken = await _tokenRefreshFn!();
    return newToken;
  }

  static Future<Map<String, dynamic>> _buildHeaders(
      Map<String, dynamic>? headers,
      String token,
      bool useTokenRefresh,
      String tokenType,) async {

    final builtHeaders = Map<String, dynamic>.from(_defaultHeaders);
    if (headers != null) {
      builtHeaders.addAll(headers);
    }
    if (token.isNotEmpty && useTokenRefresh && _tokenRefreshFn != null) {
      token = await _refreshToken(token);
    }
    if (token.isNotEmpty) {
      builtHeaders['Authorization'] = '$tokenType $token';
    }
    return builtHeaders;
  }

  static dynamic _decodeResponse(dynamic data) {
    if (data is String) {
      return ApiResponse.fromJson(jsonDecode(data));
    } else if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data);
    } else {
      return ApiResponse(success: false, message: 'Unexpected response format');
    }
  }

  // Cancel a request using the provided token
  static void cancelRequest(CancelToken token) => token.cancel('Request canceled');

  static String _buildFullUrl(String endPoint, [String? basePathOverride]) {
    final basePath = basePathOverride ?? _basePath;
    if (basePath != null) {
      return '$basePath$endPoint';
    }
    return endPoint;
  }

  static Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          return Exception("Request to API server was cancelled");
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception("Connection timeout with API server");
        case DioExceptionType.badResponse:
          return Exception("Received invalid status code: ${error.response?.statusCode}");
        case DioExceptionType.unknown:
          return Exception("Connection to API server failed due to internet connection");
        default:
          return Exception("Something went wrong");
      }
    } else {
      return Exception("Unexpected error occurred");
    }
  }

}
