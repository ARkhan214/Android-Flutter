import 'package:flutter/material.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/service/account_service.dart';
import '../service/fixed_deposit_service.dart';

class FixedDepositPage extends StatefulWidget {
  const FixedDepositPage({super.key});

  @override
  State<FixedDepositPage> createState() => _FixedDepositPageState();
}

class _FixedDepositPageState extends State<FixedDepositPage> {
  final _service = FixedDepositService();

  final _amountController = TextEditingController();
  int? _selectedMonths;
  double? _estimatedInterestRate;
  double? _maturityAmount;
  String _message = "";

  late AccountService accountService;
  late AccountsProfile accountsProfile;

  final List<int> monthsList = [12, 24, 36, 48, 60, 72, 84, 96, 108, 120];

  @override
  void initState() {
    super.initState();
    accountService = AccountService();
  }

  void _calculatePreview() {
    double? amount = double.tryParse(_amountController.text);
    int? months = _selectedMonths;

    if (amount == null || months == null) return;

    double rate = 0;
    if (amount >= 100000) {
      if (months >= 60)
        rate = 12;
      else if (months >= 36)
        rate = 11;
      else if (months >= 12)
        rate = 10;
    } else {
      if (months >= 12) rate = 7;
    }

    double maturity = amount + (amount * rate / 100 * months / 12);

    setState(() {
      _estimatedInterestRate = rate;
      _maturityAmount = maturity;
    });
  }

  Future<void> _createFD() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || _selectedMonths == null) {
      setState(() => _message = "⚠️ Please enter valid amount & duration!");
      return;
    }

    if (amount < 50000) {
      setState(() => _message = "⚠️ Minimum deposit is 50,000 Taka.");
      return;
    }

    final fd = await _service.createFD(amount, _selectedMonths!);

    if (fd != null) {
      setState(() {
        _message = "✅ FD Created Successfully! FD ID: ${fd.id}";
      });
    } else {
      setState(() {
        _message = "❌ Failed to create FD. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Fixed Deposit"),
      //   backgroundColor: Colors.green,
      // ),
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text("Fixed Deposit"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: "Deposit Amount",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculatePreview(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: "Duration (Months)",
                border: OutlineInputBorder(),
              ),
              items: monthsList
                  .map(
                    (m) => DropdownMenuItem(value: m, child: Text("$m Months")),
                  )
                  .toList(),
              value: _selectedMonths,
              onChanged: (val) {
                setState(() => _selectedMonths = val);
                _calculatePreview();
              },
            ),
            const SizedBox(height: 16),
            if (_estimatedInterestRate != null && _maturityAmount != null)
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  title: Text("Interest Rate: $_estimatedInterestRate%"),
                  subtitle: Text(
                    "Maturity Amount: ${_maturityAmount!.toStringAsFixed(2)} BDT",
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createFD,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: const Text("Confirm FD", style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            Text(_message, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
