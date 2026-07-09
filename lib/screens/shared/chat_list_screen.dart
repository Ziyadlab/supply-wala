import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../widgets/app_widgets.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Chat')) : null,
      body: state.chats.isEmpty
          ? const EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No chats yet',
              message: 'Start a conversation from a supplier profile or order.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.chats.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final thread = state.chats[index];
                return ChatTile(
                  thread: thread,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(thread: thread),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
