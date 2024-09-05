import 'package:dio/dio.dart';
import 'dart:convert';

import 'package:request_mate/src/models/response_models.dart';

class HttpService {
  final Dio _dio;
  final String? _basePath;

  HttpService({
    String? basePath,
    BaseOptions? options,
    List<Interceptor>? interceptors,
  })  : _basePath = basePath,
        _dio = Dio(options) {
    if (interceptors != null && interceptors.isNotEmpty) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  Future<dynamic> request(
      String method,
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        dynamic data,
        CancelToken? cancelToken,
        Options? options,
        bool useDefaultResponse = true,
      }) async {
    final fullUrl = _buildFullUrl(endPoint, basePathOverride);

    try {
      final response = await _dio.request(
        fullUrl,
        data: data,
        queryParameters: queryParams,
        options: options?.copyWith(method: method, headers: headers) ?? Options(method: method, headers: headers),
        cancelToken: cancelToken,
      );

      if (useDefaultResponse) {
        if (response.data is String) {
          final decodedData = jsonDecode(response.data);
          return ApiResponse.fromJson(decodedData);
        } else if (response.data is Map<String, dynamic>) {
          return ApiResponse.fromJson(response.data);
        } else {
          return ApiResponse(success: false, message: 'Unexpected response format');
        }
      } else {
        return response.data;
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> get(
      String endPoint, {
        String? basePathOverride,
        Map<String, dynamic>? headers,
        Map<String, dynamic>? queryParams,
        CancelToken? cancelToken,
        Options? options,
        bool useDefaultResponse = true,
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
    );
  }

  CancelToken createCancelToken() => CancelToken();

  void cancelRequest(CancelToken token) => token.cancel('Request canceled');

  String _buildFullUrl(String endPoint, [String? basePathOverride]) {
    final basePath = basePathOverride ?? _basePath;
    if (basePath != null) {
      return '$basePath$endPoint';
    }
    return endPoint;
  }

  Exception _handleError(dynamic error) {
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
