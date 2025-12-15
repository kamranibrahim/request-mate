import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CustomInterceptor extends Interceptor {
  final bool showAPILogs;

  CustomInterceptor({required this.showAPILogs});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final bool shouldLog = showAPILogs || kDebugMode;


    if (shouldLog) {
      log("--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}",
          name: 'HttpRequest');
      log("Headers: ${options.headers}", name: 'HttpRequest');
      final data = options.data;
      if(data is FormData && data.files.isNotEmpty){
        log("FormData files:", name: 'HttpRequest');
        for (final file in data.files) {
          log(
            "  ${file.key}: ${file.value.filename}",
            name: 'HttpRequest',
          );
        }
      } else if (options.data != null) {
        log("Request Body: ${jsonEncode(options.data)}", name: 'HttpRequest');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final bool shouldLog = showAPILogs || kDebugMode;

    if (shouldLog) {
      log("<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}",
          name: 'HttpResponse');
      log("Response: ${jsonEncode(response.data)}", name: 'HttpResponse');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final bool shouldLog = showAPILogs || kDebugMode;

    if (shouldLog) {
      log("<-- ERROR ${err.response?.statusCode ?? 'Unknown'}",
          name: 'HttpError');
      if (err.response != null && err.response?.data != null) {
        log("Error Response: ${jsonEncode(err.response?.data)}",
            name: 'HttpError');
      }
    }
    handler.next(err);
  }
}
