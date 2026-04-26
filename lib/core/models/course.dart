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
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      slug: json['slug'],
      subtitle: json['subtitle'],
      thumbnail: json['thumbnail'] ?? '',
      instructorName: json['instructor'] is Map ? json['instructor']['name'] : json['instructor_name'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      discountPrice: json['discount_price'] != null ? double.tryParse(json['discount_price'].toString()) : null,
      level: json['level'],
      rating: json['average_rating'] != null ? double.tryParse(json['average_rating'].toString()) : null,
      totalEnrollments: json['total_enrollments'],
      sections: json['sections'],
    );
  }
}
