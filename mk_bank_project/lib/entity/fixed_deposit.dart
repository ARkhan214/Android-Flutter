// lib/model/fixed_deposit.dart

class FixedDepositForView {
  final int id;
  final double depositAmount;
  final int durationInMonths;
  final double interestRate;
  final double maturityAmount;
  final String status;
  final DateTime startDate;
  final DateTime maturityDate;
  final int? accountId; // Angular কোডের ভিত্তিতে ধরে নিলাম

  FixedDepositForView({
    required this.id,
    required this.depositAmount,
    required this.durationInMonths,
    required this.interestRate,
    required this.maturityAmount,
    required this.status,
    required this.startDate,
    required this.maturityDate,
    this.accountId,
  });

  factory FixedDepositForView.fromJson(Map<String, dynamic> json) {
    // API থেকে আসা JSON ডেটা অনুযায়ী ম্যাপ করুন
    return FixedDepositForView(
      id: json['id'] as int,
      depositAmount: (json['depositAmount'] as num).toDouble(),
      durationInMonths: json['durationInMonths'] as int,
      interestRate: (json['interestRate'] as num).toDouble(),
      maturityAmount: (json['maturityAmount'] as num).toDouble(),
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate']),
      maturityDate: DateTime.parse(json['maturityDate']),
      // Nested data: fd.account?.id এর জন্য
      accountId: json['account'] != null && json['account']['id'] != null
          ? json['account']['id'] as int
          : null,
    );
  }
}