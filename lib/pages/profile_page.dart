import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/arc_data.dart';
import '../models/app_settings.dart';
import '../utils/storage_helper.dart';
import '../utils/notification_helper.dart';
import '../utils/export_helper.dart';
import '../providers/theme_provider.dart';
import 'arc_setup_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ArcData? _arcData;
  AppSettings? _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final arcData = await StorageHelper.loadArcData();
    final settings = await StorageHelper.loadAppSettings();

    setState(() {
      _arcData = arcData;
      _settings = settings ?? AppSettings.defaultSettings();
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (_settings == null) return;
    await StorageHelper.saveAppSettings(_settings!);
    
    // Update notifications if enabled
    if (_settings!.notificationsEnabled) {
      await NotificationHelper.scheduleDailyReminder(_settings!);
    }
  }

  void _editArcName() {
    if (_arcData == null) return;

    final controller = TextEditingController(text: _arcData!.arcName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text(
          'Edit Arc Name',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter new arc name',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF0A0E21),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final updatedArc = ArcData(
                  arcName: newName,
                  duration: _arcData!.duration,
                  goals: _arcData!.goals,
                  startDate: _arcData!.startDate,
                );
                await StorageHelper.saveArcData(updatedArc);
                setState(() {
                  _arcData = updatedArc;
                });
                if (mounted) Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editGoals() {
    if (_arcData == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGoalsPage(arcData: _arcData!),
      ),
    ).then((_) => _loadData());
  }

  void _restartArc() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text(
          'Restart Arc?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will clear all your progress and start fresh. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear all data
              await StorageHelper.clearArcData();
              await StorageHelper.clearDailyProgress();
              await StorageHelper.clearProgressStats();
              await StorageHelper.clearJournalEntries();

              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArcSetupPage(),
                  ),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
            ),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  void _setNotificationTime() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings!.notificationHour,
        minute: _settings!.notificationMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90E2),
              surface: Color(0xFF1D1E33),
            ),
          ),
          child: child!,
        );
      },
    ).then((time) {
      if (time != null) {
        setState(() {
          _settings = _settings!.copyWith(
            notificationHour: time.hour,
            notificationMinute: time.minute,
          );
        });
        _saveSettings();
      }
    });
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
                _buildArcInfoSection(),
                const SizedBox(height: 24),
                _buildThemesSection(),
                const SizedBox(height: 24),
                _buildNotificationsSection(),
                const SizedBox(height: 24),
                _buildDataExportSection(),
                const SizedBox(height: 24),
                _buildAboutSection(),
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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage your arc and preferences.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildArcInfoSection() {
    if (_arcData == null) {
      return const SizedBox.shrink();
    }

    final daysCompleted = _arcData!.getDaysCompleted();
    final daysRemaining = _arcData!.getDaysRemaining();

    return Container(
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
                  color: const Color(0xFF4A90E2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.stars,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Current Arc',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _arcData!.arcName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF50C878),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.calendar_today,
                label: 'Day $daysCompleted/${_arcData!.duration}',
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.timer,
                label: '$daysRemaining days left',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          const Text(
            'Your Goals:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ..._arcData!.goals.map((goal) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xFF50C878),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      goal,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _editArcName,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Name'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    side: const BorderSide(color: Color(0xFF4A90E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _editGoals,
                  icon: const Icon(Icons.list, size: 16),
                  label: const Text('Edit Goals'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A90E2),
                    side: const BorderSide(color: Color(0xFF4A90E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _restartArc,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Restart Arc'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE74C3C),
                side: const BorderSide(color: Color(0xFFE74C3C)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4A90E2)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemesSection() {
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
                  color: const Color(0xFF9B59B6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.palette,
                  color: Color(0xFF9B59B6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildThemeOption('Default Dark', 'Blue & emerald winter theme', 0),
          const SizedBox(height: 12),
          _buildThemeOption('Minimal', 'Clean monochrome design', 1),
          const SizedBox(height: 12),
          _buildThemeOption('Warrior', 'Bold red & black theme', 2),
          const SizedBox(height: 8),
          const Text(
            'Theme applies instantly across the app! ✨',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF50C878),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, String description, int themeIndex) {
    final isSelected = _settings!.themeIndex == themeIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _settings = _settings!.copyWith(themeIndex: themeIndex);
        });
        _saveSettings();
        
        // Apply theme immediately
        Provider.of<ThemeProvider>(context, listen: false).setTheme(themeIndex);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title theme applied! ✨'),
            backgroundColor: const Color(0xFF50C878),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF9B59B6) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF9B59B6) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF9B59B6),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
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
                  color: const Color(0xFF50C878).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xFF50C878),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildToggleOption(
            'Daily Reminders',
            'Get notified to check in daily',
            _settings!.notificationsEnabled,
            (value) {
              setState(() {
                _settings = _settings!.copyWith(notificationsEnabled: value);
              });
              _saveSettings();
            },
          ),
          if (_settings!.notificationsEnabled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _setNotificationTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0E21),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFF50C878),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Notification Time',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${_settings!.notificationHour.toString().padLeft(2, '0')}:${_settings!.notificationMinute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF50C878),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Motivational Style:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildMotivationStyleOption('Short Tips', '"Stay locked in."', 0),
            const SizedBox(height: 8),
            _buildMotivationStyleOption('Quotes', 'Inspirational quotes', 1),
            const SizedBox(height: 8),
            _buildMotivationStyleOption('Custom', 'Your own reminders', 2),
          ],
          const SizedBox(height: 12),
          const Text(
            'Notifications active! You\'ll get daily reminders. 🔔',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF50C878),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (newValue) async {
            onChanged(newValue);
            
            // Request permission and schedule notifications
            if (newValue) {
              final hasPermission = await NotificationHelper.requestPermission();
              if (hasPermission) {
                await NotificationHelper.scheduleDailyReminder(_settings!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Daily reminders enabled! 🔔'),
                      backgroundColor: Color(0xFF50C878),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                // Permission denied
                setState(() {
                  _settings = _settings!.copyWith(notificationsEnabled: false);
                });
                _saveSettings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification permission required'),
                      backgroundColor: Color(0xFFE74C3C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            } else {
              await NotificationHelper.cancelAll();
            }
          },
          activeColor: const Color(0xFF50C878),
        ),
      ],
    );
  }

  Widget _buildMotivationStyleOption(String title, String example, int styleIndex) {
    final isSelected = _settings!.motivationStyle == styleIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _settings = _settings!.copyWith(motivationStyle: styleIndex);
        });
        _saveSettings();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF50C878) : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF50C878) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    example,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF50C878),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataExportSection() {
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
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cloud_upload,
                  color: Color(0xFFFF6B35),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Export Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExportOption(
            Icons.backup,
            'Full Backup',
            'Export all data as JSON',
            () async {
              try {
                await ExportHelper.exportAllData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data exported successfully! 📦'),
                      backgroundColor: Color(0xFF50C878),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: const Color(0xFFE74C3C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            Icons.summarize,
            'Summary Report',
            'Export readable summary',
            () async {
              try {
                await ExportHelper.exportSummary();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Summary exported! 📊'),
                      backgroundColor: Color(0xFF50C878),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: const Color(0xFFE74C3C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            Icons.menu_book,
            'Journal Export',
            'Export all journal entries',
            () async {
              try {
                await ExportHelper.exportJournal();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Journal exported! 📔'),
                      backgroundColor: Color(0xFF50C878),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: const Color(0xFFE74C3C),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E21),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF6B35), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
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
                  Icons.info_outline,
                  color: Color(0xFF4A90E2),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAboutRow(Icons.apps, 'The Winter Arc', 'Your arc companion'),
          const SizedBox(height: 12),
          _buildAboutRow(Icons.code, 'Version', '1.0.0'),
          const SizedBox(height: 12),
          _buildAboutRow(Icons.android, 'Platform', 'Android'),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          const Center(
            child: Column(
              children: [
                Text(
                  'Made with ❄️ for winter warriors',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '© 2025 The Winter Arc',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4A90E2)),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Edit Goals Page
class EditGoalsPage extends StatefulWidget {
  final ArcData arcData;

  const EditGoalsPage({super.key, required this.arcData});

  @override
  State<EditGoalsPage> createState() => _EditGoalsPageState();
}

class _EditGoalsPageState extends State<EditGoalsPage> {
  late List<String> _goals;
  final TextEditingController _newGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _goals = List<String>.from(widget.arcData.goals);
  }

  @override
  void dispose() {
    _newGoalController.dispose();
    super.dispose();
  }

  void _addGoal() {
    final newGoal = _newGoalController.text.trim();
    if (newGoal.isEmpty) return;

    if (_goals.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 goals allowed'),
          backgroundColor: Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _goals.add(newGoal);
      _newGoalController.clear();
    });
  }

  void _removeGoal(int index) {
    if (_goals.length <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum 3 goals required'),
          backgroundColor: Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _goals.removeAt(index);
    });
  }

  Future<void> _saveGoals() async {
    if (_goals.length < 3 || _goals.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please have 3-5 goals'),
          backgroundColor: Color(0xFFE74C3C),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updatedArc = ArcData(
      arcName: widget.arcData.arcName,
      duration: widget.arcData.duration,
      goals: _goals,
      startDate: widget.arcData.startDate,
    );

    await StorageHelper.saveArcData(updatedArc);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goals updated successfully! ✅'),
          backgroundColor: Color(0xFF50C878),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF4A90E2)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Goals',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '3-5 goals required',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${_goals.length}/5',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF50C878),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1E33),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.drag_indicator,
                            color: Colors.white38,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _goals[index],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            color: const Color(0xFFE74C3C),
                            onPressed: () => _removeGoal(index),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newGoalController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add new goal...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1D1E33),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _addGoal(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addGoal,
                    icon: const Icon(Icons.add_circle, size: 32),
                    color: const Color(0xFF50C878),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveGoals,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF50C878),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
