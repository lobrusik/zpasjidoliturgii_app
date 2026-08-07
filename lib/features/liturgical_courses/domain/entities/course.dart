import 'package:equatable/equatable.dart';

class Course extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int order;
  final String category;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.order,
    required this.category,
  });

  @override
  List<Object?> get props => [id, title, description, thumbnailUrl, order, category];
}