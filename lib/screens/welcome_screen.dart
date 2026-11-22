import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Экран приветствия NEXO.
///
/// Тема (светлая/тёмная) берётся из текущей темы приложения.
/// Навигация и смена языка не зашиты: передайте [onLogin] и
/// [onLanguageTap] снаружи.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    this.onLogin,
    this.onLanguageTap,
    this.title = 'NEXO',
    this.slogan = 'Больше, чем просто чат',
    this.loginLabel = 'Войти',
    this.languageLabel = 'Continue in English',
    this.logoAsset = 'assets/images/nexo_logo.png',
  });

  /// Нажатие на главную кнопку «Войти».
  final VoidCallback? onLogin;

  /// Нажатие на кнопку смены языка.
  final VoidCallback? onLanguageTap;

  final String title;
  final String slogan;
  final String loginLabel;

  /// Текст кнопки смены языка (предлагается другой язык, как в Telegram).
  final String languageLabel;
  final String logoAsset;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const String _font = 'Montserrat';

  // Фирменные цвета.
  static const Color _primary = Color(0xFF713BFF);
  static const Color _darkBg = Color(0xFF080A2B);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lightTitle = Color(0xFF1E1B4B);
  static const Color _lightSlogan = Color(0xFF4B4A75);

  late final AnimationController _waves = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Уважаем системную настройку «убрать анимацию».
    if (MediaQuery.disableAnimationsOf(context)) {
      _waves.stop();
    } else if (!_waves.isAnimating) {
      _waves.repeat();
    }
  }

  @override
  void dispose() {
    _waves.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size screen = MediaQuery.sizeOf(context);

    final double logoSize = (screen.width * 0.58).clamp(140.0, 280.0);
    final double titleSize = (screen.width * 0.12).clamp(36.0, 52.0);
    final double sloganSize = (screen.width * 0.042).clamp(14.0, 18.0);
    final double hPadding = (screen.width * 0.10).clamp(24.0, 56.0);
    final double bottomPadding = (screen.height * 0.05).clamp(20.0, 56.0);

    final Color titleColor = isDark ? _white : _lightTitle;
    final Color sloganColor = isDark ? _white.withAlpha(204) : _lightSlogan;
    final Color languageColor = isDark ? _white : _primary;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: isDark ? _darkBg : _white,
        body: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _WelcomeBackgroundPainter(
                    isDark: isDark,
                    animation: _waves,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                physics: const ClampingScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        hPadding,
                        0,
                        hPadding,
                        bottomPadding,
                      ),
                      child: Column(
                        children: [
                          const Spacer(flex: 9),
                          Image.asset(
                            widget.logoAsset,
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: _font,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              height: 1.1,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.slogan,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: _font,
                              fontSize: sloganSize,
                              fontWeight: FontWeight.w500,
                              color: sloganColor,
                            ),
                          ),
                          const Spacer(flex: 5),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: widget.onLogin ?? () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primary,
                                foregroundColor: _white,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontFamily: _font,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(widget.loginLabel),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: widget.onLanguageTap ?? () {},
                            style: TextButton.styleFrom(
                              foregroundColor: languageColor,
                              minimumSize: const Size(120, 44),
                              textStyle: const TextStyle(
                                fontFamily: _font,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: Text(widget.languageLabel),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Фон: большие плавные анимированные фиолетовые формы по углам.
///
/// Анимация зациклена: все смещения — синусы с целым числом периодов,
/// поэтому в конце цикла форма совпадает с началом без рывка.
class _WelcomeBackgroundPainter extends CustomPainter {
  _WelcomeBackgroundPainter({
    required this.isDark,
    required this.animation,
  }) : super(repaint: animation);

  final bool isDark;
  final Animation<double> animation;

  static Color _c(int rgb, double alpha) =>
      Color(0xFF000000 | rgb).withAlpha((alpha * 255).round());

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect rect = Offset.zero & size;
    final double phase = animation.value * 2 * math.pi;

    // Плавное смещение: амплитуда [amp] в долях размера, сдвиг фазы [shift].
    double s(double shift, double amp) => math.sin(phase + shift) * amp;

    if (isDark) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0D33), Color(0xFF080A2B), Color(0xFF120B3E)],
            stops: [0.0, 0.55, 1.0],
          ).createShader(rect),
      );

      // Верхний правый угол: большая плавная форма.
      final Path top = Path()
        ..moveTo(w * 0.25, 0)
        ..cubicTo(
          w * (0.32 + s(0.0, 0.05)),
          h * (0.11 + s(1.0, 0.02)),
          w * (0.68 + s(2.0, 0.05)),
          h * (0.12 + s(3.0, 0.02)),
          w,
          h * (0.28 + s(4.0, 0.015)),
        )
        ..lineTo(w, 0)
        ..close();
      canvas.drawPath(
        top,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c(0x713BFF, 0.06), _c(0x713BFF, 0.34)],
          ).createShader(rect),
      );

      // Нижняя волна (дальняя).
      final Path waveBack = Path()
        ..moveTo(0, h * (0.66 + s(0.5, 0.015)))
        ..cubicTo(
          w * (0.36 + s(1.5, 0.06)),
          h * (0.56 + s(2.5, 0.03)),
          w * (0.64 + s(3.5, 0.06)),
          h * (0.88 + s(4.5, 0.03)),
          w,
          h * (0.68 + s(5.5, 0.015)),
        )
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        waveBack,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c(0x713BFF, 0.10), _c(0xB66CFF, 0.40)],
          ).createShader(rect),
      );

      // Нижняя волна (ближняя), двигается в другой фазе.
      final Path waveFront = Path()
        ..moveTo(0, h * (0.84 + s(3.0, 0.012)))
        ..cubicTo(
          w * (0.34 + s(4.0, 0.06)),
          h * (0.76 + s(5.0, 0.025)),
          w * (0.66 + s(6.0, 0.06)),
          h * (0.98 + s(0.8, 0.02)),
          w,
          h * (0.82 + s(1.8, 0.012)),
        )
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        waveFront,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [_c(0x713BFF, 0.24), _c(0xB66CFF, 0.32)],
          ).createShader(rect),
      );
    } else {
      // Чисто белый фон, чтобы не было видно границ у логотипа.
      canvas.drawRect(rect, Paint()..color = const Color(0xFFFFFFFF));

      // Верхний левый угол: внешний слой (большой).
      final Path topOuter = Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.85, 0)
        ..cubicTo(
          w * (0.80 + s(0.0, 0.05)),
          h * (0.12 + s(1.0, 0.02)),
          w * (0.38 + s(2.0, 0.06)),
          h * (0.14 + s(3.0, 0.025)),
          0,
          h * (0.34 + s(4.0, 0.015)),
        )
        ..close();
      canvas.drawPath(
        topOuter,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c(0xB66CFF, 0.26), _c(0x713BFF, 0.07)],
          ).createShader(rect),
      );

      // Верхний левый угол: внутренний слой.
      final Path topInner = Path()
        ..moveTo(0, 0)
        ..lineTo(w * 0.55, 0)
        ..cubicTo(
          w * (0.50 + s(2.5, 0.05)),
          h * (0.08 + s(3.5, 0.02)),
          w * (0.22 + s(4.5, 0.05)),
          h * (0.10 + s(5.5, 0.02)),
          0,
          h * (0.20 + s(0.5, 0.012)),
        )
        ..close();
      canvas.drawPath(
        topInner,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_c(0x713BFF, 0.18), _c(0xB66CFF, 0.06)],
          ).createShader(rect),
      );

      // Нижний правый угол: внешний слой (большой).
      final Path bottomOuter = Path()
        ..moveTo(w, h * (0.60 + s(1.0, 0.015)))
        ..cubicTo(
          w * (0.80 + s(2.0, 0.05)),
          h * (0.66 + s(3.0, 0.025)),
          w * (0.62 + s(4.0, 0.06)),
          h * (0.86 + s(5.0, 0.025)),
          w * (0.22 + s(6.0, 0.03)),
          h,
        )
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        bottomOuter,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [_c(0xB66CFF, 0.10), _c(0x713BFF, 0.24)],
          ).createShader(rect),
      );

      // Нижний правый угол: внутренний слой, темнее.
      final Path bottomInner = Path()
        ..moveTo(w, h * (0.76 + s(3.5, 0.012)))
        ..cubicTo(
          w * (0.86 + s(4.5, 0.04)),
          h * (0.80 + s(5.5, 0.02)),
          w * (0.74 + s(0.3, 0.05)),
          h * (0.92 + s(1.3, 0.02)),
          w * (0.50 + s(2.3, 0.03)),
          h,
        )
        ..lineTo(w, h)
        ..close();
      canvas.drawPath(
        bottomInner,
        Paint()..color = _c(0x713BFF, 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WelcomeBackgroundPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}