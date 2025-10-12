import 'package:flutter/material.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import '../service/authservice.dart';
import '../service/account_service.dart';
import '../service/transaction_service.dart';

class TransferMoneyPage extends StatefulWidget {
  const TransferMoneyPage({super.key});

  @override
  State<TransferMoneyPage> createState() => _TransferMoneyPageState();
}

class _TransferMoneyPageState extends State<TransferMoneyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _receiverIdController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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

  void _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final transaction = Transaction(
      accountId: myAccount?['id'],
      receiverAccountId: int.parse(_receiverIdController.text),
      amount: double.parse(_amountController.text),
      type: 'TRANSFER',
      description: _descriptionController.text,
      transactionTime: DateTime.now(),
    );

    try {
      await transactionService.transfer(
        transaction,
        transaction.receiverAccountId!,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transfer Successful!')));
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Transfer Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
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
            children: [
              TextFormField(
                controller: _receiverIdController,
                decoration: const InputDecoration(
                  labelText: 'Receiver Account ID',
                ),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTransfer,
                child: const Text('Submit Transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
