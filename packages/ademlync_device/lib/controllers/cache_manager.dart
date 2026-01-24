import '../models/adem/config_cache.dart';
import '../models/adem/measure_cache.dart';
import '../models/modules/push_button_module.dart';

class CacheManager {
  static final _manager = CacheManager._internal();
  factory CacheManager() => _manager;
  CacheManager._internal();

  final _cacheMap = <CacheType, Object>{};

  /// Retrieves cached data of the specified type
  ///
  /// Throws a [StateError] if the cache is not available or has an incorrect type.
  T _get<T>(CacheType type) {
    final cache = _cacheMap[type];
    if (cache != null && cache is T) {
      return cache as T;
    } else {
      throw StateError('Cache not ready or wrong type for $type');
    }
  }

  /// Stores data in the cache
  ///
  /// Overwrites existing data for the specified [CacheType].
  void _cache(CacheType type, Object data) {
    _cacheMap[type] = data;
  }

  /// Clears all cached data
  void clear() {
    _cacheMap.clear();
  }

  // MARK: Getter

  /// Retrieves the cached [ConfigCache] instance
  ConfigCache getConfig() {
    return _get<ConfigCache>(CacheType.config);
  }

  /// Retrieves the cached [MeasureCache] instance
  MeasureCache getMeasure() {
    return _get<MeasureCache>(CacheType.measure);
  }

  /// Retrieves the cached [PushButtonModule] instance
  PushButtonModule getPushButtonModule() {
    return _get<PushButtonModule>(CacheType.pushButtonModule);
  }

  // MARK: Setter

  /// Caches a [ConfigCache] instance
  void cacheConfig(ConfigCache data) {
    _cache(CacheType.config, data);
  }

  /// Caches a [MeasureCache] instance
  void cacheMeasure(MeasureCache data) {
    _cache(CacheType.measure, data);
  }

  /// Caches a [PushButtonModule] instance
  void cachePushButtonModule(PushButtonModule data) {
    _cache(CacheType.pushButtonModule, data);
  }
}

enum CacheType { config, measure, pushButtonModule }
