import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'side_navigation.dart';
import 'bottom_navigation.dart';
import 'task_data.dart';
import 'services/api_service.dart';
import 'notifications.dart';
import 'models/notification.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> get _tasks => TaskData.tasks;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  String _categoryFilter = 'All';
  String _sortOption = 'None';

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  List<String> get _categories => TaskData.categories;
  List<String> get _categoryFilterItems => ['All', ...TaskData.categories];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<NotificationData>(context, listen: false).fetchNotifications();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _loadCategories();
    await _loadTasks();
    if (mounted) setState(() {});
  }

  Future<void> _loadTasks() async {
    try {
      final data = await ApiService.getTasks();
      debugPrint('getTasks response: $data');
      if (data['tasks'] != null && data['tasks'] is List) {
        TaskData.tasks = (data['tasks'] as List)
            .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Load tasks error: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ApiService.getCategories();
      if (data['categories'] != null && data['categories'] is List) {
        TaskData.categories = (data['categories'] as List)
            .map((e) => e['name'].toString())
            .toList();
      }
    } catch (e) {
      TaskData.categories = ['General', 'Study', 'Work', 'Personal'];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _toApiDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'High') return Colors.red;
    if (priority == 'Medium') return Colors.orange;
    return Colors.green;
  }

  bool _isOverdue(Task task) {
    final DateTime now = DateTime.now();
    final DateTime currentDate = DateTime(now.year, now.month, now.day);
    final DateTime taskDate =
    DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
    return !task.isCompleted && taskDate.isBefore(currentDate);
  }

  List<Task> _getFilteredTasks() {
    List<Task> filtered = _tasks.where((task) {
      final bool matchesSearch =
      task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final bool matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Completed' && task.isCompleted) ||
          (_statusFilter == 'Pending' && !task.isCompleted);
      final bool matchesPriority =
          _priorityFilter == 'All' || task.priority == _priorityFilter;
      final bool matchesCategory =
          _categoryFilter == 'All' || task.category == _categoryFilter;
      return matchesSearch && matchesStatus && matchesPriority && matchesCategory;
    }).toList();

    if (_sortOption == 'Due Date Ascending') {
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_sortOption == 'Due Date Descending') {
      filtered.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    }
    return filtered;
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;
  int get _pendingCount => _tasks.where((t) => !t.isCompleted).length;

  void _goToProfile() => goToRoute('/profile');
  void _logout() => goToRoute('/login');

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ── Notification time formatter ─────────────────────────────────────────────
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Notifications bottom sheet ──────────────────────────────────────────────
  void _showNotificationsPanel(NotificationData notifications) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return ChangeNotifierProvider.value(
              value: notifications,
              child: Consumer<NotificationData>(
                builder: (_, notif, __) {
                  return Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 4),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Notifications',
                                style: Theme.of(context).textTheme.titleLarge),
                            if (notif.unreadCount > 0)
                              TextButton.icon(
                                onPressed: () async {
                                  await notif.markAllRead();
                                },
                                icon: const Icon(Icons.done_all, size: 16),
                                label: const Text('Mark all read'),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      // Loading indicator
                      if (notif.isLoading)
                        const LinearProgressIndicator(),
                      // List
                      Expanded(
                        child: notif.notifications.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none,
                                  size: 56,
                                  color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'No notifications yet',
                                style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'You\'re all caught up!',
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        )
                            : ListView.separated(
                          controller: scrollController,
                          itemCount: notif.notifications.length,
                          separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                          itemBuilder: (_, index) {
                            final NotificationItem n =
                            notif.notifications[index];
                            return ListTile(
                              tileColor: n.isRead
                                  ? null
                                  : Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.07),
                              leading: CircleAvatar(
                                backgroundColor: n.isRead
                                    ? Colors.grey[200]
                                    : Theme.of(context).primaryColor,
                                child: Icon(
                                  Icons.notifications,
                                  color: n.isRead
                                      ? Colors.grey
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                // Show title if available, else message
                                n.title.isNotEmpty
                                    ? n.title
                                    : n.message,
                                style: TextStyle(
                                  fontWeight: n.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  if (n.title.isNotEmpty &&
                                      n.message.isNotEmpty)
                                    Text(
                                      n.message,
                                      style: const TextStyle(
                                          fontSize: 13),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _timeAgo(n.createdAt),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                              trailing: !n.isRead
                                  ? Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              )
                                  : null,
                              onTap: () async {
                                if (!n.isRead) {
                                  await notif.markOneRead(n.id);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      // Refresh button at bottom
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => notif.fetchNotifications(),
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ── Date picker ─────────────────────────────────────────────────────────────
  Future<DateTime?> _pickDate(DateTime initial) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return null;
    return await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
  }

  // ── Task dialog ──────────────────────────────────────────────────────────────
  void _showTaskDialog({Task? task, int? index}) async {
    DateTime selectedDate = task?.dueDate ?? DateTime.now();
    String selectedPriority = task?.priority ?? 'Medium';
    String selectedCategory = task?.category ?? 'General';

    if (!_categories.contains(selectedCategory)) {
      selectedCategory =
      _categories.isNotEmpty ? _categories.first : 'General';
    }

    final TextEditingController titleController =
    TextEditingController(text: task?.title ?? '');
    final FocusNode titleFocusNode = FocusNode();
    final Task? originalTask = task;
    final ValueNotifier<DateTime> dateNotifier = ValueNotifier(selectedDate);

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog(
              title: Text(originalTask == null ? 'Add Task' : 'Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      focusNode: titleFocusNode,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        prefixIcon: Icon(Icons.task),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder<DateTime>(
                      valueListenable: dateNotifier,
                      builder: (_, date, __) {
                        return InkWell(
                          onTap: () async {
                            final DateTime? picked =
                            await _pickDate(dateNotifier.value);
                            if (picked != null) {
                              dateNotifier.value = picked;
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Due Date',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(_formatDate(date)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: _priorities
                          .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p,
                            overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedPriority = value!),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c,
                            overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (value) =>
                          setDialogState(() => selectedCategory = value!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    titleFocusNode.unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final String titleText = titleController.text.trim();
                    if (titleText.isEmpty) {
                      _showMessage('Please enter task title');
                      return;
                    }

                    final String dueDateStr = _toApiDate(dateNotifier.value);
                    final String snappedPriority = selectedPriority;
                    final String snappedCategory = selectedCategory;

                    titleFocusNode.unfocus();
                    FocusManager.instance.primaryFocus?.unfocus();
                    await Future.delayed(const Duration(milliseconds: 50));

                    if (!mounted) return;
                    Navigator.pop(dialogContext);

                    if (originalTask == null) {
                      try {
                        final data = await ApiService.createTask(
                          title: titleText,
                          priority: snappedPriority,
                          category: snappedCategory,
                          dueDate: dueDateStr,
                        );
                        if (!mounted) return;
                        if (data['task'] != null) {
                          setState(() => TaskData.tasks
                              .add(Task.fromJson(data['task'])));
                        } else {
                          await _loadTasks();
                          if (mounted) setState(() {});
                        }
                      } catch (e) {
                        if (mounted) _showMessage('Failed to add task');
                      }
                    } else {
                      try {
                        final data = await ApiService.updateTask(
                          taskId: originalTask.id,
                          title: titleText,
                          priority: snappedPriority,
                          category: snappedCategory,
                          dueDate: dueDateStr,
                        );
                        if (!mounted) return;
                        if (data['task'] != null) {
                          final i = TaskData.tasks
                              .indexWhere((t) => t.id == originalTask.id);
                          if (i != -1) {
                            setState(() => TaskData.tasks[i] =
                                Task.fromJson(data['task']));
                          }
                        } else {
                          await _loadTasks();
                          if (mounted) setState(() {});
                        }
                      } catch (e) {
                        if (mounted) _showMessage('Failed to update task');
                      }
                    }
                  },
                  child: Text(originalTask == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    titleFocusNode.dispose();
    titleController.dispose();
    dateNotifier.dispose();
  }

  void _confirmDeleteTask(int index) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  final task = TaskData.tasks[index];
                  await ApiService.deleteTask(task.id);
                } catch (e) {
                  debugPrint('Delete error: $e');
                }
                if (mounted) setState(() => TaskData.tasks.removeAt(index));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showTaskDetails(Task task, int index) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            children: [
              Text('Task Details',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 15),
              ListTile(
                leading:
                Icon(Icons.title, color: Theme.of(context).primaryColor),
                title: const Text('Title'),
                subtitle: Text(task.title),
              ),
              ListTile(
                leading: Icon(Icons.calendar_today,
                    color: Theme.of(context).primaryColor),
                title: const Text('Due Date'),
                subtitle: Text(_formatDate(task.dueDate)),
              ),
              ListTile(
                leading:
                Icon(Icons.flag, color: _getPriorityColor(task.priority)),
                title: const Text('Priority'),
                subtitle: Text(task.priority,
                    style: TextStyle(
                        color: _getPriorityColor(task.priority),
                        fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: Icon(Icons.category,
                    color: Theme.of(context).primaryColor),
                title: const Text('Category'),
                subtitle: Text(task.category),
              ),
              ListTile(
                leading: Icon(
                  task.isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.isCompleted ? Colors.green : Colors.grey,
                ),
                title: const Text('Status'),
                subtitle: Text(task.isCompleted ? 'Completed' : 'Pending'),
              ),
              if (_isOverdue(task))
                const ListTile(
                  leading: Icon(Icons.warning, color: Colors.red),
                  title: Text('Overdue'),
                  subtitle: Text('This task is past its due date',
                      style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(bottomSheetContext);
                      try {
                        final data = await ApiService.toggleTask(task.id);
                        if (!mounted) return;
                        if (data['task'] != null) {
                          final i = TaskData.tasks
                              .indexWhere((t) => t.id == task.id);
                          if (i != -1) {
                            setState(() => TaskData.tasks[i] =
                                Task.fromJson(data['task']));
                          }
                        } else {
                          setState(() =>
                          TaskData.tasks[index].isCompleted =
                          !TaskData.tasks[index].isCompleted);
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() =>
                          TaskData.tasks[index].isCompleted =
                          !TaskData.tasks[index].isCompleted);
                        }
                      }
                    },
                    child: Text(
                        task.isCompleted ? 'Mark Pending' : 'Mark Complete'),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _showTaskDialog(task: task, index: index);
                    },
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      _confirmDeleteTask(index);
                    },
                    child: const Text('Delete'),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(icon, size: 24, color: Theme.of(context).primaryColor),
              const SizedBox(height: 5),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt,
              size: 45, color: Theme.of(context).primaryColor),
          const SizedBox(height: 6),
          Text(
            _tasks.isEmpty
                ? 'No tasks added yet'
                : 'No tasks found for selected filters',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _tasks.isEmpty
                ? 'Tap + to add your first task'
                : 'Try another filter',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        items: items
            .map((item) => DropdownMenuItem(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Task> filteredTasks = _getFilteredTasks();

    return Scaffold(
      drawer: const SideNavigation(selectedIndex: 1),
      appBar: AppBar(
        title: const Text('All Tasks'),
        actions: [
          Consumer<NotificationData>(
            builder: (context, notifications, _) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () => _showNotificationsPanel(notifications),
                ),
                if (notifications.unreadCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.red, shape: BoxShape.circle),
                      child: Text(
                        '${notifications.unreadCount}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
              onPressed: _goToProfile, icon: const Icon(Icons.person)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  _buildSummaryCard(context, 'Total',
                      _tasks.length.toString(), Icons.list_alt),
                  _buildSummaryCard(context, 'Completed',
                      _completedCount.toString(), Icons.check_circle),
                  _buildSummaryCard(context, 'Pending',
                      _pendingCount.toString(), Icons.pending_actions),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Search and Filter Tasks',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 48,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search task by title',
                    prefixIcon: Icon(Icons.search),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFilterDropdown(
                    value: _statusFilter,
                    label: 'Status',
                    items: const ['All', 'Completed', 'Pending'],
                    onChanged: (value) =>
                        setState(() => _statusFilter = value!),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterDropdown(
                    value: _priorityFilter,
                    label: 'Priority',
                    items: const ['All', 'High', 'Medium', 'Low'],
                    onChanged: (value) =>
                        setState(() => _priorityFilter = value!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildFilterDropdown(
                    value: _categoryFilter,
                    label: 'Category',
                    items: _categoryFilterItems,
                    onChanged: (value) =>
                        setState(() => _categoryFilter = value!),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterDropdown(
                    value: _sortOption,
                    label: 'Sort',
                    items: const [
                      'None',
                      'Due Date Ascending',
                      'Due Date Descending'
                    ],
                    onChanged: (value) =>
                        setState(() => _sortOption = value!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredTasks.isEmpty
                    ? SingleChildScrollView(
                    child: SizedBox(
                        height: 150,
                        child: _buildEmptyState(context)))
                    : Scrollbar(
                  thumbVisibility: true,
                  thickness: 6,
                  radius: const Radius.circular(10),
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final Task task = filteredTasks[index];
                      final int originalIndex =
                      TaskData.tasks.indexOf(task);
                      return Card(
                        child: ListTile(
                          onTap: () =>
                              _showTaskDetails(task, originalIndex),
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (value) => setState(
                                    () => task.isCompleted = value ?? false),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Due: ${_formatDate(task.dueDate)}'),
                              Text('Priority: ${task.priority}',
                                  style: TextStyle(
                                      color: _getPriorityColor(
                                          task.priority),
                                      fontWeight: FontWeight.bold)),
                              Text('Category: ${task.category}'),
                              Text(
                                  'Status: ${task.isCompleted ? 'Completed' : 'Pending'}'),
                              if (_isOverdue(task))
                                const Text('Overdue',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold)),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showTaskDialog(
                                    task: task, index: originalIndex);
                              } else if (value == 'delete') {
                                _confirmDeleteTask(originalIndex);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                  value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}