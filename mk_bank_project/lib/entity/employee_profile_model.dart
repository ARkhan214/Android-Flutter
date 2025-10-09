class EmployeeProfileModel {
  final int id;
  final String name;
  final String status;
  final String nid;
  final String phoneNumber;
  final String address;
  final String position;
  final double salary;
  final DateTime dateOfJoining;
  final DateTime dateOfBirth;
  final DateTime retirementDate;
  final int userId;
  final String photo;
  final String role;

  EmployeeProfileModel({
    required this.id,
    required this.name,
    required this.status,
    required this.nid,
    required this.phoneNumber,
    required this.address,
    required this.position,
    required this.salary,
    required this.dateOfJoining,
    required this.dateOfBirth,
    required this.retirementDate,
    required this.userId,
    required this.photo,
    required this.role,
  });

  factory EmployeeProfileModel.fromJson(Map<String, dynamic> json) {
    return EmployeeProfileModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      nid: json['nid'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      position: json['position'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      dateOfJoining: DateTime.parse(json['dateOfJoining']),
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      retirementDate: DateTime.parse(json['retirementDate']),
      userId: json['userId'] ?? 0,
      photo: json['photo'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'nid': nid,
      'phoneNumber': phoneNumber,
      'address': address,
      'position': position,
      'salary': salary,
      'dateOfJoining': dateOfJoining.toIso8601String(),
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'retirementDate': retirementDate.toIso8601String(),
      'userId': userId,
      'photo': photo,
      'role': role,
    };
  }
}
