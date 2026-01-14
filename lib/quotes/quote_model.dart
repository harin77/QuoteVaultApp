/// Quote model
class Quote {
  final String id;
  final String text;
  final String author;
  final String category;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.createdAt,
  });

  /// Create Quote from Supabase JSON
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      text: json['text'] as String,
      author: json['author'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Quote to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author,
      'category': category,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    String? category,
    DateTime? createdAt,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
