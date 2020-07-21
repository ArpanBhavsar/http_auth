// Copyright (c) 2018, Marco Esposito (marcoesposito1988@gmail.com).
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license
// that can be found in the LICENSE file.

import 'package:http_auth/http_auth.dart';
import 'package:http_auth/src/http_auth_negotiate.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

void main() async {
  group('httpbin Basic Auth', () {
    http.BaseClient client;

//    setUp(() {
//
//    });

    test('HTTP', () async {
      final url = 'http://eu.httpbin.org/basic-auth/user/passwd';
      client = BasicAuthClient('user', 'passwd');

      var response = await client.get(url);
      expect(response.statusCode == 200, isTrue);
    });

    test('HTTPS', () async {
      final url = 'https://eu.httpbin.org/basic-auth/user/passwd';
      client = BasicAuthClient('user', 'passwd');

      var response = await client.get(url);
      expect(response.statusCode == 200, isTrue);
    });
  });

  group('httpbin Digest Auth', () {
    http.BaseClient client;

//    setUp(() {
//
//    });

    test('HTTP', () async {
      final url = 'http://eu.httpbin.org/digest-auth/auth/user/passwd';
      client = DigestAuthClient('user', 'passwd');

      var response = await client.get(url);
      expect(response.statusCode == 200, isTrue);
    });

    test('HTTPS', () async {
      final url = 'https://eu.httpbin.org/digest-auth/auth/user/passwd';
      client = DigestAuthClient('user', 'passwd');

      var response = await client.get(url);
      expect(response.statusCode == 200, isTrue);
    });
  });

  group('jigsaw Digest Auth', () {
    http.BaseClient client;

//    setUp(() {
//
//    });

    test('HTTP', () async {
      final url = 'http://jigsaw.w3.org/HTTP/Digest/';
      client = DigestAuthClient('guest', 'guest');

      var response = await client.get(url);
      expect(response.statusCode, 200);
    });

    test('HTTPS', () async {
      final url = 'https://jigsaw.w3.org/HTTP/Digest/';
      client = DigestAuthClient('guest', 'guest');

      var response = await client.get(url);
      expect(response.statusCode, 200);
    });
  });

  group('Auto negotiate test', () {
    final digestUrl = 'http://jigsaw.w3.org/HTTP/Digest/';
    final basicUrl = 'http://jigsaw.w3.org/HTTP/Basic/';
    test('negotiate basic', () async {
      final client = NegotiateAuthClient('guest', 'guest');
      final response = await client.get(basicUrl);
      expect(response.statusCode, 200);
    });
    test('negotiate digest', () async {
      final client = NegotiateAuthClient('guest', 'guest');
      final response = await client.get(digestUrl + rand);
      expect(response.statusCode, 200);
    });
  });

  group('Digest: Multiple requests', () {
    test('negotiate digest', () async {
      final count = _CountingHttpClient();
      final url = 'http://httpbin.org/digest-auth/auth/foo/bar';
      final client = NegotiateAuthClient('foo', 'bar', inner: count);
      final response = await client.get(url);
      expect(response.statusCode, 200);
      expect(count.requestCount, 2);
      // lets try a second request.
      final response2 = await client.get(url);
      expect(response2.statusCode, 200);
      expect(count.requestCount, 3);
    });
  });
}

String get rand => '?t=${DateTime.now().millisecondsSinceEpoch}';

class _CountingHttpClient extends http.BaseClient {
  final _inner = http.Client();
  int requestCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requestCount++;
    return _inner.send(request);
  }
}
