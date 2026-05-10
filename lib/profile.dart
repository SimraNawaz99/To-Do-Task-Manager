import 'package:flutter/material.dart';
import 'main.dart';
import 'user_data.dart';
import 'side_navigation.dart';
import 'bottom_navigation.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _goToDashboard() {
    goToRoute('/dashboard');
  }

  void _logout() {
    goToRoute('/login');
  }

  @override
  Widget build(BuildContext context) {
    final String displayName =
    UserData.name.isEmpty ? 'Name not available' : UserData.name;

    final String displayEmail =
    UserData.email.isEmpty ? 'Email not available' : UserData.email;

    return Scaffold(
      drawer: const SideNavigation(selectedIndex: 2),

      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: _goToDashboard,
            icon: const Icon(Icons.dashboard),
          ),
        ],
      ),

      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          thickness: 6,
          radius: const Radius.circular(10),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 10),

              CircleAvatar(
                radius: 45,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  Icons.person,
                  size: 55,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 5),

              Text(
                displayEmail,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Name',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.email,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Email',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    displayEmail,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

              Card(
                child: ListTile(
                  leading: Icon(
                    Icons.task_alt,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Account Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Task Manager User',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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

      bottomNavigationBar: const AppBottomNavigation(currentIndex: 2),
    );
  }
}