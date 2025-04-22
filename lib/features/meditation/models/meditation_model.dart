class Meditation {
  final int? id;
  final String title;
  final String category;
  final int duration;
  final String imagePath;
  final String audioPath;
  final int playCount;  // Diubah dari favorite menjadi playCount
  final String description;

  Meditation({
    this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.imagePath,
    required this.audioPath,
    required this.description,
    this.playCount = 0,  // Diubah dari favorite menjadi playCount
  });

  factory Meditation.fromMap(Map<String, dynamic> map) {
    return Meditation(
      id: map['id'],
      title: map['title'],
      category: map['category'],
      duration: map['duration'],
      imagePath: map['image_path'],
      audioPath: map['audio_path'],
      playCount: map['playCount'],  // Menggunakan kolom favorite existing di database
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'duration': duration,
      'image_path': imagePath,
      'audio_path': audioPath,
      'playCount': playCount,  // Menyimpan playCount ke kolom favorite di database
      'description': description,
    };
  }
}