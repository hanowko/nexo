import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Статус исходящего сообщения.
enum MessageStatus {
  /// Отправлено (одна галочка).
  sent,

  /// Прочитано (две галочки).
  read,
}

/// Сообщение в переписке.
///
/// Временная модель для демонстрации. Когда появится база данных,
/// её можно заменить на настоящую модель сообщения.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.time,
    required this.isMine,
    this.status = MessageStatus.sent,
  });

  final String id;
  final String text;

  /// Время в готовом для показа виде («19:42»).
  final String time;

  /// true — сообщение текущего пользователя (справа).
  final bool isMine;

  /// Используется только для исходящих сообщений.
  final MessageStatus status;
}

/// Экран переписки NEXO.
///
/// Работает на демонстрационных данных. Все действия и переходы
/// передаются снаружи через callback-параметры. Отправленное сообщение
/// добавляется только в локальный список экрана.
class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.contactId = '1',
    this.contactName = 'Алексей',
    this.contactStatus = 'в сети',
    this.isOnline = true,
    this.initialMessages = demoMessages,
    this.onBack,
    this.onCall,
    this.onVideoCall,
    this.onAttach,
    this.onEmoji,
    this.onSend,
  });

  /// Демонстрационные сообщения.
  static const List<ChatMessage> demoMessages = [
    ChatMessage(
      id: 'm1',
      text: 'Привет! Как дела?',
      time: '19:35',
      isMine: false,
    ),
    ChatMessage(
      id: 'm2',
      text: 'Отлично! А у тебя?',
      time: '19:36',
      isMine: true,
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: 'm3',
      text: 'Давай созвонимся позже?',
      time: '19:37',
      isMine: false,
    ),
    ChatMessage(
      id: 'm4',
      text: 'Хорошо 👍',
      time: '19:38',
      isMine: true,
      status: MessageStatus.read,
    ),
  ];

  /// Идентификатор собеседника (влияет на цвет аватара).
  final String contactId;

  /// Имя собеседника.
  final String contactName;

  /// Текст статуса под именем («в сети», «был(а) недавно» и т. д.).
  final String contactStatus;

  /// Показывать зелёный индикатор рядом со статусом.
  final bool isOnline;

  /// Сообщения для показа при открытии экрана.
  final List<ChatMessage> initialMessages;

  /// Стрелка «назад». Если не передан, выполняется Navigator.maybePop.
  final VoidCallback? onBack;

  /// Иконка обычного звонка.
  final VoidCallback? onCall;

  /// Иконка видеозвонка.
  final VoidCallback? onVideoCall;

  /// Кнопка прикрепления файла.
  final VoidCallback? onAttach;

  /// Кнопка эмодзи.
  final VoidCallback? onEmoji;

  /// Вызывается после добавления нового сообщения в список (текст).
  final ValueChanged<String>? onSend;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const String _font = 'Montserrat';

  // Фирменные цвета.
  static const Color _primary = Color(0xFF713BFF);
  static const Color _secondary = Color(0xFFB66CFF);
  static const Color _darkBg = Color(0xFF080A2B);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _lightTitle = Color(0xFF1E1B4B);
  static const Color _lightSub = Color(0xFF5B5A80);

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  late final List<ChatMessage> _messages =
      List<ChatMessage>.of(widget.initialMessages);

  @override
  void initState() {
    super.initState();
    // При открытии клавиатуры прокручиваем к последнему сообщению.
    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus) {
        Future<void>.delayed(
          const Duration(milliseconds: 350),
          _scrollToBottom,
        );
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(false));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom([bool animate = true]) {
    if (!mounted || !_scrollController.hasClients) return;
    final double target = _scrollController.position.maxScrollExtent;
    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  String _nowTime() {
    final DateTime now = DateTime.now();
    final String h = now.hour.toString().padLeft(2, '0');
    final String m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _send() {
    final String text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          id: 'local_${DateTime.now().microsecondsSinceEpoch}',
          text: text,
          time: _nowTime(),
          isMine: true,
          // Прочтения ещё нет: показываем одну галочку.
          status: MessageStatus.sent,
        ),
      );
    });
    _inputController.clear();
    widget.onSend?.call(text);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Size screen = MediaQuery.sizeOf(context);

    final double hPadding = (screen.width * 0.04).clamp(12.0, 24.0);

    final Color titleColor = isDark ? _white : _lightTitle;
    final Color subColor = isDark ? _white.withAlpha(166) : _lightSub;
    final Color accent = isDark ? _secondary : _primary;
    final Color lineColor =
        isDark ? _white.withAlpha(26) : const Color(0x141E1B4B);

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
            Column(
              children: [
                // Верхняя панель.
                _Header(
                  isDark: isDark,
                  contactId: widget.contactId,
                  name: widget.contactName,
                  status: widget.contactStatus,
                  isOnline: widget.isOnline,
                  titleColor: titleColor,
                  subColor: subColor,
                  accent: accent,
                  lineColor: lineColor,
                  hPadding: hPadding,
                  onBack:
                      widget.onBack ?? () => Navigator.maybePop(context),
                  onCall: widget.onCall ?? () {},
                  onVideoCall: widget.onVideoCall ?? () {},
                ),

                // Область сообщений.
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(hPadding, 16, hPadding, 12),
                      itemCount: _messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ChatMessage message = _messages[index];
                        return _MessageBubble(
                          message: message,
                          isDark: isDark,
                          maxWidth: screen.width * 0.78,
                        );
                      },
                    ),
                  ),
                ),

                // Нижняя панель ввода.
                _InputBar(
                  isDark: isDark,
                  controller: _inputController,
                  focusNode: _inputFocus,
                  hPadding: hPadding,
                  lineColor: lineColor,
                  onAttach: widget.onAttach ?? () {},
                  onEmoji: widget.onEmoji ?? () {},
                  onSend: _send,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Верхняя панель: назад, аватар, имя и статус, звонки.
class _Header extends StatelessWidget {
  const _Header({
    required this.isDark,
    required this.contactId,
    required this.name,
    required this.status,
    required this.isOnline,
    required this.titleColor,
    required this.subColor,
    required this.accent,
    required this.lineColor,
    required this.hPadding,
    required this.onBack,
    required this.onCall,
    required this.onVideoCall,
  });

  final bool isDark;
  final String contactId;
  final String name;
  final String status;
  final bool isOnline;
  final Color titleColor;
  final Color subColor;
  final Color accent;
  final Color lineColor;
  final double hPadding;
  final VoidCallback onBack;
  final VoidCallback onCall;
  final VoidCallback onVideoCall;

  @override
  Widget build(BuildContext context) {
    const String font = 'Montserrat';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0D33) : const Color(0xFFFFFFFF),
        border: Border(bottom: BorderSide(color: lineColor)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding - 8, 8, hPadding - 8, 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Назад',
                onPressed: onBack,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: titleColor,
                ),
              ),
              _Avatar(id: contactId, name: name, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (isOnline) ...[
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: subColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Видеозвонок',
                onPressed: onVideoCall,
                icon: Icon(Icons.videocam_outlined, size: 26, color: accent),
              ),
              IconButton(
                tooltip: 'Звонок',
                onPressed: onCall,
                icon: Icon(Icons.call_outlined, size: 24, color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Круглый аватар с инициалами (вместо реальных фото).
class _Avatar extends StatelessWidget {
  const _Avatar({required this.id, required this.name, required this.size});

  final String id;
  final String name;
  final double size;

  static const List<List<Color>> _palettes = [
    [Color(0xFF713BFF), Color(0xFFB66CFF)],
    [Color(0xFF3B82F6), Color(0xFF7C9CFF)],
    [Color(0xFFEC4899), Color(0xFFF59ABF)],
    [Color(0xFF10B981), Color(0xFF5ED8B0)],
    [Color(0xFFF59E0B), Color(0xFFF9C25E)],
    [Color(0xFF6366F1), Color(0xFFA5A8FF)],
  ];

  String get _initials {
    final List<String> parts = name
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
    final int hash = id.codeUnits.fold<int>(0, (int a, int b) => a + b);
    final List<Color> colors = _palettes[hash % _palettes.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}

/// Пузырь сообщения.
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isDark,
    required this.maxWidth,
  });

  final ChatMessage message;
  final bool isDark;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    const String font = 'Montserrat';
    final bool mine = message.isMine;

    final Color bubbleColor = mine
        ? const Color(0xFF713BFF)
        : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFF3F1FF));
    final Color textColor = mine
        ? const Color(0xFFFFFFFF)
        : (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1E1B4B));
    final Color timeColor = mine
        ? const Color(0xB3FFFFFF)
        : (isDark ? const Color(0x99FFFFFF) : const Color(0xFF5B5A80));

    // «Хвостик» пузыря: меньший радиус у нижнего угла со стороны автора.
    final BorderRadius radius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: Radius.circular(mine ? 20 : 6),
      bottomRight: Radius.circular(mine ? 6 : 20),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.text,
                      style: TextStyle(
                        fontFamily: font,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.time,
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: timeColor,
                            ),
                          ),
                          if (mine) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.status == MessageStatus.read
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                              size: 15,
                              color: timeColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Нижняя панель ввода: поле, скрепка, эмодзи, кнопка отправки.
class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.isDark,
    required this.controller,
    required this.focusNode,
    required this.hPadding,
    required this.lineColor,
    required this.onAttach,
    required this.onEmoji,
    required this.onSend,
  });

  final bool isDark;
  final TextEditingController controller;
  final FocusNode focusNode;
  final double hPadding;
  final Color lineColor;
  final VoidCallback onAttach;
  final VoidCallback onEmoji;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    const String font = 'Montserrat';
    final Color fill =
        isDark ? const Color(0x0FFFFFFF) : const Color(0xFFF3F1FF);
    final Color hint =
        isDark ? const Color(0x73FFFFFF) : const Color(0xFF5B5A80);
    final Color icon =
        isDark ? const Color(0xA6FFFFFF) : const Color(0xFF5B5A80);
    final Color text =
        isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1E1B4B);

    // Переопределяем тему полей ввода только для этого поля: общая тема
    // приложения (AppTheme) добавляла собственную заливку, из-за чего
    // внутри скруглённой «таблетки» был виден тёмный прямоугольник.
    final ThemeData fieldTheme = Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0D33) : const Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: lineColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPadding, 10, hPadding, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                // Container с clipBehavior обрезает всё содержимое по
                // скруглению, поэтому острых углов не остаётся.
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0x14FFFFFF)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Theme(
                          data: fieldTheme,
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            minLines: 1,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            cursorColor: const Color(0xFF713BFF),
                            style: TextStyle(
                              fontFamily: font,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: text,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Написать сообщение...',
                              hintStyle: TextStyle(
                                fontFamily: font,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: hint,
                              ),
                              filled: false,
                              fillColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(
                                18,
                                14,
                                4,
                                14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Прикрепить файл',
                        onPressed: onAttach,
                        icon: Icon(Icons.attach_file_rounded,
                            size: 22, color: icon),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 48,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        tooltip: 'Эмодзи',
                        onPressed: onEmoji,
                        icon: Icon(Icons.emoji_emotions_outlined,
                            size: 22, color: icon),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 48,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: const Color(0xFF713BFF),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onSend,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.send_rounded,
                      size: 22,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Фон экрана: тёмный градиент / чистый белый.
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