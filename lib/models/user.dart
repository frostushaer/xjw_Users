class User {
  final int id;
  final String firstName;
  final String lastName;
  final String gender;
  final String email;
  final String code;
  final String phone;
  final String uid;
  final String refCode;
  final String profilePicture;
  final String dateOfJoining;
  final String auth;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.email,
    required this.code,
    required this.phone,
    required this.uid,
    required this.refCode,
    required this.profilePicture,
    required this.dateOfJoining,
    required this.auth,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      gender: json['gender'],
      email: json['email'],
      code: json['c_code'],
      phone: json['phone'],
      uid: json['uid'],
      refCode: json['ref_code'] ?? '',
      profilePicture: json['user_dp'] ?? '',
      dateOfJoining: json['doj'],
      auth: json['auth'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender,
        'email': email,
        'c_code': code,
        'phone': phone,
        'uid': uid,
        'ref_code': refCode,
        'user_dp': profilePicture,
        'doj': dateOfJoining,
        'auth': auth,
      };
}
