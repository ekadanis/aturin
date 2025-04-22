import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:relax_fik/features/meditation/models/meditation_model.dart';
import 'package:relax_fik/features/meditation/services/meditation_service.dart';
import 'package:relax_fik/features/meditation/ui/meditation_detail_screen.dart';
import 'package:relax_fik/features/meditation/services/audio_player_service.dart';
import 'package:relax_fik/features/alarm/services/alarm_service.dart';
import 'package:relax_fik/features/meditation/ui/search_meditation_screen.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({Key? key}) : super(key: key);

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final MeditationService _meditationService = MeditationService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final AlarmService _alarmService = AlarmService();
  List<Meditation> _meditations = [];
  List<Meditation> _filteredMeditations = []; // Untuk hasil pencarian
  String _selectedCategory = 'All';
  bool _isLoading = true;
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;
  int _alarmCount = 0;

  final List<String> _categories = [
    'All',
    'Alam',
    'Instrumental',
    'Perkotaan yang tenang',
    'Imajinatif',
  ];

  @override
  void initState() {
    super.initState();
    _loadMeditations();
    _loadAlarmCount();
    _setupAudioPlayer();
  }

  Future<void> _loadAlarmCount() async {
    final alarms = await _alarmService.getAlarms();
    setState(() {
      _alarmCount = alarms.length;
    });
  }

  void _setupAudioPlayer() {
    _audioPlayerService.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  Future<void> _loadMeditations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_selectedCategory == 'All') {
        _meditations = await _meditationService.getMeditations();
      } else {
        _meditations = await _meditationService.getMeditationsByCategory(_selectedCategory);
      }
      _filteredMeditations = _meditations; // Inisialisasi hasil pencarian
    } catch (e) {
      // Handle error
      debugPrint('Error loading meditations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ruang Tenang',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchMeditationScreen(),
                ),
              );
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildCategoryFilter(),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMeditationList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        
        // Personal greeting section with clean white background
        Row(
          children: [
            // Avatar
            ClipOval(
              child: Image.asset(
                'assets/images/Avatar.png',
                fit: BoxFit.cover,
                width: 60,
                height: 60,
              ),
            ),
            const SizedBox(width: 16),
            
            // Greeting and alarm info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff5263F3),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Zhafran!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Kamu memiliki ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '$_alarmCount',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB74206),
                      ),
                    ),
                    Text(
                      ' alarm meditasi yang dijadwalkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
              _loadMeditations();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : const Color(0xFFC6D6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF5263F3),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMeditationList() {
    return ListView.builder(
      itemCount: _filteredMeditations.length,
      itemBuilder: (context, index) {
        final meditation = _filteredMeditations[index];
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MeditationDetailScreen(meditation: meditation),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    meditation.imagePath,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meditation.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.play_circle_outline, size: 16),
                              const SizedBox(width: 4),
                              Text('${meditation.playCount} kali diputar'),
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: Icon(
                                _currentlyPlayingIndex == index && _isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_currentlyPlayingIndex == index && _isPlaying) {
                                    // Pause the currently playing audio
                                    _audioPlayerService.pause();
                                    _isPlaying = false;
                                  } else {
                                    _audioPlayerService.play(
                                      meditation.audioPath,
                                      meditationTitle: meditation.title
                                    );
                                    _currentlyPlayingIndex = index;
                                    _isPlaying = true;
                                    
                                    // Increment play count when a meditation is played
                                    _meditationService.incrementPlayCount(meditation.id!);
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}