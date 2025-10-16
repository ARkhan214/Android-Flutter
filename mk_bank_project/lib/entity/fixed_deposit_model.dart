class FixedDeposit {
  int? id;
  double? depositAmount;
  int? durationInMonths;
  double? interestRate;
  double? prematureInterestRate;
  String? startDate;
  String? maturityDate;
  double? maturityAmount;
  String? prematureWithdrawalDate;
  String? status;
  String? lastUpdatedAt;
  AccountInfo? account;

  FixedDeposit({
    this.id,
    this.depositAmount,
    this.durationInMonths,
    this.interestRate,
    this.prematureInterestRate,
    this.startDate,
    this.maturityDate,
    this.maturityAmount,
    this.prematureWithdrawalDate,
    this.status,
    this.lastUpdatedAt,
    this.account,
  });

  factory FixedDeposit.fromJson(Map<String, dynamic> json) {
    return FixedDeposit(
      id: json['id'],
      depositAmount: (json['depositAmount'] as num?)?.toDouble(),
      durationInMonths: json['durationInMonths'],
      interestRate: (json['interestRate'] as num?)?.toDouble(),
      prematureInterestRate: (json['prematureInterestRate'] as num?)?.toDouble(),
      startDate: json['startDate'],
      maturityDate: json['maturityDate'],
      maturityAmount: (json['maturityAmount'] as num?)?.toDouble(),
      prematureWithdrawalDate: json['prematureWithdrawalDate'],
      status: json['status'],
      lastUpdatedAt: json['lastUpdatedAt'],
      account: json['account'] != null ? AccountInfo.fromJson(json['account']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depositAmount': depositAmount,
      'durationInMonths': durationInMonths,
    };
  }
}

class AccountInfo {
  int id;
  String name;
  String accountType;
  double balance;

  AccountInfo({
    required this.id,
    required this.name,
    required this.accountType,
    required this.balance,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      id: json['id'],
      name: json['name'],
      accountType: json['accountType'],
      balance: (json['balance'] as num).toDouble(),
    );
  }
}
