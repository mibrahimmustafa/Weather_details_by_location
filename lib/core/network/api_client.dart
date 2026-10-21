import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/app_failure.dart';

/// Thin JSON HTTP client with timeouts, retries and UTF-8 decoding.
///
/// Retries only apply to transient failures (network, 429, 5xx). Malformed
/// responses are never retried, because repeating the request cannot help.
class ApiClient {
  ApiClient({
    http.Client? client,
    this.timeout = const Duration(seconds: 18),
    this.maxAttempts = 3,
    Future<void> Function(Duration)? delay,
  }) : _client = client ?? http.Client(),
       _delay = delay ?? ((duration) => Future<void>.delayed(duration));

  final http.Client _client;
  final Duration timeout;
  final int maxAttempts;
  final Future<void> Function(Duration) _delay;

  Future<Map<String, dynamic>> getJson(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _client
            .get(
              uri,
              headers: {
                'Accept': 'application/json',
                'User-Agent': 'Ajwaa/1.0 (+https://github.com/mibrahimmustafa)',
                ...?headers,
              },
            )
            .timeout(timeout);

        if (response.statusCode == 429) {
          lastError = const AppFailure(
            FailureKind.rateLimited,
            debugMessage: 'HTTP 429',
          );
          if (attempt < maxAttempts) {
            await _delay(Duration(milliseconds: 500 * attempt));
            continue;
          }
          throw lastError;
        }

        if (response.statusCode >= 500) {
          lastError = AppFailure(
            FailureKind.server,
            debugMessage: 'HTTP ${response.statusCode}',
          );
          if (attempt < maxAttempts) {
            await _delay(Duration(milliseconds: 400 * attempt));
            continue;
          }
          throw lastError;
        }

        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw AppFailure(
            FailureKind.server,
            debugMessage: 'HTTP ${response.statusCode}',
          );
        }

        final decoded = _decode(response.bodyBytes);
        if (decoded is! Map<String, dynamic>) {
          throw const AppFailure(
            FailureKind.malformed,
            debugMessage: 'Expected a JSON object',
          );
        }
        return decoded;
      } on TimeoutException catch (error) {
        lastError = AppFailure(
          FailureKind.timeout,
          debugMessage: error.message,
        );
      } on http.ClientException catch (error) {
        lastError = AppFailure(
          FailureKind.network,
          debugMessage: error.message,
        );
      } on AppFailure catch (error) {
        lastError = error;
        if (error.kind != FailureKind.network &&
            error.kind != FailureKind.timeout &&
            error.kind != FailureKind.server &&
            error.kind != FailureKind.rateLimited) {
          rethrow;
        }
      } catch (error) {
        lastError = AppFailure(FailureKind.unknown, debugMessage: '$error');
      }

      if (attempt < maxAttempts) {
        await _delay(Duration(milliseconds: 350 * attempt));
      }
    }

    throw lastError is AppFailure
        ? lastError
        : AppFailure(FailureKind.unknown, debugMessage: '$lastError');
  }

  dynamic _decode(List<int> bytes) {
    try {
      return jsonDecode(utf8.decode(bytes, allowMalformed: true));
    } on FormatException catch (error) {
      throw AppFailure(FailureKind.malformed, debugMessage: error.message);
    }
  }

  void dispose() => _client.close();
}
