import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/arc_data.dart';
import '../models/daily_progress.dart';
import '../models/progress_stats.dart';
import '../utils/storage_helper.dart';
import '../utils/quotes_helper.dart';
import 'progress_page.dart';
import 'journal_page.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  ArcData? _arcData;
  DailyProgress? _dailyProgress;
  ProgressStats? _progressStats;
  bool _isLoading = true;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final arcData = await StorageHelper.loadArcData();
    final dailyProgress = await StorageHelper.loadDailyProgress();
    final progressStats = await StorageHelper.loadProgressStats();

    setState(() {
      _arcData = arcData;
      _dailyProgress = dailyProgress ?? DailyProgress.create(arcData?.goals ?? []);
      _progressStats = progressStats ?? ProgressStats.create();
      _isLoading = false;
    });

    // Check if all goals are completed and update stats
    _checkDayCompletion();
  }

  Future<void> _toggleGoal(String goal) async {
    if (_dailyProgress == null) return;

    setState(() {
      _dailyProgress!.toggleGoal(goal);
    });

    await StorageHelper.saveDailyProgress(_dailyProgress!);
    
    // Check if day is now complete
    _checkDayCompletion();
  }

  Future<void> _checkDayCompletion() async {
    if (_dailyProgress == null || _progressStats == null) return;

    // If all goals are completed for today
    if (_dailyProgress!.isFullyCompleted()) {
      final today = DateTime.now();
      
      // Mark today as completed if not already marked
      if (!_progressStats!.isDateCompleted(today)) {
        setState(() {
          _progressStats = _progressStats!.markDateCompleted(today);
        });
        await StorageHelper.saveProgressStats(_progressStats!);
        
        // Show celebration
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('🎉 All goals completed! Day conquered!'),
              backgroundColor: const Color(0xFF50C878),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  double _getOverallProgress() {
    if (_dailyProgress == null || _dailyProgress!.goals.isEmpty) {
      return 0.0;
    }
    return _dailyProgress!.getCompletionPercentage() / 100;
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

    if (_arcData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No Arc Data Found',
            style: TextStyle(color: Colors.white),
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
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildProgressRing(),
                      const SizedBox(height: 40),
                      _buildDailyGoals(),
                      const SizedBox(height: 24),
                      _buildMotivationalQuote(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final daysCompleted = _arcData!.getDaysCompleted();
    final totalDays = _arcData!.duration;

    return Column(
      children: [
        Text(
          _arcData!.arcName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Day $daysCompleted of $totalDays',
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF50C878),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing() {
    final daysCompleted = _arcData!.getDaysCompleted();
    final totalDays = _arcData!.duration;
    final arcProgress = daysCompleted / totalDays;
    final dailyProgress = _getOverallProgress();

    return Container(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring - Arc Progress (total days)
          CustomPaint(
            size: const Size(280, 280),
            painter: ProgressRingPainter(
              progress: arcProgress,
              strokeWidth: 20,
              color: const Color(0xFF4A90E2).withOpacity(0.3),
              backgroundColor: const Color(0xFF1D1E33),
            ),
          ),

          // Inner ring - Daily Goals Progress
          CustomPaint(
            size: const Size(240, 240),
            painter: ProgressRingPainter(
              progress: dailyProgress,
              strokeWidth: 16,
              color: const Color(0xFF50C878),
              backgroundColor: const Color(0xFF1D1E33),
            ),
          ),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'DAY',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$daysCompleted',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(dailyProgress * 100).toInt()}% Today',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF50C878),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoals() {
    if (_dailyProgress == null || _dailyProgress!.goals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '${_dailyProgress!.getCompletedCount()}/${_dailyProgress!.goals.length}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF50C878),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._dailyProgress!.goals.entries.map((entry) {
            final goalName = entry.key;
            final isCompleted = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _toggleGoal(goalName),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF50C878).withOpacity(0.1)
                        : const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted
                          ? const Color(0xFF50C878)
                          : Colors.white12,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF50C878)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCompleted
                                ? const Color(0xFF50C878)
                                : Colors.white38,
                            width: 2,
                          ),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          goalName,
                          style: TextStyle(
                            fontSize: 16,
                            color: isCompleted
                                ? Colors.white
                                : Colors.white70,
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.white54,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        const Icon(
                          Icons.celebration,
                          size: 20,
                          color: Color(0xFF50C878),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    final quote = QuotesHelper.getDailyQuote();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A90E2).withOpacity(0.2),
            const Color(0xFF50C878).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4A90E2).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.format_quote,
            color: Color(0xFF4A90E2),
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.trending_up,
                label: 'Progress',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.book_rounded,
                label: 'Journal',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        
        // Navigate to respective pages
        if (index == 1) {
          // Progress page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProgressPage()),
          ).then((_) {
            // Reset selection when returning
            setState(() {
              _currentNavIndex = 0;
            });
          });
        } else if (index == 2) {
          // Journal page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JournalPage()),
          ).then((_) {
            // Reset selection when returning
            setState(() {
              _currentNavIndex = 0;
            });
          });
        } else if (index != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label page - Coming soon!'),
              backgroundColor: const Color(0xFF4A90E2),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90E2).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF4A90E2)
                  : Colors.white54,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF4A90E2)
                    : Colors.white54,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for circular progress rings
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
