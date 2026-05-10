import 'package:flutter/material.dart';
import 'user_data.dart';

class SideNavigation extends StatelessWidget {
  final int selectedIndex;

  const SideNavigation({
    super.key,
    required this.selectedIndex,
  });

  void _goToPage(BuildContext context, String routeName) {
    Navigator.of(context).pop();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        routeName,
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
    UserData.name.isEmpty ? 'Task Manager User' : UserData.name;

    final String displayEmail =
    UserData.email.isEmpty ? 'user@email.com' : UserData.email;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              displayName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(displayEmail),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.deepPurple,
                size: 42,
              ),
            ),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  selected: selectedIndex == 0,
                  selectedTileColor: const Color(0xFFEDE7F6),
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () {
                    if (selectedIndex == 0) {
                      Navigator.of(context).pop();
                    } else {
                      _goToPage(context, '/dashboard');
                    }
                  },
                ),

                ListTile(
                  selected: selectedIndex == 1,
                  selectedTileColor: const Color(0xFFEDE7F6),
                  leading: const Icon(Icons.task_alt),
                  title: const Text('All Tasks'),
                  onTap: () {
                    if (selectedIndex == 1) {
                      Navigator.of(context).pop();
                    } else {
                      _goToPage(context, '/home');
                    }
                  },
                ),

                ListTile(
                  selected: selectedIndex == 2,
                  selectedTileColor: const Color(0xFFEDE7F6),
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  onTap: () {
                    if (selectedIndex == 2) {
                      Navigator.of(context).pop();
                    } else {
                      _goToPage(context, '/profile');
                    }
                  },
                ),

                const Divider(),

                ListTile(
                  selected: selectedIndex == 3,
                  selectedTileColor: const Color(0xFFEDE7F6),
                  leading: const Icon(Icons.category),
                  title: const Text('Categories'),
                  onTap: () {
                    if (selectedIndex == 3) {
                      Navigator.of(context).pop();
                    } else {
                      _goToPage(context, '/categories');
                    }
                  },
                ),

                ListTile(
                  selected: selectedIndex == 4,
                  selectedTileColor: const Color(0xFFEDE7F6),
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    if (selectedIndex == 4) {
                      Navigator.of(context).pop();
                    } else {
                      _goToPage(context, '/settings');
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              _goToPage(context, '/login');
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}