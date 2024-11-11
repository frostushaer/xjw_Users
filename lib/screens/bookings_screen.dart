import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../widgets/base_screen.dart';
import '../widgets/booking_card.dart';

class BookingScreen extends StatefulWidget {
  final User user;

  const BookingScreen({super.key, required this.user});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ApiService _apiService = ApiService();
  List<Booking> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      print(
          'Fetching bookings for user with uid: ${widget.user.uid}'); // Log the uid
      final bookings = await _apiService.listBookings(widget.user.uid);
      setState(() {
        _bookings = bookings;
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

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      user: widget.user,
      currentIndex: 1,
      child: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Bookings'),
        ),
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _bookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      return BookingCard(
                        booking: _bookings[index],
                        onCancel: () async {
                          // Handle booking cancellation
                          await _apiService
                              .cancelBooking(_bookings[index].id.toString());
                          setState(() {
                            _bookings.removeAt(index);
                          });
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
