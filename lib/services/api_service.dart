import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/booking.dart';
import '../models/address.dart';
import '../models/recipient.dart';

class ApiService {
  final String _baseUrl = 'https://xjwmobilemassage.com.au/app/api.php';

  Future<Map<String, dynamic>> postRequest(Map<String, String> data) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        body: data,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        }, // Specify headers
      );

      // Debug the response status code and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        String responseBody = response.body.trim();

        // Remove any unexpected characters at the end of the response
        responseBody = responseBody.replaceAll(RegExp(r'\s+\[\]$'), '');

        // Check if the response body is valid JSON
        if (_isJson(responseBody)) {
          final decodedResponse = json.decode(responseBody);
          if (decodedResponse is Map<String, dynamic> &&
              decodedResponse.containsKey('error') &&
              decodedResponse['error']) {
            throw Exception(
                decodedResponse['message'] ?? 'Unknown error from server');
          }
          return decodedResponse;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('API responded with status ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Failed to connect to API');
    }
  }

  bool _isJson(String str) {
    try {
      json.decode(str);
    } catch (e) {
      return false;
    }
    return true;
  }

  // User Signup
  Future<Map<String, dynamic>> signup({
    required String firstName,
    required String lastName,
    required String gender,
    required String code,
    required String phone,
    required String email,
    required String password,
  }) async {
    final response = await postRequest({
      'action': 'signup',
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'c_code': code,
      'phone': phone,
      'email': email,
      'pssword': password,
    });
    return response;
  }

  // User Signin
  Future<User> signin({
    required String email,
    required String password,
  }) async {
    final response = await postRequest({
      'action': 'signin',
      'email': email,
      'pssword': password,
    });
    return User.fromJson(response['user']);
  }

  // Refresh User Data
  Future<User> refreshUID(String id) async {
    final response = await postRequest({'action': 'refreshingUID', 'id': id});
    return User.fromJson(response['user']);
  }

  // Forget Password Request
  Future<String> forgetPassword(String email) async {
    final response = await postRequest(
        {'action': 'forget_password_request', 'email': email});
    return response['message'];
  }

  // OTP Verification
  Future<String> verifyOTP(String email, String otp) async {
    final response = await postRequest(
        {'action': 'otp_verification', 'email': email, 'otp': otp});
    return response['message'];
  }

  // Change Password
  Future<String> changePassword(String email, String newPassword) async {
    final response = await postRequest(
        {'action': 'xchange_password', 'email': email, 'pssword': newPassword});
    return response['message'];
  }

  // Update Profile
  Future<String> updateProfile(
      String id, String firstName, String lastName, String phone) async {
    final response = await postRequest({
      'action': 'update_profile',
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
    });
    return response['message'];
  }

  // Upload Profile Image
  Future<String> uploadProfileImage(String id, String imageBase64) async {
    final response = await postRequest(
        {'action': 'update_user_picc', 'id': id, 'image': imageBase64});
    return response['message'];
  }

  // Add Address
  Future<String> addAddress(
      String uid,
      String locationType,
      String address,
      String suburb,
      String postcode,
      String country,
      String parking,
      String stairs,
      String pets,
      String notes) async {
    final response = await postRequest({
      'action': 'add_new_address',
      'uid': uid,
      'location_type': locationType,
      'address': address,
      'suburb': suburb,
      'postcode': postcode,
      'country': country,
      'parking': parking,
      'stairs': stairs,
      'pets': pets,
      'notes': notes,
    });
    return response['message'];
  }

  // List Addresses
  Future<List<Address>> listAddresses(String uid) async {
    final response = await postRequest({
      'action': 'address_list',
      'uid': uid,
    });

    if (response['error'] == false) {
      return (response['data'] as List)
          .map((e) => Address.fromJson(e))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load addresses.');
    }
  }

  // Delete Address
  Future<String> deleteAddress(String id) async {
    final response = await postRequest({'action': 'delete_address', 'id': id});
    if (response['error'] == false) {
      return response['message'];
    } else {
      throw Exception(response['message'] ?? 'Failed to delete address.');
    }
  }

  Future<String> addRecipient(
      String firstname,
      String lastname,
      String email,
      String ccode,
      String phone,
      String relation,
      String gender,
      String nftt,
      String uid) async {
    final response = await postRequest({
      'action': 'add_recipient',
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'ccode': ccode,
      'phone': phone,
      'relation': relation,
      'gender': gender,
      'nftt': nftt,
      'uid': uid,
    });
    return response['message']; // Adjust based on the response structure
  }

  // List Recipients
  Future<List<Recipient>> listRecipients(String uid) async {
    final response = await postRequest({
      'action': 'recipient_list',
      'uid': uid,
    });

    debugPrint('Response from server: $response'); // Log the response

    if (response['error'] == false) {
      return (response['recipients'] as List)
          .map((data) => Recipient.fromJson(data))
          .toList();
    } else {
      throw Exception(response['message']);
    }
  }

  // Delete Recipient
  Future<String> deleteRecipient(String recipientId) async {
    final response =
        await postRequest({'action': 'delete_recipient', 'id': recipientId});
    if (response['error'] == false) {
      return response['message'];
    } else {
      throw Exception(response['message'] ?? 'Failed to delete recipient.');
    }
  }

  Future<String> addBooking({
    required String service,
    required String practitioner,
    required String bdate,
    required String duration,
    required String timeslot,
    required String bookingFor,
    required String recipient,
    required String address,
    required String note,
    required String scharge,
    required String tfee,
    required String total,
    required String status,
    required String paymentStatus,
    required String transactionId,
    required String uid,
    required String practitionerId,
  }) async {
    final requestData = {
      'action': 'add_booking',
      'service': service,
      'practitioner': practitioner,
      'bdate': bdate,
      'duration': duration,
      'timeslot': timeslot,
      'booking_for': bookingFor,
      'recipient': recipient,
      'address': address,
      'note': note,
      'scharge': scharge,
      'tfee': tfee,
      'total': total,
      'status': status,
      'payment_status': paymentStatus,
      'transaction_id': transactionId,
      'uid': uid,
      'practitioner_id': practitionerId,
    };

    // Log the request data for debugging
    print('Request data: $requestData');

    final response = await postRequest(requestData);
    return response['message'];
  }

  // Fetch Services
  Future<List<Map<String, dynamic>>> fetchServices() async {
    final response = await postRequest({'action': 'spinner_list_service'});
    if (response['error'] == false && response.containsKey('services')) {
      return List<Map<String, dynamic>>.from(response['services']);
    } else {
      final errorMessage = response['message'] ?? 'Failed to load services.';
      print('Error fetching services: $errorMessage'); // Debug log
      throw Exception(errorMessage);
    }
  }

  // Fetch Durations
  Future<List<Map<String, dynamic>>> fetchDurations(String serviceName) async {
    final response = await postRequest({
      'action': 'get_duration_list',
      'sid': serviceName,
    });
    if (response['error'] == false) {
      return List<Map<String, dynamic>>.from(response['durations']);
    } else {
      throw Exception(response['message'] ?? 'Failed to load durations.');
    }
  }

  // Fetch Time Slots
  Future<List<Map<String, dynamic>>> fetchTimeSlots({
    String? serviceId,
    String? durationId,
    required String date,
  }) async {
    // Ensure the date is in a correct format if needed (consider using DateFormat)
    final Map<String, String> requestData = {
      'action': 'get_all_time_slots',
      'date': date, // Include the date in the request
    };

    // Optionally add service and duration IDs to the request
    if (serviceId != null) requestData['service_id'] = serviceId;
    if (durationId != null) requestData['duration_id'] = durationId;

    final response = await postRequest(requestData);

    if (response['error'] == false && response.containsKey('time_slots')) {
      return List<Map<String, dynamic>>.from(response['time_slots']);
    } else {
      final errorMessage = response['message'] ?? 'Failed to load time slots.';
      print('Error fetching time slots: $errorMessage'); // Debug log
      throw Exception(errorMessage);
    }
  }

  // Fetch Practitioners by Gender
  Future<List<Map<String, dynamic>>> fetchPractitionersByGender(
      String gender) async {
    final response = await postRequest({
      'action': 'spinner_list_practitioner_by_gender',
      'gender': gender,
    });
    if (response['error'] == false) {
      return List<Map<String, dynamic>>.from(response['practitioners']);
    } else {
      throw Exception(response['message'] ?? 'Failed to load practitioners.');
    }
  }

  // Fetch All Practitioners
  Future<List<Map<String, dynamic>>> fetchPractitioners() async {
    final response = await postRequest({'action': 'spinner_list_practitioner'});
    if (response['error'] == false) {
      return List<Map<String, dynamic>>.from(response['practitioners']);
    } else {
      throw Exception(response['message'] ?? 'Failed to load practitioners.');
    }
  }

  // List Bookings
  Future<List<Booking>> listBookings(String uid) async {
    print('Fetching bookings for uid: $uid'); // Log the uid
    final response =
        await postRequest({'action': 'get_mybooking_list', 'uid': uid});
    if (response['error'] == false) {
      return (response['bookings'] as List)
          .map((e) => Booking.fromJson(e))
          .toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to load bookings.');
    }
  }

  // Update Booking Status
  Future<String> updateBookingStatus(String id, String status) async {
    final response = await postRequest({
      'action': 'update_booking_status_by_user',
      'id': id,
      'status': status,
    });
    return response['message'];
  }

  // Cancel Booking
  Future<String> cancelBooking(String id) async {
    final response = await postRequest(
        {'action': 'update_booking_status_by_user', 'id': id, 'status': '3'});
    return response['message'];
  }
}
