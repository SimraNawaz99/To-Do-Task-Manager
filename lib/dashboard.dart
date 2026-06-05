// lib/dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'user_data.dart';
import 'side_navigation.dart';
import 'bottom_navigation.dart';
import 'task_data.dart';
import 'notifications.dart'; // Notification service

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isOverdue(Task task) {
    final today = DateTime.now();
    final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return !task.isCompleted && taskDate.isBefore(today);
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'High') return Colors.red;
    if (priority == 'Medium') return Colors.orange;
    return Colors.green;
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 30),
                const SizedBox(height: 8),
                Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarStrip(BuildContext context) {
    final today = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final date = today.add(Duration(days: index));
              final isToday = index == 0;
              final dayName = days[date.weekday - 1];

              return Container(
                width: 58,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isToday ? Colors.deepPurple : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.deepPurple, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(dayName,
                        style: TextStyle(
                            color: isToday ? Colors.white70 : Colors.deepPurple,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(date.day.toString(),
                        style: TextStyle(
                            color: isToday ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _goToHome() => goToRoute('/home');
  void _goToProfile() => goToRoute('/profile');

  @override
  Widget build(BuildContext context) {
    final displayName = UserData.name.isEmpty ? 'User' : UserData.name;
    final tasks = TaskData.tasks;
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final pendingTasks = tasks.where((t) => !t.isCompleted).length;
    final overdueTasks = tasks.where(_isOverdue).length;

    final todayTasks = tasks.where((t) => _isToday(t.dueDate)).toList();
    final highPriorityTasks = tasks.where((t) => t.priority == 'High' && !t.isCompleted).toList();
    final upcomingTasks = tasks.where((t) => t.dueDate.isAfter(DateTime.now()) && !t.isCompleted).toList();

    final progressValue = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
    final progressPercent = (progressValue * 100).round();

    return Scaffold(
      drawer: const SideNavigation(selectedIndex: 0),
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // -------- Notifications Badge --------
          Consumer<NotificationData>(
            builder: (context, notificationData, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      notificationData.markAllRead();
                      // Navigate to NotificationsScreen if implemented
                    },
                  ),
                  if (notificationData.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '${notificationData.unreadCount}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(onPressed: _goToProfile, icon: const Icon(Icons.person)),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting card
                Card(
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: Colors.deepPurple, size: 38),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_getGreeting()},', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                              const SizedBox(height: 3),
                              Text(displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 3),
                              Text(_formatDate(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Dashboard cards row 1
                Row(
                  children: [
                    _buildDashboardCard(
                        context: context,
                        title: 'Total Tasks',
                        value: totalTasks.toString(),
                        icon: Icons.list_alt,
                        color: Colors.deepPurple),
                    _buildDashboardCard(
                        context: context,
                        title: 'Completed',
                        value: completedTasks.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green),
                  ],
                ),
                // Dashboard cards row 2
                Row(
                  children: [
                    _buildDashboardCard(
                        context: context,
                        title: 'Pending',
                        value: pendingTasks.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange),
                    _buildDashboardCard(
                        context: context,
                        title: 'Overdue',
                        value: overdueTasks.toString(),
                        icon: Icons.warning,
                        color: Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                // Today's progress
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's Progress", style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progressValue, minHeight: 10, borderRadius: BorderRadius.circular(20)),
                        const SizedBox(height: 10),
                        Text('$progressPercent% completed • $completedTasks of $totalTasks tasks done',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Quick actions
                Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildQuickAction(context: context, title: 'Add Task', icon: Icons.add_task, onTap: _goToHome),
                    _buildQuickAction(context: context, title: 'All Tasks', icon: Icons.task_alt, onTap: _goToHome),
                    _buildQuickAction(context: context, title: 'Profile', icon: Icons.person, onTap: _goToProfile),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Weekly Calendar', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                _buildCalendarStrip(context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}