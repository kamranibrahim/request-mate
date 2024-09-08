
---

# RequestMate

`RequestMate` is a simple and powerful HTTP client package for Flutter/Dart applications, built on top of the Dio package. It provides a clean and flexible way to handle various types of network requests, including standard GET, POST, PATCH, PUT, DELETE, and multipart requests, with easy-to-use configurations for headers, logging, token management, and error handling.

## Features

- Simplified HTTP requests (GET, POST, PUT, PATCH, DELETE).
- Multipart file upload.
- Global configuration for base URL, headers, and timeouts.
- Token management with automatic token refresh.
- Request cancellation support.
- Customizable logging for API requests and responses.
- Error handling with customizable responses.

## Installation

Add `request_mate` to your `pubspec.yaml` file:

```yaml
dependencies:
  request_mate: ^1.0.0
```

Then, run:

```bash
flutter pub get
```

## Usage

### 1. Basic Configuration

Before making any network calls, you should configure the global settings such as the base URL, headers, and timeouts.

```dart
import 'package:request_mate/request_mate.dart';

void main() {
  RequestMate.configure(
    basePath: 'https://api.example.com/',
    defaultHeaders: {
      'Content-Type': 'application/json',
    },
    tokenCheckAndRefreshFn: () async {
      // Logic to refresh your token
      return 'new_token';
    },
    showLogs: true,
    connectTimeout: 10, // in seconds
    receiveTimeout: 10, // in seconds
  );

  // Continue with your app initialization
}
```

### 2. Making a Simple GET Request

```dart
import 'package:request_mate/request_mate.dart';

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

### 3. Making a POST Request with Data

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
    print('Created successfully: ${response.data}');
  } else {
    print('Error: ${response.errorMessage}');
  }
}
```

### 4. Uploading Files with Multipart Request

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
    print('File uploaded successfully: ${response.data}');
  } else {
    print('Error: ${response.errorMessage}');
  }
}
```

### 5. Canceling a Request

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

// Call cancel when needed
cancelToken.cancel('Request canceled by the user.');
```

## Advanced Configuration

- **Token Refresh Function:** You can provide a custom function to handle token refresh logic. This will be invoked automatically when making requests.

```dart
RequestMate.configure(
  tokenCheckAndRefreshFn: () async {
    // Refresh the token and return the new one
    return 'new_token';
  }
);
```

- **Logging:** Enable or disable logging of requests and responses globally or on a per-request basis.

```dart
showLogs: true,
```

## Error Handling

By default, `RequestMate` will return an `ApiResponse` object with the following structure:

```dart
ApiResponse({
  required bool success,
  dynamic data,
  String? errorMessage,
  int? statusCode,
});
```

You can handle errors easily by checking the `success` field and displaying the appropriate error message.

## Contributing

Contributions are welcome! If you find any bugs or have feature requests, please feel free to create an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and distribute the software, subject to the conditions laid out in the license.

---

This `README.md` provides an overview of how to use the `request_mate` package, including installation, basic configuration, usage examples, and error handling. Let me know if you need any adjustments!