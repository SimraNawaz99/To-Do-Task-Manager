import 'package:flutter/material.dart';

class Task {
  String title;
  DateTime dueDate;
  String priority;
  String category;
  bool isCompleted;

  Task({
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _tasks = [];

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _statusFilter = 'All';
  String _priorityFilter = 'All';
  String _categoryFilter = 'All';
  String _sortOption = 'None';

  final List<String> _priorities = ['High', 'Medium', 'Low'];
  final List<String> _categories = ['General', 'Study', 'Work', 'Personal'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  bool _isOverdue(Task task) {
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    final taskDate = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );

    return !task.isCompleted && taskDate.isBefore(currentDate);
  }

  List<Task> _getFilteredTasks() {
    List<Task> filtered = _tasks.where((task) {
      final matchesSearch =
      task.title.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == 'All' ||
          (_statusFilter == 'Completed' && task.isCompleted) ||
          (_statusFilter == 'Pending' && !task.isCompleted);

      final matchesPriority =
          _priorityFilter == 'All' || task.priority == _priorityFilter;

      final matchesCategory =
          _categoryFilter == 'All' || task.category == _categoryFilter;

      return matchesSearch &&
          matchesStatus &&
          matchesPriority &&
          matchesCategory;
    }).toList();

    if (_sortOption == 'Due Date Ascending') {
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_sortOption == 'Due Date Descending') {
      filtered.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    }

    return filtered;
  }

  int get _completedCount =>
      _tasks.where((task) => task.isCompleted).toList().length;

  int get _pendingCount =>
      _tasks.where((task) => !task.isCompleted).toList().length;

  void _showTaskDialog({Task? task, int? index}) async {
    final TextEditingController titleController =
    TextEditingController(text: task?.title ?? '');

    DateTime selectedDate = task?.dueDate ?? DateTime.now();
    String selectedPriority = task?.priority ?? 'Medium';
    String selectedCategory = task?.category ?? 'General';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(task == null ? 'Add Task' : 'Edit Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        prefixIcon: Icon(Icons.task),
                      ),
                    ),

                    const SizedBox(height: 15),

                    InkWell(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          setDialogState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Due Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(_formatDate(selectedDate)),
                      ),
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
                          .map(
                            (priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(
                            priority,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedPriority = value!;
                        });
                      },
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
                          .map(
                            (category) => DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
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
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter task title'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (task == null) {
                        _tasks.add(
                          Task(
                            title: titleController.text.trim(),
                            dueDate: selectedDate,
                            priority: selectedPriority,
                            category: selectedCategory,
                          ),
                        );
                      } else {
                        _tasks[index!] = Task(
                          title: titleController.text.trim(),
                          dueDate: selectedDate,
                          priority: selectedPriority,
                          category: selectedCategory,
                          isCompleted: task.isCompleted,
                        );
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Text(task == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                });
                Navigator.pop(dialogContext);
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
              Text(
                'Task Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 15),

              ListTile(
                leading: Icon(
                  Icons.title,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Title'),
                subtitle: Text(task.title),
              ),

              ListTile(
                leading: Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Due Date'),
                subtitle: Text(_formatDate(task.dueDate)),
              ),

              ListTile(
                leading: Icon(
                  Icons.flag,
                  color: _getPriorityColor(task.priority),
                ),
                title: const Text('Priority'),
                subtitle: Text(
                  task.priority,
                  style: TextStyle(
                    color: _getPriorityColor(task.priority),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: Icon(
                  Icons.category,
                  color: Theme.of(context).primaryColor,
                ),
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
                  subtitle: Text(
                    'This task is past its due date',
                    style: TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _tasks[index].isCompleted =
                          !_tasks[index].isCompleted;
                        });
                        Navigator.pop(bottomSheetContext);
                      },
                      child: Text(
                        task.isCompleted ? 'Mark Pending' : 'Mark Complete',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
          Icon(
            Icons.task_alt,
            size: 70,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 10),
          Text(
            _tasks.isEmpty
                ? 'No tasks added yet'
                : 'No tasks found for selected filters',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _tasks.isEmpty ? 'Tap + to add your first task' : 'Try another filter',
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
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do Task Manager'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                _buildSummaryCard(
                  context,
                  'Total',
                  _tasks.length.toString(),
                  Icons.list_alt,
                ),
                _buildSummaryCard(
                  context,
                  'Completed',
                  _completedCount.toString(),
                  Icons.check_circle,
                ),
                _buildSummaryCard(
                  context,
                  'Pending',
                  _pendingCount.toString(),
                  Icons.pending_actions,
                ),
              ],
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Search and Filter Tasks',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search task by title',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),

            const SizedBox(height: 12),

            Column(
              children: [
                Row(
                  children: [
                    _buildFilterDropdown(
                      value: _statusFilter,
                      label: 'Status',
                      items: ['All', 'Completed', 'Pending'],
                      onChanged: (value) {
                        setState(() {
                          _statusFilter = value!;
                        });
                      },
                    ),

                    const SizedBox(width: 10),

                    _buildFilterDropdown(
                      value: _priorityFilter,
                      label: 'Priority',
                      items: ['All', 'High', 'Medium', 'Low'],
                      onChanged: (value) {
                        setState(() {
                          _priorityFilter = value!;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildFilterDropdown(
                      value: _categoryFilter,
                      label: 'Category',
                      items: ['All', 'General', 'Study', 'Work', 'Personal'],
                      onChanged: (value) {
                        setState(() {
                          _categoryFilter = value!;
                        });
                      },
                    ),

                    const SizedBox(width: 10),

                    _buildFilterDropdown(
                      value: _sortOption,
                      label: 'Sort',
                      items: [
                        'None',
                        'Due Date Ascending',
                        'Due Date Descending',
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortOption = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: filteredTasks.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (context, index) {
                  final task = filteredTasks[index];
                  final originalIndex = _tasks.indexOf(task);

                  return Card(
                    child: ListTile(
                      onTap: () {
                        _showTaskDetails(task, originalIndex);
                      },
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            task.isCompleted = value ?? false;
                          });
                        },
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          Text('Due: ${_formatDate(task.dueDate)}'),

                          Text(
                            'Priority: ${task.priority}',
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text('Category: ${task.category}'),

                          Text(
                            'Status: ${task.isCompleted ? 'Completed' : 'Pending'}',
                          ),

                          if (_isOverdue(task))
                            const Text(
                              'Overdue',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showTaskDialog(
                              task: task,
                              index: originalIndex,
                            );
                          } else if (value == 'delete') {
                            _confirmDeleteTask(originalIndex);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}