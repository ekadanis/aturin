import 'package:alarm/alarm.dart' as alarm_package;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:aturin/core/database/database_helper.dart';
import 'package:aturin/features/alarm/models/alarm_model.dart';

class AlarmService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> initializeAlarm() async {
    await alarm_package.Alarm.init();
  }

  Future<List<AlarmModel>> getAlarms() async {
    final alarmMaps = await _databaseHelper.getAlarms();
    return alarmMaps.map((map) => AlarmModel.fromMap(map)).toList();
  }

  Future<AlarmModel?> getAlarm(int id) async {
    final alarmMap = await _databaseHelper.getAlarm(id);
    if (alarmMap == null) return null;
    return AlarmModel.fromMap(alarmMap);
  }

  Future<int> addAlarm(AlarmModel alarm) async {
    final id = await _databaseHelper.insertAlarm(alarm.toMap());

    // Set the actual alarm
    if (alarm.isActive == 1) {
      await _setAlarm(id, alarm);
    }

    return id;
  }

  Future<int> updateAlarm(AlarmModel alarm) async {
    final result = await _databaseHelper.updateAlarm(alarm.toMap());

    // Update the actual alarm
    if (alarm.id != null) {
      await alarm_package.Alarm.stop(alarm.id!);
      if (alarm.isActive == 1) {
        await _setAlarm(alarm.id!, alarm);
      }
    }

    return result;
  }

  Future<int> deleteAlarm(int id) async {
    await alarm_package.Alarm.stop(id);
    return await _databaseHelper.deleteAlarm(id);
  }

  Future<int> toggleAlarmStatus(int id, int isActive) async {
    final result = await _databaseHelper.toggleAlarmStatus(id, isActive);

    if (isActive == 1) {
      final alarm = await getAlarm(id);
      if (alarm != null) {
        await _setAlarm(id, alarm);
      }
    } else {
      await alarm_package.Alarm.stop(id);
    }

    return result;
  }

  Future<void> _setAlarm(int id, AlarmModel alarm) async {
    try {
      // Log untuk debugging
      print('Setting alarm with id: $id, time: ${alarm.time}, date: ${alarm.date}');
      
      final dateTime = _parseDateTime(alarm.time, alarm.date);
      print('Parsed DateTime: $dateTime');
      
      // Pastikan waktu alarm valid (tidak di masa lalu)
      final now = DateTime.now();
      DateTime finalDateTime = dateTime;
      if (dateTime.isBefore(now)) {
        // Jika waktu alarm sudah lewat, atur untuk besok
        print('Warning: Alarm time is in the past, adjusting to tomorrow');
        finalDateTime = DateTime(
          now.year, now.month, now.day + 1, 
          dateTime.hour, dateTime.minute
        );
      }
      
      print('Final alarm time: $finalDateTime');
      
      // PENTING: Selalu hentikan alarm dengan ID sama yang mungkin sudah ada
      print('Menghentikan alarm yang mungkin sudah ada dengan ID: $id');
      try {
        // Coba hentikan alarm dengan ID ini terlepas dari apakah alarm ada atau tidak
        await alarm_package.Alarm.stop(id);
        // Tambahkan delay kecil untuk memastikan alarm benar-benar berhenti
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        // Jika alarm tidak ada, ini akan mengabaikan error
        print('Tidak ada alarm aktif dengan ID: $id atau error: $e');
      }
      
      final alarmSettings = alarm_package.AlarmSettings(
        id: id,
        dateTime: finalDateTime,
        assetAudioPath: 'assets/audio/alarm.mp3',
        loopAudio: true,
        vibrate: true,
        warningNotificationOnKill: Platform.isAndroid,
        androidFullScreenIntent: true,
        volumeSettings: alarm_package.VolumeSettings.fade(
          volume: 1.0,
          fadeDuration: const Duration(seconds: 2), // Lebih singkat untuk testing
          volumeEnforced: true,
        ),
        notificationSettings: alarm_package.NotificationSettings(
          title: 'Waktunya Meditasi',
          body: alarm.title,
          stopButton: 'Stop',
          icon: 'notification_icon',
          iconColor: const Color(0xff862778),
        ),
      );

      print('Setting new alarm with settings: ${alarmSettings.assetAudioPath}');
      await alarm_package.Alarm.set(alarmSettings: alarmSettings);
      print('Alarm set successfully for time: ${finalDateTime.toString()}');
    } catch (e) {
      print('Error setting alarm: $e');
      rethrow;
    }
  }

  DateTime _parseDateTime(String time, String date) {
    try {
      // Format waktu
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      // Format tanggal
      final dateParts = date.split(', ');
      
      // Jika format tanggal adalah "Senin, 20 Apr 2023"
      if (dateParts.length > 1) {
        final dateOnly = dateParts[1].trim().split(' ');
        
        if (dateOnly.length >= 3) {
          final day = int.parse(dateOnly[0]);
          final month = _getMonthNumber(dateOnly[1]);
          final year = int.parse(dateOnly[2]);
          
          return DateTime(year, month, day, hour, minute);
        }
      }
      
      // Jika format di atas gagal, coba format alternatif atau gunakan tanggal hari ini
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      // Jika parsing gagal, gunakan waktu saat ini + 1 jam
      final now = DateTime.now().add(const Duration(hours: 1));
      return DateTime(now.year, now.month, now.day, now.hour, now.minute);
    }
  }

  int _getMonthNumber(String month) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4, 'Mei': 5, 'Juni': 6,
      'Juli': 7, 'Agustus': 8, 'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12,
    };

    return months[month] ?? 1;
  }
}
