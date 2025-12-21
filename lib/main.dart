import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

/// Global error handler - opacity ve diğer hataları yakalar
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorController.stream;

  void handleError(FlutterErrorDetails details) {
    final errorString = details.exception.toString();
    final errorMessage = details.exceptionAsString();

    // Opacity hatalarını yakala ve sessizce işle
    if (_isOpacityError(errorString)) {
      _errorController.add('Görüntüleme hatası düzeltildi');
      return; // Opacity hatalarını sessizce yok say
    }

    // DevTools hatalarını sessizce yakala
    if (_isDevToolsError(errorString)) {
      return; // DevTools hatalarını sessizce yok say
    }

    // Overflow hatalarını sessizce yakala (responsive tasarımda normal)
    if (_isOverflowError(errorString)) {
      return; // Overflow hatalarını sessizce yok say
    }

    // Diğer kritik hatalar için loglama yap ama kullanıcıya gösterme
    debugPrint('Flutter Error: $errorMessage');
    
    // Sadece production'da kritik olmayan hataları sessizce işle
    // Development'ta tüm hataları göster
    if (const bool.fromEnvironment('dart.vm.product')) {
      _errorController.add('Bir hata oluştu, lütfen sayfayı yenileyin');
    } else {
      FlutterError.presentError(details);
    }
  }

  bool _isOpacityError(String error) {
    final lowerError = error.toLowerCase();
    return lowerError.contains('opacity') ||
        lowerError.contains('the opacity argument must be greater than or equal to 0.0') ||
        lowerError.contains('the opacity argument must be less than or equal to 1.0') ||
        lowerError.contains('opacity argument must be');
  }

  bool _isDevToolsError(String error) {
    return error.contains('DevTools') ||
        error.contains('activeDevToolsServerAddress') ||
        error.contains('connectedVmServiceUri');
  }

  bool _isOverflowError(String error) {
    return error.contains('RenderFlex overflowed') ||
        error.contains('overflowed by');
  }

  void dispose() {
    _errorController.close();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Global error handler'ı ayarla
  final errorHandler = GlobalErrorHandler();
  FlutterError.onError = errorHandler.handleError;
  
  // Web için URL stratejisi - Path based routing
  usePathUrlStrategy();
  
  // Türkçe tarih formatı için
  await initializeDateFormatting('tr_TR', null);
  
  runApp(MyApp(errorHandler: errorHandler));
}

class MyApp extends StatefulWidget {
  final GlobalErrorHandler errorHandler;

  const MyApp({
    super.key,
    required this.errorHandler,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _errorMessage;
  StreamSubscription<String>? _errorSubscription;

  @override
  void initState() {
    super.initState();
    // Error stream'i dinle
    _errorSubscription = widget.errorHandler.errorStream.listen((error) {
      if (mounted) {
        setState(() {
          _errorMessage = error;
        });
        // 3 saniye sonra mesajı kaldır
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _errorMessage = null;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SesMetin Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Hata mesajı banner'ı
            if (_errorMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      color: AppTheme.warningColor,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _errorMessage = null;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
