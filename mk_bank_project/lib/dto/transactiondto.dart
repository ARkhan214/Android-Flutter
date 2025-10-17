

import 'package:mk_bank_project/dto/accountsdto.dart';

class TransactionDTO {
  final int? id;
  final AccountsDTO account; // পূর্ণ Account object
  final AccountsDTO? receiverAccount; // পূর্ণ Receiver Account object (nullable)
  final String? type; // DEBIT or CREDIT
  final String? transactionType; // e.g., TRANSFER, BILL_PAYMENT
  final double? amount;
  final String? transactionTime;
  final String? description;
  final String? companyName;
  final String? accountHolderBillingId;

  // Statement Page এর জন্য অতিরিক্ত ফিল্ড
  final double? runningBalance;

  TransactionDTO({
    this.id,
    required this.account,
    this.receiverAccount,
    this.type,
    this.transactionType,
    this.amount,
    this.transactionTime,
    this.description,
    this.companyName,
    this.accountHolderBillingId,
    this.runningBalance, // runningBalance এখানে রাখুন
  });

  // API রেসপন্স থেকে অবজেক্ট তৈরি করা
  factory TransactionDTO.fromJson(Map<String, dynamic> json) {
    return TransactionDTO(
      id: json['id']?.toInt(),
      // গুরুত্বপূর্ণ: nested JSON কে AccountsDTO তে কনভার্ট করা
      account: AccountsDTO.fromJson(json['account']),
      receiverAccount: json['receiverAccount'] != null
          ? AccountsDTO.fromJson(json['receiverAccount'])
          : null,
      type: json['type'],
      transactionType: json['transactionType'],
      amount: (json['amount'] is int) ? (json['amount'] as int).toDouble() : json['amount']?.toDouble(),
      transactionTime: json['transactionTime'],
      description: json['description'],
      companyName: json['companyName'],
      accountHolderBillingId: json['accountHolderBillingId'],
      // runningBalance API থেকে আসে না, তাই এখানে null থাকবে
      runningBalance: null,
    );
  }

  // runningBalance আপডেট করার জন্য copyWith মেথড (StatementPage এ ব্যবহৃত)
  TransactionDTO copyWith({
    double? runningBalance,
  }) {
    return TransactionDTO(
      id: id,
      account: account,
      receiverAccount: receiverAccount,
      type: type,
      transactionType: transactionType,
      amount: amount,
      transactionTime: transactionTime,
      description: description,
      companyName: companyName,
      accountHolderBillingId: accountHolderBillingId,
      runningBalance: runningBalance ?? this.runningBalance,
    );
  }
}