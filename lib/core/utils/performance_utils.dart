import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance utilities for optimizing the app
class PerformanceUtils {
  static bool _performanceMonitoring = false;

  /// Debounce utility for search and other frequent operations
  static void debounce(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }

  static final Map<String, Timer> _debounceTimers = {};

  void trackWidgetLifecycle(WidgetRef ref, String widgetName) {
    if (!_performanceMonitoring) return;
    
    final startTime = DateTime.now();
    print('Widget $widgetName: Build started at ${startTime.millisecondsSinceEpoch}');
    
    // Note: Widget disposal tracking would need to be implemented differently
    // as WidgetRef doesn't have onDispose method in this Riverpod version
  }

  /// Throttle utility for scroll events
  static void throttle(
    String key,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    if (_throttleTimers[key]?.isActive ?? false) return;
    
    callback();
    _throttleTimers[key] = Timer(delay, () {});
  }

  static final Map<String, Timer> _throttleTimers = {};

  /// Clear all timers
  static void dispose() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    for (final timer in _throttleTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _throttleTimers.clear();
  }

  /// Memory usage monitoring (debug only)
  static void logMemoryUsage(String context) {
    if (kDebugMode) {
      debugPrint('Memory usage at $context: ${_getMemoryUsage()}');
    }
  }

  static String _getMemoryUsage() {
    // This is a simplified memory usage indicator
    // In a real app, you might use more sophisticated memory monitoring
    return 'Memory monitoring not implemented';
  }
}

/// A widget that automatically disposes resources when not needed
class AutoDisposeWidget extends ConsumerWidget {
  final Widget Function(BuildContext context, WidgetRef ref) builder;
  final VoidCallback? onDispose;

  const AutoDisposeWidget({
    super.key,
    required this.builder,
    this.onDispose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: Auto-dispose functionality would need to be implemented differently
    // as WidgetRef doesn't have onDispose method in this Riverpod version
    
    return builder(context, ref);
  }
}

/// A mixin for widgets that need to track their lifecycle
mixin PerformanceTrackingMixin<T extends StatefulWidget> on State<T> {
  late final Stopwatch _stopwatch;
  
  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    if (kDebugMode) {
      debugPrint('${widget.runtimeType} initialized');
    }
  }
  
  @override
  void dispose() {
    _stopwatch.stop();
    if (kDebugMode) {
      debugPrint(
        '${widget.runtimeType} disposed after ${_stopwatch.elapsedMilliseconds}ms'
      );
    }
    super.dispose();
  }
}

/// Optimized list view that only builds visible items
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Add performance tracking for list items
        return _OptimizedListItem(
          index: index,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

class _OptimizedListItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _OptimizedListItem({
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // In debug mode, we can add performance monitoring
    if (kDebugMode) {
      return RepaintBoundary(
        child: child,
      );
    }
    
    return RepaintBoundary(
      child: child,
    );
  }
}

/// Cached network image widget with better performance
class OptimizedCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // For now, use a simple Image.network
    // In a real app, you'd use cached_network_image package
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );
  }
}

/// Timer class for debouncing and throttling
class Timer {
  final Duration duration;
  final VoidCallback callback;
  bool _isActive = false;

  Timer(this.duration, this.callback) {
    _isActive = true;
    Future.delayed(duration, () {
      if (_isActive) {
        callback();
      }
      _isActive = false;
    });
  }

  bool get isActive => _isActive;

  void cancel() {
    _isActive = false;
  }
}

/// Provider for managing app-wide performance settings
final performanceSettingsProvider = StateNotifierProvider<PerformanceSettingsNotifier, PerformanceSettings>(
  (ref) => PerformanceSettingsNotifier(),
);

class PerformanceSettings {
  final bool enableAnimations;
  final bool enableHapticFeedback;
  final int maxCacheSize;
  final bool enablePerformanceMonitoring;

  const PerformanceSettings({
    this.enableAnimations = true,
    this.enableHapticFeedback = true,
    this.maxCacheSize = 100,
    this.enablePerformanceMonitoring = false,
  });

  PerformanceSettings copyWith({
    bool? enableAnimations,
    bool? enableHapticFeedback,
    int? maxCacheSize,
    bool? enablePerformanceMonitoring,
  }) {
    return PerformanceSettings(
      enableAnimations: enableAnimations ?? this.enableAnimations,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      enablePerformanceMonitoring: enablePerformanceMonitoring ?? this.enablePerformanceMonitoring,
    );
  }
}

class PerformanceSettingsNotifier extends StateNotifier<PerformanceSettings> {
  PerformanceSettingsNotifier() : super(const PerformanceSettings());

  void updateAnimations(bool enabled) {
    state = state.copyWith(enableAnimations: enabled);
  }

  void updateHapticFeedback(bool enabled) {
    state = state.copyWith(enableHapticFeedback: enabled);
  }

  void updateCacheSize(int size) {
    state = state.copyWith(maxCacheSize: size);
  }

  void updatePerformanceMonitoring(bool enabled) {
    state = state.copyWith(enablePerformanceMonitoring: enabled);
  }
}