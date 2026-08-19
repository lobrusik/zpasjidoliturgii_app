class InteractiveLesson {
  final String id;
  final String courseId;
  final int dayStage;
  final String title;
  final List<LessonSlide> slides;

  InteractiveLesson({
    required this.id,
    required this.courseId,
    required this.dayStage,
    required this.title,
    required this.slides,
  });

  factory InteractiveLesson.fromJson(Map<String, dynamic> json, String documentId) {
    return InteractiveLesson(
      id: documentId,
      courseId: json['courseId'] ?? '',
      dayStage: json['day_stage'] ?? 0,
      title: json['title'] ?? '',
      slides: (json['slides'] as List<dynamic>? ?? [])
          .map((slideJson) => LessonSlide.fromJson(slideJson))
          .toList(),
    );
  }
}

class LessonSlide {
  final String type; // 'intro', 'text', 'info_cards', 'image', 'true_false', 'drag_drop', 'summary'
  final String title;
  final String? content;
  final String? imageUrl;
  final String? videoUrl;
  final String? quote;
  final List<dynamic>? dataList; //True, false
  final List<String>? categories; // Drag & Drop
  final List<Map<String, dynamic>>? itemsToMatch; // Drag & Drop

  LessonSlide({
    required this.type,
    required this.title,
    this.content,
    this.imageUrl,
    this.videoUrl,
    this.quote,
    this.dataList,
    this.categories,
    this.itemsToMatch,
  });

  factory LessonSlide.fromJson(Map<String, dynamic> json) {
    return LessonSlide(
      type: json['type'] ?? 'text',
      title: json['title'] ?? '',
      content: json['content'],
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      quote: json['quote'],
      dataList: json['dataList'],
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      itemsToMatch: (json['itemsToMatch'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList(),
    );
  }
}