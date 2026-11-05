import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:schooler_chat/constants/constants.dart';
import 'package:schooler_chat/models/message_model.dart';

class MessageBupple extends StatelessWidget {
  const new({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    final isCurrentUser = currentUserEmail == message.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? kChatAccentColor
                  : const Color.fromARGB(255, 19, 36, 60),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isCurrentUser ? 18 : 5),
                bottomRight: Radius.circular(isCurrentUser ? 5 : 18),
              ),
              border: isCurrentUser
                  ? null
                  : Border.all(color: const Color.fromARGB(255, 13, 15, 19)),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...[
                    Text(
                      message.userId,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 243, 239),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isCurrentUser
                          ? Colors.white
                          : const Color.fromARGB(255, 192, 205, 220),
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
