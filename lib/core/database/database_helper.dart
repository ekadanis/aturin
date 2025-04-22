import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'meditation_app.db');
    return await openDatabase(
      path,
      version: 4, // Tingkatkan versi database
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade, // Tambahkan handler upgrade
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Journal table
    await db.execute('''
      CREATE TABLE journals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        mood TEXT,
        content TEXT,
        created_at TEXT
      )
    ''');

    // Meditation table
    await db.execute('''
      CREATE TABLE meditations(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        category TEXT,
        description TEXT,
        duration INTEGER,
        image_path TEXT,
        audio_path TEXT,
        playCount INTEGER DEFAULT 0
      )
    ''');

    // Alarm table
    await db.execute('''
      CREATE TABLE alarms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        meditation_id INTEGER,
        title TEXT,
        category TEXT,
        time TEXT,
        date TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (meditation_id) REFERENCES meditations (id) ON DELETE CASCADE
      )
    ''');

    // Insert sample meditation data
    await _insertSampleMeditations(db);
  }

  // Handler untuk upgrade database dari versi lama ke versi baru
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Cek dulu apakah kolom sudah ada sebelum menambahkan
      var tableInfo = await db.rawQuery("PRAGMA table_info(meditations)");
      bool hasDescription = false;

      for (var column in tableInfo) {
        if (column['name'] == 'description') {
          hasDescription = true;
          break;
        }
      }

      if (!hasDescription) {
        await db.execute('ALTER TABLE meditations ADD COLUMN description TEXT');
      }

      // Hapus data lama dan masukkan data baru dengan image path yang diperbarui
      await db.execute('DELETE FROM meditations');
      await _insertSampleMeditations(db);
    }
  }

  Future<void> _insertSampleMeditations(Database db) async {
    final List<Map<String, dynamic>> meditations = [
      {
        "title": "Suara Ombak Laut",
        "category": "Alam",
        "description":
            "Deburan ombak yang menghantam pantai dengan lembut menghadirkan ketenangan alami, membebaskan pikiran seperti berada di tepi laut yang damai.",
        "duration": 0,
        "image_path": "assets/images/alam_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Suara Api Unggun",
        "category": "Imajinatif",
        "description":
            "Letupan kayu yang terbakar perlahan menciptakan kehangatan, seakan duduk bersama di sekitar api unggun di malam yang sunyi dan damai.",
        "duration": 0,
        "image_path": "assets/images/imajinatif_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Suasana Kota yang Tenang",
        "category": "Perkotaan yang tenang",
        "description":
            "Biasanya penuh hiruk pikuk, kini kota terasa tenang. Suara kendaraan yang jauh dan hembusan angin lembut menciptakan ruang refleksi di tengah gedung-gedung tinggi.",
        "duration": 0,
        "image_path": "assets/images/perkotaan_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Melodi Hujan",
        "category": "Alam",
        "description":
            "Rintik hujan yang jatuh perlahan menciptakan melodi alami yang mengalun lembut, membangkitkan kenangan dan membawa rasa damai dalam hati.",
        "duration": 0,
        "image_path": "assets/images/alam_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Musik Harpa Malam",
        "category": "Instrumental",
        "description":
            "Alunan harpa yang tenang dan lembut mengisi malam dengan kedamaian, mengantar kita ke suasana rileks yang mendalam dan penuh harmoni.",
        "duration": 0,
        "image_path": "assets/images/instrumental_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Suara Di Kafe",
        "category": "Perkotaan yang tenang",
        "description":
            "Kombinasi suara gelas, langkah kaki, dan percakapan pelan menciptakan nuansa nyaman layaknya berada di kafe kecil yang hangat dan santai.",
        "duration": 0,
        "image_path": "assets/images/perkotaan_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Lembutnya Angin",
        "category": "Alam",
        "description":
            "Desiran angin yang menyentuh dedaunan menghadirkan ketenangan, seolah membisikkan kedamaian dalam setiap hembusan yang melewati.",
        "duration": 0,
        "image_path": "assets/images/alam_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Petualangan di Hutan",
        "category": "Imajinatif",
        "description":
            "Suara hutan yang hidup dengan kicauan burung dan hembusan dedaunan menghadirkan rasa petualangan yang menantang sekaligus menenangkan.",
        "duration": 0,
        "image_path": "assets/images/imajinatif_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Melodi Gitar Akustik",
        "category": "Instrumental",
        "description":
            "Petikan gitar akustik yang jernih membawa kita dalam suasana hangat, santai, dan penuh perasaan, seperti duduk di sore yang tenang.",
        "duration": 0,
        "image_path": "assets/images/instrumental_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
      {
        "title": "Tunggu Matahari Terbit",
        "category": "Imajinatif",
        "description":
            "Keheningan menjelang pagi berpadu dengan suara alam yang perlahan bangun, menciptakan suasana syahdu saat menanti matahari menyinari dunia.",
        "duration": 0,
        "image_path": "assets/images/imajinatif_kategori.png",
        "audio_path": "assets/audio/suara_airlaut.mp3",
        "playCount": 0,
      },
    ];

    for (var meditation in meditations) {
      await db.insert('meditations', meditation);
    }
  }

  // Journal CRUD operations
  Future<int> insertJournal(Map<String, dynamic> journal) async {
    Database db = await database;
    return await db.insert('journals', journal);
  }

  Future<List<Map<String, dynamic>>> getJournals() async {
    Database db = await database;
    return await db.query('journals', orderBy: 'date DESC');
  }

  Future<Map<String, dynamic>?> getJournal(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'journals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateJournal(Map<String, dynamic> journal) async {
    Database db = await database;
    return await db.update(
      'journals',
      journal,
      where: 'id = ?',
      whereArgs: [journal['id']],
    );
  }

  Future<int> deleteJournal(int id) async {
    Database db = await database;
    return await db.delete('journals', where: 'id = ?', whereArgs: [id]);
  }

  // Meditation operations
  Future<List<Map<String, dynamic>>> getMeditations() async {
    Database db = await database;
    return await db.query('meditations');
  }

  Future<List<Map<String, dynamic>>> getMeditationsByCategory(
    String category,
  ) async {
    Database db = await database;
    if (category == 'All') {
      return await db.query('meditations');
    }
    return await db.query(
      'meditations',
      where: 'category = ?',
      whereArgs: [category],
    );
  }

  Future<Map<String, dynamic>?> getMeditation(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'meditations',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

Future<int> updateMeditationPlayCount(int id, int playCount) async {
  Database db = await database;
  return await db.update(
    'meditations',
    {'playCount': playCount},
    where: 'id = ?',
    whereArgs: [id],
  );
}

  // Alarm CRUD operations
  Future<int> insertAlarm(Map<String, dynamic> alarm) async {
    Database db = await database;
    return await db.insert('alarms', alarm);
  }

  Future<List<Map<String, dynamic>>> getAlarms() async {
    Database db = await database;
    return await db.query('alarms', orderBy: 'date ASC, time ASC');
  }

  Future<Map<String, dynamic>?> getAlarm(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateAlarm(Map<String, dynamic> alarm) async {
    Database db = await database;
    return await db.update(
      'alarms',
      alarm,
      where: 'id = ?',
      whereArgs: [alarm['id']],
    );
  }

  Future<int> deleteAlarm(int id) async {
    Database db = await database;
    return await db.delete('alarms', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleAlarmStatus(int id, int isActive) async {
    Database db = await database;
    return await db.update(
      'alarms',
      {'is_active': isActive},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
