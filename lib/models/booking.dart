class Booking {
  final int id;
  final String service;
  final String practitioner;
  final String bookingDate;
  final String duration;
  final String timeSlot;
  final String bookingFor;
  final String recipient;
  final String address;
  final String note;
  final String serviceCharge;
  final String totalFee;
  final String total;
  final String status;
  final String paymentStatus;
  final String transactionId;
  final String invoiceId;
  final String createdAt;
  final String providerName;
  final String location;
  final String notes; // Add this line

  Booking({
    required this.id,
    required this.service,
    required this.practitioner,
    required this.bookingDate,
    required this.duration,
    required this.timeSlot,
    required this.bookingFor,
    required this.recipient,
    required this.address,
    required this.note,
    required this.serviceCharge,
    required this.totalFee,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.transactionId,
    required this.invoiceId,
    required this.createdAt,
    required this.providerName,
    required this.location,
    required this.notes, // Add this line
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      service: json['service'] ?? '',
      practitioner: json['practitioner'] ?? '',
      bookingDate: json['bdate'] ?? '',
      duration: json['duration'] ?? '',
      timeSlot: json['timeslot'] ?? '',
      bookingFor: json['booking_for'] ?? '',
      recipient: json['recipient'] ?? '',
      address: json['address'] ?? '',
      note: json['note'] ?? '',
      serviceCharge: json['scharge'] ?? '',
      totalFee: json['tfee'] ?? '',
      total: json['total'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      transactionId: json['transaction_id'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      createdAt: json['cur_time'] ?? '',
      providerName: json['provider_name'] ?? '',
      location: json['location'] ?? '',
      notes: json['notes'] ?? '', // Add this line
    );
  }
}
