import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/chat_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/welcome_screen.dart';

class NexoApp extends StatelessWidget {
  const NexoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEXO',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Builder нужен, чтобы получить context внутри Navigator.
      home: Builder(
        builder: (BuildContext context) => WelcomeScreen(
          onLogin: () => _openLogin(context),
        ),
      ),
    );
  }

  /// Приветствие -> вход.
  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext loginContext) => LoginScreen(
          onRegister: () => _openRegister(loginContext),
          // TODO: заменить на настоящую авторизацию (Firebase).
          // Сейчас любой корректно заполненный вход открывает чаты.
          onLogin: (String identifier, String password) =>
              _openChats(loginContext),
        ),
      ),
    );
  }

  /// Вход -> регистрация.
  void _openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext registerContext) => RegisterScreen(
          // Регистрация открыта поверх входа, поэтому «Войти» просто
          // закрывает её и возвращает на экран входа.
          onLogin: () => Navigator.of(registerContext).pop(),
          // TODO: заменить на настоящую регистрацию (Firebase).
          // Сейчас любая корректно заполненная форма открывает чаты.
          onRegister: (String username, String email, String password) =>
              _openChats(registerContext),
        ),
      ),
    );
  }

  /// Открывает список чатов и очищает историю экранов,
  /// чтобы «назад» не возвращал на вход.
  void _openChats(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (BuildContext chatsContext) => ChatsScreen(
          onChatTap: (ChatPreview chat) => _openChat(chatsContext, chat),
          // TODO: создание чата, контакты и профиль пока без экранов.
        ),
      ),
      (Route<dynamic> route) => false,
    );
  }

  /// Список чатов -> переписка.
  void _openChat(BuildContext context, ChatPreview chat) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          contactId: chat.id,
          contactName: chat.name,
          contactStatus: chat.isGroup ? 'группа' : 'в сети',
          isOnline: !chat.isGroup,
          // TODO: подставить настоящие сообщения и статус из базы.
        ),
      ),
    );
  }
}