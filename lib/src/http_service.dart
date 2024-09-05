import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:request_mate/src/models/response_models.dart';

class HttpService {
  static final Dio _dio = Dio();
  static String? _basePath;
  static Future<bool> Function()? preCheckFn;
  static bool usePreCheckFnHttpCalls = false;
  static bool showAPILogs = false;
  HttpService._();

  // Main request method
  static Future<dynamic> request(
      String method,
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
        bool? usePreCheckFn,
      }) async {
    final fullUrl = _buildFullUrl(endPoint, basePathOverride);

    // Log request details before making the call
    showLog({
      'method': method,
      'url': fullUrl,
      'headers': headers,
      'queryParams': queryParams,
      'data': data,
    }, logName: 'Request', showLog: true);

    // Run preCheckFn if enabled
    await checkPreFunction(usePreCheckFn);

    headers = headers ?? {};
    if (token.isNotEmpty) {
      headers['Authorization'] = '$tokenType $token';
    }

    try {
      final response = await _dio.request(
        fullUrl,
        data: data,
        queryParameters: queryParams,
        options: options?.copyWith(method: method, headers: headers) ?? Options(method: method, headers: headers),
        cancelToken: cancelToken,
      );

      // Log response details after the call
      showLog(response.data, logName: 'Response', showLog: true);

      if (useDefaultResponse) {
        if (response.data is String) {
          // Decode the string into JSON
          final decodedData = jsonDecode(response.data);
          return ApiResponse.fromJson(decodedData);
        } else if (response.data is Map<String, dynamic>) {
          return ApiResponse.fromJson(response.data);
        } else {
          // In case the response is in an unexpected format
          return ApiResponse(success: false, message: 'Unexpected response format');
        }
      } else {
        // Return the raw response data if not using the default ApiResponse
        return response.data;
      }
    } catch (e) {
      throw _handleError(e);
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
        String tokenType = 'Bearer',
        bool useDefaultResponse = true,
        required String token,
        bool? usePreCheckFn,
      }) {
    return request(
      'GET',
      endPoint,
      basePathOverride: basePathOverride,
      headers: headers,
      queryParams: queryParams,
      cancelToken: cancelToken,
      options: options,
      useDefaultResponse: useDefaultResponse,
      token: token,
      tokenType: tokenType,
      usePreCheckFn: usePreCheckFn,
    );
  }

  // Other methods for POST, PUT, PATCH, DELETE, etc., would follow the same pattern as `get`

  // Create a cancel token for canceling requests
  static CancelToken createCancelToken() => CancelToken();

  // Cancel a request using the provided token
  static void cancelRequest(CancelToken token) => token.cancel('Request canceled');

  // Build full URL by adding basePath if provided
  static String _buildFullUrl(String endPoint, [String? basePathOverride]) {
    final basePath = basePathOverride ?? _basePath;
    if (basePath != null) {
      return '$basePath$endPoint';
    }
    return endPoint;
  }

  // Handle errors
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

  static Future checkPreFunction(usePreCheckFn) async {
    if (preCheckFn != null && (usePreCheckFn ?? usePreCheckFnHttpCalls)) {
      final shouldProceed = await preCheckFn!();
      if (!shouldProceed) {
        return ApiResponse(success: false, message: "Pre-check failed, request aborted");
      }
    }
  }

  static void showLog(
      data, {
        bool? showLog,
        bool enableJsonEncode = true,
        bool showPrint = false,
        required String logName,
      }) {
    try {
      if (showAPILogs ?? showLog ?? kDebugMode) {
        showPrint
            ? debugPrint(data.toString())
            : log(
          enableJsonEncode ? jsonEncode(data) : data.toString(),
          time: DateTime.timestamp(),
          name: 'HttpCalls => $logName',
        );
      }
    } catch (e) {
      log('Exception while logging', time: DateTime.timestamp());
    }
  }
}
