import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';
import '../../core/session_service.dart';
import 'api_exception.dart';

/// HTTP client with timeouts, retries, and optional Bearer auth.
class YensApiClient {
  YensApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await SessionService.instance.bearerToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.parse('${AppConfig.apiBase}$path').replace(queryParameters: query);
    return _withRetry(() async {
      final res = await _client
          .get(uri, headers: await _headers())
          .timeout(AppConfig.requestTimeout);
      return res;
    });
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final uri = Uri.parse('${AppConfig.apiBase}$path');
    return _withRetry(() async {
      return _client
          .post(
            uri,
            headers: await _headers(),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);
    });
  }

  Future<http.Response> put(String path, {Object? body}) async {
    final uri = Uri.parse('${AppConfig.apiBase}$path');
    return _withRetry(() async {
      return _client
          .put(
            uri,
            headers: await _headers(),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);
    });
  }

  Future<http.Response> _withRetry(Future<http.Response> Function() run) async {
    Object? lastError;
    for (var attempt = 0; attempt <= AppConfig.maxRetries; attempt++) {
      try {
        final res = await run();
        if (res.statusCode >= 500 && attempt < AppConfig.maxRetries) {
          await Future<void>.delayed(AppConfig.retryDelay * (attempt + 1));
          continue;
        }
        return res;
      } on TimeoutException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }
      if (attempt < AppConfig.maxRetries) {
        await Future<void>.delayed(AppConfig.retryDelay * (attempt + 1));
      }
    }
    throw ApiException(lastError?.toString() ?? 'Network request failed');
  }

  void dispose() {
    _client.close();
  }
}
