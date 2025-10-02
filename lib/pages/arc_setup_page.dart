import 'package:flutter/material.dart';
import '../models/arc_data.dart';
import '../utils/storage_helper.dart';

class ArcSetupPage extends StatefulWidget {
  const ArcSetupPage({super.key});

  @override
  State<ArcSetupPage> createState() => _ArcSetupPageState();
}

class _ArcSetupPageState extends State<ArcSetupPage> {
  int _duration = 75;
  final List<String> _selectedGoals = [];
  final TextEditingController _arcNameController = TextEditingController();
  final TextEditingController _customGoalController = TextEditingController();

  final List<String> _goalTemplates = [
    'Fitness & Exercise',
    'Study & Learning',
    'Meditation',
    'Journaling',
    'Wake up Early',
    'Read Daily',
    'Healthy Eating',
    'Cold Showers',
  ];

  @override
  void dispose() {
    _arcNameController.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        if (_selectedGoals.length < 5) {
          _selectedGoals.add(goal);
        } else {
          _showMessage('You can select maximum 5 goals');
        }
      }
    });
  }

  void _addCustomGoal() {
    final customGoal = _customGoalController.text.trim();
    if (customGoal.isEmpty) {
      _showMessage('Please enter a goal name');
      return;
    }

    if (_selectedGoals.length >= 5) {
      _showMessage('You can select maximum 5 goals');
      return;
    }

    setState(() {
      _selectedGoals.add(customGoal);
      _customGoalController.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4A90E2),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _createArc() async {
    // Validate inputs
    if (_selectedGoals.length < 3) {
      _showMessage('Please select at least 3 goals');
      return;
    }

    final arcName = _arcNameController.text.trim();
    if (arcName.isEmpty) {
      _showMessage('Please give your arc a name');
      return;
    }

    // Create arc data
    final arcData = ArcData(
      arcName: arcName,
      duration: _duration,
      goals: _selectedGoals,
      startDate: DateTime.now(),
    );

    // Save to storage
    await StorageHelper.saveArcData(arcData);

    // Navigate to Home Dashboard (placeholder for now)
    if (mounted) {
      _showMessage('Arc created successfully! 🎯');
      // TODO: Navigate to Home Dashboard
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomeDashboard()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                const SizedBox(height: 40),

                // Step 1: Duration
                _buildDurationSection(),
                const SizedBox(height: 40),

                // Step 2: Goals
                _buildGoalsSection(),
                const SizedBox(height: 40),

                // Step 3: Arc Name
                _buildArcNameSection(),
                const SizedBox(height: 40),

                // Create Button
                _buildCreateButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start Your Arc',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Set your challenge details.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Choose Duration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '$_duration Days',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF50C878),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _duration.toDouble(),
            min: 70,
            max: 90,
            divisions: 20,
            activeColor: const Color(0xFF4A90E2),
            inactiveColor: const Color(0xFF0A0E21),
            label: '$_duration days',
            onChanged: (value) {
              setState(() {
                _duration = value.toInt();
              });
            },
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '70 days',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              Text(
                '90 days',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection() {
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Select Goals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${_selectedGoals.length}/5',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF50C878),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Choose 3-5 goals to focus on',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Goal templates
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _goalTemplates.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return GestureDetector(
                onTap: () => _toggleGoal(goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF4A90E2)
                        : const Color(0xFF0A0E21),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF4A90E2)
                          : Colors.white24,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.white,
                        ),
                      if (isSelected) const SizedBox(width: 6),
                      Text(
                        goal,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),

          // Custom goal input
          const Text(
            'Or add a custom goal:',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customGoalController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter custom goal...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF0A0E21),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _addCustomGoal(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addCustomGoal,
                icon: const Icon(Icons.add_circle, size: 32),
                color: const Color(0xFF50C878),
              ),
            ],
          ),

          // Display selected goals
          if (_selectedGoals.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Selected Goals:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._selectedGoals.map((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xFF50C878),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        goal,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: Colors.white38,
                      onPressed: () => _toggleGoal(goal),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildArcNameSection() {
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
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Name Your Arc',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Give your arc a title',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _arcNameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Discipline Arc, Warrior Arc...',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF0A0E21),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: const Icon(
                Icons.stars,
                color: Color(0xFF50C878),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _createArc,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF50C878),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Create My Arc',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
