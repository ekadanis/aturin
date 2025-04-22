import 'package:flutter/material.dart';
import 'package:relax_fik/features/meditation/models/meditation_model.dart';
import 'package:relax_fik/features/meditation/services/meditation_service.dart';
import 'package:relax_fik/features/meditation/ui/meditation_detail_screen.dart';
import 'package:relax_fik/features/meditation/services/audio_player_service.dart';
import 'package:audioplayers/audioplayers.dart';

class SearchMeditationScreen extends StatefulWidget {
  const SearchMeditationScreen({Key? key}) : super(key: key);

  @override
  State<SearchMeditationScreen> createState() => _SearchMeditationScreenState();
}

class _SearchMeditationScreenState extends State<SearchMeditationScreen> {
  final MeditationService _meditationService = MeditationService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final TextEditingController _searchController = TextEditingController();
  List<Meditation> _allMeditations = [];
  List<Meditation> _searchResults = [];
  bool _isLoading = true;
  int? _currentlyPlayingIndex;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadMeditations();
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setupAudioPlayer() {
    _audioPlayerService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  Future<void> _loadMeditations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _allMeditations = await _meditationService.getMeditations();
      _searchResults = [];
    } catch (e) {
      debugPrint('Error loading meditations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchMeditations(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allMeditations
            .where((meditation) =>
                meditation.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _searchMeditations,
          decoration: InputDecoration(
            hintText: 'Cari meditasi...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _searchMeditations('');
              },
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isEmpty && _searchResults.isEmpty
              ? _buildEmptySearchPrompt()
              : _buildSearchResults(),
    );
  }

  Widget _buildEmptySearchPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Cari meditasi favoritmu',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan judul atau kata kunci',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ditemukan hasil',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba dengan kata kunci lain',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final meditation = _searchResults[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MeditationDetailScreen(meditation: meditation),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16)),
                        child: Image.asset(
                          meditation.imagePath,
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meditation.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kategori: ${meditation.category}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.play_circle_outline,
                                      size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${meditation.playCount} kali diputar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(12.0),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _currentlyPlayingIndex == index && _isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              if (_currentlyPlayingIndex == index &&
                                  _isPlaying) {
                                _audioPlayerService.pause();
                              } else {
                                _audioPlayerService.play(meditation.audioPath,
                                    meditationTitle: meditation.title);
                                _currentlyPlayingIndex = index;
                                _meditationService
                                    .incrementPlayCount(meditation.id!);
                              }
                            });
                          },
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