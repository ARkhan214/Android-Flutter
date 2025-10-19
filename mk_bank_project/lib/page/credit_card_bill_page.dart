import 'package:flutter/material.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// ⚠️ আপনার আসল ফাইল পাথ অনুযায়ী পরিবর্তন করুন
import '../../service/bill_payment_service.dart';

// import 'package:your_project/pages/invoice_page.dart';

class CreditCardBillPage extends StatefulWidget {
  const CreditCardBillPage({super.key});

  @override
  State<CreditCardBillPage> createState() => _CreditCardBillPageState();
}

class _CreditCardBillPageState extends State<CreditCardBillPage> {
  // Angular Form এর সমতুল্য: GlobalKey
  final _formKey = GlobalKey<FormState>();

  // Angular FormControls এর সমতুল্য: TextEditingController এবং ভ্যালু
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _billingIdController = TextEditingController();
  String? _selectedBank;
  String _token = '';

  // Credit Card Issuer তালিকা
  final List<String> _banks = [
    'City Bank',
    'Eastern Bank Limited (EBL)',
    'BRAC Bank',
    'Dutch-Bangla Bank',
    'Standard Chartered Bank',
    'Prime Bank',
    'Mutual Trust Bank',
    'SouthEast Bank',
    'Islami Bank Bangladesh',
    'One Bank',
    'United Commercial Bank (UCB)'
  ];

  final BillPaymentService _billPaymentService = BillPaymentService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _billingIdController.dispose();
    super.dispose();
  }

  // --- LOCAL STORAGE লজিক ---

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. টোকেন লোড
    setState(() {
      _token = prefs.getString('authToken') ?? '';
    });

    // 2. সেভ করা ফর্ম ডেটা লোড
    final savedForm = prefs.getString('creditCardBillForm');
    if (savedForm != null) {
      final data = jsonDecode(savedForm);
      _amountController.text = data['amount']?.toString() ?? '';
      _billingIdController.text = data['accountHolderBillingId'] ?? '';
      _selectedBank = data['companyName'];
      setState(() {});
    }

    // 3. ভ্যালু চেঞ্জ লজিক (প্রতিবার ফর্ম আপডেট হলে সেভ করা)
    _amountController.addListener(_saveForm);
    _billingIdController.addListener(_saveForm);
  }

  void _saveForm() async {
    final prefs = await SharedPreferences.getInstance();
    final formData = {
      'amount': double.tryParse(_amountController.text) ?? 0,
      'companyName': _selectedBank,
      'accountHolderBillingId': _billingIdController.text,
    };
    prefs.setString('creditCardBillForm', jsonEncode(formData));
  }

  // --- SUBMIT লজিক ---

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Form is invalid! Please fill all required fields.', isError: true);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackbar('Amount must be greater than 0.', isError: true);
      return;
    }

    // Transaction মডেল তৈরি করা হলো
    final transaction = Transaction(
      id: 0, // অথবা আপনার মডেল অনুযায়ী সেট করুন
      type: 'CREDIT_CARD', // Angular-এর type: 'CREDIT_CARD' এর সমতুল্য
      amount: amount,
      companyName: _selectedBank,
      accountHolderBillingId: _billingIdController.text,
      transactionTime: DateTime.now(),
      accountId: 0, // আপনার সোর্স Account ID
    );

    try {
      // API কল: payCreditCard ব্যবহার করা হয়েছে
      final res = await _billPaymentService.payCreditCard(transaction.toJson(), _token);

      _showSnackbar('${res.amount.toStringAsFixed(2)} Taka Credit Card Bill Payment successful!', isError: false);
      _resetForm();

      // router.navigate(['/invoice']) এর সমতুল্য
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const InvoicePage()),
      // );

    } catch (err) {
      _showSnackbar(err.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  // --- ফর্ম রিসেট লজিক ---

  void _resetForm() async {
    _formKey.currentState?.reset();
    _amountController.clear();
    _billingIdController.clear();
    setState(() {
      _selectedBank = null;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('creditCardBillForm');
  }

  // --- ইউটিলিটি ফাংশন ---

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- UI/ভিউ ---

  @override
  Widget build(BuildContext context) {
    // Angular-এর max-width: 720px এবং shadow-lg এর জন্য
    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 Credit Card Payment'),
        backgroundColor: const Color(0xff1e3a8a), // Indigo কালার
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              elevation: 8, // shadow-lg
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      const Text(
                        '💳 Credit Card Payment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1e3a8a),
                        ),
                      ),
                      const Divider(height: 40, thickness: 1, color: Color(0x401e3a8a)),

                      // Bank / Company Name
                      _buildLabel('Bank / Company Name', const Color(0xff1e3a8a)),
                      _buildDropdown(),
                      const SizedBox(height: 20),

                      // Account / Credit Card Number
                      _buildLabel('Account / Credit Card Number', const Color(0xff1e3a8a)),
                      _buildTextField(
                        controller: _billingIdController,
                        hint: 'Enter card number / billing ID',
                        validator: (value) => value == null || value.isEmpty ? 'Credit card number is required.' : null,
                      ),
                      const SizedBox(height: 20),

                      // Amount
                      _buildLabel('Amount', const Color(0xff1e3a8a)),
                      _buildTextField(
                        controller: _amountController,
                        hint: 'Enter amount',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Amount is required.';
                          if (double.tryParse(value) == null || double.parse(value)! < 1) return 'Amount must be at least 1.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Pay Bill Button (Submit)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: _token.isNotEmpty ? _onSubmit : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff1e3a8a), // Primary Color
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('💳 Pay Bill', style: TextStyle(fontSize: 18)),
                              ),
                            ),
                          ),

                          // Reset Button
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: OutlinedButton(
                                onPressed: _resetForm,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  side: const BorderSide(color: Colors.grey),
                                ),
                                child: const Text('Reset', style: TextStyle(fontSize: 18, color: Colors.black54)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Not logged in note
                      if (_token.isEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.yellow.shade100,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.yellow.shade400)
                          ),
                          child: const Text(
                            '⚠️ You are not logged in. Please login to make a payment.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black87, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Label Helper Widget
  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // TextField Helper Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      validator: validator,
      onChanged: (value) { _saveForm(); },
    );
  }

  // Dropdown Helper Widget
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBank,
      decoration: InputDecoration(
        hintText: '-- Select Bank --',
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      items: _banks.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBank = newValue;
          _saveForm();
        });
      },
      validator: (value) => value == null || value.isEmpty ? 'Company name is required.' : null,
    );
  }
}