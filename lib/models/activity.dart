import 'package:flutter/material.dart';

class Activity {
  final String type;
  final String description;
  final DateTime timestamp;
  final String? username;
  final String? recordTitle;

  Activity({
    required this.type,
    required this.description,
    required this.timestamp,
    this.username,
    this.recordTitle,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      username: json['username'],
      recordTitle: json['recordTitle'],
    );
  }

  // Aktivite türüne göre ikon
  IconData get icon {
    switch (type) {
      case 'user_registered':
        return Icons.person_add;
      case 'record_created':
        return Icons.note_add;
      case 'share_created':
        return Icons.share;
      default:
        return Icons.info;
    }
  }

  // Aktivite türüne göre renk
  Color get color {
    switch (type) {
      case 'user_registered':
        return const Color(0xFF10B981);
      case 'record_created':
        return const Color(0xFF3B82F6);
      case 'share_created':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

class ActivitiesResponse {
  final bool success;
  final String message;
  final List<Activity> activities;

  ActivitiesResponse({
    required this.success,
    required this.message,
    required this.activities,
  });

  factory ActivitiesResponse.fromJson(Map<String, dynamic> json) {
    return ActivitiesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => Activity.fromJson(a))
              .toList() ??
          [],
    );
  }
}

