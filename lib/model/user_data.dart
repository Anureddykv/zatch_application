class UserData {
  String name;
  String gender;
  String? dobDay;
  String? dobMonth;
  String? dobYear;
  final String email;
  final String phone;

  UserData({
    required this.name,
    required this.gender,
    this.dobDay,
    this.dobMonth,
    this.dobYear,
    required this.email,
    required this.phone,
  });

  // A helper to create a copy of the object
  UserData copyWith({
    String? name,
    String? gender,
    String? dobDay,
    String? dobMonth,
    String? dobYear,
  }) {
    return UserData(
      name: name ?? this.name,
      gender: gender ?? this.gender,
      dobDay: dobDay ?? this.dobDay,
      dobMonth: dobMonth ?? this.dobMonth,
      dobYear: dobYear ?? this.dobYear,
      email: email,
      phone: phone,
    );
  }
}