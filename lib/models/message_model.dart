class Message {
  final String message;
  final String createdAt;
  final String userId;

  new({required this.message, required this.createdAt, required this.userId});

  factory Message.fromJson(json) {
    return Message(
      message: json['message'],
      createdAt: json['createdAt'].toString(),
      userId: json['userId'],
    );
  }
}
