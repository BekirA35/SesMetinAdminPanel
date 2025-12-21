import 'package:flutter/material.dart';

/// Güvenli Opacity widget'ı - opacity değerini otomatik olarak
/// 0.0 ile 1.0 arasında clamp eder ve hataları önler.
class SafeOpacity extends StatelessWidget {
  final Widget child;
  final double opacity;

  const SafeOpacity({
    super.key,
    required this.child,
    required this.opacity,
  });

  /// Opacity değerini güvenli hale getirir
  /// - NaN ve Infinite değerleri 1.0'a dönüştürür
  /// - Değeri 0.0-1.0 aralığına clamp eder
  static double safeOpacityValue(double value) {
    // Null kontrolü
    if (value.isNaN || value.isInfinite) {
      return 1.0;
    }
    
    // Clamp işlemi - her zaman 0.0 ile 1.0 arasında
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    try {
      final safeValue = safeOpacityValue(opacity);
      return Opacity(
        opacity: safeValue,
        child: child,
      );
    } catch (e) {
      // Herhangi bir hata durumunda tam opak göster
      return Opacity(
        opacity: 1.0,
        child: child,
      );
    }
  }
}

/// Güvenli FadeTransition widget'ı
class SafeFadeTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> opacity;

  const SafeFadeTransition({
    super.key,
    required this.child,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: opacity,
      builder: (context, child) {
        try {
          final safeValue = SafeOpacity.safeOpacityValue(opacity.value);
          return Opacity(
            opacity: safeValue,
            child: child,
          );
        } catch (e) {
          // Hata durumunda tam opak göster
          return Opacity(
            opacity: 1.0,
            child: child,
          );
        }
      },
      child: child,
    );
  }
}

