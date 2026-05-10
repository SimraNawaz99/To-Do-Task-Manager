import 'package:flutter/material.dart';
import 'main.dart';
import 'side_navigation.dart';
import 'bottom_navigation.dart';
import 'task_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool dailyReminderEnabled = false;

  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 0);

  void _pickReminderTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );

    if (pickedTime != null) {
      setState(() {
        reminderTime = pickedTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reminder time set to ${pickedTime.format(context)}'),
        ),
      );
    }
  }

  void _showAboutAppDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('About App'),
          content: const Text(
            'To-Do Task Manager\n\n'
                'Version: 1.0\n\n'
                'This app helps users manage daily tasks, organize categories, '
                'track progress, and improve productivity.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text(
            'Need help?\n\n'
                '1. Tap + to add a new task.\n'
                '2. Use filters to search tasks by status, priority, or category.\n'
                '3. Open Categories to create custom task groups.\n'
                '4. Use Dashboard to view progress and task summary.\n\n'
                'For support, contact:\n'
                'support@taskmanager.com',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearAllTasks() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Tasks'),
          content: const Text(
            'Are you sure you want to delete all tasks? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  TaskData.tasks.clear();
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All tasks cleared successfully'),
                  ),
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _resetSettings() {
    setState(() {
      notificationsEnabled = true;
      dailyReminderEnabled = false;
      reminderTime = const TimeOfDay(hour: 9, minute: 0);
      appThemeMode.value = ThemeMode.light;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset successfully'),
      ),
    );
  }

  void _logout() {
    goToRoute('/login');
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 16,
        bottom: 6,
        left: 4,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = appThemeMode.value == ThemeMode.dark;

    return Scaffold(
      drawer: const SideNavigation(selectedIndex: 4),

      appBar: AppBar(
        title: const Text('Settings'),
      ),

      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.settings,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'App Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Customize your task manager',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildSectionTitle('Notifications'),

              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    Icons.notifications,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Notifications'),
                  subtitle: Text(
                    notificationsEnabled
                        ? 'Task notifications are enabled'
                        : 'Task notifications are disabled',
                  ),
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Notifications enabled'
                              : 'Notifications disabled',
                        ),
                      ),
                    );
                  },
                ),
              ),

              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    Icons.alarm,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Daily Reminder'),
                  subtitle: Text(
                    dailyReminderEnabled
                        ? 'Reminder set for ${reminderTime.format(context)}'
                        : 'Daily reminder is disabled',
                  ),
                  value: dailyReminderEnabled,
                  onChanged: (value) {
                    setState(() {
                      dailyReminderEnabled = value;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Daily reminder enabled'
                              : 'Daily reminder disabled',
                        ),
                      ),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.access_time,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Reminder Time'),
                  subtitle: Text(reminderTime.format(context)),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickReminderTime,
                ),
              ),

              _buildSectionTitle('Appearance'),

              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    Icons.dark_mode,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Dark Mode'),
                  subtitle: Text(
                    isDarkMode ? 'Dark mode selected' : 'Light mode selected',
                  ),
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      appThemeMode.value =
                      value ? ThemeMode.dark : ThemeMode.light;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Dark mode enabled' : 'Light mode enabled',
                        ),
                      ),
                    );
                  },
                ),
              ),

              _buildSectionTitle('Task Data'),

              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  title: const Text('Clear All Tasks'),
                  subtitle: const Text(
                    'Delete all saved tasks from this session',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _confirmClearAllTasks,
                ),
              ),

              _buildSectionTitle('Support'),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.info,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('About App'),
                  subtitle: const Text('To-Do Task Manager v1.0'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showAboutAppDialog,
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.help,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Help & Support'),
                  subtitle: const Text('View app guide and support contact'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showHelpSupportDialog,
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.restart_alt,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Reset Settings'),
                  subtitle: const Text('Restore default settings'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _resetSettings,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}