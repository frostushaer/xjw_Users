class Address {
  final String id; // This should match the ID from your API if applicable
  final String locationType;
  final String address;
  final String suburb;
  final String postcode;
  final String country;
  final String parking;
  final String stairs;
  final String pets;
  final String notes;

  Address({
    required this.id, // Assuming you have an id field
    required this.locationType,
    required this.address,
    required this.suburb,
    required this.postcode,
    required this.country,
    required this.parking,
    required this.stairs,
    required this.pets,
    required this.notes,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] ?? '0', // If there's no id, assign a default
      locationType: json['location_type'] ?? '',
      address: json['address'] ?? '',
      suburb: json['suburb'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country'] ?? '',
      parking: json['parking'] ?? '',
      stairs: json['stairs'] ?? '',
      pets: json['pets'] ?? '',
      notes: json['notes'] ?? '', // Handle null notes gracefully
    );
  }
}
