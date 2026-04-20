import 'dart:collection';

import 'package:validasi/src/engine/result.dart';

/// Simple per-engine-instance cache with fixed-size LRU policy.
class EngineCache {
  static const int _kMaxCacheEntries = 512;

  static final Expando<LinkedHashMap<Object, ValidasiResult<dynamic>>>
      _engineCache =
      Expando<LinkedHashMap<Object, ValidasiResult<dynamic>>>('_engineCache');

  static LinkedHashMap<Object, ValidasiResult<dynamic>> _of(Object engine) {
    return _engineCache[engine] ??=
        LinkedHashMap<Object, ValidasiResult<dynamic>>();
  }

  static ValidasiResult<dynamic>? get(Object engine, Object key) {
    final cache = _of(engine);
    final hit = cache.remove(key);
    if (hit == null) return null;
    // LRU: reinsert as most recently used
    cache[key] = hit;
    return hit;
  }

  static void set(Object engine, Object key, ValidasiResult<dynamic> value) {
    final cache = _of(engine);
    cache[key] = value;
    if (cache.length > _kMaxCacheEntries) {
      // Evict least recently used (first key in LinkedHashMap insertion order)
      final firstKey = cache.keys.first;
      cache.remove(firstKey);
    }
  }

  static void clear(Object engine) {
    _of(engine).clear();
  }
}

/// Compute a stable, structural key for common JSON-like inputs.
/// Falls back to object identity for other types.
Object computeCacheKey(dynamic value) => _keyOf(value);

Object _keyOf(dynamic v) {
  if (v == null) return 'null';
  if (v is bool) return v ? 'b:1' : 'b:0';
  if (v is num) return 'n:$v';
  if (v is String) return 's:${v.length}:$v';
  if (v is List) {
    final buffer = StringBuffer('l[');
    buffer.write(v.length);
    buffer.write(']:');
    for (var i = 0; i < v.length; i++) {
      if (i > 0) buffer.write('|');
      buffer.write(_keyOf(v[i]));
    }
    return buffer.toString();
  }
  if (v is Map) {
    // Canonicalize by sorted stringified keys
    final entries = <String>[];
    v.forEach((k, val) {
      final ks = _keyOf(k).toString();
      final vs = _keyOf(val).toString();
      entries.add('$ks=$vs');
    });
    entries.sort();
    return 'm{${entries.join('|')}}';
  }
  // Fallback: per-instance identity + type
  return 'o:${v.runtimeType}#${identityHashCode(v)}';
}
