import 'package:relax_fik/core/database/database_helper.dart';
import 'package:relax_fik/features/journal/models/journal_model.dart';

class JournalService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Journal>> getJournals() async {
    final journalMaps = await _databaseHelper.getJournals();
    return journalMaps.map((map) => Journal.fromMap(map)).toList();
  }

  Future<Journal?> getJournal(int id) async {
    final journalMap = await _databaseHelper.getJournal(id);
    if (journalMap == null) return null;
    return Journal.fromMap(journalMap);
  }

  Future<int> addJournal(Journal journal) async {
    return await _databaseHelper.insertJournal(journal.toMap());
  }

  Future<int> updateJournal(Journal journal) async {
    return await _databaseHelper.updateJournal(journal.toMap());
  }

  Future<int> deleteJournal(int id) async {
    return await _databaseHelper.deleteJournal(id);
  }
}