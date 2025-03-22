import 'dart:convert';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String forUserId; // User ID who should receive this notification

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.forUserId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
      forUserId: json['forUserId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'forUserId': forUserId,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      forUserId: forUserId,
    );
  }
}