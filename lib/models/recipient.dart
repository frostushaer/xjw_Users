class Recipient {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String ccode;
  final String phone;
  final String relation;
  final String gender;
  final String nftt;
  final String uid;

  Recipient({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.ccode,
    required this.phone,
    required this.relation,
    required this.gender,
    required this.nftt,
    required this.uid,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      id: json['id'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      email: json['email'],
      ccode: json['ccode'],
      phone: json['phone'],
      relation: json['relation'],
      gender: json['gender'],
      nftt: json['nftt'],
      uid: json['uid'],
    );
  }
}
