class AccountsDTO {
  final int? id;
  final String name;
  final String accountType;
  final String phoneNumber;
  final String address;
  final String? accountOpeningDate;

  // --- New fields added for Loan View (all kept nullable) ---
  final bool? accountActiveStatus;
  final double? balance;
  final String? nid;
  final String? photo;
  final String? dateOfBirth;
  final String? accountClosingDate;
  final String? role;
  // -----------------------------------------------------------

  AccountsDTO({
    this.id,
    required this.name,
    required this.accountType,
    required this.phoneNumber,
    required this.address,
    this.accountOpeningDate,

    // New fields are kept optional in the constructor
    this.accountActiveStatus,
    this.balance,
    this.nid,
    this.photo,
    this.dateOfBirth,
    this.accountClosingDate,
    this.role,
  });

  // --- FromJson: Convert JSON data to a Dart object (for API response) ---
  factory AccountsDTO.fromJson(Map<String, dynamic> json) {
    // Old fields with your previous logic/Null-Safety:
    final String nameValue = json['name'] as String? ?? 'N/A';
    final String accountTypeValue = json['accountType'] as String? ?? 'N/A';
    final String phoneNumberValue = json['phoneNumber'] as String? ?? 'N/A';
    final String addressValue = json['address'] as String? ?? 'N/A';

    return AccountsDTO(
      id: json['id'] as int?,
      name: nameValue,
      accountType: accountTypeValue,
      phoneNumber: phoneNumberValue,
      address: addressValue,
      accountOpeningDate: json['accountOpeningDate'] as String?,

      // New fields: will be parsed if present in JSON, otherwise remain null.
      accountActiveStatus: json['accountActiveStatus'] as bool?,
      // num? to double?
      balance: (json['balance'] as num?)?.toDouble(),
      nid: json['nid'] as String?,
      photo: json['photo'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      accountClosingDate: json['accountClosingDate'] as String?,
      role: json['role'] as String?,
    );
  }

  // --- ToJson: Convert Dart object to a JSON Map (for sending data to API) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'accountType': accountType,
      'phoneNumber': phoneNumber,
      'address': address,
      'accountOpeningDate': accountOpeningDate,

      // New fields
      'accountActiveStatus': accountActiveStatus,
      'balance': balance,
      'nid': nid,
      'photo': photo,
      'dateOfBirth': dateOfBirth,
      'accountClosingDate': accountClosingDate,
      'role': role,
    };
  }
}