import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_routes.dart';
import '../widgets/BottomNavWidget.dart';

class ChatUsersScreen extends StatelessWidget {
  const ChatUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.home),
          ),
          title: const Text('Chats', style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: myUid == null
            ? const Center(child: Text('Please sign in'))
            : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('participants', arrayContains: myUid)
                    .orderBy('lastMessageAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chats = snap.data?.docs ?? const [];
                  if (chats.isEmpty) {
                    return const Center(child: Text('No conversations'));
                  }
                  return ListView.separated(
                    itemCount: chats.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final d = chats[i].data();
                      final chatId = chats[i].id;
                      final parts =
                          (d['participants'] as List?)?.cast<String>() ??
                          const [];
                      final other = parts.firstWhere(
                        (p) => p != myUid,
                        orElse: () => parts.isNotEmpty ? parts.first : '',
                      );
                      final lookupId = other;
                      // Avoid using chat title to prevent duplicate names; prefer fetched user/shop name
                      final last = (d['lastMessage'] ?? '').toString();
                      final img = (d['image'] ?? null);

                      // Prefer showing user profile if exists; else fallback to shop profile
                      return StreamBuilder<
                        DocumentSnapshot<Map<String, dynamic>>
                      >(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(lookupId)
                            .snapshots(),
                        builder: (context, userSnap) {
                          final userExists = (userSnap.data?.exists ?? false);
                          final user = userSnap.data?.data();
                          final userName = user?['Name'];
                          final userAvatar = user?['profile'] ?? user?['image'];
                          if (userExists && userName != null) {
                            final name = userName.toString();
                            final avatar = img ?? userAvatar;
                            return _chatTile(
                              context,
                              chatId,
                              name,
                              avatar,
                              last,
                            );
                          }
                          return StreamBuilder<
                            DocumentSnapshot<Map<String, dynamic>>
                          >(
                            stream: FirebaseFirestore.instance
                                .collection('shop_users')
                                .doc(lookupId)
                                .snapshots(),
                            builder: (context, shopSnap) {
                              final shop = shopSnap.data?.data();
                              final name =
                                  (shop?['company'] ??
                                          shop?['companyLegalName'] ??
                                          'Chat')
                                      .toString();
                              final avatar =
                                  img ?? shop?['profile'] ?? shop?['image'];
                              return _chatTile(
                                context,
                                chatId,
                                name,
                                avatar,
                                last,
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
        bottomNavigationBar: BottomNavWidget(
          currentIndex: 2,
          onTap: (idx) {
            switch (idx) {
              case 0:
                Navigator.pushReplacementNamed(context, AppRoutes.home);
                break;
              case 1:
                Navigator.pushReplacementNamed(context, AppRoutes.orders);
                break;
              case 2:
                // already on Chat
                break;
            }
          },
        ),
      ),
    );
  }
}

Widget _chatTile(
  BuildContext context,
  String chatId,
  String name,
  dynamic avatar,
  String last,
) {
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.grey.shade300,
      backgroundImage: (avatar is String && avatar.isNotEmpty)
          ? NetworkImage(avatar)
          : null,
      child: (avatar == null || (avatar is String && avatar.isEmpty))
          ? Text(name.isNotEmpty ? name.substring(0, 1) : '?')
          : null,
    ),
    title: Text(name),
    subtitle: Text(
      last.isEmpty ? 'Tap to open chat' : last,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(),
          settings: RouteSettings(arguments: chatId),
        ),
      );
    },
  );
}
