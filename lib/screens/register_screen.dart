import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Экран регистрации NEXO.
///
/// Настоящая регистрация не реализована и успех не имитируется:
/// экран только проверяет поля и передаёт данные в [onRegister].
/// Все действия и переходы передаются снаружи через callback-параметры.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    this.onBack,
    this.onRegister,
    this.onLogin,
  });

  /// Кнопка «назад». Если не передан, выполняется Navigator.maybePop.
  final VoidCallback? onBack;

  /// Вызывается после успешной проверки полей:
  /// (имя пользователя, почта, пароль).
  final void Function(String username, String email, String password)?
      onRegister;

  /// Ссылка «Войти» («Уже есть аккаунт?»).
  final VoidCallback? onLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _submitted = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ---------- Проверка полей ----------

  String? _validateUsername(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Введите имя пользователя';
    if (v.length < 3) return 'Имя слишком короткое (минимум 3 символа)';
    if (v.length > 24) return 'Имя слишком длинное (максимум 24 символа)';
    if (!RegExp(r'^[A-Za-zА-Яа-яЁё0-9_.]+$').hasMatch(v)) {
      return 'Только буквы, цифры, «_» и «.»';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final String v = (value ?? '').trim();
    if (v.isEmpty) return 'Введите почту';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(v)) {
      return 'Некорректная почта';
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
      widget.onRegister?.call(
        _usernameController.text.trim(),
        _emailController.text.trim(),
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
    final Color fill = isDark ? _white.withAlpha(15) : _lightField;
    final Color hintColor = isDark ? _white.withAlpha(115) : _lightSub;
    final Color iconColor = isDark ? _white.withAlpha(166) : _lightSub;
    final Color borderColor =
        isDark ? _white.withAlpha(20) : Colors.transparent;

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

    final TextStyle fieldTextStyle = TextStyle(
      fontFamily: _font,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: textColor,
    );

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
                              'Регистрация',
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
                              'Создайте аккаунт NEXO',
                              style: TextStyle(
                                fontFamily: _font,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: subColor,
                              ),
                            ),
                            SizedBox(height: screen.height * 0.04),

                            // 4-6. Поля ввода.
                            Form(
                              key: _formKey,
                              autovalidateMode: _submitted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _usernameController,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    cursorColor: _primary,
                                    style: fieldTextStyle,
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: 'Имя пользователя',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                    validator: _validateUsername,
                                    onFieldSubmitted: (_) =>
                                        _emailFocus.requestFocus(),
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    cursorColor: _primary,
                                    style: fieldTextStyle,
                                    decoration: _fieldDecoration(
                                      isDark: isDark,
                                      hint: 'Почта',
                                      icon: Icons.mail_outline_rounded,
                                    ),
                                    validator: _validateEmail,
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
                                    style: fieldTextStyle,
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

                            // 7. Кнопка «Зарегистрироваться».
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
                                child: const Text('Зарегистрироваться'),
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 24),

                            // 8. «Уже есть аккаунт? Войти».
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    'Уже есть аккаунт? ',
                                    style: TextStyle(
                                      fontFamily: _font,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: subColor,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: widget.onLogin ?? () {},
                                    borderRadius: BorderRadius.circular(6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                        horizontal: 2,
                                      ),
                                      child: Text(
                                        'Войти',
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