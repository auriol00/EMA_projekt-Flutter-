import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moonflow/components/CustomApp_Bar.dart';
import 'package:moonflow/components/my_drawer.dart';
import 'package:moonflow/components/textField.dart';
import 'package:moonflow/models/message_model.dart';
import 'package:moonflow/services/api_service.dart';
import 'package:moonflow/components/user_avatar.dart';
import 'package:moonflow/utilities/app_localizations.dart';
import 'package:emoji_selector/emoji_selector.dart';

class ChatScreenPage extends StatefulWidget {
  const ChatScreenPage({super.key});

  @override
  State<ChatScreenPage> createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Message> _messages = [];
  final ApiService apiService = ApiService();
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    setState(() {
      _messages.add(Message(text: msg, isUserMessage: true));
      _messages.add(Message(text: '…', isUserMessage: false)); // typing
      _controller.clear();
    });

    FocusScope.of(context).unfocus();
    String reply;
    try {
      reply = await apiService.getChatResponse(msg);
    } catch (_) {
      if (!mounted) return;
      reply = AppLocalizations.translate(context, 'error_loading_response');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _messages.removeLast();
      _messages.add(Message(text: reply, isUserMessage: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.translate(context, 'chat_title')),
            const SizedBox(width: 8),
            CircleAvatar(radius: 12, backgroundColor: cs.primary),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.question_mark)),
        ],
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[i];
                final me = m.isUserMessage;

                final avatar = me
                    ? UserAvatar(
                        radius: 20,
                        fallbackAsset: 'assets/avatar2.png',
                      )
                    : const CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/avatar_bot.jpg'),
                      );

                final bubbleColor = me
                    ? cs.primary.withAlpha(60)
                    : theme.cardColor;

                return Align(
                  alignment:
                      me ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment:
                        me ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!me) avatar,
                      const SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            m.text,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      if (me) ...[const SizedBox(width: 4), avatar],
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showEmojiPicker
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                      ),
                      color: theme.iconTheme.color,
                      onPressed: () {
                        if (_showEmojiPicker) {
                          FocusScope.of(context).requestFocus(_focusNode);
                        } else {
                          FocusScope.of(context).unfocus();
                        }
                        setState(() => _showEmojiPicker = !_showEmojiPicker);
                      },
                    ),
                    Expanded(
                      child: MyTextField(
                        controller: _controller,
                        hintText:
                            AppLocalizations.translate(context, 'chat_hint'),
                        obscureText: false,
                        focusNode: _focusNode,
                        onChanged: (text) {},
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: cs.primary,
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
                Offstage(
                  offstage: !_showEmojiPicker,
                  child: SafeArea(
                    top: false,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.35,
                      ),
                      child: EmojiSelector(
                        onSelected: (emoji) {
                          _controller.text += emoji.char;
                          _controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: _controller.text.length),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
