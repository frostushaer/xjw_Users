import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddAddressScreen extends StatefulWidget {
  final String userId;

  const AddAddressScreen({super.key, required this.userId});

  @override
  _AddAddressScreenState createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String locationType = '';
  String address = '';
  String suburb = '';
  String postcode = '';
  String country = '';
  String parking = '';
  String stairs = '';
  String pets = '';
  String notes = '';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Save the form fields

      try {
        final message = await _apiService.addAddress(
          widget.userId,
          locationType,
          address,
          suburb,
          postcode,
          country,
          parking,
          stairs,
          pets,
          notes,
        );

        // Show a success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        Navigator.of(context).pop(); // Go back after adding
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Address'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Location Type',
                onSaved: (value) => locationType = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location type' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Address',
                onSaved: (value) => address = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Suburb',
                onSaved: (value) => suburb = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a suburb' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Postcode',
                onSaved: (value) => postcode = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a postcode' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Country',
                onSaved: (value) => country = value ?? '',
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a country' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Parking',
                onSaved: (value) => parking = value ?? '',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Stairs',
                onSaved: (value) => stairs = value ?? '',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Pets',
                onSaved: (value) => pets = value ?? '',
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Notes',
                onSaved: (value) => notes = value ?? '',
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.teal,
                ),
                child:
                    const Text('Add Address', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }
}
