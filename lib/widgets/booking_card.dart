import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingCard extends StatefulWidget {
  final Booking booking;
  final VoidCallback? onCancel;

  const BookingCard({super.key, required this.booking, this.onCancel});

  @override
  _BookingCardState createState() => _BookingCardState();
}

class _BookingCardState extends State<BookingCard> {
  bool _isExpanded = false;

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return CupertinoColors.activeOrange; // Pending
      case 1:
        return CupertinoColors.activeGreen; // Completed
      case 2:
        return CupertinoColors.destructiveRed; // Cancelled
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Completed';
      case 2:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(CupertinoIcons.calendar,
                        color: CupertinoColors.activeBlue),
                    const SizedBox(width: 8),
                    Text(
                      widget.booking.service,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Date: ${widget.booking.bookingDate}'),
                Text('Time: ${widget.booking.timeSlot}'),
                Text(
                  'Status: ${_getStatusText(int.parse(widget.booking.status))}',
                  style: TextStyle(
                      color: _getStatusColor(int.parse(widget.booking.status))),
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  const Divider(color: CupertinoColors.systemGrey),
                  Text('Service Provider: ${widget.booking.providerName}'),
                  Text('Location: ${widget.booking.location}'),
                  Text('Notes: ${widget.booking.notes}'),
                  if (widget.booking.status == 0 &&
                      widget.onCancel != null) ...[
                    const SizedBox(height: 8),
                    CupertinoButton(
                      color: CupertinoColors.destructiveRed,
                      onPressed: widget.onCancel,
                      child: const Text('Cancel Booking'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
