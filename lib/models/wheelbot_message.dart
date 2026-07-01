class WheelbotMessage {
  final String role;
  final String content;
  final DateTime timestamp;
  final List<WheelbotAction> buttons;

  const WheelbotMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.buttons = const [],
  });

  bool get isUser => role == 'user';

  Map<String, dynamic> toApiJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };
}

class WheelbotAction {
  final String label;
  final String action;
  final String icon;

  const WheelbotAction({
    required this.label,
    required this.action,
    required this.icon,
  });
}

class WheelbotReply {
  final bool success;
  final String? message;
  final String? error;
  final String? provider;

  const WheelbotReply({
    required this.success,
    this.message,
    this.error,
    this.provider,
  });

  factory WheelbotReply.fromJson(Map<String, dynamic> json) {
    return WheelbotReply(
      success: json['success'] == true,
      message: json['message']?.toString(),
      error: json['error']?.toString(),
      provider: json['provider']?.toString(),
    );
  }
}
