import 'package:flutter/material.dart';
import 'main.dart';
import 'side_navigation.dart';
import 'bottom_navigation.dart';
import 'task_data.dart';

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
    final DateTime now = DateTime.now();
    final DateTime currentDate = DateTime(now.year, now.month, now.day);

    final DateTime taskDate = DateTime(
      task.dueDate.year,
      task.dueDate.month,
      task.dueDate.day,
    );

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

  int get _completedCount {
    return _tasks.where((task) => task.isCompleted).length;
  }

  int get _pendingCount {
    return _tasks.where((task) => !task.isCompleted).length;
  }

  void _goToProfile() {
    goToRoute('/profile');
  }

  void _logout() {
    goToRoute('/login');
  }

  void _showTaskDialog({Task? task, int? index}) async {
    final TextEditingController titleController =
    TextEditingController(text: task?.title ?? '');

    DateTime selectedDate = task?.dueDate ?? DateTime.now();
    String selectedPriority = task?.priority ?? 'Medium';

    String selectedCategory = task?.category ?? 'General';
    if (!_categories.contains(selectedCategory)) {
      selectedCategory = _categories.isNotEmpty ? _categories.first : 'General';
    }

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
                        final DateTime? pickedDate = await showDatePicker(
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
                      items: _priorities.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(
                            priority,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
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
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter task title'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (task == null) {
                        TaskData.tasks.add(
                          Task(
                            title: titleController.text.trim(),
                            dueDate: selectedDate,
                            priority: selectedPriority,
                            category: selectedCategory,
                          ),
                        );
                      } else {
                        TaskData.tasks[index!] = Task(
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
                  TaskData.tasks.removeAt(index);
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
                          TaskData.tasks[index].isCompleted =
                          !TaskData.tasks[index].isCompleted;
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
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall,
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
            size: 45,
            color: Theme.of(context).primaryColor,
          ),
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
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
          IconButton(
            onPressed: _goToProfile,
            icon: const Icon(Icons.person),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
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

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Search and Filter Tasks',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),

              const SizedBox(height: 6),

              SizedBox(
                height: 48,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search task by title',
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  _buildFilterDropdown(
                    value: _statusFilter,
                    label: 'Status',
                    items: const ['All', 'Completed', 'Pending'],
                    onChanged: (value) {
                      setState(() {
                        _statusFilter = value!;
                      });
                    },
                  ),

                  const SizedBox(width: 8),

                  _buildFilterDropdown(
                    value: _priorityFilter,
                    label: 'Priority',
                    items: const ['All', 'High', 'Medium', 'Low'],
                    onChanged: (value) {
                      setState(() {
                        _priorityFilter = value!;
                      });
                    },
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
                    onChanged: (value) {
                      setState(() {
                        _categoryFilter = value!;
                      });
                    },
                  ),

                  const SizedBox(width: 8),

                  _buildFilterDropdown(
                    value: _sortOption,
                    label: 'Sort',
                    items: const [
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

              const SizedBox(height: 8),

              Expanded(
                child: filteredTasks.isEmpty
                    ? SingleChildScrollView(
                  child: SizedBox(
                    height: 150,
                    child: _buildEmptyState(context),
                  ),
                )
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
                            itemBuilder: (context) {
                              return const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ];
                            },
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
        onPressed: () {
          _showTaskDialog();
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const AppBottomNavigation(currentIndex: 1),
    );
  }
}