import '../../domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.thumbnailUrl,
    required super.order,
    required super.category,
  });

  // Mapping a Firestore document to a Dart model
  factory CourseModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return CourseModel(
      id: documentId,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      order: json['order'] ?? 0,
      category: json['category'] ?? 'trunk',
    );
  }

  // Preparing data for transmission
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'order': order,
      'category': category,
    };
  }
}