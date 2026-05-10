import 'package:flutter/material.dart';
import 'main.dart';
import 'side_navigation.dart';
import 'bottom_navigation.dart';
import 'task_data.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();

  final List<String> _defaultCategories = [
    'General',
    'Study',
    'Work',
    'Personal',
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
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

  void _showAddCategoryDialog() {
    _categoryController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: TextField(
            controller: _categoryController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              prefixIcon: Icon(Icons.category),
              hintText: 'Example: Health',
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
                final String categoryName = _categoryController.text.trim();

                if (categoryName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter category name'),
                    ),
                  );
                  return;
                }

                final bool alreadyExists = TaskData.categories.any(
                      (category) =>
                  category.toLowerCase() == categoryName.toLowerCase(),
                );

                if (alreadyExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category already exists'),
                    ),
                  );
                  return;
                }

                setState(() {
                  TaskData.addCategory(categoryName);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$categoryName category added'),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteCategory(String category) {
    if (_isDefaultCategory(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Default categories cannot be deleted'),
        ),
      );
      return;
    }

    final int categoryTaskCount = _getCategoryCount(category);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: Text(
            categoryTaskCount == 0
                ? 'Are you sure you want to delete "$category"?'
                : '"$category" has $categoryTaskCount task(s). If you delete this category, those tasks will be moved to General.',
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
                  for (final task in TaskData.tasks) {
                    if (task.category == category) {
                      task.category = 'General';
                    }
                  }

                  TaskData.categories.remove(category);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$category category deleted'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String category,
  }) {
    final int total = _getCategoryCount(category);
    final int completed = _getCompletedCount(category);
    final Color color = _getCategoryColor(category);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(
            _getCategoryIcon(category),
            color: color,
          ),
        ),
        title: Text(category),
        subtitle: Text('$total tasks • $completed completed'),
        trailing: _isDefaultCategory(category)
            ? const Icon(Icons.arrow_forward_ios)
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
          goToRoute('/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalTasks = TaskData.tasks.length;

    return Scaffold(
      drawer: const SideNavigation(selectedIndex: 3),

      appBar: AppBar(
        title: const Text('Categories'),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'All Categories',
                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 8),

              ...TaskData.categories.map((category) {
                return _buildCategoryCard(
                  context: context,
                  category: category,
                );
              }).toList(),

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