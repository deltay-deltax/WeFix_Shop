import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewModels/chat_viewmodel.dart';
import '../core/constants/app_routes.dart';
import '../widgets/BottomNavWidget.dart';
import 'service_requesr-t_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wefix_shop/widgets/full_screen_image_view.dart';
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController msgCtrl = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markRead();
    });
  }

  void _markRead() async {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    String? chatId;
    if (routeArgs is Map) {
      chatId = (routeArgs['chatId'] ?? '') as String?;
    } else if (routeArgs is String) {
      chatId = routeArgs;
    }
    if (chatId == null) return;
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    final doc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['lastMessageSenderId'] != myUid) {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
          'isRead': true,
        });
      }
    }
  }

  @override
  void dispose() {
    msgCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;

    String? chatId;
    String? headerTitle;
    String? headerImage;

    if (routeArgs is Map) {
      chatId = (routeArgs['chatId'] ?? '') as String?;
      headerTitle = (routeArgs['title'] ?? '') as String?;
      headerImage = routeArgs['image'] as String?;
    } else if (routeArgs is String) {
      chatId = routeArgs;
    }

    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Consumer<ChatViewModel>(
        builder: (context, vm, child) => WillPopScope(
          onWillPop: () async {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            return false;
          },
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: (headerTitle != null && headerTitle.isNotEmpty)
                  ? AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.home,
                        ),
                      ),
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                (headerImage != null && headerImage!.isNotEmpty)
                                ? CachedNetworkImageProvider(headerImage!)
                                : null,
                            backgroundColor: Colors.grey[300],
                            child: (headerImage == null || headerImage!.isEmpty)
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              headerTitle!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _ChatHeader(chatId: chatId),
            ),
            body: Column(
              children: [
                const SizedBox(height: 8),

                /// ============== MESSAGES ==============
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: chatId == null
                        ? const Stream.empty()
                        : FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .collection('messages')
                              .orderBy('createdAt', descending: true)
                              .snapshots(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snap.data?.docs ?? [];
                      final myUid = FirebaseAuth.instance.currentUser?.uid;

                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'Say hi 👋',
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (_, i) {
                          final d = docs[i].data();
                          final isMe = d['senderId'] == myUid;
                          final text = (d['text'] ?? '').toString();
                          final imageUrl = d['imageUrl'] as String?;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: const BoxConstraints(maxWidth: 320),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFFE5F0FF)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (imageUrl != null && imageUrl.isNotEmpty)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => FullScreenImageView(imageUrl: imageUrl),
                                          ),
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          placeholder: (context, url) => Container(
                                            height: 150,
                                            color: Colors.grey[300],
                                            child: const Center(child: CircularProgressIndicator()),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            height: 150,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        ),
                                      ),
                                    ),

                                  if (text.isNotEmpty)
                                    Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 18, // ✅ BIGGER
                                        height: 1.4,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                /// ============== INPUT BAR ==============
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Row(
                      children: [
                        /// PLUS
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE3F2FD),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () =>
                                _handleImagePickAndSend(context, chatId),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// TEXT FIELD CONTAINER
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _focusNode.hasFocus
                                    ? const Color(0xFF4285F4) // 🔵 ON FOCUS
                                    : Colors.transparent,
                                width: 1.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: msgCtrl,
                              focusNode: _focusNode,
                              minLines: 1,
                              maxLines: 5,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: 'Type your message...',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onTap: () {
                                setState(() {});
                              },
                              onEditingComplete: () {
                                setState(() {});
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// SEND BUTTON
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF4285F4),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () async {
                              final text = msgCtrl.text.trim();
                              if (text.isEmpty || chatId == null) return;

                              final myUid =
                                  FirebaseAuth.instance.currentUser?.uid;

                              await FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .collection('messages')
                                  .add({
                                    'text': text,
                                    'senderId': myUid,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                              await FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .set({
                                    'lastMessage': text,
                                    'lastMessageAt':
                                        FieldValue.serverTimestamp(),
                                    'lastMessageSenderId': myUid,
                                    'isRead': false,
                                  }, SetOptions(merge: true));

                              msgCtrl.clear();
                            },
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
      ),
    );
  }

  Future<void> _handleImagePickAndSend(
    BuildContext context,
    String? chatId,
  ) async {
    if (chatId == null) return;

    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;

    final path =
        'chat_images/$chatId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(path);

    await ref.putData(await x.readAsBytes());
    final url = await ref.getDownloadURL();

    final myUid = FirebaseAuth.instance.currentUser?.uid;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
          'imageUrl': url,
          'senderId': myUid,
          'createdAt': FieldValue.serverTimestamp(),
        });

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'lastMessage': '[image]',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageSenderId': myUid,
      'isRead': false,
    }, SetOptions(merge: true));
  }
}

// =========================================

class _ChatHeader extends StatelessWidget {
  final String? chatId;
  const _ChatHeader({required this.chatId});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.home),
      ),
      title: const Text('Chat', style: TextStyle(color: Colors.black)),
    );
  }
}
