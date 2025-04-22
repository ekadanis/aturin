import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:relax_fik/features/alarm/ui/add_alarm_screen.dart';
import 'package:relax_fik/features/meditation/models/meditation_model.dart';
import 'package:relax_fik/features/meditation/services/audio_player_service.dart';

class MeditationDetailScreen extends StatefulWidget {
  final Meditation meditation;

  const MeditationDetailScreen({
    Key? key,
    required this.meditation,
  }) : super(key: key);

  @override
  State<MeditationDetailScreen> createState() => _MeditationDetailScreenState();
}

class _MeditationDetailScreenState extends State<MeditationDetailScreen> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
    _checkIfAlreadyPlaying();
    
    // Auto-play audio ketika layar detail dibuka
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_isPlaying) {
        _playAudio();
      }
    });
  }

  void _checkIfAlreadyPlaying() {
    // Check if the current meditation is already playing
    if (_audioPlayerService.currentMeditationTitle == widget.meditation.title) {
      setState(() {
        _isPlaying = _audioPlayerService.isPlaying;
        _position = _audioPlayerService.position;
        _duration = _audioPlayerService.duration;
      });
    }
  }

  void _setupAudioPlayer() {
    _audioPlayerService.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayerService.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _audioPlayerService.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });
  }

  // Method to play audio using path from the meditation model
  void _playAudio() {
    _audioPlayerService.play(
      widget.meditation.audioPath,
      meditationTitle: widget.meditation.title
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'relaxation':
        return const Icon(Icons.self_improvement, size: 20);
      case 'focus':
        return const Icon(Icons.center_focus_strong, size: 20);
      case 'sleep':
        return const Icon(Icons.nightlight_round, size: 20);
      default:
        return const Icon(Icons.category, size: 20);
    }
  }

  @override
  void dispose() {
    // We should NOT dispose the audio service since it's a singleton
    // and might be used by other screens
    // Instead, just unsubscribe from any listeners we've added
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meditation.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm_add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAlarmScreen(meditation: widget.meditation),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    widget.meditation.imagePath,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.meditation.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _getCategoryIcon(widget.meditation.category),
                            const SizedBox(width: 8),
                            Text(
                              'Category: ${widget.meditation.category}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.timer, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Duration: ${_formatDuration(_duration)}',
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.meditation.description}',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              children: [
                Slider(
                  min: 0,
                  max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                  value: _position.inSeconds.toDouble() > _duration.inSeconds.toDouble() 
                      ? _duration.inSeconds.toDouble() 
                      : _position.inSeconds.toDouble(),
                  onChanged: (value) {
                    final position = Duration(seconds: value.toInt());
                    _audioPlayerService.seek(position);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(_position)),
                      Text(_formatDuration(_duration)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        _audioPlayerService.seek(Duration(seconds: _position.inSeconds - 10));
                      },
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: IconButton(
                        iconSize: 32,
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_isPlaying) {
                            _audioPlayerService.pause();
                          } else {
                            _playAudio();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        _audioPlayerService.seek(Duration(seconds: _position.inSeconds + 10));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}