/// 消息类型
/// 0-text
/// 1-img
/// 2-audio
/// 3-video
enum MessageType {
  text,
  img,
  audio,
  video;

  int get code {
    switch (this) {
      case MessageType.text:
        return 0;
      case MessageType.img:
        return 1;
      case MessageType.audio:
        return 2;
      case MessageType.video:
        return 3;
    }
  }

  static MessageType fromCode(int code) {
    switch (code) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.img;
      case 2:
        return MessageType.audio;
      case 3:
        return MessageType.video;
      default:
        throw ArgumentError("Invalid code: $code");
    }
  }
}
