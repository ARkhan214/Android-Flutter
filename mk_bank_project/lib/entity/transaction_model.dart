class Transaction {
  int? id;
  String type;
  String? companyName;
  String? accountHolderBillingId;
  double amount;
  DateTime transactionTime;
  String? description;
  int? accountId;
  int? receiverAccountId;
  String? token;

  Transaction({
    this.id,
    required this.type,
    this.companyName,
    this.accountHolderBillingId,
    required this.amount,
    required this.transactionTime,
    this.description,
    this.accountId,
    this.receiverAccountId,
    this.token,
  });

  // JSON থেকে object বানানো
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toInt(),
      type: json['type'] ?? '',
      companyName: json['companyName'],
      accountHolderBillingId: json['accountHolderBillingId'],
      amount: (json['amount'] is int) ? (json['amount'] as int).toDouble() : json['amount'] ?? 0.0,
      transactionTime: DateTime.parse(json['transactionTime']),
      description: json['description'],
      accountId: json['account'] != null ? json['account']['id']?.toInt() : null,
      receiverAccountId: json['receiverAccount'] != null ? json['receiverAccount']['id']?.toInt() : null,
      token: json['token'],
    );
  }

  // Object থেকে JSON বানানো
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'companyName': companyName,
      'accountHolderBillingId': accountHolderBillingId,
      'amount': amount,
      'transactionTime': transactionTime.toIso8601String(),
      'description': description,
      'accountId': accountId,
      'receiverAccountId': receiverAccountId,
      'token': token,
    };
  }
}
