/// [BaseApiClient]: a configured `Dio` with bearer auth, a loading signal and
/// logging.
library;

import 'dart:async';

import 'package:dio/dio.dart';

/// Supplies the bearer token for each request, or null when signed out.
typedef TokenProvider = FutureOr<String?> Function();

/// Receives one line of request/response logging.
typedef ApiLogger = void Function(String message);

/// Called with true when the first request starts and false when the last
/// one finishes.
typedef LoadingCallback = void Function(bool isLoading);

/// A configured [Dio] client with bearer auth, a loading signal and logging.
///
/// ```dart
/// final api = BaseApiClient(
///   baseUrl: 'https://api.example.com',
///   tokenProvider: () => BasePrefs.getString('access_token'),
///   onLoadingChanged: (busy) => busy ? showLoader() : hideLoader(),
///   logger: debugPrint,
/// );
///
/// final res = await api.get('/v1/profile');
/// final profile = Profile.fromJson(res.data as Map<String, dynamic>);
/// ```
///
/// Every method returns Dio's own [Response], so parse it with whatever model
/// layer you already have. Pass `showLoader: false` on a request that should
/// stay silent, such as background polling.
class BaseApiClient {
  /// Creates a client pointed at [baseUrl].
  ///
  /// [validateStatus] decides which status codes resolve rather than throw.
  /// The default resolves everything below 500, so 4xx bodies reach your
  /// error handling instead of surfacing as a [DioException].
  BaseApiClient({
    required String baseUrl,
    this.tokenProvider,
    this.onLoadingChanged,
    this.logger,
    Duration timeout = const Duration(seconds: 45),
    String contentType = Headers.jsonContentType,
    bool Function(int? status)? validateStatus,
    List<Interceptor> interceptors = const <Interceptor>[],
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: timeout,
           receiveTimeout: timeout,
           sendTimeout: timeout,
           contentType: contentType,
           validateStatus:
               validateStatus ?? (status) => status != null && status < 500,
         ),
       ) {
    dio.interceptors.add(_LifecycleInterceptor(this));
    dio.interceptors.addAll(interceptors);
  }

  /// The underlying client, for anything this wrapper does not expose —
  /// cancel tokens, extra interceptors, download.
  final Dio dio;

  /// Supplies the bearer token attached to each request.
  final TokenProvider? tokenProvider;

  /// Notified when the in-flight request count rises above or returns to zero.
  final LoadingCallback? onLoadingChanged;

  /// Receives request and response logging. Null disables it.
  ///
  /// Pass `debugPrint` in debug builds only — response bodies routinely
  /// contain personal data, and on Android `print` output is readable by
  /// other apps through logcat.
  final ApiLogger? logger;

  int _inFlight = 0;

  /// Sends a GET request.
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
    bool showLoader = true,
    CancelToken? cancelToken,
    void Function(int received, int total)? onReceiveProgress,
  }) async => dio.get<dynamic>(
    path,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
    onReceiveProgress: onReceiveProgress,
    options: await _options(headers, authenticated, showLoader),
  );

  /// Sends a POST request with a JSON-encodable [data] body.
  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
    bool showLoader = true,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    void Function(int received, int total)? onReceiveProgress,
  }) async => dio.post<dynamic>(
    path,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
    onSendProgress: onSendProgress,
    onReceiveProgress: onReceiveProgress,
    options: await _options(headers, authenticated, showLoader),
  );

  /// Sends a PATCH request.
  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
    bool showLoader = true,
    CancelToken? cancelToken,
  }) async => dio.patch<dynamic>(
    path,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
    options: await _options(headers, authenticated, showLoader),
  );

  /// Sends a PUT request.
  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
    bool showLoader = true,
    CancelToken? cancelToken,
  }) async => dio.put<dynamic>(
    path,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
    options: await _options(headers, authenticated, showLoader),
  );

  /// Sends a DELETE request.
  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
    bool showLoader = true,
    CancelToken? cancelToken,
  }) async => dio.delete<dynamic>(
    path,
    data: data,
    queryParameters: queryParameters,
    cancelToken: cancelToken,
    options: await _options(headers, authenticated, showLoader),
  );

  /// Uploads [data] as `multipart/form-data`.
  ///
  /// [timeout] overrides the client's send timeout for this request, which
  /// large uploads usually need.
  Future<Response<dynamic>> postFormData(
    String path, {
    required FormData data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool authenticated = true,
    bool showLoader = true,
    Duration? timeout,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    final options = await _options(headers, authenticated, showLoader);
    return dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: options.copyWith(
        contentType: Headers.multipartFormDataContentType,
        sendTimeout: timeout,
      ),
    );
  }

  Future<Options> _options(
    Map<String, dynamic>? headers,
    bool authenticated,
    bool showLoader,
  ) async {
    final merged = <String, dynamic>{...?headers};
    if (authenticated) {
      final token = await tokenProvider?.call();
      // Omit the header entirely when signed out; sending "Bearer null"
      // reads as a malformed token rather than as no token at all.
      if (token != null && token.isNotEmpty) {
        merged['Authorization'] = 'Bearer $token';
      }
    }
    return Options(
      headers: merged,
      extra: <String, dynamic>{_showLoaderKey: showLoader},
    );
  }

  void _requestStarted() {
    if (_inFlight++ == 0) {
      onLoadingChanged?.call(true);
    }
  }

  void _requestFinished() {
    if (_inFlight > 0 && --_inFlight == 0) {
      onLoadingChanged?.call(false);
    }
  }
}

const String _showLoaderKey = 'base_api_client.showLoader';
const String _countedKey = 'base_api_client.counted';

/// Drives the loading signal and the logger for one [BaseApiClient].
class _LifecycleInterceptor extends Interceptor {
  _LifecycleInterceptor(this.client);

  final BaseApiClient client;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.extra[_showLoaderKey] != false) {
      options.extra[_countedKey] = true;
      client._requestStarted();
    }
    client.logger?.call('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _settle(response.requestOptions);
    client.logger?.call(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}\n${response.data}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _settle(err.requestOptions);
    client.logger?.call(
      '✗ ${err.type.name} ${err.requestOptions.method} '
      '${err.requestOptions.uri}\n'
      '${err.response?.statusCode ?? ''} ${err.response?.data ?? err.message}',
    );
    handler.next(err);
  }

  /// Balances exactly one [_requestStarted] per request, whichever way it ends.
  void _settle(RequestOptions options) {
    if (options.extra.remove(_countedKey) == true) {
      client._requestFinished();
    }
  }
}
