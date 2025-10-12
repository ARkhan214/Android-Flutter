import 'package:flutter/material.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:mk_bank_project/service/authservice.dart';
import 'package:mk_bank_project/service/transaction_service.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({super.key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _agentNumberController = TextEditingController(
    text: "017XXXXXXXX",
  );

  bool _isLoading = false;
  late AuthService authService;
  late AccountService accountService;
  late TransactionService transactionService;
  Map<String, dynamic>? myAccount;

  @override
  void initState() {
    super.initState();
    authService = AuthService();
    accountService = AccountService();
    transactionService = TransactionService(authService: authService);
    _loadMyProfile();
  }

  void _loadMyProfile() async {
    var profile = await accountService.getAccountsProfile();

    setState(() {
      myAccount = profile;
    });
  }

  Future<void> _submitWithdraw() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final transaction = Transaction(
        type: "WITHDRAW",
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        transactionTime: DateTime.now(),
      );

      final transactionService = TransactionService(authService: AuthService());
      final result = await transactionService.makeTransaction(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${result.amount} Taka Withdraw Successful!"),
          backgroundColor: Colors.green,
        ),
      );

      _formKey.currentState!.reset();
      _amountController.clear();
      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Withdraw Failed: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("💸 Cash Out"),
      //   backgroundColor: Colors.teal,
      // ),
      appBar: AppBar(
        title: const Text("💸 Cash Out"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () async {
            final profile = await accountService.getAccountsProfile();

            if (profile != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountsProfile(profile: profile),
                ),
              );
            }
          },
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter amount";
                  }
                  if (double.tryParse(value)! <= 0) {
                    return "Amount must be greater than 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 🔹 Fake Agent Number Field (UI Only)
              // TextFormField(
              //   enabled: true, // backend বা user input নিষ্ক্রিয় রাখবে
              //   initialValue: "017XXXXXXXX", // এখানে যা খুশি demo value দিতে পারো
              //   decoration: const InputDecoration(
              //     labelText: "Agent Number",
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // const SizedBox(height: 20),
              TextFormField(
                controller: _agentNumberController,
                decoration: const InputDecoration(
                  labelText: "Agent Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description (Optional)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _submitWithdraw,
                        icon: const Icon(Icons.send),
                        label: const Text("Submit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
