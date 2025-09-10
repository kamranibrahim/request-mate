
# RequestMate

`RequestMate` is a lightweight yet powerful HTTP client for Flutter/Dart, built on top of the **Dio** package. It simplifies networking with a clean API for standard requests (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`) and multipart uploads, while offering global configuration, token management, request cancellation, and interceptor support.

---

## ✨ Features

* Easy-to-use HTTP requests (`GET`, `POST`, `PUT`, `PATCH`, `DELETE`).
* Multipart file upload support.
* Global configuration for base URL, headers, and timeouts.
* Token management with automatic refresh support.
* Request cancellation with `CancelToken`.
* Built-in and custom logging for requests and responses.
* Customizable error handling with a standard `ApiResponse` format.
* Support for custom Dio interceptors.

---

## 🚀 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  request_mate: ^0.0.1-beta.3
```

Then install:

```bash
flutter pub get
```

---

## 🛠 Usage

### 1. Global Configuration

Configure `RequestMate` once before making requests:

```dart
import 'package:request_mate/request_mate.dart';

void main() {
  RequestMate.configure(
    basePath: 'https://api.example.com/',
    defaultHeaders: {
      'Content-Type': 'application/json',
    },
    tokenCheckAndRefreshFn: () async {
      // Logic to refresh token
      return 'new_token';
    },
    showLogs: true,
    connectTimeout: 10,  // in seconds
    receiveTimeout: 10,  // in seconds
  );

  // Continue app initialization...
}
```

---

### 2. GET Request

```dart
Future<void> fetchData() async {
  final response = await HttpService.request(
    RequestMateType.get,
    '/data-endpoint',
    token: 'your_token',
  );

  if (response.success) {
    print('Data: ${response.data}');
  } else {
    print('Error: ${response.errorMessage}');
  }
}
```

---

### 3. POST Request with Data

```dart
Future<void> createData() async {
  final response = await HttpService.request(
    RequestMateType.post,
    '/create-endpoint',
    data: {
      'name': 'John Doe',
      'age': 30,
    },
    token: 'your_token',
  );

  if (response.success) {
    print('Created: ${response.data}');
  } else {
    print('Error: ${response.errorMessage}');
  }
}
```

---

### 4. Multipart Upload

```dart
import 'dart:io';

Future<void> uploadFile(File file) async {
  final response = await HttpService.multipartRequest(
    '/upload-endpoint',
    files: {'file': file},
    bodyParams: {'description': 'My file upload'},
    token: 'your_token',
  );

  if (response.success) {
    print('Upload successful: ${response.data}');
  } else {
    print('Error: ${response.errorMessage}');
  }
}
```

---

### 5. Cancel a Request

```dart
import 'package:dio/dio.dart';

CancelToken cancelToken = CancelToken();

Future<void> fetchDataWithCancel() async {
  try {
    final response = await HttpService.request(
      RequestMateType.get,
      '/data-endpoint',
      token: 'your_token',
      cancelToken: cancelToken,
    );
    print('Data: ${response.data}');
  } catch (e) {
    print('Request was canceled');
  }
}

// Cancel when needed
cancelToken.cancel('Request canceled by the user.');
```

---

### 6. Using Custom Interceptors

You can register Dio interceptors globally when configuring `RequestMate`:

```dart
import 'package:dio/dio.dart';

void main() {
  setupRequestMate(
    basePath: 'https://api.example.com/',
    customInterceptors: [
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('➡️ Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ Error: ${e.message}');
          return handler.next(e);
        },
      ),
    ],
  );
}
```

**Use cases for interceptors:**

* Add/modify headers (e.g., tokens, localization).
* Implement global error handling (e.g., redirect on 401).
* Add retry logic with exponential backoff.
* Customize logging beyond the built-in logger.

---

## ⚙️ Advanced Configuration

* **Token refresh function:**
  Automatically called before requests to keep tokens valid.

  ```dart
  RequestMate.configure(
    tokenCheckAndRefreshFn: () async {
      return 'new_token';
    },
  );
  ```

* **Logging:**
  Enable or disable request/response logs.

  ```dart
  showLogs: true,
  ```

---

## 🛡 Error Handling

All responses are wrapped in an `ApiResponse`:

```dart
ApiResponse({
  required bool success,
  dynamic data,
  String? errorMessage,
  int? statusCode,
});
```

This makes it simple to check success and handle errors consistently.

---

## 🤝 Contributing

Contributions are welcome! Open issues or submit pull requests for features, fixes, or improvements.

---

## 📄 License

Licensed under the [MIT License](LICENSE).
You are free to use, modify, and distribute this package.

---
