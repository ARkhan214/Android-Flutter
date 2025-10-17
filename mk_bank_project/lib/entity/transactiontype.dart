enum TransactionType {
  // Enum values are usually lowercase in Dart,
  // but for API compatibility, we use exact strings and a helper.
  initialbalance('INITIALBALANCE'),
  deposit('DEPOSIT'),
  withdraw('WITHDRAW'),
  fixedDeposit('FIXED_DEPOSIT'),
  transfer('TRANSFER'),
  receive('RECEIVE');

  // String value to send to the API
  final String apiValue;

  const TransactionType(this.apiValue);

  // স্ট্রিং থেকে Enum পাওয়ার জন্য একটি সহায়ক ফাংশন (ঐচ্ছিক)
  static TransactionType? fromApiValue(String? value) {
    if (value == null) return null;
    try {
      return TransactionType.values.firstWhere(
              (e) => e.apiValue.toUpperCase() == value.toUpperCase());
    } catch (e) {
      return null;
    }
  }
}