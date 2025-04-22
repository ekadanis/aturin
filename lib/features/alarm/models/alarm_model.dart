class AlarmModel {
  final int? id;
  final int? meditationId;
  final String title;
  final String category;
  final String time;
  final String date;
  final int isActive;

  AlarmModel({
    this.id,
    this.meditationId,
    required this.title,
    required this.category,
    required this.time,
    required this.date,
    this.isActive = 1,
  });

  factory AlarmModel.fromMap(Map<String, dynamic> map) {
    return AlarmModel(
      id: map['id'],
      meditationId: map['meditation_id'],
      title: map['title'],
      category: map['category'],
      time: map['time'],
      date: map['date'],
      isActive: map['is_active'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meditation_id': meditationId,
      'title': title,
      'category': category,
      'time': time,
      'date': date,
      'is_active': isActive,
    };
  }
}
