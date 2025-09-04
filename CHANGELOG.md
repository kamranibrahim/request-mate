# Changelog

All notable changes to the `request_mate` package will be documented here.

## [0.0.1-beta.1] - Initial Beta Release
### Added
- Basic HTTP client built on top of **Dio**.
- Support for HTTP methods: `GET`, `POST`, `PUT`, `PATCH`, and `DELETE`.
- Enum `RequestMateType` to standardize request method usage.
- Multipart request support (kept separate from normal requests).
- Global configuration setup in `request_mate.dart`:
    - Base URL
    - Default headers (including token)
    - Logging mechanism for requests and responses
    - Toggle for enabling/disabling logs
- Auto JSON decoding of API responses.
- `ApiResponse` model for standardized responses when `useDefaultResponse` is enabled.
- Support for custom response mapping using `fromJson`.
- Token management:
    - Token automatically included in every request.
    - JWT token expiry decoding support.
- Utility functions in `network_utils.dart`.
- Error handling via `exceptions.dart`.
- Interceptor support via `custom_interceptors.dart`.

