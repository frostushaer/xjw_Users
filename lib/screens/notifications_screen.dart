import 'package:flutter/material.dart';
import '../models/user.dart';
import '../widgets/base_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final User user;

  const NotificationsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      user: user,
      currentIndex: 2, // Set the current index to the notifications tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: const Center(
          child: Text(
            'No new notifications',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
