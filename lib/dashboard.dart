import 'package:flutter/material.dart';
import 'main.dart';
import 'user_data.dart';
import 'side_navigation.dart';
import 'bottom_navigation.dart';
import 'task_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final int hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _formatDate(DateTime date) {
    const List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }

  String _shortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isToday(DateTime date) {
    final DateTime now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isOverdue(Task task) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime taskDate = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );

    return !task.isCompleted && taskDate.isBefore(today);
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'High') {
      return Colors.red;
    } else if (priority == 'Medium') {
      return Colors.orange;
    } else {
      return Colors.green;
    }
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
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      String actionText,
      VoidCallback onPressed,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(actionText),
        ),
      ],
    );
  }

  Widget _buildEmptyDashboardItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFEDE7F6),
              child: Icon(
                icon,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTaskItem({
    required BuildContext context,
    required Task task,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted ? Colors.green : Colors.deepPurple,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration:
            task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          '${_shortDate(task.dueDate)} • ${task.priority} • ${task.category}',
        ),
        trailing: Icon(
          Icons.flag,
          color: _getPriorityColor(task.priority),
        ),
      ),
    );
  }

  Widget _buildCalendarStrip(BuildContext context) {
    final DateTime today = DateTime.now();

    const List<String> days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final DateTime date = today.add(Duration(days: index));
              final bool isToday = index == 0;
              final String dayName = days[date.weekday - 1];

              return Container(
                width: 58,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: isToday ? Colors.deepPurple : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.deepPurple,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        color: isToday ? Colors.white70 : Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        color: isToday ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _goToHome() {
    goToRoute('/home');
  }

  void _goToProfile() {
    goToRoute('/profile');
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
    UserData.name.isEmpty ? 'User' : UserData.name;

    final List<Task> tasks = TaskData.tasks;

    final int totalTasks = tasks.length;
    final int completedTasks = tasks.where((task) => task.isCompleted).length;
    final int pendingTasks = tasks.where((task) => !task.isCompleted).length;
    final int overdueTasks = tasks.where((task) => _isOverdue(task)).length;

    final List<Task> todayTasks = tasks.where((task) {
      return _isToday(task.dueDate);
    }).toList();

    final List<Task> highPriorityTasks = tasks.where((task) {
      return task.priority == 'High' && !task.isCompleted;
    }).toList();

    final List<Task> upcomingTasks = tasks.where((task) {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);

      final DateTime taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );

      return taskDate.isAfter(today) && !task.isCompleted;
    }).toList();

    final double progressValue =
    totalTasks == 0 ? 0 : completedTasks / totalTasks;

    final int progressPercent = (progressValue * 100).round();

    return Scaffold(
      drawer: const SideNavigation(selectedIndex: 0),

      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: _goToProfile,
            icon: const Icon(Icons.person),
          ),
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
                Card(
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: Colors.deepPurple,
                            size: 38,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()},',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                displayName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                _formatDate(DateTime.now()),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildDashboardCard(
                      context: context,
                      title: 'Total Tasks',
                      value: totalTasks.toString(),
                      icon: Icons.list_alt,
                      color: Colors.deepPurple,
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Completed',
                      value: completedTasks.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ],
                ),

                Row(
                  children: [
                    _buildDashboardCard(
                      context: context,
                      title: 'Pending',
                      value: pendingTasks.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    _buildDashboardCard(
                      context: context,
                      title: 'Overdue',
                      value: overdueTasks.toString(),
                      icon: Icons.warning,
                      color: Colors.red,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Progress",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),

                        const SizedBox(height: 12),

                        LinearProgressIndicator(
                          value: progressValue,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(20),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '$progressPercent% completed • $completedTasks of $totalTasks tasks done',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    _buildQuickAction(
                      context: context,
                      title: 'Add Task',
                      icon: Icons.add_task,
                      onTap: _goToHome,
                    ),
                    _buildQuickAction(
                      context: context,
                      title: 'All Tasks',
                      icon: Icons.task_alt,
                      onTap: _goToHome,
                    ),
                    _buildQuickAction(
                      context: context,
                      title: 'Profile',
                      icon: Icons.person,
                      onTap: _goToProfile,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Weekly Calendar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 6),

                _buildCalendarStrip(context),

                const SizedBox(height: 12),

                _buildSectionTitle(
                  context,
                  "Today's Tasks",
                  'View All',
                  _goToHome,
                ),

                if (todayTasks.isEmpty)
                  _buildEmptyDashboardItem(
                    context: context,
                    icon: Icons.today,
                    title: 'No tasks for today',
                    subtitle: 'Go to All Tasks and add your first task.',
                  )
                else
                  Column(
                    children: todayTasks.take(3).map((task) {
                      return _buildDashboardTaskItem(
                        context: context,
                        task: task,
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 8),

                _buildSectionTitle(
                  context,
                  'High Priority',
                  'View All',
                  _goToHome,
                ),

                if (highPriorityTasks.isEmpty)
                  _buildEmptyDashboardItem(
                    context: context,
                    icon: Icons.flag,
                    title: 'No high priority tasks',
                    subtitle: 'Important tasks will appear here.',
                  )
                else
                  Column(
                    children: highPriorityTasks.take(3).map((task) {
                      return _buildDashboardTaskItem(
                        context: context,
                        task: task,
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 8),

                _buildSectionTitle(
                  context,
                  'Upcoming Tasks',
                  'View All',
                  _goToHome,
                ),

                if (upcomingTasks.isEmpty)
                  _buildEmptyDashboardItem(
                    context: context,
                    icon: Icons.calendar_month,
                    title: 'No upcoming tasks',
                    subtitle: 'Upcoming deadlines will appear here.',
                  )
                else
                  Column(
                    children: upcomingTasks.take(3).map((task) {
                      return _buildDashboardTaskItem(
                        context: context,
                        task: task,
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 8),

                Text(
                  'Productivity Tip',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 35,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Start with one small task. Small progress is still progress.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: const AppBottomNavigation(currentIndex: 0),
    );
  }
}