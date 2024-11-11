import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/bookings_screen.dart';
import '../screens/add_booking_screen.dart';
import '../screens/notifications_screen.dart';

class BaseScreen extends StatefulWidget {
  final User user;
  final Widget child;
  final int currentIndex;

  const BaseScreen({
    super.key,
    required this.user,
    required this.child,
    required this.currentIndex,
  });

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final List<IconData> _iconList = [
    Icons.home,
    Icons.calendar_today,
    Icons.notifications,
    Icons.person,
  ];

  void _onBottomNavTap(int index) {
    if (index == widget.currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(user: widget.user)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BookingScreen(user: widget.user)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NotificationsScreen(user: widget.user)),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(
              user: widget.user,
              onLogout: _handleLogout,
            ),
          ),
        );
        break;
    }
  }

  void _handleLogout() {
    // Handle logout logic here
    print("User logged out");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBookingScreen(
                user: widget.user, // Pass the user parameter
                onBookingAdded: () {
                  // Handle booking added logic here
                },
              ),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: widget.currentIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: _onBottomNavTap,
        activeColor: Colors.teal,
        inactiveColor: Colors.grey,
        iconSize: 28,
      ),
    );
  }
}
