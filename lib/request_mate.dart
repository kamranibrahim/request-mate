import 'package:dio/dio.dart';
import 'package:request_mate/src/http_service.dart';

class RequestMate {
  static void initialize({
    required String basePath,
    bool showLogs = false,
    List<Interceptor>? customInterceptors,
    int? connectTimeout,
    Map<String, dynamic>? defaultHeaders,
    int? receiveTimeout,
    Future<String> Function()? tokenCheckAndRefreshFn,
  }) {
    // Initialize HttpService

    if (customInterceptors != null) {
      for (var interceptor in customInterceptors) {
        HttpService.addInterceptor(interceptor);
      }
    }

    // Set other configurations
    HttpService.configure(
      basePath: basePath,
      showLogs: showLogs,
      connectTimeout: connectTimeout,
      defaultHeaders: defaultHeaders,
      receiveTimeout: receiveTimeout,
      tokenCheckAndRefreshFn: tokenCheckAndRefreshFn,
    );
  }
}
