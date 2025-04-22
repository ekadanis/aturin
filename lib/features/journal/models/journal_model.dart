class Journal {
  final int? id;
  final String date;
  final String mood;
  final String content;
  final String createdAt;

  Journal({
    this.id,
    required this.date,
    required this.mood,
    required this.content,
    required this.createdAt,
  });

  factory Journal.fromMap(Map<String, dynamic> map) {
    return Journal(
      id: map['id'],
      date: map['date'],
      mood: map['mood'],
      content: map['content'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
      'content': content,
      'created_at': createdAt,
    };
  }
}