import 'package:flutter/foundation.dart';

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

  static bool parseBoolCaseInsensitive(Map<String, dynamic> json) {
    final lowerMap = {
      for (final entry in json.entries)
        entry.key.toLowerCase(): entry.value
    };

    final value = lowerMap['status'] ?? lowerMap['success'];

    return value == true || value == 1 || value == "true";
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    String? message;
    try{
      message = json['message'] ?? json['Message'] ?? json['MESSAGE'] ?? ['Message'];
    }catch(e){
      debugPrint('Error parsing "message": $e');
    }
    return ApiResponse<T>(
      success: parseBoolCaseInsensitive(json),
      message: message,
      errorMessage:
          json['errorMessage'] ?? json['ErrorMessage'] ?? json['error_message'],
      data:
          json['data'] ?? json['response'] ?? json['DATA'] ?? json['RESPONSE'],
      statusCode: json['status_code'] ??
          json['statusCode'] ??
          json['StatusCode'] ??
          json['STATUSCODE'],
    );
  }
}
