import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  void _goToPage(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    String routeName = '/dashboard';

    if (index == 0) {
      routeName = '/dashboard';
    } else if (index == 1) {
      routeName = '/home';
    } else if (index == 2) {
      routeName = '/profile';
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        _goToPage(context, index);
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}