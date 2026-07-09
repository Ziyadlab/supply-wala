import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key, required this.thread});

  final ChatThread thread;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            NetworkThumb(url: widget.thread.avatarUrl, size: 36, radius: 12),
            const SizedBox(width: 10),
            Expanded(
              child: Text(widget.thread.name, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.thread.messages.isEmpty
                ? const EmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Start chatting',
                    message:
                        'Send a message to discuss products, prices, or delivery.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.thread.messages.length,
                    itemBuilder: (_, index) {
                      final message = widget.thread.messages[index];
                      return Align(
                        alignment: message.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          constraints: const BoxConstraints(maxWidth: 280),
                          decoration: BoxDecoration(
                            color: message.isMine
                                ? AppColors.orange
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: message.isMine
                                ? null
                                : Border.all(color: AppColors.line),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(
                              color: message.isMine
                                  ? Colors.white
                                  : AppColors.ink,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      state.sendMessage(widget.thread, controller.text);
                      controller.clear();
                    },
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
