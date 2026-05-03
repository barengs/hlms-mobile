class TimelineItem {
  final int id;
  final String title;
  final String type; // 'course', 'session', 'assignment'
  final int referenceId;
  final String? slug;
  final int sortOrder;
  final bool isRequired;
  final bool isCompleted;
  final DateTime? completedAt;
  final Map<String, dynamic> meta;

  TimelineItem({
    required this.id,
    required this.title,
    required this.type,
    required this.referenceId,
    this.slug,
    required this.sortOrder,
    required this.isRequired,
    required this.isCompleted,
    this.completedAt,
    required this.meta,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? 'session',
      referenceId: json['reference_id'] ?? 0,
      slug: json['slug'],
      sortOrder: json['sort_order'] ?? 0,
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      meta: json['meta'] ?? {},
    );
  }
}
