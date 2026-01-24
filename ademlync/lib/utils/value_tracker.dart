class ValueTracker<T> {
  final T _original;
  T value;

  ValueTracker(this.value) : _original = value;

  bool get isEdited => switch ((_original, value)) {
    (DateTime o, DateTime v) => o.hour != v.hour,
    _ => _original != value,
  };

  void reset() {
    value = _original;
  }
}

ValueTracker<T>? buildValueTracker<T>(T? value) {
  return value != null ? ValueTracker(value) : null;
}
