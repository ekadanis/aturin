import 'package:relax_fik/core/database/database_helper.dart';
import 'package:relax_fik/features/meditation/models/meditation_model.dart';

class MeditationService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<List<Meditation>> getMeditations() async {
    final meditationMaps = await _databaseHelper.getMeditations();
    return meditationMaps.map((map) => Meditation.fromMap(map)).toList();
  }

  Future<List<Meditation>> getMeditationsByCategory(String category) async {
    final meditationMaps = await _databaseHelper.getMeditationsByCategory(category);
    return meditationMaps.map((map) => Meditation.fromMap(map)).toList();
  }

  Future<Meditation?> getMeditation(int id) async {
    final meditationMap = await _databaseHelper.getMeditation(id);
    if (meditationMap == null) return null;
    return Meditation.fromMap(meditationMap);
  }
  
  // Metode untuk menambah play count
  Future<bool> incrementPlayCount(int meditationId) async {
    try {
      final meditationMap = await _databaseHelper.getMeditation(meditationId);
      if (meditationMap == null) return false;
      
      final meditation = Meditation.fromMap(meditationMap);
      final updatedPlayCount = meditation.playCount + 1;
      
      await _databaseHelper.updateMeditationPlayCount(meditationId, updatedPlayCount);
      return true;
    } catch (e) {
      print('Error incrementing play count: $e');
      return false;
    }
  }
}