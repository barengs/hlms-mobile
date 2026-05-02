import 'package:hlms_mobile/core/models/course.dart';

class Enrollment {
  final int id;
  final String type; // 'course', 'batch', 'class'
  final String title;
  final String? slug;
  final String thumbnail;
  final String? instructor;
  final int progress;
  final DateTime? enrolledAt;

  Enrollment({
    required this.id,
    required this.type,
    required this.title,
    this.slug,
    required this.thumbnail,
    this.instructor,
    required this.progress,
    this.enrolledAt,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: json['type'] ?? 'course',
      title: json['title'] ?? json['course_title'] ?? '',
      slug: json['slug'] ?? json['course_slug'],
      thumbnail: json['thumbnail'] ?? '',
      instructor: json['instructor'],
      progress: (double.tryParse(json['progress'].toString()) ?? 0).toInt(),
      enrolledAt: (json['enrolled_at'] ?? json['created_at']) != null 
          ? DateTime.parse(json['enrolled_at'] ?? json['created_at']) 
          : null,
    );
  }
}
