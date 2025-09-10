library;

export 'src/http_service.dart';
export 'src/models/response_models.dart';
export 'src/utilities/network_utils.dart';
import 'package:dio/dio.dart';
import 'package:request_mate/request_mate.dart';

/// Initializes and configures the `request_mate` library.
///
/// This function sets up the global settings for the `request_mate` package,
/// including base URL, logging options, custom interceptors, and timeout settings.
/// It also optionally configures a function for token refresh if required.
///
/// **Parameters:**
///
/// - `basePath` (**required**):
///   The base URL for all API requests. This URL will be used as the prefix for all endpoint paths.
///
/// - `showLogs` (default: `false`):
///   A boolean indicating whether to enable logging for API requests and responses.
///   If set to `true`, the library will log detailed information about requests and responses.
///
/// - `customInterceptors` (default: `null`):
///   An optional list of custom `Interceptor` instances to be added to the Dio instance.
///   These interceptors can be used to modify requests and responses or handle errors.
///
/// - `connectTimeout` (default: `null`):
///   An optional integer representing the connection timeout in seconds.
///   This specifies how long to wait for a connection to be established before timing out.
///
/// - `defaultHeaders` (default: `null`):
///   An optional map of default headers to be included in all requests.
///   These headers will be merged with any headers specified in individual requests.
///
/// - `receiveTimeout` (default: `null`):
///   An optional integer representing the receive timeout in seconds.
///   This specifies how long to wait for a response from the server before timing out.
///
/// - `tokenCheckAndRefreshFn` (default: `null`):
///   An optional function that checks if the token needs to be refreshed and returns a new token.
///   This function will be used to refresh the authentication token if it's expired or invalid.
///
/// **Usage Example:**
///
/// ```dart
/// setupRequestMate(
///   basePath: 'https://api.example.com/',
///   showLogs: true,
///   customInterceptors: [CustomInterceptor()],
///   connectTimeout: 10,
///   defaultHeaders: {'platform': 'android'},
///   receiveTimeout: 10,
///   tokenCheckAndRefreshFn: () async {
///     // Logic to refresh token
///     return 'new-token';
///   },
/// );
/// ```
///
/// In this example, the `setupRequestMate` function configures the `request_mate` package
/// with a base URL, enables logging, adds a custom interceptor, sets timeouts,
/// and provides a function for token refresh.
///
/// **Note:**
/// Ensure that the `basePath` parameter is set correctly to match the API endpoints you intend to interact with.
/// If you do not need to set custom interceptors or handle token refresh, you can omit those parameters.

void setupRequestMate({
  required String basePath,
  bool showLogs = false,
  List<Interceptor>? customInterceptors,
  int? connectTimeout,
  Map<String, dynamic>? defaultHeaders,
  int? receiveTimeout,
  Future<String> Function()? tokenCheckAndRefreshFn,
}) {
  if (customInterceptors != null) {
    for (var interceptor in customInterceptors) {
      HttpService.addInterceptor(interceptor);
    }
  }

  HttpService.configure(
    basePath: basePath,
    showLogs: showLogs,
    connectTimeout: connectTimeout,
    defaultHeaders: defaultHeaders,
    receiveTimeout: receiveTimeout,
    tokenCheckAndRefreshFn: tokenCheckAndRefreshFn,
  );
}
