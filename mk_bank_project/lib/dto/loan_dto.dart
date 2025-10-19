import 'package:mk_bank_project/dto/accountsdto.dart';

class LoanDTO {
  final int id;
  final double loanAmount;
  final double interestRate;
  final double emiAmount;
  final double remainingAmount;
  final double totalAlreadyPaidAmount;
  final String status;
  final String loanType;
  final String loanStartDate; // API থেকে String হিসেবে আসবে
  final String loanMaturityDate; // API থেকে String হিসেবে আসবে
  final AccountsDTO account;

  LoanDTO({
    required this.id,
    required this.loanAmount,
    required this.interestRate,
    required this.emiAmount,
    required this.remainingAmount,
    required this.totalAlreadyPaidAmount,
    required this.status,
    required this.loanType,
    required this.loanStartDate,
    required this.loanMaturityDate,
    required this.account,
  });

  factory LoanDTO.fromJson(Map<String, dynamic> json) {
    return LoanDTO(
      id: json['id'] as int,
      // loanAmount, interestRate, emiAmount ইত্যাদি Double হিসেবে পার্স করা
      loanAmount: (json['loanAmount'] as num).toDouble(),
      interestRate: (json['interestRate'] as num).toDouble(),
      emiAmount: (json['emiAmount'] as num).toDouble(),
      remainingAmount: (json['remainingAmount'] as num).toDouble(),
      totalAlreadyPaidAmount: (json['totalAlreadyPaidAmount'] as num).toDouble(),
      status: json['status'] as String,
      loanType: json['loanType'] as String,
      loanStartDate: json['loanStartDate'] as String,
      loanMaturityDate: json['loanMaturityDate'] as String,
      // AccountsDTO-কেFromJson ব্যবহার করে পার্স করা
      account: AccountsDTO.fromJson(json['account'] as Map<String, dynamic>),
    );
  }
}