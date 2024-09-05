class ApiResponse<T> {
  final bool success;
  final String? message;
  final String? errorMessage;
  final dynamic statusCode;
  final dynamic data;

  ApiResponse({
    required this.success,
    this.message,
    this.errorMessage,
    this.statusCode,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? json['Message'] ?? json['MESSAGE'] ?? ['Message'],
      errorMessage: json['errorMessage'] ?? json['ErrorMessage'],
      data: json['data'] ?? json['response'] ?? json['DATA'] ?? json['RESPONSE'],
      statusCode : json['status_code'] ?? json['statusCode'] ?? json['StatusCode'] ?? json['STATUSCODE'],
    );
  }
}