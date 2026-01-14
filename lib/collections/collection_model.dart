/// Collection model
class Collection {
  final String id;
  final String name;
  final String userId;
  final DateTime createdAt;
  final int quoteCount;

  Collection({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    this.quoteCount = 0,
  });

  /// Create Collection from Supabase JSON
  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      quoteCount: json['quote_count'] as int? ?? 0,
    );
  }

  /// Convert Collection to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
