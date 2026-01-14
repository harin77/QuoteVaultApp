import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../core/constants.dart';
import '../core/supabase_client.dart';
import '../core/theme.dart';
import '../notifications/daily_quote_service.dart';
import '../auth/login_screen.dart';

/// Profile screen with user settings
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  
  const ProfileScreen({super.key, this.onThemeChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _darkMode = false;
  String _accentColor = AppConstants.defaultAccentColor;
  double _fontSize = AppConstants.defaultFontSize.toDouble();
  String _notificationTime = AppConstants.defaultNotificationTime;
  bool _notificationEnabled = false;
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = SupabaseService.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email;
      });

      // Load profile from database
      try {
        final response = await SupabaseService.client
            .from(AppConstants.profilesTable)
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          setState(() {
            _userName = response['name'] as String?;
            _userEmail = response['email'] as String? ?? user.email;
          });
        }
      } catch (e) {
        // Ignore errors
      }
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool(AppConstants.darkModeKey) ?? false;
      _accentColor =
          prefs.getString(AppConstants.accentColorKey) ?? AppConstants.defaultAccentColor;
      _fontSize = prefs.getDouble(AppConstants.fontSizeKey) ??
          AppConstants.defaultFontSize.toDouble();
      _notificationTime = prefs.getString(AppConstants.notificationTimeKey) ??
          AppConstants.defaultNotificationTime;
      _notificationEnabled =
          prefs.getBool(AppConstants.notificationEnabledKey) ?? false;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.darkModeKey, value);
    setState(() => _darkMode = value);
    widget.onThemeChanged?.call();
  }

  Future<void> _saveAccentColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accentColorKey, color);
    setState(() => _accentColor = color);
    widget.onThemeChanged?.call();
  }

  Future<void> _saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.fontSizeKey, size);
    setState(() => _fontSize = size);
  }

  Future<void> _saveNotificationTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.notificationTimeKey, time);
    setState(() => _notificationTime = time);

    if (_notificationEnabled) {
      await DailyQuoteService.scheduleDailyNotification(time);
    }
  }

  Future<void> _saveNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.notificationEnabledKey, enabled);
    setState(() => _notificationEnabled = enabled);

    if (enabled) {
      await DailyQuoteService.scheduleDailyNotification(_notificationTime);
    } else {
      await DailyQuoteService.cancelNotifications();
    }
  }

  Future<void> _selectNotificationTime() async {
    final timeParts = _notificationTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (selectedTime != null) {
      final timeString =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      await _saveNotificationTime(timeString);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Profile Card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (_userName?.isNotEmpty == true
                              ? _userName![0].toUpperCase()
                              : _userEmail?.isNotEmpty == true
                                  ? _userEmail![0].toUpperCase()
                                  : 'U')
                          .toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName ?? _userEmail ?? 'User',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_userEmail != null)
                          Text(
                            _userEmail!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section
          Text(
            'Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Dark Mode
          Card(
            child: ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: _darkMode,
                onChanged: _saveDarkMode,
              ),
            ),
          ),

          // Accent Color
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Accent Color'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getAccentColorValue(_accentColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () async {
                final color = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Accent Color'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildColorOption('Purple', AppTheme.primaryPurple),
                        _buildColorOption('Blue', AppTheme.primaryBlue),
                        _buildColorOption('Green', AppTheme.primaryGreen),
                        _buildColorOption('Red', AppTheme.primaryRed),
                        _buildColorOption('Orange', AppTheme.primaryOrange),
                      ],
                    ),
                  ),
                );
                if (color != null) {
                  await _saveAccentColor(color);
                }
              },
            ),
          ),

          // Font Size
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Font Size'),
                  trailing: Text('${_fontSize.toInt()}px'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Slider(
                    value: _fontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    label: '${_fontSize.toInt()}px',
                    onChanged: _saveFontSize,
                  ),
                ),
              ],
            ),
          ),

          // Daily Quote Time
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Daily Quote Time'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_notificationTime),
                  const SizedBox(width: 8),
                  Switch(
                    value: _notificationEnabled,
                    onChanged: _saveNotificationEnabled,
                  ),
                ],
              ),
              onTap: _selectNotificationTime,
            ),
          ),

          const SizedBox(height: 32),

          // Log Out Button
          ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(String name, Color color) {
    return ListTile(
      title: Text(name),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
      onTap: () => Navigator.pop(context, name.toLowerCase()),
    );
  }

  Color _getAccentColorValue(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'purple':
        return AppTheme.primaryPurple;
      case 'blue':
        return AppTheme.primaryBlue;
      case 'green':
        return AppTheme.primaryGreen;
      case 'red':
        return AppTheme.primaryRed;
      case 'orange':
        return AppTheme.primaryOrange;
      default:
        return AppTheme.primaryPurple;
    }
  }
}
