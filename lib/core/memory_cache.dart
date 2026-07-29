/// Tiny in-memory TTL cache for hot reads (products, home payload).
class MemoryCache<T> {
  MemoryCache({this.ttl = const Duration(minutes: 5)});

  final Duration ttl;
  T? _value;
  DateTime? _storedAt;

  /// True if a value has been put and hasn't expired yet (even if value is null).
  bool get hasValue {
    if (_storedAt == null) return false;
    if (DateTime.now().difference(_storedAt!) > ttl) {
      clear();
      return false;
    }
    return true;
  }

  T? get value {
    if (!hasValue) return null;
    return _value;
  }

  void put(T data) {
    _value = data;
    _storedAt = DateTime.now();
  }

  void clear() {
    _value = null;
    _storedAt = null;
  }
}
