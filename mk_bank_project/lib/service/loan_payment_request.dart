class LoanPaymentRequest {
  final int loanId;
  final double amount;

  LoanPaymentRequest({required this.loanId, required this.amount});

  Map<String, dynamic> toJson() => {
    'loanId': loanId,
    'amount': amount,
  };
}