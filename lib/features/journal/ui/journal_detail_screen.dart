import 'package:flutter/material.dart';
import 'package:relax_fik/features/journal/models/journal_model.dart';
import 'package:relax_fik/features/journal/services/journal_service.dart';
import 'package:relax_fik/features/journal/ui/add_journal_screen.dart';

class JournalDetailScreen extends StatefulWidget {
  final Journal journal;

  const JournalDetailScreen({
    Key? key,
    required this.journal,
  }) : super(key: key);

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  final JournalService _journalService = JournalService();
  bool _isLoading = false;

  // Mapping ikon dan terjemahan untuk setiap mood
  final Map<String, IconData> _moodIcons = {
    'Happy': Icons.sentiment_very_satisfied,
    'Sad': Icons.sentiment_dissatisfied,
    'Angry': Icons.mood_bad,
    'Anxious': Icons.sentiment_neutral,
    'Calm': Icons.sentiment_satisfied,
  };

  final Map<String, String> _moodTranslations = {
    'Happy': 'Senang',
    'Sad': 'Sedih',
    'Angry': 'Marah',
    'Anxious': 'Cemas',
    'Calm': 'Tenang',
  };

  String _getMoodTranslation(String mood) {
    return _moodTranslations[mood] ?? mood;
  }

  Future<void> _deleteJournal() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _journalService.deleteJournal(widget.journal.id!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      // Handle error
      debugPrint('Error deleting journal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus catatan'),
          ),
        );
      }
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
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddJournalScreen(journal: widget.journal),
                ),
              );

              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _isLoading ? null : _deleteJournal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Satu card yang menggabungkan semua informasi
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bagian header dengan tanggal dan mood
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.journal.date,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _getMoodColor(widget.journal.mood).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _getMoodColor(widget.journal.mood),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _moodIcons[widget.journal.mood] ?? Icons.mood,
                                      color: _getMoodColor(widget.journal.mood),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getMoodTranslation(widget.journal.mood),
                                      style: TextStyle(
                                        color: _getMoodColor(widget.journal.mood),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Divider antar bagian
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Divider(
                              color: Colors.grey.withOpacity(0.3),
                              height: 1,
                            ),
                          ),
                          // Bagian konten catatan
                          const Row(
                            children: [
                              Icon(Icons.note_alt, color: Colors.grey),
                              SizedBox(width: 8),
                              Text(
                                'Catatan Hari Ini',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.journal.content,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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