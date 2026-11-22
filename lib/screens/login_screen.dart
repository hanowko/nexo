import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Экран авторизации NEXO (вход в аккаунт).
///
/// Настоящая авторизация не реализована: экран только проверяет
/// заполнение полей и передаёт введённые данные в [onLogin].
/// Все переходы и действия передаются снаружи через callback-параметры.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.onBack,
    this.onLogin,
    this.onGoogle,
    this.onApple,
    this.onRegister,
  });

  /// Кнопка «назад». Если не передан, выполняется Navigator.maybePop.
  final VoidCallback? onBack;

  /// Вызывается после успешной проверки полей: (логин или почта, пароль).
  final void Function(String identifier, String password)? onLogin;

  /// Кнопка «Продолжить с Google».
  final VoidCallback? onGoogle;

  /// Кнопка «Продолжить с Apple».
  final VoidCallback? onApple;

  /// Ссылка «Зарегистрироваться».
  final VoidCallback? onRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _font = 'Montserrat';

  // Фирменные цвета.
  static const Color _primary = Color(0xFF713BFF);
  static const Color _secondary = Color(0xFFB66CFF);
  static const Color _darkBg = Color(0xFF080A2B);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lightTitle = Color(0xFF1E1B4B);
  static const Color _lightSub = Color(0xFF5B5A80);
  static const Color _lightField = Color(0xFFF3F1FF);
  static const Color _error = Color(0xFFFF5C7A);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ---------- Проверка полей ----------

  String? _validateIdentifier(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Введите почту или никнейм';
    if (v.contains('@')) {
      final RegExp email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
      if (!email.hasMatch(v)) return 'Некорректная почта';
    } else if (v.length < 3) {
      return 'Никнейм слишком короткий (минимум 3 символа)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Введите пароль';
    if (v.length < 6) return 'Пароль слишком короткий (минимум 6 символов)';
    return null;
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin?.call(
        _identifierController.text.trim(),
        _passwordController.text,
      );
    }
  }

  // ---------- Оформление ----------

  InputDecoration _fieldDecoration({
    required bool isDark,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final Color fill =
        isDark ? _white.withAlpha(15) : _lightField; // ~6% белого в тёмной
    final Color hintColor = isDark ? _white.withAlpha(115) : _lightSub;
    final Color iconColor = isDark ? _white.withAlpha(166) : _lightSub;
    final Color borderColor = isDark ? _white.withAlpha(20) : Colors.transparent;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: _font,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: hintColor,
      ),
      errorStyle: const TextStyle(
        fontFamily: _font,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _error,
      ),
      errorMaxLines: 2,
      filled: true,
      fillColor: fill,
      prefixIcon: Icon(icon, size: 22, color: iconColor),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: border(borderColor),
      border: border(borderColor),
      focusedBorder: border(_primary, 1.5),
      errorBorder: border(_error),
      focusedErrorBorder: border(_error, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size screen = MediaQuery.sizeOf(context);

    final double hPadding = (screen.width * 0.07).clamp(20.0, 40.0);
    final double titleSize = (screen.width * 0.07).clamp(24.0, 30.0);

    final Color titleColor = isDark ? _white : _lightTitle;
    final Color subColor = isDark ? _white.withAlpha(178) : _lightSub;
    final Color textColor = isDark ? _white : _lightTitle;
    final Color lineColor = isDark ? _white.withAlpha(31) : const Color(0x1F1E1B4B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: isDark ? _darkBg : _white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(child: _Background(isDark: isDark)),
            SafeArea(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => FocusScope.of(context).unfocus(),
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hPadding, 8, hPadding, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Кнопка «назад».
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _BackButton(
                                isDark: isDark,
                                onPressed: widget.onBack ??
                                    () => Navigator.maybePop(context),
                              ),
                            ),
                            SizedBox(height: screen.height * 0.04),

                            // 2-3. Заголовок и подзаголовок.
                            Text(
                              'Вход в аккаунт',
                              style: TextStyle(
                                fontFamily: _font,
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                color: titleColor,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Рады снова видеть вас!',
                              style: TextStyle(
                                fontFamily: _font,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: subColor,
                              ),
                            ),
                            SizedBox(height: screen.height * 0.04),

                            // 4-5. Поля ввода.
                            Form(
                              key: _formKey,
                              autovalidateMode: _submitted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _identifierController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    cursorColor: _primary,
                                    style: TextStyle(
                                      fontFamily: _font,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: 'Почта или никнейм',
                                      icon: Icons.mail_outline_rounded,
                                    ),
                                    validator: _validateIdentifier,
                                    onFieldSubmitted: (_) =>
                                        _passwordFocus.requestFocus(),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocus,
                                    obscureText: _obscurePassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    textInputAction: TextInputAction.done,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    cursorColor: _primary,
                                    style: TextStyle(
                                      fontFamily: _font,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: textColor,
                                    ),
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: 'Пароль',
                                      icon: Icons.lock_outline_rounded,
                                      suffix: IconButton(
                                        tooltip: _obscurePassword
                                            ? 'Показать пароль'
                                            : 'Скрыть пароль',
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 22,
                                          color: isDark
                                              ? _white.withAlpha(166)
                                              : _lightSub,
                                        ),
                                        onPressed: () => setState(() =>
                                            _obscurePassword =
                                                !_obscurePassword),
                                      ),
                                    ),
                                    validator: _validatePassword,
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 6. Кнопка «Войти».
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primary,
                                  foregroundColor: _white,
                                  elevation: 0,
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                    fontFamily: _font,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                child: const Text('Войти'),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 7. Разделитель «или».
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: lineColor, height: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  child: Text(
                                    'или',
                                    style: TextStyle(
                                      fontFamily: _font,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: subColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: lineColor, height: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // 8. Google.
                            _SocialButton(
                              isDark: isDark,
                              label: 'Продолжить с Google',
                              icon: const SizedBox(
                                width: 22,
                                height: 22,
                                child: CustomPaint(painter: _GoogleLogoPainter()),
                              ),
                              onPressed: widget.onGoogle ?? () {},
                            ),
                            const SizedBox(height: 12),

                            // 9. Apple.
                            _SocialButton(
                              isDark: isDark,
                              label: 'Продолжить с Apple',
                              icon: Icon(
                                Icons.apple,
                                size: 26,
                                color: isDark ? _white : Colors.black,
                              ),
                              onPressed: widget.onApple ?? () {},
                            ),

                            const Spacer(),
                            const SizedBox(height: 24),

                            // 10. «Нет аккаунта? Зарегистрироваться».
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Нет аккаунта? ',
                                    style: TextStyle(
                                      fontFamily: _font,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: subColor,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: widget.onRegister ?? () {},
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        'Зарегистрироваться',
                                        style: TextStyle(
                                          fontFamily: _font,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? _secondary : _primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Круглая кнопка «назад».
class _BackButton extends StatelessWidget {
  const _BackButton({required this.isDark, required this.onPressed});

  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? const Color(0xFFFFFFFF).withAlpha(15)
          : const Color(0xFFF3F1FF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1E1B4B),
          ),
        ),
      ),
    );
  }
}

/// Кнопка входа через сторонний сервис (Google / Apple).
class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.isDark,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final bool isDark;
  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1E1B4B),
          backgroundColor: isDark
              ? const Color(0xFFFFFFFF).withAlpha(10)
              : const Color(0xFFFFFFFF),
          side: BorderSide(
            color: isDark
                ? const Color(0xFFFFFFFF).withAlpha(36)
                : const Color(0x261E1B4B),
          ),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Фон экрана: тёмный градиент со свечением / чистый белый.
class _Background extends StatelessWidget {
  const _Background({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (!isDark) {
      return const ColoredBox(color: Color(0xFFFFFFFF));
    }
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B0D33), Color(0xFF080A2B), Color(0xFF0E0A33)],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(1.1, -1.0),
            radius: 0.9,
            colors: [Color(0x40713BFF), Color(0x00713BFF)],
          ),
        ),
      ),
    );
  }
}

/// Логотип Google «G», нарисованный кодом (без картинок и пакетов).
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double stroke = size.width * 0.2;
    final double radius = (size.width - stroke) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    double rad(double deg) => deg * 3.1415926535 / 180;

    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Углы в градусах: 0 — справа, по часовой стрелке.
    canvas.drawArc(rect, rad(215), rad(100), false, arc(const Color(0xFFEA4335)));
    canvas.drawArc(rect, rad(135), rad(80), false, arc(const Color(0xFFFBBC05)));
    canvas.drawArc(rect, rad(45), rad(90), false, arc(const Color(0xFF34A853)));
    canvas.drawArc(rect, rad(0), rad(45), false, arc(const Color(0xFF4285F4)));

    // Горизонтальная перекладина буквы G.
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width - stroke / 2, center.dy),
      arc(const Color(0xFF4285F4)),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}