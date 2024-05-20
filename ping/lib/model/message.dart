import 'message_type.dart';

class Message {
  final MessageType type;
  final String? message;

  final String? img;
  final String? audio;
  final String? video;

  final String sender;
  final String receiver;

  // final DateTime time;

  Message({
    this.message,
    this.img,
    this.audio,
    this.video,
    required this.type,
    // required this.time,
    required this.sender,
    required this.receiver,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.code,
      'message': message,
      'img': img,
      'audio': audio,
      'video': video,
      'sender': sender,
      'receiver': receiver,
      // 'time': time,
    };
  }
}
