import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/settings_controller.dart';
import '../controllers/audio_controller.dart';
import '../controllers/game_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 4,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF5F5DC),
              const Color(0xFFFAEBD7),
              const Color(0xFFF0E68C).withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildSoundSection(),
              const SizedBox(height: 24),
              _buildDisplaySection(),
              const SizedBox(height: 24),
              _buildGameSection(),
              const SizedBox(height: 24),
              _buildAboutSection(),
              const SizedBox(height: 24),
              _buildResetSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundSection() {
    return Consumer<SettingsController>(
      builder: (context, settings, child) {
        return _buildSection(
          title: 'Sound',
          icon: Icons.volume_up,
          children: [
            _buildSwitchTile(
              title: 'Sound Effects',
              subtitle: 'Game move sounds',
              value: settings.soundEnabled,
              onChanged: (value) async {
                await settings.setSoundEnabled(value);
              },
            ),
            _buildSwitchTile(
              title: 'Background Music',
              subtitle: 'Ambient game music',
              value: settings.musicEnabled,
              onChanged: (value) async {
                await settings.setMusicEnabled(value);
              },
            ),
            _buildSliderTile(
              title: 'Volume',
              subtitle: '${(settings.volume * 100).round()}%',
              value: settings.volume,
              onChanged: (value) async {
                await settings.setVolume(value);
              },
            ),
            _buildSwitchTile(
              title: 'Haptic Feedback',
              subtitle: 'Vibration on moves',
              value: settings.hapticFeedbackEnabled,
              onChanged: (value) async {
                await settings.setHapticFeedbackEnabled(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisplaySection() {
    return Consumer<SettingsController>(
      builder: (context, settings, child) {
        return _buildSection(
          title: 'Display',
          icon: Icons.palette,
          children: [
            _buildSwitchTile(
              title: 'Dark Mode',
              subtitle: 'Toggle dark theme',
              value: settings.darkMode,
              onChanged: (value) async {
                await settings.setDarkMode(value);
              },
            ),
            _buildSwitchTile(
              title: 'Animations',
              subtitle: 'UI animations and transitions',
              value: settings.animationsEnabled,
              onChanged: (value) async {
                await settings.setAnimationsEnabled(value);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGameSection() {
    return Consumer<GameController>(
      builder: (context, gameController, child) {
        return _buildSection(
          title: 'Game',
          icon: Icons.sports_esports,
          children: [
            ListTile(
              title: const Text('Clear Game History'),
              subtitle: const Text('Remove all saved games'),
              leading: const Icon(Icons.delete),
              onTap: () {
                _showClearHistoryDialog();
              },
            ),
            ListTile(
              title: const Text('Reset Statistics'),
              subtitle: const Text('Reset all game statistics'),
              leading: const Icon(Icons.refresh),
              onTap: () {
                _showResetStatsDialog();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info,
      children: [
        ListTile(
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
          leading: const Icon(Icons.info_outline),
        ),
        ListTile(
          title: const Text('Developer'),
          subtitle: const Text('Flutter Game Studio'),
          leading: const Icon(Icons.code),
        ),
        ListTile(
          title: const Text('Privacy Policy'),
          subtitle: const Text('View privacy policy'),
          leading: const Icon(Icons.privacy_tip),
          onTap: () {
            _launchUrl('https://tictactoeflutter.com/privacy');
          },
        ),
        ListTile(
          title: const Text('Support'),
          subtitle: const Text('Get help and support'),
          leading: const Icon(Icons.help),
          onTap: () {
            _launchUrl('https://tictactoeflutter.com/support');
          },
        ),
      ],
    );
  }

  Widget _buildResetSection() {
    return Consumer<SettingsController>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () {
              _showResetDialog();
            },
            icon: const Icon(Icons.restore),
            label: const Text('Reset All Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD2B48C),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF8B4513)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFD2B48C)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: children,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B4513),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: const Color(0xFF8B4513).withOpacity(0.7),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF8B4513),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B4513),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF8B4513).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF8B4513),
            inactiveColor: const Color(0xFFD2B48C),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Game History'),
        content: const Text('Are you sure you want to clear all game history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<GameController>().clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Game history cleared'),
                  backgroundColor: Color(0xFF8B4513),
                ),
              );
            },
            child: const Text('Clear'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showResetStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Statistics'),
        content: const Text('Are you sure you want to reset all statistics?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Reset statistics logic would go here
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Statistics reset'),
                  backgroundColor: Color(0xFF8B4513),
                ),
              );
            },
            child: const Text('Reset'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text('This will reset all settings to their default values.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<SettingsController>().resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: Color(0xFF8B4513),
                ),
              );
            },
            child: const Text('Reset'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) {
    // In a real app, you would use url_launcher package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would open: $url'),
        backgroundColor: const Color(0xFF8B4513),
      ),
    );
  }
}