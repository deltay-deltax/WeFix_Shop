import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatUsersScreen extends StatelessWidget {
  const ChatUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = List.generate(12, (i) => 'User ${i + 1}');
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.separated(
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final name = users[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Text(name.substring(0, 1)),
            ),
            title: Text(name),
            subtitle: const Text('Tap to open chat'),
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ChatScreen()));
            },
          );
        },
      ),
    );
  }
}
