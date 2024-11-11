import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AddBookingScreen extends StatefulWidget {
  final Function onBookingAdded;
  final User user; // Add user parameter

  const AddBookingScreen(
      {super.key, required this.onBookingAdded, required this.user});

  @override
  _AddBookingScreenState createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _bdateController = TextEditingController();
  final TextEditingController _bookingForController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  final ApiService _apiService = ApiService();

  // Lists for dropdown data
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _practitioners = [];
  List<Map<String, dynamic>> _durations = [];
  List<Map<String, dynamic>> _timeSlots = [];

  // Selected values for dropdowns
  String? _selectedService;
  String? _selectedGender;
  String? _selectedPractitioner;
  String? _selectedDuration;
  String? _selectedTimeSlot;
  String? _selectedBookingFor;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  // Load services
  Future<void> _loadServices() async {
    try {
      final services = await _apiService.fetchServices();
      setState(() {
        _services = services;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load services: $e')),
      );
    }
  }

  // Load practitioners based on gender
  Future<void> _loadPractitioners(String gender) async {
    try {
      final practitioners =
          await _apiService.fetchPractitionersByGender(gender);
      setState(() {
        _practitioners = practitioners;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load practitioners: $e')),
      );
    }
  }

  // Load durations based on selected service
  Future<void> _loadDurations(String serviceName) async {
    try {
      final durations = await _apiService.fetchDurations(serviceName);
      setState(() {
        _durations = durations;
        _selectedDuration = null; // Reset selected duration
        _timeSlots.clear(); // Clear time slots when new durations are loaded
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load durations: $e')),
      );
    }
  }

  // Load time slots based on selected date and duration
  Future<void> _loadTimeSlots(String durationId) async {
    final selectedDate = _bdateController.text;

    // Check if the date is empty
    if (selectedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    try {
      final timeSlots = await _apiService.fetchTimeSlots(
        durationId: durationId,
        date: selectedDate, // Pass the selected date here
      );
      setState(() {
        _timeSlots = timeSlots;
        _selectedTimeSlot = null; // Reset selected time slot
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load time slots: $e')),
      );
    }
  }

  // Date picker for booking date
  Future<void> _selectBookingDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _bdateController.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // format as YYYY-MM-DD
        _selectedDuration = null;
        _selectedTimeSlot = null;
        _timeSlots = [];
      });
    }
  }

  // Calculate total
  String _calculateTotal() {
    double scharge = 120.0; // Fixed service charge
    double tfee = 3.48; // Fixed total fee
    return (scharge + tfee).toString();
  }

  // Submit booking form
  Future<void> _submitBooking() async {
    if (_formKey.currentState!.validate()) {
      try {
        final selectedPractitioner = _practitioners.firstWhere((practitioner) =>
            practitioner['id'].toString() == _selectedPractitioner);
        final selectedDuration = _durations.firstWhere(
            (duration) => duration['id'].toString() == _selectedDuration);
        final selectedTimeSlot = _timeSlots
            .firstWhere((slot) => slot['id'].toString() == _selectedTimeSlot);

        final requestData = {
          'service': _selectedService ?? '',
          'practitioner':
              '${selectedPractitioner['firstname']} ${selectedPractitioner['lastname']}',
          'bdate': _bdateController.text,
          'duration': '${selectedDuration['duration']} Min',
          'timeslot':
              '${selectedTimeSlot['time_start']} - ${selectedTimeSlot['time_end']}',
          'booking_for': _selectedBookingFor ?? '',
          'recipient': _recipientController.text,
          'address': _addressController.text,
          'note': 'Notes', // Default value for note
          'scharge': '120', // Fixed service charge
          'tfee': '3.48', // Fixed total fee
          'total': _calculateTotal(), // Calculate total
          'status': '0', // Default status to confirmed
          'payment_status': '0', // Default value for payment status
          'uid': widget.user.id.toString(), // Use actual user ID
          'practitioner_id': _selectedPractitioner ?? '', // Add practitioner ID
          'transaction_id': '0', // Allow transaction ID to be empty
        };

        // Log the request data for debugging
        print('Request data: $requestData');

        final message = await _apiService.addBooking(
          service: requestData['service']!,
          practitioner: requestData['practitioner']!,
          bdate: requestData['bdate']!,
          duration: requestData['duration']!,
          timeslot: requestData['timeslot']!,
          bookingFor: requestData['booking_for']!,
          recipient: requestData['recipient']!,
          address: requestData['address']!,
          note: requestData['note']!,
          scharge: requestData['scharge']!,
          tfee: requestData['tfee']!,
          total: requestData['total']!,
          status: requestData['status']!,
          paymentStatus: requestData['payment_status']!,
          uid: requestData['uid']!,
          practitionerId: requestData['practitioner_id']!,
          transactionId: requestData['transaction_id']!, // Add transaction ID
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        widget.onBookingAdded();
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add booking: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Add Booking'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Service Dropdown
                Material(
                  color: Colors.transparent,
                  child: DropdownButtonFormField<String>(
                    value: _selectedService,
                    hint: const Text('Select Service',
                        style: TextStyle(color: Colors.black)),
                    items: _services.map((service) {
                      return DropdownMenuItem<String>(
                        value: service['service_name'],
                        child: Text(service['service_name'],
                            style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedService = value;
                        _selectedGender = null;
                        _selectedPractitioner = null;
                        _selectedDuration = null;
                        _selectedTimeSlot = null;
                        _practitioners = [];
                        _durations = [];
                        _timeSlots = [];
                      });
                      if (value != null) {
                        _loadDurations(value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a service';
                      }
                      return null;
                    },
                  ),
                ),
                // Practitioner Gender Dropdown
                Visibility(
                  visible: _selectedService != null,
                  child: Material(
                    color: Colors.transparent,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      hint: const Text('Select Practitioner Gender',
                          style: TextStyle(color: Colors.black)),
                      items: ['Male', 'Female'].map((gender) {
                        return DropdownMenuItem<String>(
                          value: gender,
                          child: Text(gender,
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          _selectedPractitioner = null;
                          _practitioners = [];
                        });
                        if (value != null) {
                          _loadPractitioners(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a gender';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Practitioner Dropdown
                Visibility(
                  visible: _selectedGender != null,
                  child: Material(
                    color: Colors.transparent,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPractitioner,
                      hint: const Text('Select Practitioner',
                          style: TextStyle(color: Colors.black)),
                      items: _practitioners.map((practitioner) {
                        return DropdownMenuItem<String>(
                          value: practitioner['id'].toString(),
                          child: Text(
                              '${practitioner['firstname']} ${practitioner['lastname']}',
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPractitioner = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a practitioner';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Booking Date
                Visibility(
                  visible: _selectedPractitioner != null,
                  child: Material(
                    color: Colors.transparent,
                    child: TextFormField(
                      controller: _bdateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Booking Date',
                        labelStyle: const TextStyle(color: Colors.black),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today, color: Colors.black),
                          onPressed: () => _selectBookingDate(context),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a booking date';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Duration Dropdown
                Visibility(
                  visible: _bdateController.text.isNotEmpty,
                  child: Material(
                    color: Colors.transparent,
                    child: DropdownButtonFormField<String>(
                      value: _selectedDuration,
                      hint: const Text('Select Duration',
                          style: TextStyle(color: Colors.black)),
                      items: _durations.map((duration) {
                        return DropdownMenuItem<String>(
                          value: duration['id'].toString(),
                          child: Text('${duration['duration']}',
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDuration = value;
                          _selectedTimeSlot = null;
                          _timeSlots = [];
                        });
                        if (value != null) {
                          _loadTimeSlots(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a duration';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Time Slot Dropdown
                Visibility(
                  visible: _timeSlots.isNotEmpty,
                  child: Material(
                    color: Colors.transparent,
                    child: DropdownButtonFormField<String>(
                      value: _selectedTimeSlot,
                      hint: const Text('Select Time Slot',
                          style: TextStyle(color: Colors.black)),
                      items: _timeSlots.map((slot) {
                        return DropdownMenuItem<String>(
                          value: slot['id'].toString(),
                          child: Text(
                              '${slot['time_start']} - ${slot['time_end']}',
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeSlot = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a time slot';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Booking For Dropdown
                Visibility(
                  visible: _selectedTimeSlot != null,
                  child: Material(
                    color: Colors.transparent,
                    child: DropdownButtonFormField<String>(
                      value: _selectedBookingFor,
                      hint: const Text('Booking For',
                          style: TextStyle(color: Colors.black)),
                      items: ['Myself', 'Recipient'].map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option,
                              style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBookingFor = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select booking for';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Full Name
                Visibility(
                  visible: _selectedTimeSlot != null,
                  child: Material(
                    color: Colors.transparent,
                    child: TextFormField(
                      controller: _recipientController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Mobile
                Visibility(
                  visible: _selectedTimeSlot != null,
                  child: Material(
                    color: Colors.transparent,
                    child: TextFormField(
                      controller:
                          _mobileController, // Corrected mobile controller
                      decoration: const InputDecoration(
                        labelText: 'Mobile',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mobile number';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Full Address
                Visibility(
                  visible: _selectedTimeSlot != null,
                  child: Material(
                    color: Colors.transparent,
                    child: TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full address';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                // Submit Button
                ElevatedButton(
                  onPressed: _submitBooking,
                  child: const Text('Submit Booking'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
