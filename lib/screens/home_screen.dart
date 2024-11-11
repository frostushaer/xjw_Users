import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/booking.dart';
import '../models/user.dart';
import 'add_booking_screen.dart';
import '../widgets/base_screen.dart';
import '../widgets/booking_card.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<Booking> _recentBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecentBookings();
  }

  Future<void> _fetchRecentBookings() async {
    try {
      final bookings = await _apiService.listBookings(widget.user.uid);
      setState(() {
        _recentBookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookings: $e')),
      );
    }
  }

  void _navigateToAddBooking() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBookingScreen(
          user: widget.user, // Pass the user parameter
          onBookingAdded: (booking) {
            setState(() {
              _recentBookings.add(booking);
            });
          },
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20)
                      .copyWith(top: 60),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${widget.user.firstName}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Relax and unwind with our services',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildCarouselSlider(),
                      const SizedBox(height: 16),
                      _buildSpecialOffers(),
                      const SizedBox(height: 16),
                      _buildUpcomingBookings(),
                      const SizedBox(height: 16),
                      _buildRecentBookings(),
                      const SizedBox(height: 16),
                      _buildPopularServices(),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      user: widget.user,
      currentIndex: 0,
      child: _buildHomeScreen(),
    );
  }

  Widget _buildCarouselSlider() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        enlargeCenterPage: true,
      ),
      items: [
        'assets/maxresdefault.jpg',
        'assets/wellness-frau-15.jpg',
      ].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                color: Colors.amber,
                image: DecorationImage(
                  image: AssetImage(i),
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Offers',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildOfferCard('assets/maxresdefault.jpg', '20% Off Spa'),
              _buildOfferCard(
                  'assets/wellness-frau-15.jpg', 'Buy 1 Get 1 Free Massage'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Bookings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        _recentBookings.isNotEmpty
            ? BookingCard(booking: _recentBookings.first)
            : const Text('No upcoming bookings'),
      ],
    );
  }

  Widget _buildRecentBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Bookings',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _recentBookings.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    _recentBookings.length > 3 ? 3 : _recentBookings.length,
                itemBuilder: (context, index) {
                  return BookingCard(booking: _recentBookings[index]);
                },
              )
            : const Text('No recent bookings'),
      ],
    );
  }

  Widget _buildPopularServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildServiceCard(Icons.spa, 'Spa'),
            _buildServiceCard(Icons.fitness_center, 'Massage'),
          ],
        ),
      ],
    );
  }

  Widget _buildOfferCard(String imagePath, String title) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal.shade200,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}
