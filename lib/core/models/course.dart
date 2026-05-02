class Course {
  final int id;
  final String title;
  final String slug;
  final String? subtitle;
  final String thumbnail;
  final String? instructorName;
  final double? price;
  final double? discountPrice;
  final String? level;
  final double? rating;
  final int? totalEnrollments;
  final List<dynamic>? sections;
  final String? description;
  final List<dynamic>? requirements;
  final List<dynamic>? outcomes;
  final bool isEnrolled;

  Course({
    required this.id,
    required this.title,
    required this.slug,
    this.subtitle,
    required this.thumbnail,
    this.instructorName,
    this.price,
    this.discountPrice,
    this.level,
    this.rating,
    this.totalEnrollments,
    this.sections,
    this.description,
    this.requirements,
    this.outcomes,
    this.isEnrolled = false,
  });

  factory Course.fromJson(Map<String, dynamic> json, [Map<String, dynamic>? meta]) {
    return Course(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'],
      slug: json['slug'],
      subtitle: json['subtitle'],
      thumbnail: json['thumbnail'] ?? '',
      instructorName: json['instructor'] is Map ? json['instructor']['name'] : json['instructor_name'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      discountPrice: json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null,
      level: json['level'],
      rating: json['average_rating'] != null ? double.tryParse(json['average_rating'].toString()) : null,
      totalEnrollments: json['total_enrollments'] != null ? int.tryParse(json['total_enrollments'].toString()) : null,
      sections: json['sections'],
      description: json['description'],
      requirements: json['requirements'] is String ? [json['requirements']] : json['requirements'],
      outcomes: json['outcomes'] is String ? [json['outcomes']] : json['outcomes'],
      isEnrolled: meta?['is_enrolled'] ?? false,
    );
  }
}
