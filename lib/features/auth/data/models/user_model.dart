import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final Map<String, List<String>> progress; 

  const UserModel({
    required this.id,
    required this.email,
    required this.progress,
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
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'progress': progress,
    };
  }

  @override
  List<Object?> get props => [id, email, progress];
}