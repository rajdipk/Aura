class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isAnimated; 

  Message({
    required this.text,
    required this.isUser,
    this.isAnimated = false, 
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
}
