import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:request_mate/src/interceptors/custom_interceptors.dart';
import 'package:request_mate/src/models/response_models.dart';
import 'package:request_mate/src/utilities/network_utils.dart';

/// A class for handling HTTP requests using the Dio package.
///
/// This class provides methods to configure global settings for HTTP requests,
/// add interceptors, make requests, and handle errors.
class HttpService {
  static final Dio _dio = Dio();
  static String? _basePath;
  static Map<String, dynamic> _defaultHeaders = {};
  static bool? _showAPILogs;
  static Future<String> Function()? _tokenRefreshFn;

  /// Initializes the service with default interceptors.
  ///
  /// Adds the `CustomInterceptor` to the Dio instance.
  static void initialize() {
    addInterceptor(CustomInterceptor(showAPILogs: _showAPILogs ?? false));
  }

  /// Adds an interceptor to the Dio instance.
  ///
  /// [interceptor] The interceptor to be added.
  static void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Clears all interceptors from the Dio instance.
  static void clearInterceptors() {
    _dio.interceptors.clear();
  }

  /// Configures global settings for HTTP requests.
  ///
  /// [basePath] The base URL for all API requests.
  /// [defaultHeaders] Optional default headers for all requests.
  /// [tokenCheckAndRefreshFn] Optional function for refreshing tokens.
  /// [showLogs] Whether to enable logging for API requests and responses.
  /// [connectTimeout] Connection timeout in seconds.
  /// [receiveTimeout] Receive timeout in seconds.
  static void configure({
    required String basePath,
    Map<String, dynamic>? defaultHeaders,
    Future<String> Function()? tokenCheckAndRefreshFn,
    bool showLogs = false,
    int? connectTimeout,
    int? receiveTimeout,
  }) {
    _basePath = basePath;
    _defaultHeaders = defaultHeaders ?? {};
    _tokenRefreshFn = tokenCheckAndRefreshFn;
    _showAPILogs = showLogs;

    _dio.options.connectTimeout = Duration(seconds: connectTimeout ?? 8);
    _dio.options.receiveTimeout = Duration(seconds: receiveTimeout ?? 8);

    initialize();
  }

  /// Sends an HTTP request.
  ///
  /// [methodType] The HTTP method to use (e.g., GET, POST).
  /// [endPoint] The endpoint for the request.
  /// [basePathOverride] Optional override for the base path.
  /// [additionalHeaders] Optional additional headers for the request.
  /// [queryParams] Optional query parameters for the request.
  /// [data] Optional request body data.
  /// [cancelToken] Optional token for canceling the request.
  /// [options] Optional additional Dio request options.
  /// [token] The authorization token for the request.
  /// [tokenType] The type of the token (default: 'Bearer').
  /// [useDefaultResponse] Whether to use the default response handling.
  /// [useTokenExpireFn] Whether to use the token expiration function.
  /// [useTokenRefreshFn] Whether to use the token refresh function.
  /// [showLogs] Whether to show logs for this request.
  ///
  /// Returns the response data or an error.
  static Future<dynamic> request(
      RequestMateType methodType,
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? additionalHeaders,
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

    additionalHeaders = await _buildHeaders(additionalHeaders, token, useTokenRefreshFn, tokenType);

    try {
      final response = await _dio.request(
        fullUrl,
        data: data,
        queryParameters: queryParams,
        options: options?.copyWith(method: methodType.value, headers: additionalHeaders)
            ?? Options(
              method: methodType.value,
              headers: additionalHeaders,
            ),
        cancelToken: cancelToken,
      );

      if (useDefaultResponse) {
        return _decodeResponse(response.data);
      } else {
        return response.data;
      }
    }  catch (e) {
      return _handleError(e, useDefaultResponse: useDefaultResponse);
    }
  }

  /// Sends a multipart HTTP request.
  ///
  /// [endPoint] The endpoint for the request.
  /// [files] Map of file paths to upload.
  /// [bodyParams] Map of body parameters.
  /// [filesKey] Optional key for the files.
  /// [basePathOverride] Optional override for the base path.
  /// [headers] Optional headers for the request.
  /// [queryParams] Optional query parameters for the request.
  /// [cancelToken] Optional token for canceling the request.
  /// [options] Optional additional Dio request options.
  /// [token] The authorization token for the request.
  /// [tokenType] The type of the token (default: 'Bearer').
  /// [useDefaultResponse] Whether to use the default response handling.
  /// [useTokenExpireFn] Whether to use the token expiration function.
  /// [useTokenRefreshFn] Whether to use the token refresh function.
  /// [showLogs] Whether to show logs for this request.
  /// [method] The HTTP method to use (default: POST).
  ///
  /// Returns the response data or an error.
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
        RequestMateType method = RequestMateType.post,
      }) async {
    final fullUrl = _buildFullUrl(endPoint, basePathOverride);

    headers = await _buildHeaders(headers, token, useTokenRefreshFn , tokenType);

    final formData = FormData();

    if(bodyParams.isNotEmpty) {
      bodyParams.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }
    if(files.isNotEmpty) {
      if(files.isNotEmpty) {
        for (final entry in files.entries) {
          final file = entry.value;
          if (!await file.exists()) {
            throw Exception("File ${file.path} does not exist");
          }

          final fileSize = await file.length();
          if (fileSize > 5 * 1024 * 1024) {
            final length = fileSize;

            formData.files.add(
              MapEntry(
                entry.key,
                MultipartFile.fromStream(
                  ()=> file.openRead(),
                  length,
                  filename: file.uri.pathSegments.last,
                ),
              ),
            );
          } else {
            formData.files.add(
              MapEntry(
                entry.key,
                await MultipartFile.fromFile(
                    file.path,
                    filename: file.uri.pathSegments.last
                ),
              ),
            );
          }
        }
      }
    }

    try {
      final response = await _dio.request(
        fullUrl,
        data: formData,
        queryParameters: queryParams,
        options: options?.copyWith(
          method: method.value,
          headers: headers,
        ) ?? Options(method: method.value, headers: headers),
        cancelToken: cancelToken,
      );

      if (useDefaultResponse) {
        return _decodeResponse(response.data);
      } else {
        return response.data;
      }
    } catch (e) {
      return _handleError(e, useDefaultResponse: useDefaultResponse);
    }
  }

  /// Refreshes the authorization token.
  ///
  /// [token] The current token to be refreshed.
  ///
  /// Returns the new token.
  static Future<String> _refreshToken(String token) async {
    if (_tokenRefreshFn == null) return token;
    return await _tokenRefreshFn!();
  }

  /// Builds the headers for a request.
  ///
  /// [headers] Optional additional headers for the request.
  /// [token] The authorization token.
  /// [useTokenRefresh] Whether to use the token refresh function.
  /// [tokenType] The type of the token (e.g., 'Bearer').
  ///
  /// Returns a map of headers.
  static Future<Map<String, dynamic>> _buildHeaders(
      Map<String, dynamic>? headers,
      String token,
      bool useTokenRefresh,
      String tokenType,) async {

    final builtHeaders = Map<String, dynamic>.from(_defaultHeaders);
    if (headers != null) {
      builtHeaders.addAll(Map<String, dynamic>.from(headers));
    }
    if (token.isNotEmpty) {
      try {
        if (useTokenRefresh && _tokenRefreshFn != null) {
          token = await _refreshToken(token);
        }
      } catch (_) {
        debugPrint("Token refresh failed, proceeding with existing token");
      }
    }
    if (token.isNotEmpty) {
      builtHeaders['Authorization'] = '$tokenType $token';
    }
    return builtHeaders;
  }

  /// Decodes the response data.
  ///
  /// [data] The response data to be decoded.
  ///
  /// Returns a [ApiResponse] or the raw data
  static dynamic _decodeResponse(dynamic data) {
    if (data is String) {
      return ApiResponse.fromJson(jsonDecode(data));
    } else if (data is Map<String, dynamic>) {
      return ApiResponse.fromJson(data);
    } else {
      return ApiResponse(success: false, message: 'Unexpected response format');
    }
  }

  /// Cancels a request.
  ///
  /// [token] The token used to cancel the request.
  static void cancelRequest(CancelToken token) => token.cancel('Request canceled');

  /// Builds the full URL for a request.
  ///
  /// [endPoint] The endpoint for the request.
  /// [basePathOverride] Optional override for the base path.
  ///
  /// Returns the full URL.
  static String _buildFullUrl(String endPoint, [String? basePathOverride]) {
    final basePath = basePathOverride ?? _basePath;
    if (basePath != null) {
      return '$basePath$endPoint';
    }
    return endPoint;
  }

  /// Handles errors that occur during requests.
  ///
  /// [error] The error that occurred.
  /// [useDefaultResponse] Whether to use the default response format for errors.
  ///
  /// Returns an [ApiResponse] or a raw error object.
  static dynamic _handleError(dynamic error, {bool useDefaultResponse = true}) {
    String errorMessage;
    int? statusCode;

    if (error is DioException) {
      statusCode = error.response?.statusCode;
      switch (error.type) {
        case DioExceptionType.cancel:
          errorMessage = "Request to API server was cancelled";
          break;
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = "Connection timeout with API server";
          break;
        case DioExceptionType.badResponse:
          errorMessage = "Received invalid status code: ${error.response?.statusCode}";
          break;
        case DioExceptionType.unknown:
          errorMessage = "Connection to API server failed due to internet connection";
          break;
        default:
          errorMessage = "Something went wrong";
          break;
      }
    } else {
      errorMessage = "Unexpected error occurred";
    }

    if (useDefaultResponse) {
      return ApiResponse(
        success: false,
        errorMessage: errorMessage,
        statusCode: statusCode,
      );
    } else {
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': statusCode,
      };
    }
  }
}
