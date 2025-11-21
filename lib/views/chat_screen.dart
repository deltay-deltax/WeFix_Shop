import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModels/chat_viewmodel.dart';
import '../widgets/message_bubble.dart';
import '../core/constants/app_routes.dart';
import '../widgets/BottomNavWidget.dart';
import 'service_requesr-t_screen.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Consumer<ChatViewModel>(
        builder: (context, vm, child) => Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.store, color: Colors.black),
                ),
                SizedBox(width: 12),
                Text(
                  vm.shopName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.call, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
          body: Column(
            children: [
              SizedBox(height: 12),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "Today",
                  style: TextStyle(
                    backgroundColor: Colors.grey[200],
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: vm.messages.length,
                  reverse: false,
                  itemBuilder: (context, i) =>
                      MessageBubble(message: vm.messages[i]),
                ),
              ),
              // Message Input Bar
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        color: Colors.grey[700],
                      ),
                      Expanded(
                        child: TextField(
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Type your message",
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.attach_file),
                        color: Colors.grey[700],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.photo_camera_outlined),
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 2),
                      Material(
                        color: const Color(0xFF4285F4),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {},
                          splashRadius: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavWidget(
            currentIndex: 2,
            onTap: (idx) {
              switch (idx) {
                case 0:
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                  break;
                case 1:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => ServiceRequestsScreen()),
                  );
                  break;
                case 2:
                  // already on Chat
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
