import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

import 'package:driver_app/src/services/api_client.dart';
import 'package:driver_app/src/services/connectivity_service.dart';
import 'package:driver_app/src/services/offline_queue_service.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late Directory tmp;
  late Box<Map<dynamic, dynamic>> box;
  late MockApiClient api;
  late MockDio dio;
  late MockConnectivityService conn;
  late OfflineQueueService svc;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('oq_test');
    Hive.init(tmp.path);
    box = await Hive.openBox<Map<dynamic, dynamic>>('offline_queue');
    await box.clear();

    api = MockApiClient();
    dio = MockDio();
    conn = MockConnectivityService();
    when(() => api.dio).thenReturn(dio);
    when(() => conn.onlineStream).thenAnswer((_) => const Stream<bool>.empty());

    svc = OfflineQueueService(api, conn);
  });

  tearDown(() async {
    svc.dispose();
    await box.clear();
    await Hive.close();
    tmp.deleteSync(recursive: true);
  });

  group('enqueue', () {
    test('adds an entry carrying path, method and idempotency key', () async {
      await svc.enqueueRequest(
        path: '/api/driver/deliveries/1/complete',
        method: 'POST',
        data: {'x': 1},
        idempotencyKey: 'complete-1',
      );
      expect(box.length, 1);
      final e = box.values.first;
      expect(e['path'], '/api/driver/deliveries/1/complete');
      expect(e['method'], 'POST');
      expect(e['idempotencyKey'], 'complete-1');
    });

    test('dedups on idempotency key', () async {
      await svc.enqueueRequest(path: '/p', method: 'POST', idempotencyKey: 'k1');
      await svc.enqueueRequest(path: '/p', method: 'POST', idempotencyKey: 'k1');
      expect(box.length, 1);
    });

    test('synthesises METHOD-path key when none given', () async {
      await svc.enqueueRequest(path: '/p', method: 'post');
      expect(box.values.first['idempotencyKey'], 'POST-/p');
    });
  });

  group('processQueue replay', () {
    test('replays POST with decoded body + idempotency header, then removes it', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/p')));

      await svc.enqueueRequest(path: '/p', method: 'POST', data: {'a': 1}, idempotencyKey: 'k1');
      await svc.processQueue();

      expect(box.length, 0, reason: 'successful replay should clear the entry');
      final captured = verify(
        () => dio.post('/p', data: captureAny(named: 'data'), options: captureAny(named: 'options')),
      ).captured;
      expect(captured[0], {'a': 1});
      expect((captured[1] as Options).headers?['X-Idempotency-Key'], 'k1');
    });

    test('dead-letters (keeps, marks failed) on a 4xx permanent failure', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/p'),
          response: Response(requestOptions: RequestOptions(path: '/p'), statusCode: 409),
        ),
      );
      await svc.enqueueRequest(path: '/p', method: 'POST', idempotencyKey: 'k1');
      await svc.processQueue();
      // Not dropped silently: kept on disk, flagged for the driver to see + retry.
      expect(box.length, 1);
      expect(box.values.first['status'], 'DEAD_LETTER');
      expect(box.values.first['lastError'], 'HTTP_409');
      expect(svc.state.failed, 1);
      expect(svc.state.pending, 0);
    });

    test('retryItem re-arms a dead-letter and re-sends it', () async {
      // Fail with 500 throughout the exhaust phase so the item dead-letters.
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: '/p'),
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: RequestOptions(path: '/p'), statusCode: 500),
      ));
      await svc.enqueueRequest(path: '/p', method: 'POST', idempotencyKey: 'k1');
      for (var i = 0; i < 4; i++) {
        await svc.processQueue();
      }
      expect(box.values.first['status'], 'DEAD_LETTER',
          reason: '5xx past max retries dead-letters (not dropped)');
      final key = box.keys.first;
      // Now the server recovers and a manual retry succeeds → entry cleared.
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer((_) async => Response(requestOptions: RequestOptions(path: '/p')));
      await svc.retryItem(key);
      expect(box.length, 0, reason: 'a successful manual retry clears the entry');
    });

    test('keeps the entry on a connection error (retry later)', () async {
      when(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/p'),
          type: DioExceptionType.connectionError,
        ),
      );
      await svc.enqueueRequest(path: '/p', method: 'POST', idempotencyKey: 'k1');
      await svc.processQueue();
      expect(box.length, 1);
    });

    test('dead-letters entries older than the TTL without hitting the network', () async {
      await box.add({
        'id': 'old',
        'path': '/p',
        'method': 'POST',
        'data': null,
        'timestamp': DateTime.now().subtract(const Duration(hours: 25)).toIso8601String(),
        'idempotencyKey': 'old',
        'retryCount': 0,
        'status': 'PENDING',
      });
      await svc.processQueue();
      expect(box.length, 1);
      expect(box.values.first['status'], 'DEAD_LETTER');
      expect(box.values.first['lastError'], 'TTL_EXPIRED');
      verifyNever(() => dio.post(any(), data: any(named: 'data'), options: any(named: 'options')));
    });
  });
}
