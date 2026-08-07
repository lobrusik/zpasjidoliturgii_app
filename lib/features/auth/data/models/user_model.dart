import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final Map<String, List<String>> progress;
  final int completoriumStreak;
  final String? lastCompletoriumDate;
  final bool isAdmin; 

  const UserModel({
    required this.id,
    required this.email,
    required this.progress,
    this.completoriumStreak = 0,
    this.lastCompletoriumDate,
    this.isAdmin = false,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    final rawProgress = json['progress'] as Map<String, dynamic>? ?? {};
    final Map<String, List<String>> parsedProgress = {};
    
    rawProgress.forEach((key, value) {
      parsedProgress[key] = List<String>.from(value ?? []);
    });

    return UserModel(
      id: documentId,
      email: json['email'] ?? '',
      progress: parsedProgress,
      completoriumStreak: json['completoriumStreak'] ?? 0,
      lastCompletoriumDate: json['lastCompletoriumDate'] as String?,
      isAdmin: json['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'progress': progress,
      'completoriumStreak': completoriumStreak,
      'lastCompletoriumDate': lastCompletoriumDate,
      'isAdmin': isAdmin,
    };
  }

  @override
  List<Object?> get props => [id, email, progress, completoriumStreak, lastCompletoriumDate, isAdmin];
}