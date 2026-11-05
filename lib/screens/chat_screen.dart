import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schooler_chat/constants/constants.dart';
import 'package:schooler_chat/main_screen.dart';
import 'package:schooler_chat/models/message_model.dart';
import 'package:schooler_chat/widgets/message_bupple.dart';

class ChatScreen extends StatefulWidget {
  const new({super.key});

  static const String id = '/chatscreen';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore messages = FirebaseFirestore.instance;
  bool isLoading = false;
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();

  void _scrollToLatestMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kChatBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 72,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(kLgoPath, height: 42, width: 42),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Schooler Chat',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Community conversation',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });
                    try {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.popAndPushNamed(context, MainScreen.id);
                      }
                    } on Exception catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    }

                    setState(() {
                      isLoading = false;
                    });
                  },
                  tooltip: 'Sign out',
                  icon: const Icon(Icons.logout_rounded),
                ),
        ],
      ),
      body: StreamBuilder(
        stream: messages
            .collection("messages")
            .orderBy("createdAt")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kChatAccentColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load messages: ${snapshot.error}',
                style: const TextStyle(color: kChatTextColor),
                textAlign: TextAlign.center,
              ),
            );
          }

          List<Message> messageList = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            messageList.add(Message.fromJson(snapshot.data!.docs[i]));
          }
          if (messageList.isNotEmpty) _scrollToLatestMessage();
          return Column(
            children: [
              Expanded(
                child: messageList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: Color(0xffE5F0F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.forum_outlined,
                                size: 32,
                                color: kChatAccentColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'No messages yet',
                              style: TextStyle(
                                color: kChatTextColor,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Start the conversation below.',
                              style: TextStyle(
                                color: kChatMutedColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        itemCount: messageList.length,
                        itemBuilder: (context, index) =>
                            MessageBupple(message: messageList[index]),
                      ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  padding: const EdgeInsets.fromLTRB(16, 4, 6, 4),
                  decoration: BoxDecoration(
                    color: kChatSurfaceColor,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: kChatBorderColor),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.07),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: kChatTextColor, fontSize: 15),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Write a message...",
                      hintStyle: const TextStyle(color: kChatMutedColor),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        tooltip: 'Send message',
                        style: IconButton.styleFrom(
                          backgroundColor: kChatAccentColor,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.arrow_upward_rounded, size: 20),
                        onPressed: () async {
                          if (controller.text.trim().isEmpty) return;
                          await messages.collection("messages").add({
                            "message": controller.text.trim(),
                            "createdAt": DateTime.now(),
                            "userId": auth.currentUser!.email,
                          });
                          controller.clear();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

//  ListView(
//         padding: EdgeInsets.all(10),
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(19),
//                     topLeft: Radius.circular(19),
//                     topRight: Radius.circular(19),
//                   ),
//                   color: Colors.amber,
//                 ),
//                 child: Text(
//                   " عليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهالسلام عليكم ورحمة الله",
//                 ),
//               ),
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     bottomRight: Radius.circular(19),
//                     topLeft: Radius.circular(19),
//                     topRight: Radius.circular(19),
//                   ),
//                   color: Colors.teal,
//                 ),
//                 child: Text(
//                   " عليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهالسلام عليكم ورحمة الله",
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                 padding: EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(19),
//                     topLeft: Radius.circular(19),
//                     topRight: Radius.circular(19),
//                   ),
//                   color: Colors.amber,
//                 ),
//                 child: Text(
//                   " عليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهعليكم ورحمة اللهالسلام عليكم ورحمة الله",
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       Row(
//         children: [
//           TextField(
//             decoration: InputDecoration(
//               labelText: "Enter message...",
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//           ),
//         ],
//       ),
