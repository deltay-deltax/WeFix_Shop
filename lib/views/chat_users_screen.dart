import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_colors.dart';
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
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, AppRoutes.home),
          ),
          title: const Text(
            'Messages',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: myUid == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Please sign in',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
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
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 100,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start chatting with your customers',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: chats.length,
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
                      final last = (d['lastMessage'] ?? '').toString();
                      final img = (d['image'] ?? null);

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

                            return _buildModernChatTile(
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
                              final shopExists =
                                  (shopSnap.data?.exists ?? false);
                              final shop = shopSnap.data?.data();
                              final shopName = shop?['companyName'];
                              final shopAvatar =
                                  shop?['profile'] ?? shop?['image'];

                              if (shopExists && shopName != null) {
                                final name = shopName.toString();
                                final avatar = img ?? shopAvatar;

                                return _buildModernChatTile(
                                  context,
                                  chatId,
                                  name,
                                  avatar,
                                  last,
                                );
                              }

                              return _buildModernChatTile(
                                context,
                                chatId,
                                'Unknown',
                                null,
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
                Navigator.pushReplacementNamed(context, AppRoutes.requests);
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

  Widget _buildModernChatTile(
    BuildContext context,
    String chatId,
    String name,
    dynamic avatar,
    String last,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(),
                settings: RouteSettings(arguments: chatId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with gradient border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.6),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade100,
                    backgroundImage: (avatar is String && avatar.isNotEmpty)
                        ? NetworkImage(avatar)
                        : null,
                    child:
                        (avatar == null || (avatar is String && avatar.isEmpty))
                        ? Text(
                            name.isNotEmpty
                                ? name.substring(0, 1).toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Name and message
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.icon,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        last.isEmpty ? 'Tap to open chat' : last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
