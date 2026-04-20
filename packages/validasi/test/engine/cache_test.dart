import 'package:test/test.dart';
import 'package:validasi/src/engine/cache.dart';
import 'package:validasi/src/engine/result.dart';

void main() {
  group('EngineCache', () {
    late Object engine1;
    late Object engine2;

    setUp(() {
      engine1 = Object();
      engine2 = Object();
    });

    tearDown(() {
      EngineCache.clear(engine1);
      EngineCache.clear(engine2);
    });

    test('should store and retrieve cached result', () {
      final result = ValidasiResult<String>.success('test');
      final key = 'testKey';

      EngineCache.set(engine1, key, result);
      final retrieved = EngineCache.get(engine1, key);

      expect(retrieved, equals(result));
      expect(retrieved?.data, equals('test'));
    });

    test('should return null for non-existent key', () {
      final retrieved = EngineCache.get(engine1, 'nonExistentKey');

      expect(retrieved, isNull);
    });

    test('should isolate cache per engine instance', () {
      final result1 = ValidasiResult<String>.success('engine1');
      final result2 = ValidasiResult<String>.success('engine2');
      final key = 'sameKey';

      EngineCache.set(engine1, key, result1);
      EngineCache.set(engine2, key, result2);

      final retrieved1 = EngineCache.get(engine1, key);
      final retrieved2 = EngineCache.get(engine2, key);

      expect(retrieved1?.data, equals('engine1'));
      expect(retrieved2?.data, equals('engine2'));
    });

    test('should update LRU order on get', () {
      final result1 = ValidasiResult<String>.success('first');
      final result2 = ValidasiResult<String>.success('second');
      final result3 = ValidasiResult<String>.success('third');

      EngineCache.set(engine1, 'key1', result1);
      EngineCache.set(engine1, 'key2', result2);

      // Access key1 to make it most recently used
      EngineCache.get(engine1, 'key1');

      // Fill cache to just under capacity (512 - 2 = 510 more items)
      for (int i = 0; i < 510; i++) {
        EngineCache.set(engine1, 'filler$i', result3);
      }

      // Now add one more to trigger eviction
      // key2 should be evicted (least recently used)
      // key1 should remain (was accessed after key2)
      EngineCache.set(engine1, 'trigger', result3);

      expect(EngineCache.get(engine1, 'key1'), isNotNull);
      expect(EngineCache.get(engine1, 'key2'), isNull); // This was evicted
    });

    test('should evict least recently used when exceeding max size', () {
      // Fill cache beyond max size (512 entries)
      for (int i = 0; i < 513; i++) {
        final result = ValidasiResult<int>.success(i);
        EngineCache.set(engine1, 'key$i', result);
      }

      // First key should have been evicted
      expect(EngineCache.get(engine1, 'key0'), isNull);

      // Last key should still be present
      final last = EngineCache.get(engine1, 'key512');
      expect(last, isNotNull);
      expect(last?.data, equals(512));
    });

    test('should clear all cache entries for an engine', () {
      EngineCache.set(engine1, 'key1', ValidasiResult<String>.success('1'));
      EngineCache.set(engine1, 'key2', ValidasiResult<String>.success('2'));
      EngineCache.set(engine1, 'key3', ValidasiResult<String>.success('3'));

      EngineCache.clear(engine1);

      expect(EngineCache.get(engine1, 'key1'), isNull);
      expect(EngineCache.get(engine1, 'key2'), isNull);
      expect(EngineCache.get(engine1, 'key3'), isNull);
    });

    test('should not affect other engines when clearing', () {
      EngineCache.set(engine1, 'key', ValidasiResult<String>.success('1'));
      EngineCache.set(engine2, 'key', ValidasiResult<String>.success('2'));

      EngineCache.clear(engine1);

      expect(EngineCache.get(engine1, 'key'), isNull);
      expect(EngineCache.get(engine2, 'key'), isNotNull);
    });

    test('should handle different result types', () {
      final stringResult = ValidasiResult<String>.success('text');
      final intResult = ValidasiResult<int>.success(42);
      final listResult = ValidasiResult<List<int>>.success([1, 2, 3]);

      EngineCache.set(engine1, 'string', stringResult);
      EngineCache.set(engine1, 'int', intResult);
      EngineCache.set(engine1, 'list', listResult);

      expect(EngineCache.get(engine1, 'string')?.data, equals('text'));
      expect(EngineCache.get(engine1, 'int')?.data, equals(42));
      expect(EngineCache.get(engine1, 'list')?.data, equals([1, 2, 3]));
    });
  });

  group('computeCacheKey', () {
    test('should compute key for null', () {
      final key = computeCacheKey(null);
      expect(key, equals('null'));
    });

    test('should compute key for boolean true', () {
      final key = computeCacheKey(true);
      expect(key, equals('b:1'));
    });

    test('should compute key for boolean false', () {
      final key = computeCacheKey(false);
      expect(key, equals('b:0'));
    });

    test('should compute key for numbers', () {
      expect(computeCacheKey(42), equals('n:42'));
      expect(computeCacheKey(3.14), equals('n:3.14'));
      expect(computeCacheKey(0), equals('n:0'));
      expect(computeCacheKey(-5), equals('n:-5'));
    });

    test('should compute key for strings', () {
      final key = computeCacheKey('hello');
      expect(key, equals('s:5:hello'));

      final emptyKey = computeCacheKey('');
      expect(emptyKey, equals('s:0:'));
    });

    test('should compute key for lists', () {
      final key = computeCacheKey([1, 2, 3]);
      expect(key, equals('l[3]:n:1|n:2|n:3'));

      final emptyKey = computeCacheKey([]);
      expect(emptyKey, equals('l[0]:'));
    });

    test('should compute key for nested lists', () {
      final key = computeCacheKey([
        [1, 2],
        [3, 4]
      ]);
      expect(key, equals('l[2]:l[2]:n:1|n:2|l[2]:n:3|n:4'));
    });

    test('should compute key for maps', () {
      final key = computeCacheKey({'a': 1, 'b': 2});
      // Map keys are sorted
      expect(key, contains('m{'));
      expect(key, contains('s:1:a=n:1'));
      expect(key, contains('s:1:b=n:2'));
    });

    test('should compute key for empty map', () {
      final key = computeCacheKey({});
      expect(key, equals('m{}'));
    });

    test('should compute stable keys for maps with same content', () {
      final key1 = computeCacheKey({'x': 10, 'y': 20});
      final key2 = computeCacheKey({'y': 20, 'x': 10});

      // Should be equal regardless of insertion order
      expect(key1, equals(key2));
    });

    test('should compute key for complex structures', () {
      final data = {
        'name': 'John',
        'age': 30,
        'scores': [95, 87, 92],
      };

      final key = computeCacheKey(data);
      expect(key, startsWith('m{'));
      expect(key, contains('s:4:name'));
      expect(key, contains('s:3:age'));
      expect(key, contains('s:6:scores'));
    });

    test('should use identity hash for custom objects', () {
      final obj = Object();
      final key = computeCacheKey(obj);

      expect(key, startsWith('o:Object#'));
    });

    test('should produce different keys for different custom objects', () {
      final obj1 = Object();
      final obj2 = Object();

      final key1 = computeCacheKey(obj1);
      final key2 = computeCacheKey(obj2);

      expect(key1, isNot(equals(key2)));
    });

    test('should produce same key for same primitive values', () {
      expect(computeCacheKey(42), equals(computeCacheKey(42)));
      expect(computeCacheKey('test'), equals(computeCacheKey('test')));
      expect(computeCacheKey(true), equals(computeCacheKey(true)));
    });

    test('should produce different keys for different values', () {
      expect(computeCacheKey(1), isNot(equals(computeCacheKey(2))));
      expect(computeCacheKey('a'), isNot(equals(computeCacheKey('b'))));
      expect(computeCacheKey(true), isNot(equals(computeCacheKey(false))));
    });
  });
}
