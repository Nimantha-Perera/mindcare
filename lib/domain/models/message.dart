class Message {
  final String text;
  final bool isFromUser;
  final String? senderName;

  Message({
    required this.text,
    required this.isFromUser,
    this.senderName,
  });
}