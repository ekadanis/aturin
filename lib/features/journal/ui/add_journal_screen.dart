import 'package:flutter/material.dart';
import 'package:relax_fik/core/utils/date_formatter.dart';
import 'package:relax_fik/features/journal/models/journal_model.dart';
import 'package:relax_fik/features/journal/services/journal_service.dart';

class AddJournalScreen extends StatefulWidget {
  final Journal? journal;

  const AddJournalScreen({
    Key? key,
    this.journal,
  }) : super(key: key);

  @override
  State<AddJournalScreen> createState() => _AddJournalScreenState();
}

class _AddJournalScreenState extends State<AddJournalScreen> {
  final JournalService _journalService = JournalService();
  final TextEditingController _contentController = TextEditingController();
  
  String _selectedMood = 'Senang';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  final List<String> _moods = ['Senang', 'Sedih', 'Marah', 'Cemas', 'Tenang'];

  // Mapping ikon untuk setiap mood
  final Map<String, IconData> _moodIcons = {
    'Senang': Icons.sentiment_very_satisfied,
    'Sedih': Icons.sentiment_dissatisfied,
    'Marah': Icons.mood_bad,
    'Cemas': Icons.sentiment_neutral,
    'Tenang': Icons.sentiment_satisfied,
  };

  @override
  void initState() {
    super.initState();
    
    if (widget.journal != null) {
      _contentController.text = widget.journal!.content;
      // Sesuaikan mood dari bahasa Inggris ke Indonesia
      _selectedMood = _convertMoodToIndonesian(widget.journal!.mood);
    }
  }

  String _convertMoodToIndonesian(String englishMood) {
    final Map<String, String> moodMap = {
      'Happy': 'Senang',
      'Sad': 'Sedih',
      'Angry': 'Marah',
      'Anxious': 'Cemas',
      'Calm': 'Tenang'
    };
    
    return moodMap[englishMood] ?? 'Senang';
  }

  String _convertMoodToEnglish(String indonesianMood) {
    final Map<String, String> moodMap = {
      'Senang': 'Happy',
      'Sedih': 'Sad',
      'Marah': 'Angry',
      'Cemas': 'Anxious',
      'Tenang': 'Calm'
    };
    
    return moodMap[indonesianMood] ?? 'Happy';
  }

  Future<void> _saveJournal() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tulis catatan Anda'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final journal = Journal(
        id: widget.journal?.id,
        date: DateFormatter.formatDate(_selectedDate),
        mood: _convertMoodToEnglish(_selectedMood), // Konversi ke bahasa Inggris untuk penyimpanan
        content: _contentController.text,
        createdAt: DateTime.now().toIso8601String(),
      );

      if (widget.journal == null) {
        await _journalService.addJournal(journal);
      } else {
        await _journalService.updateJournal(journal);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving journal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan catatan'),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      locale: const Locale('id', 'ID'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.journal == null ? 'Tambah Catatan' : 'Edit Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveJournal,
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
                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormatter.formatDate(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Suasana Hati',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tampilan mood dengan ikon yang lebih menarik
                  Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _moods.length,
                      itemBuilder: (context, index) {
                        final mood = _moods[index];
                        final isSelected = mood == _selectedMood;
                        final moodColor = _getMoodColor(mood);
                        
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood;
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? moodColor.withOpacity(0.2) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? moodColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _moodIcons[mood],
                                  color: moodColor,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  mood,
                                  style: TextStyle(
                                    color: isSelected ? moodColor : Colors.black87,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Catatan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentController,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      hintText: 'Tuliskan pikiran Anda di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveJournal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Simpan Catatan',
                        style: TextStyle(fontSize: 16),
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
      case 'senang':
        return Colors.green;
      case 'sedih':
        return Colors.blue;
      case 'marah':
        return Colors.red;
      case 'cemas':
        return Colors.orange;
      case 'tenang':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}