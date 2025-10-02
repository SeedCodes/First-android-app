import 'package:flutter/material.dart';
import 'dart:io';
import '../models/journal_entry.dart';
import '../models/arc_data.dart';
import '../utils/storage_helper.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final TextEditingController _entryController = TextEditingController();
  final TextEditingController _weeklyController = TextEditingController();
  
  List<JournalEntry> _entries = [];
  JournalEntry? _todayEntry;
  ArcData? _arcData;
  bool _isLoading = true;
  String? _selectedMood;
  String? _photoPath;
  bool _showWeeklyPrompt = false;
  
  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Great'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😔', 'label': 'Struggling'},
    {'emoji': '💪', 'label': 'Motivated'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _weeklyController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final entries = await StorageHelper.loadJournalEntries();
    final arcData = await StorageHelper.loadArcData();
    
    // Find today's entry if exists
    final today = DateTime.now();
    final todayEntry = entries.firstWhere(
      (entry) => entry.isToday(),
      orElse: () => JournalEntry(
        date: today,
        content: '',
        mood: null,
        photoPath: null,
      ),
    );

    // Check if we should show weekly reflection
    final daysCompleted = arcData?.getDaysCompleted() ?? 0;
    final shouldShowWeekly = daysCompleted > 0 && 
                             daysCompleted % 7 == 0 && 
                             !todayEntry.hasWeeklyReflection;

    setState(() {
      _entries = entries;
      _todayEntry = todayEntry;
      _arcData = arcData;
      _entryController.text = todayEntry.content;
      _selectedMood = todayEntry.mood;
      _photoPath = todayEntry.photoPath;
      _showWeeklyPrompt = shouldShowWeekly;
      _isLoading = false;
    });
  }

  Future<void> _saveEntry() async {
    if (_todayEntry == null) return;

    final updatedEntry = _todayEntry!.copyWith(
      content: _entryController.text.trim(),
      mood: _selectedMood,
      photoPath: _photoPath,
    );

    // Update or add entry
    final updatedEntries = List<JournalEntry>.from(_entries);
    final existingIndex = updatedEntries.indexWhere((e) => e.isToday());
    
    if (existingIndex >= 0) {
      updatedEntries[existingIndex] = updatedEntry;
    } else {
      updatedEntries.insert(0, updatedEntry);
    }

    await StorageHelper.saveJournalEntries(updatedEntries);

    setState(() {
      _entries = updatedEntries;
      _todayEntry = updatedEntry;
    });
  }

  Future<void> _saveWeeklyReflection() async {
    if (_todayEntry == null || _weeklyController.text.trim().isEmpty) return;

    final updatedEntry = _todayEntry!.copyWith(
      weeklyReflection: _weeklyController.text.trim(),
    );

    final updatedEntries = List<JournalEntry>.from(_entries);
    final existingIndex = updatedEntries.indexWhere((e) => e.isToday());
    
    if (existingIndex >= 0) {
      updatedEntries[existingIndex] = updatedEntry;
    } else {
      updatedEntries.insert(0, updatedEntry);
    }

    await StorageHelper.saveJournalEntries(updatedEntries);

    setState(() {
      _entries = updatedEntries;
      _todayEntry = updatedEntry;
      _showWeeklyPrompt = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weekly reflection saved! 📝'),
          backgroundColor: Color(0xFF50C878),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _selectMood(String mood) {
    setState(() {
      _selectedMood = mood;
    });
    _saveEntry();
  }

  Future<void> _addPhoto() async {
    // In a real app, this would open image picker
    // For now, we'll show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo picker would open here (requires image_picker package)'),
        backgroundColor: Color(0xFF4A90E2),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Placeholder: Simulate adding a photo
    // In production, use image_picker package:
    // final picker = ImagePicker();
    // final image = await picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   setState(() {
    //     _photoPath = image.path;
    //   });
    //   _saveEntry();
    // }
  }

  void _removePhoto() {
    setState(() {
      _photoPath = null;
    });
    _saveEntry();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4A90E2),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBackButton(),
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildTodaySection(),
                      const SizedBox(height: 16),
                      _buildMoodPicker(),
                      const SizedBox(height: 16),
                      _buildPhotoSection(),
                      if (_showWeeklyPrompt) ...[
                        const SizedBox(height: 24),
                        _buildWeeklyPrompt(),
                      ],
                      const SizedBox(height: 32),
                      _buildJournalHistory(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back,
              color: Color(0xFF4A90E2),
              size: 20,
            ),
            SizedBox(width: 4),
            Text(
              'Back',
              style: TextStyle(
                color: Color(0xFF4A90E2),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final today = DateTime.now();
    final formattedDate = '${_getMonthName(today.month)} ${today.day}, ${today.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Journal',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text(
              'Capture your daily reflections',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A90E2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodaySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Today\'s Entry',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _entryController,
            maxLines: 8,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'How was today? Wins? Struggles?\n\nWrite about your progress, challenges, or anything on your mind...',
              hintStyle: const TextStyle(
                color: Colors.white38,
                fontSize: 15,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E21),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            onChanged: (text) {
              // Auto-save after short delay
              Future.delayed(const Duration(seconds: 1), () {
                _saveEntry();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['emoji'];
              return GestureDetector(
                onTap: () => _selectMood(mood['emoji']!),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4A90E2).withOpacity(0.2)
                            : const Color(0xFF0A0E21),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4A90E2)
                              : Colors.white24,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mood['emoji']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mood['label']!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? const Color(0xFF4A90E2) : Colors.white54,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (_photoPath != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: const Color(0xFF0A0E21),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: 64,
                            color: Color(0xFF4A90E2),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Photo Preview',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // In production with real photos:
                    // child: Image.file(
                    //   File(_photoPath!),
                    //   fit: BoxFit.cover,
                    // ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _removePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            GestureDetector(
              onTap: _addPhoto,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      color: Color(0xFF4A90E2),
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add Photo',
                      style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Workout proof, study notes, etc.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9B59B6).withOpacity(0.3),
            const Color(0xFF8E44AD).withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF9B59B6).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF9B59B6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Weekly Reflection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'How did your week go overall?',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white70,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _weeklyController,
            maxLines: 4,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Reflect on your achievements, challenges, and learnings this week...',
              hintStyle: const TextStyle(
                color: Colors.white38,
                fontSize: 14,
              ),
              filled: true,
              fillColor: const Color(0xFF0A0E21).withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveWeeklyReflection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B59B6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save Weekly Reflection',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalHistory() {
    // Filter out today's entry from history
    final pastEntries = _entries.where((e) => !e.isToday()).toList();

    if (pastEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.book_outlined,
                color: Colors.white24,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'No past entries yet',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your journal history will appear here',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Past Entries',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...pastEntries.map((entry) => _buildHistoryEntry(entry)).toList(),
      ],
    );
  }

  Widget _buildHistoryEntry(JournalEntry entry) {
    final formattedDate = '${_getMonthName(entry.date.month)} ${entry.date.day}, ${entry.date.year}';
    final snippet = entry.content.length > 120
        ? '${entry.content.substring(0, 120)}...'
        : entry.content;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white12,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (entry.mood != null) ...[
                Text(
                  entry.mood!,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A90E2),
                ),
              ),
              const Spacer(),
              if (entry.photoPath != null)
                const Icon(
                  Icons.image,
                  size: 16,
                  color: Color(0xFF50C878),
                ),
            ],
          ),
          if (snippet.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              snippet,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (entry.hasWeeklyReflection) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 12,
                    color: Color(0xFF9B59B6),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Weekly Reflection',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9B59B6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
