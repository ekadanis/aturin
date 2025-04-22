import 'package:flutter/material.dart';
import 'package:relax_fik/core/utils/date_formatter.dart';
import 'package:relax_fik/features/journal/models/journal_model.dart';
import 'package:relax_fik/features/journal/services/journal_service.dart';
import 'package:relax_fik/features/journal/ui/add_journal_screen.dart';
import 'package:relax_fik/features/journal/ui/journal_detail_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final JournalService _journalService = JournalService();
  List<Journal> _journals = [];
  bool _isLoading = true;

  // Mapping ikon untuk setiap mood
  final Map<String, IconData> _moodIcons = {
    'Happy': Icons.sentiment_very_satisfied,
    'Sad': Icons.sentiment_dissatisfied,
    'Angry': Icons.mood_bad,
    'Anxious': Icons.sentiment_neutral,
    'Calm': Icons.sentiment_satisfied,
  };

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _journals = await _journalService.getJournals();
    } catch (e) {
      debugPrint('Error loading journals: $e');
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
          'Ruang Catatan',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journals.isEmpty
              ? _buildEmptyState()
              : _buildJournalList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddJournalScreen(),
            ),
          );

          if (result == true) {
            _loadJournals();
          }
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Anda belum memiliki catatan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Buat catatan pertama Anda untuk memulai perjalanan refleksi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddJournalScreen(),
                ),
              );

              if (result == true) {
                _loadJournals();
              }
            },
            child: const Text('Buat Catatan'),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _journals.length,
      itemBuilder: (context, index) {
        final journal = _journals[index];
        
        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JournalDetailScreen(journal: journal),
              ),
            );

            if (result == true) {
              _loadJournals();
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        journal.date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getMoodColor(journal.mood).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getMoodColor(journal.mood),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            _moodIcons[journal.mood] ?? Icons.mood,
                            color: _getMoodColor(journal.mood),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    journal.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'anxious':
        return Colors.orange;
      case 'calm':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}