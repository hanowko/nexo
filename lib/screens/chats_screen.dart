import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Краткие данные о диалоге для списка чатов.
///
/// Временная модель для демонстрации. Когда появится база данных,
/// её можно заменить на настоящую модель чата.
class ChatPreview {
  const ChatPreview({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isGroup = false,
  });

  final String id;

  /// Имя пользователя или название группы.
  final String name;

  /// Текст последнего сообщения.
  final String lastMessage;

  /// Время последнего сообщения в готовом для показа виде.
  final String time;

  /// Количество непрочитанных сообщений (0 — счётчик не показывается).
  final int unreadCount;

  final bool isGroup;
}

/// Главный экран NEXO: список чатов.
///
/// Работает на демонстрационных данных. Все переходы и действия
/// передаются снаружи через callback-параметры.
class ChatsScreen extends StatefulWidget {
  const ChatsScreen({
    super.key,
    this.chats = demoChats,
    this.onNewChat,
    this.onChatTap,
    this.onChatsTap,
    this.onContactsTap,
    this.onProfileTap,
  });

  /// Демонстрационные данные.
  static const List<ChatPreview> demoChats = [
    ChatPreview(
      id: '1',
      name: 'Алексей',
      lastMessage: 'Привет! 🔥',
      time: '19:42',
      unreadCount: 2,
    ),
    ChatPreview(
      id: '2',
      name: 'Мария',
      lastMessage: 'Отлично!',
      time: '18:30',
    ),
    ChatPreview(
      id: '3',
      name: 'Группа проекта',
      lastMessage: 'Денис: Готово!',
      time: '17:20',
      unreadCount: 5,
      isGroup: true,
    ),
    ChatPreview(
      id: '4',
      name: 'Иван',
      lastMessage: 'Хорошо, спасибо!',
      time: '16:15',
    ),
    ChatPreview(
      id: '5',
      name: 'Друзья',
      lastMessage: 'Фото',
      time: 'Вчера',
      isGroup: true,
    ),
  ];

  /// Список диалогов для показа.
  final List<ChatPreview> chats;

  /// Кнопка «+» (создать новый чат).
  final VoidCallback? onNewChat;

  /// Нажатие на диалог: передаёт его данные.
  final ValueChanged<ChatPreview>? onChatTap;

  /// Нижняя вкладка «Чаты».
  final VoidCallback? onChatsTap;

  /// Нижняя вкладка «Контакты».
  final VoidCallback? onContactsTap;

  /// Нижняя вкладка «Профиль».
  final VoidCallback? onProfileTap;

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  static const String _font = 'Montserrat';

  // Фирменные цвета.
  static const Color _primary = Color(0xFF713BFF);
  static const Color _secondary = Color(0xFFB66CFF);
  static const Color _darkBg = Color(0xFF080A2B);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lightTitle = Color(0xFF1E1B4B);
  static const Color _lightSub = Color(0xFF5B5A80);
  static const Color _lightField = Color(0xFFF3F1FF);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatPreview> get _filteredChats {
    final String q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.chats;
    return widget.chats
        .where((ChatPreview c) =>
            c.name.toLowerCase().contains(q) ||
            c.lastMessage.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size screen = MediaQuery.sizeOf(context);

    final double hPadding = (screen.width * 0.06).clamp(16.0, 32.0);
    final double titleSize = (screen.width * 0.075).clamp(26.0, 32.0);

    final Color titleColor = isDark ? _white : _lightTitle;
    final Color subColor = isDark ? _white.withAlpha(166) : _lightSub;
    final Color accent = isDark ? _secondary : _primary;

    final List<ChatPreview> chats = _filteredChats;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: isDark ? const Color(0xFF0B0D33) : _white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? _darkBg : _white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            Positioned.fill(child: _Background(isDark: isDark)),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // 1-2. Заголовок и кнопка «+».
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Чаты',
                            style: TextStyle(
                              fontFamily: _font,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Material(
                          color: _primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: widget.onNewChat ?? () {},
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.add_rounded,
                                size: 26,
                                color: _white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Строка поиска.
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPadding),
                    child: _SearchField(
                      isDark: isDark,
                      controller: _searchController,
                      onChanged: (String v) => setState(() => _query = v),
                      onClear: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 4. Список диалогов.
                  Expanded(
                    child: chats.isEmpty
                        ? _EmptyState(
                            isDark: isDark,
                            color: subColor,
                            hasQuery: _query.trim().isNotEmpty,
                          )
                        : ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.fromLTRB(
                              hPadding - 8,
                              4,
                              hPadding - 8,
                              16,
                            ),
                            itemCount: chats.length,
                            itemBuilder: (BuildContext context, int index) {
                              final ChatPreview chat = chats[index];
                              return _ChatTile(
                                chat: chat,
                                isDark: isDark,
                                titleColor: titleColor,
                                subColor: subColor,
                                accent: accent,
                                onTap: () => widget.onChatTap?.call(chat),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Нижняя навигация.
        bottomNavigationBar: _BottomNav(
          isDark: isDark,
          accent: accent,
          inactiveColor: subColor,
          onChatsTap: widget.onChatsTap,
          onContactsTap: widget.onContactsTap,
          onProfileTap: widget.onProfileTap,
        ),
      ),
    );
  }
}

/// Строка поиска.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.isDark,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final bool isDark;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const String font = 'Montserrat';
    final Color fill =
        isDark ? const Color(0x0FFFFFFF) : const Color(0xFFF3F1FF);
    final Color hint =
        isDark ? const Color(0x73FFFFFF) : const Color(0xFF5B5A80);
    final Color icon =
        isDark ? const Color(0xA6FFFFFF) : const Color(0xFF5B5A80);
    final Color text = isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1E1B4B);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          cursorColor: const Color(0xFF713BFF),
          style: TextStyle(
            fontFamily: font,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: text,
          ),
          decoration: InputDecoration(
            hintText: 'Поиск',
            hintStyle: TextStyle(
              fontFamily: font,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: hint,
            ),
            filled: true,
            fillColor: fill,
            prefixIcon: Icon(Icons.search_rounded, size: 22, color: icon),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Очистить',
                    icon: Icon(Icons.close_rounded, size: 20, color: icon),
                    onPressed: onClear,
                  ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: border(
              isDark ? const Color(0x14FFFFFF) : Colors.transparent,
            ),
            border: border(
              isDark ? const Color(0x14FFFFFF) : Colors.transparent,
            ),
            focusedBorder: border(const Color(0xFF713BFF), 1.5),
          ),
        );
      },
    );
  }
}

/// Один диалог в списке.
class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.isDark,
    required this.titleColor,
    required this.subColor,
    required this.accent,
    required this.onTap,
  });

  final ChatPreview chat;
  final bool isDark;
  final Color titleColor;
  final Color subColor;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const String font = 'Montserrat';
    final bool hasUnread = chat.unreadCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              _Avatar(chat: chat),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    chat.time,
                    style: TextStyle(
                      fontFamily: font,
                      fontSize: 12,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                      color: hasUnread ? accent : subColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasUnread)
                    _UnreadBadge(count: chat.unreadCount)
                  else
                    const SizedBox(height: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Счётчик непрочитанных сообщений.
class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF713BFF),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
          height: 1.1,
        ),
      ),
    );
  }
}

/// Аватар с инициалами и цветным градиентом (вместо реальных фото).
class _Avatar extends StatelessWidget {
  const _Avatar({required this.chat});

  final ChatPreview chat;

  static const List<List<Color>> _palettes = [
    [Color(0xFF713BFF), Color(0xFFB66CFF)],
    [Color(0xFF3B82F6), Color(0xFF7C9CFF)],
    [Color(0xFFEC4899), Color(0xFFF59ABF)],
    [Color(0xFF10B981), Color(0xFF5ED8B0)],
    [Color(0xFFF59E0B), Color(0xFFF9C25E)],
    [Color(0xFF6366F1), Color(0xFFA5A8FF)],
  ];

  String get _initials {
    final List<String> parts = chat.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final int hash = chat.id.codeUnits.fold<int>(0, (int a, int b) => a + b);
    final List<Color> colors = _palettes[hash % _palettes.length];

    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: chat.isGroup
          ? const Icon(Icons.group_rounded, size: 26, color: Color(0xFFFFFFFF))
          : Text(
              _initials,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFFFFFF),
              ),
            ),
    );
  }
}

/// Пустое состояние списка (ничего не найдено / нет чатов).
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isDark,
    required this.color,
    required this.hasQuery,
  });

  final bool isDark;
  final Color color;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasQuery ? Icons.search_off_rounded : Icons.chat_bubble_outline,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              hasQuery ? 'Ничего не найдено' : 'Пока нет чатов',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Нижняя навигация: Чаты / Контакты / Профиль.
/// На этом экране активна вкладка «Чаты».
class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.isDark,
    required this.accent,
    required this.inactiveColor,
    required this.onChatsTap,
    required this.onContactsTap,
    required this.onProfileTap,
  });

  final bool isDark;
  final Color accent;
  final Color inactiveColor;
  final VoidCallback? onChatsTap;
  final VoidCallback? onContactsTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0D33) : const Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0x1AFFFFFF) : const Color(0x141E1B4B),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                label: 'Чаты',
                activeIcon: Icons.chat_bubble_rounded,
                inactiveIcon: Icons.chat_bubble_outline_rounded,
                selected: true,
                accent: accent,
                inactiveColor: inactiveColor,
                onTap: onChatsTap ?? () {},
              ),
              _NavItem(
                label: 'Контакты',
                activeIcon: Icons.contacts_rounded,
                inactiveIcon: Icons.contacts_outlined,
                selected: false,
                accent: accent,
                inactiveColor: inactiveColor,
                onTap: onContactsTap ?? () {},
              ),
              _NavItem(
                label: 'Профиль',
                activeIcon: Icons.person_rounded,
                inactiveIcon: Icons.person_outline_rounded,
                selected: false,
                accent: accent,
                inactiveColor: inactiveColor,
                onTap: onProfileTap ?? () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.selected,
    required this.accent,
    required this.inactiveColor,
    required this.onTap,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool selected;
  final Color accent;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? accent : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? activeIcon : inactiveIcon, size: 26, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
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
    );
  }
}