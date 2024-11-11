import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'edit_profile_screen.dart';
import 'manage_addresses_screen.dart';
import 'manage_recipients_screen.dart';
import 'login_screen.dart';
import '../widgets/base_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User user;
  final Function onLogout; // Callback to refresh data after logout

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      user: user,
      currentIndex: 3, // Set the current index to the profile tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.teal,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(context),
              const SizedBox(height: 30),
              _buildNavigationOptions(context),
              const SizedBox(height: 20),
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: user.profilePicture.isNotEmpty
              ? NetworkImage(user.profilePicture)
              : const AssetImage('assets/placeholder.png') as ImageProvider,
        ),
        const SizedBox(height: 10),
        Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user.email,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(user: user),
              ),
            ).then((_) {
              // Refresh user data after returning from EditProfileScreen
              // Implement your data refresh logic here if needed
            });
          },
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildNavigationOptions(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.location_on, color: Colors.teal),
          title: const Text('Manage Addresses'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ManageAddressesScreen(userId: user.id.toString()),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.person, color: Colors.teal),
          title: const Text('Manage Recipients'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ManageRecipientsScreen(userId: user.id.toString()),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Makes the button full width
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () async {
          // Clear user data from shared preferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('user');

          // Call the logout function passed from parent
          onLogout();

          // Navigate to the login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        },
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
