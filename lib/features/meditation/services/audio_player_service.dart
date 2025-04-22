import 'package:audioplayers/audioplayers.dart';

class AudioPlayerService {
  // Singleton instance
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  
  // Factory constructor to return the singleton instance
  factory AudioPlayerService() {
    return _instance;
  }
  
  // Private constructor for singleton
  AudioPlayerService._internal() {
    _initAudioPlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentAudioPath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _currentMeditationTitle;

  // Stream getters
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;
  Stream<Duration> get onDurationChanged => _audioPlayer.onDurationChanged;
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;

  // Getters
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  String? get currentAudioPath => _currentAudioPath;
  String? get currentMeditationTitle => _currentMeditationTitle;

  void _initAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      _duration = newDuration;
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      _position = newPosition;
    });
    
    // Listen for when audio playback completes
    _audioPlayer.onPlayerComplete.listen((_) async {
      print('Audio playback completed - preparing for replay');
      
      // Reset position to beginning
      _position = Duration.zero;
      _isPlaying = false;
      
      // Penting: Buat audio player siap untuk pemutaran ulang
      // dengan me-release resource dan menyiapkan sumber audio baru
      try {
        if (_currentAudioPath != null) {
          // Persiapkan ulang audio source setelah selesai diputar
          await _audioPlayer.release();
          await Future.delayed(const Duration(milliseconds: 100)); // Jeda kecil
          
          // Buat audio player baru agar tidak ada resource yang terkunci
          await _audioPlayer.setSourceAsset(_currentAudioPath!);
          
          print('Audio player ready for replay: $_currentAudioPath');
        }
      } catch (e) {
        print('Error preparing audio for replay: $e');
      }
    });
  }

  Future<void> play(String audioPath, {String? meditationTitle}) async {
    // Perbaiki format path jika perlu
    String normalizedPath = audioPath;
    
    // Hapus 'assets/' dari awal path jika ada
    if (normalizedPath.startsWith('assets/')) {
      normalizedPath = normalizedPath.replaceFirst('assets/', '');
    }
    
    print('Playing audio: $normalizedPath'); // Debug log
    
    // If this is the same audio path that was previously loaded
    if (_currentAudioPath == normalizedPath) {
      // Jika audio telah selesai atau sudah mendekati akhir, kita muat ulang
      if (_position >= _duration - const Duration(milliseconds: 500) && _duration.inSeconds > 0) {
        // Memuat ulang audio dari awal ketika mencapai akhir
        try {
          print('Restarting completed audio from beginning');
          await _audioPlayer.stop().timeout(const Duration(seconds: 2));
          
          // Reset dan persiapkan audio player
          await _audioPlayer.release().timeout(const Duration(seconds: 2));
          _position = Duration.zero;
          
          // Buat audio baru dengan sumber yang sama
          await _audioPlayer.setSourceAsset(normalizedPath).timeout(const Duration(seconds: 3));
          await _audioPlayer.resume().timeout(const Duration(seconds: 2));
          _isPlaying = true;
          print('Successfully restarted audio');
        } catch (e) {
          print('Error restarting audio: $e');
          // Fallback: coba cara yang lebih sederhana
          await _audioPlayer.stop();
          await _audioPlayer.play(AssetSource(normalizedPath));
        }
      } else {
        // Resume atau restart audio
        await _audioPlayer.resume();
      }
      _currentMeditationTitle = meditationTitle;
      return;
    }
    
    // If it's a new audio file, stop any current playback and start fresh
    try {
      await _audioPlayer.stop().timeout(const Duration(seconds: 2));
      await _audioPlayer.release().timeout(const Duration(seconds: 2));
      _currentAudioPath = normalizedPath;
      _currentMeditationTitle = meditationTitle;
      _position = Duration.zero; // Reset position for new audio
      
      // Gunakan setSourceAsset sebelum play untuk memastikan resource siap
      await _audioPlayer.setSourceAsset(normalizedPath).timeout(const Duration(seconds: 3));
      await _audioPlayer.resume().timeout(const Duration(seconds: 2));
      print('Audio started playing: $normalizedPath');
    } catch (e) {
      print('Error setting up new audio: $e');
      // Fallback ke metode lama jika ada error
      try {
        await _audioPlayer.play(AssetSource(normalizedPath));
      } catch (e2) {
        print('Fallback error: $e2');
      }
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentAudioPath = null;
    _currentMeditationTitle = null;
  }

  Future<void> seek(Duration position) async {
    try {
      // Jika audio sudah selesai dan user mencoba seek ke posisi sebelumnya
      if (!_isPlaying && _position >= _duration - const Duration(milliseconds: 500) && _currentAudioPath != null) {
        // Implementasi yang lebih aman dengan timeout protection
        try {
          // Stop dengan timeout protection
          await _audioPlayer.stop().timeout(const Duration(seconds: 5),
              onTimeout: () => print('Stop operation timed out, continuing'));
          
          // Set posisi secara lokal untuk UI update segera
          _position = position;
          
          // Play dengan timeout protection
          await _audioPlayer.play(AssetSource(_currentAudioPath!))
              .timeout(const Duration(seconds: 5),
                  onTimeout: () => print('Play operation timed out, continuing'));
          
          // Seek dengan timeout protection
          await _audioPlayer.seek(position).timeout(const Duration(seconds: 5),
              onTimeout: () => print('Seek operation timed out'));
          
          print('Audio reloaded and seeked to ${position.inSeconds} seconds');
        } catch (e) {
          print('Error during seek after completion: $e');
          // Fallback: setidaknya update posisi lokal
          _position = position; 
        }
      } else {
        // Normal seeking ketika audio sedang berjalan
        // Tambahkan timeout protection
        await _audioPlayer.seek(position).timeout(const Duration(seconds: 5),
            onTimeout: () {
          print('Normal seek operation timed out');
          // Update posisi lokal sebagai fallback
          _position = position;
        });
      }
    } catch (e) {
      print('Error in seek operation: $e');
      // Pastikan UI tetap responsif dengan mengupdate posisi lokal
      _position = position;
    }
  }
}