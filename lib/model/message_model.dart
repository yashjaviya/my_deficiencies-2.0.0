class MessageModel {
  String? id;
  String? message;
  bool isAnimeted;
  bool isAudio;
  bool isTyping;
  bool isStop;
  bool isRestore;
  int? createdAt;
  String type;
  String path;

  MessageModel({
    this.message,
    this.id,
    this.createdAt,
    this.isAudio = false,
    this.isTyping = false,
    this.isRestore = false,
    this.isStop = true,
    this.path = '',
    this.type = 'msg',
    this.isAnimeted = false
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        id: json['id'] as String?,
        message: json['message'] as String?,
        createdAt: json['createdAt'] as int?,
        type: json['type'] as String? ?? 'msg',
        isAudio: json['isAudio'] ?? false,
        isRestore: json['isRestore'] ?? false,
        isStop: json['isStop'] ?? true,
        isTyping: json['isTyping'] ?? false,
        path: json['path'] ?? '',
        isAnimeted: json['isAnimeted'] ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'createdAt': createdAt,
      'type': type,
      'isAudio': isAudio,
      'isStop': isStop,
      'isRestore': isRestore,
      'isTyping': isTyping,
      'path': path,
      'isAnimeted': isAnimeted
    };
  }
}