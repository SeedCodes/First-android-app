import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/arc_data.dart';
import '../models/progress_stats.dart';
import '../utils/storage_helper.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  ArcData? _arcData;
  ProgressStats? _progressStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final arcData = await StorageHelper.loadArcData();
    final progressStats = await StorageHelper.loadProgressStats();

    setState(() {
      _arcData = arcData;
      _progressStats = progressStats ?? ProgressStats.create();
      _isLoading = false;
    });
  }

  String _getMilestoneMessage() {
    if (_arcData == null) return '';

    final percentage = _arcData!.getProgressPercentage();
    final daysCompleted = _arcData!.getDaysCompleted();

    if (percentage >= 100) {
      return '🎉 Arc Complete! Legendary achievement unlocked!';
    } else if (percentage >= 75) {
      return '💪 75% Complete! The final push is here!';
    } else if (percentage >= 50) {
      return '🔥 Halfway through your arc! $daysCompleted/${_arcData!.duration} completed.';
    } else if (percentage >= 25) {
      return '⚡ Quarter mark reached! Keep the momentum!';
    } else if (daysCompleted >= 10) {
      return '🌟 10+ days in! You\'re building something great.';
    } else {
      return '🚀 Your journey has begun. Stay consistent!';
    }
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBackButton(),
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildWeeklyStreakView(),
                const SizedBox(height: 24),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildArcVisualization(),
                const SizedBox(height: 24),
                _buildMilestoneCard(),
                const SizedBox(height: 24),
                _buildTimelineView(),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Track your journey through the arc.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyStreakView() {
    final currentStreak = _progressStats?.currentStreak ?? 0;
    final longestStreak = _progressStats?.longestStreak ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withOpacity(0.2),
            const Color(0xFFF7931E).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF6B35).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Color(0xFFFF6B35),
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                '$currentStreak-Day Streak',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeekCalendar(),
          const SizedBox(height: 12),
          Text(
            'Best: $longestStreak days',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar() {
    final today = DateTime.now();
    final weekDays = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: weekDays.map((day) {
        final isCompleted = _progressStats?.isDateCompleted(day) ?? false;
        final isToday = day.day == today.day &&
            day.month == today.month &&
            day.year == today.year;

        return Column(
          children: [
            Text(
              _getDayName(day.weekday),
              style: TextStyle(
                fontSize: 11,
                color: isToday ? const Color(0xFF50C878) : Colors.white54,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF50C878)
                    : const Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isToday
                      ? const Color(0xFF50C878)
                      : isCompleted
                          ? const Color(0xFF50C878)
                          : Colors.white24,
                  width: isToday ? 2 : 1,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? Colors.white : Colors.white54,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildStatsSection() {
    final daysCompleted = _arcData!.getDaysCompleted();
    final totalDays = _arcData!.duration;
    final successRate = _progressStats?.getSuccessRate() ?? 0.0;
    final missedDays = _progressStats?.missedDays ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'Success Rate',
                value: '${successRate.toStringAsFixed(0)}%',
                color: const Color(0xFF50C878),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_today,
                label: 'Days Done',
                value: '$daysCompleted/$totalDays',
                color: const Color(0xFF4A90E2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.close,
                label: 'Missed Days',
                value: '$missedDays',
                color: const Color(0xFFE74C3C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.hotel_class,
                label: 'Best Streak',
                value: '${_progressStats?.longestStreak ?? 0}',
                color: const Color(0xFFF7931E),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArcVisualization() {
    final percentage = _arcData!.getProgressPercentage();
    final daysCompleted = _arcData!.getDaysCompleted();
    final totalDays = _arcData!.duration;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Arc Completion',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: ArcProgressPainter(
                progress: percentage / 100,
                color: const Color(0xFF4A90E2),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$daysCompleted of $totalDays days',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressBar(percentage / 100),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: const Color(0xFF0A0E21),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFF4A90E2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _arcData!.startDate.toString().split(' ')[0],
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
            Text(
              _arcData!.startDate
                  .add(Duration(days: _arcData!.duration))
                  .toString()
                  .split(' ')[0],
              style: const TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestoneCard() {
    final message = _getMilestoneMessage();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF50C878).withOpacity(0.2),
            const Color(0xFF4A90E2).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF50C878).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF50C878).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Color(0xFF50C878),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineView() {
    final daysCompleted = _arcData!.getDaysCompleted();
    final totalDays = _arcData!.duration;

    // Show a scrollable timeline of weeks
    final weeks = (totalDays / 7).ceil();
    final completedDates = _progressStats?.completedDates ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Journey Timeline',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(weeks, (weekIndex) {
              return _buildWeekRow(weekIndex, completedDates);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekRow(int weekIndex, List<DateTime> completedDates) {
    final startDay = weekIndex * 7 + 1;
    final daysInWeek = math.min(7, _arcData!.duration - weekIndex * 7);
    final currentDay = _arcData!.getDaysCompleted();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week ${weekIndex + 1}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(daysInWeek, (dayIndex) {
              final dayNumber = startDay + dayIndex;
              final isPast = dayNumber <= currentDay;
              final isCurrent = dayNumber == currentDay;
              final dayDate = _arcData!.startDate.add(Duration(days: dayNumber - 1));
              final isCompleted = completedDates.any((date) =>
                  date.year == dayDate.year &&
                  date.month == dayDate.month &&
                  date.day == dayDate.day);

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF50C878)
                        : isPast
                            ? const Color(0xFFE74C3C).withOpacity(0.3)
                            : const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFF4A90E2)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 11,
                              color: isPast ? Colors.white54 : Colors.white38,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Custom painter for arc visualization
class ArcProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  ArcProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Background arc
    final backgroundPaint = Paint()
      ..color = const Color(0xFF0A0E21)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi,
      math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ArcProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
