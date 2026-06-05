// lib/categories.dart

import 'package:flutter/material.dart';
import 'bottom_navigation.dart';
import 'side_navigation.dart';
import 'services/api_service.dart';
import 'task_data.dart';
import 'models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();

  bool _isLoading = false;
  bool _isAdding = false;

  List<CategoryModel> _categories = [];

  final List<String> _defaultCategories = [
    'General',
    'Study',
    'Work',
    'Personal',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTasksForCounts();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.getCategories();

      if (data['categories'] != null && data['categories'] is List) {
        final loadedCategories = (data['categories'] as List)
            .map((item) => CategoryModel.fromJson(
          Map<String, dynamic>.from(item),
        ))
            .where((category) => category.name.trim().isNotEmpty)
            .toList();

        setState(() {
          _categories = loadedCategories;
          TaskData.setCategories(
            loadedCategories.map((category) => category.name).toList(),
          );
        });
      }
    } catch (e) {
      _showMessage('Unable to load categories.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadTasksForCounts() async {
    try {
      final data = await ApiService.getTasks();

      if (data['tasks'] != null && data['tasks'] is List) {
        final loadedTasks = (data['tasks'] as List)
            .map((item) => Task.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        if (mounted) {
          setState(() {
            TaskData.setTasks(loadedTasks);
          });
        }
      }
    } catch (e) {
      // Counts will simply use currently cached tasks if loading fails.
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int _getCategoryCount(String category) {
    return TaskData.tasks.where((task) => task.category == category).length;
  }

  int _getCompletedCount(String category) {
    return TaskData.tasks.where((task) {
      return task.category == category && task.isCompleted;
    }).length;
  }

  bool _isDefaultCategory(String category) {
    return _defaultCategories.contains(category);
  }

  IconData _getCategoryIcon(String category) {
    if (category == 'Study') {
      return Icons.school;
    } else if (category == 'Work') {
      return Icons.work;
    } else if (category == 'Personal') {
      return Icons.person;
    } else if (category == 'General') {
      return Icons.folder;
    } else {
      return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    if (category == 'Study') {
      return Colors.blue;
    } else if (category == 'Work') {
      return Colors.orange;
    } else if (category == 'Personal') {
      return Colors.green;
    } else if (category == 'General') {
      return Colors.deepPurple;
    } else {
      return Colors.teal;
    }
  }

  Future<void> _showAddCategoryDialog() async {
    _categoryController.clear();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> addCategory() async {
              final categoryName = _categoryController.text.trim();

              if (categoryName.isEmpty) {
                _showMessage('Please enter category name.');
                return;
              }

              final alreadyExists = _categories.any(
                    (category) =>
                category.name.toLowerCase() == categoryName.toLowerCase(),
              );

              if (alreadyExists) {
                _showMessage('Category already exists.');
                return;
              }

              setDialogState(() {
                _isAdding = true;
              });

              try {
                final data = await ApiService.addCategory(categoryName);

                if (!mounted) return;

                if (data['statusCode'] == 201 && data['category'] != null) {
                  final newCategory = CategoryModel.fromJson(
                    Map<String, dynamic>.from(data['category']),
                  );

                  setState(() {
                    _categories.add(newCategory);
                    TaskData.addCategory(newCategory.name);
                  });

                  Navigator.of(dialogContext).pop();

                  _showMessage('${newCategory.name} category added.');
                } else {
                  setDialogState(() {
                    _isAdding = false;
                  });

                  _showMessage(data['message'] ?? 'Failed to add category.');
                }
              } catch (e) {
                setDialogState(() {
                  _isAdding = false;
                });

                _showMessage('Connection error. Please try again.');
              }
            }

            return AlertDialog(
              title: const Text('Add New Category'),
              content: TextField(
                controller: _categoryController,
                enabled: !_isAdding,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  prefixIcon: Icon(Icons.category),
                  hintText: 'Example: Health',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isAdding
                      ? null
                      : () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isAdding ? null : addCategory,
                  child: _isAdding
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    _isAdding = false;
  }

  Future<void> _confirmDeleteCategory(CategoryModel category) async {
    if (_isDefaultCategory(category.name)) {
      _showMessage('Default categories cannot be deleted.');
      return;
    }

    final categoryTaskCount = _getCategoryCount(category.name);

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            categoryTaskCount == 0
                ? 'Are you sure you want to delete "${category.name}"?'
                : '"${category.name}" has $categoryTaskCount task(s). If you delete this category, those tasks will be moved to General.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      final data = await ApiService.deleteCategory(category.id);

      if (!mounted) return;

      if (data['statusCode'] == 200) {
        final affectedTasks = TaskData.tasks.where(
              (task) => task.category == category.name,
        );

        for (final task in affectedTasks) {
          await ApiService.updateTask(
            taskId: task.id,
            title: task.title,
            priority: task.priority,
            category: 'General',
            dueDate: task.formattedDueDate,
            isCompleted: task.isCompleted ? 1 : 0,
          );

          task.category = 'General';
        }

        setState(() {
          _categories.removeWhere((item) => item.id == category.id);
          TaskData.categories.remove(category.name);
        });

        _showMessage('${category.name} category deleted.');
      } else {
        _showMessage(data['message'] ?? 'Failed to delete category.');
      }
    } catch (e) {
      _showMessage('Connection error. Please try again.');
    }
  }

  Widget _buildCategoryCard({
    required CategoryModel category,
  }) {
    final total = _getCategoryCount(category.name);
    final completed = _getCompletedCount(category.name);
    final color = _getCategoryColor(category.name);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            _getCategoryIcon(category.name),
            color: color,
          ),
        ),
        title: Text(category.name),
        subtitle: Text('$total tasks • $completed completed'),
        trailing: _isDefaultCategory(category.name)
            ? const Icon(Icons.lock_outline)
            : IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            _confirmDeleteCategory(category);
          },
        ),
        onTap: () {
          Navigator.pushNamed(context, '/dashboard');
        },
      ),
    );
  }

  Widget _buildHeaderCard(int totalTasks) {
    return Card(
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.category,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task Categories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalTasks total tasks',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await _loadCategories();
                await _loadTasksForCounts();
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalTasks = TaskData.tasks.length;

    return Scaffold(
      drawer: const SideNavigation(selectedIndex: 3),
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(totalTasks),
              const SizedBox(height: 12),
              Text(
                'All Categories',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (_categories.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No categories found.'),
                  ),
                )
              else
                ..._categories.map((category) {
                  return _buildCategoryCard(category: category);
                }),
              const SizedBox(height: 20),
              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text('Add New Category'),
                  subtitle: const Text('Create your own task category'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _showAddCategoryDialog,
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