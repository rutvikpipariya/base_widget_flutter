import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:base_widget_flutter/base_widget_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request from [handler], so no socket is ever opened.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final FutureOr<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );

/// Builds a client wired to [adapter].
BaseApiClient _client(
  _FakeAdapter adapter, {
  TokenProvider? tokenProvider,
  LoadingCallback? onLoadingChanged,
  ApiLogger? logger,
}) {
  final client = BaseApiClient(
    baseUrl: 'https://api.example.com',
    tokenProvider: tokenProvider,
    onLoadingChanged: onLoadingChanged,
    logger: logger,
  );
  client.dio.httpClientAdapter = adapter;
  return client;
}

void main() {
  group('auth header', () {
    test('attaches the bearer token from tokenProvider', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter, tokenProvider: () => 'abc123');

      await client.get('/profile');

      expect(adapter.requests.single.headers['Authorization'], 'Bearer abc123');
    });

    test('awaits an async tokenProvider', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter, tokenProvider: () async => 'async-token');

      await client.get('/profile');

      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer async-token',
      );
    });

    test('omits the header entirely when the token is null', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter, tokenProvider: () => null);

      await client.get('/public');

      // The original sent the literal string "Bearer null", which a server
      // reads as a malformed token rather than as an absent one.
      expect(adapter.requests.single.headers, isNot(contains('Authorization')));
    });

    test('omits the header when the token is empty', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter, tokenProvider: () => '');

      await client.get('/public');

      expect(adapter.requests.single.headers, isNot(contains('Authorization')));
    });

    test('omits the header when authenticated is false', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter, tokenProvider: () => 'abc123');

      await client.get('/public', authenticated: false);

      expect(adapter.requests.single.headers, isNot(contains('Authorization')));
    });

    test('keeps caller-supplied headers alongside the token', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter, tokenProvider: () => 'abc123');

      await client.get(
        '/profile',
        headers: <String, dynamic>{'X-Trace': 'trace-1'},
      );

      final headers = adapter.requests.single.headers;
      expect(headers['X-Trace'], 'trace-1');
      expect(headers['Authorization'], 'Bearer abc123');
    });
  });

  group('requests', () {
    test('resolves paths against baseUrl exactly once', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter);

      await client.get('/v1/profile');

      expect(
        adapter.requests.single.uri.toString(),
        'https://api.example.com/v1/profile',
      );
    });

    test('sends the body and method for each verb', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter);

      await client.post('/a', data: <String, String>{'k': 'v'});
      await client.patch('/b', data: <String, String>{'k': 'v'});
      await client.put('/c', data: <String, String>{'k': 'v'});
      await client.delete('/d');

      expect(adapter.requests.map((r) => r.method), <String>[
        'POST',
        'PATCH',
        'PUT',
        'DELETE',
      ]);
      expect(adapter.requests.first.data, <String, String>{'k': 'v'});
    });

    test('postFormData switches the content type', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final client = _client(adapter);

      await client.postFormData(
        '/upload',
        data: FormData.fromMap(<String, dynamic>{'name': 'x'}),
      );

      expect(
        adapter.requests.single.contentType,
        startsWith(Headers.multipartFormDataContentType),
      );
    });

    test(
      'resolves 4xx instead of throwing, so bodies reach the caller',
      () async {
        final adapter = _FakeAdapter(
          (_) => _json(<String, String>{'error': 'nope'}, statusCode: 422),
        );
        final client = _client(adapter);

        final res = await client.get('/profile');

        expect(res.statusCode, 422);
        expect(res.data, <String, String>{'error': 'nope'});
      },
    );

    test('still throws on 5xx', () async {
      final adapter = _FakeAdapter(
        (_) => _json(<String, String>{'error': 'boom'}, statusCode: 500),
      );
      final client = _client(adapter);

      expect(() => client.get('/profile'), throwsA(isA<DioException>()));
    });
  });

  group('loading signal', () {
    test('fires true then false around one request', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final events = <bool>[];
      final client = _client(adapter, onLoadingChanged: events.add);

      await client.get('/profile');

      expect(events, <bool>[true, false]);
    });

    test('stays on until the last of two overlapping requests ends', () async {
      final gates = <Completer<void>>[Completer<void>(), Completer<void>()];
      var index = 0;
      final adapter = _FakeAdapter((_) async {
        await gates[index++].future;
        return _json(<String, String>{'ok': 'y'});
      });
      final events = <bool>[];
      final client = _client(adapter, onLoadingChanged: events.add);

      final first = client.get('/a');
      final second = client.get('/b');
      // Both requests must reach the interceptor before the first is
      // released, which takes more than one microtask: get() awaits the
      // token provider before building its options.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(events, <bool>[true]);

      gates[0].complete();
      await first;
      // The original hid the loader here, while /b was still in flight.
      expect(events, <bool>[true]);

      gates[1].complete();
      await second;
      expect(events, <bool>[true, false]);
    });

    test('stays silent when showLoader is false', () async {
      final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
      final events = <bool>[];
      final client = _client(adapter, onLoadingChanged: events.add);

      await client.get('/poll', showLoader: false);

      expect(events, isEmpty);
    });

    test('returns to false when a request fails', () async {
      final adapter = _FakeAdapter(
        (_) => _json(<String, String>{'error': 'boom'}, statusCode: 500),
      );
      final events = <bool>[];
      final client = _client(adapter, onLoadingChanged: events.add);

      await expectLater(client.get('/profile'), throwsA(isA<DioException>()));

      expect(events, <bool>[true, false]);
    });
  });

  test('logger receives a line for the request and the response', () async {
    final adapter = _FakeAdapter((_) => _json(<String, String>{'ok': 'y'}));
    final lines = <String>[];
    final client = _client(adapter, logger: lines.add);

    await client.get('/profile');

    expect(lines, hasLength(2));
    expect(lines.first, contains('GET https://api.example.com/profile'));
    expect(lines.last, contains('200'));
  });
}
