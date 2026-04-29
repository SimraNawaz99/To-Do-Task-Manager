import 'package:flutter/material.dart';
import 'user_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String displayName =
    UserData.name.isEmpty ? 'Name not available' : UserData.name;

    final String displayEmail =
    UserData.email.isEmpty ? 'Email not available' : UserData.email;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 55,
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.person,
                size: 65,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              displayName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 5),

            Text(
              displayEmail,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

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

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}