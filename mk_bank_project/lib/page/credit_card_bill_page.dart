import 'package:flutter/material.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../service/bill_payment_service.dart';

class CreditCardBillPage extends StatefulWidget {
  const CreditCardBillPage({super.key});

  @override
  State<CreditCardBillPage> createState() => _CreditCardBillPageState();
}

class _CreditCardBillPageState extends State<CreditCardBillPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _billingIdController = TextEditingController();
  String? _selectedBank;
  String _token = '';

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

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('authToken') ?? '';
    });

    final savedForm = prefs.getString('creditCardBillForm');
    if (savedForm != null) {
      final data = jsonDecode(savedForm);
      _amountController.text = data['amount']?.toString() ?? '';
      _billingIdController.text = data['accountHolderBillingId'] ?? '';
      _selectedBank = data['companyName'];
      setState(() {});
    }

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

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    final transaction = Transaction(
      id: 0,
      type: 'CREDIT_CARD',
      amount: amount,
      companyName: _selectedBank,
      accountHolderBillingId: _billingIdController.text,
      transactionTime: DateTime.now(),
      accountId: 0,
    );

    try {
      final res = await _billPaymentService.payCreditCard(transaction.toJson(), _token);
      _showSnackbar('${res.amount.toStringAsFixed(2)} Taka Credit Card Bill Payment successful!', isError: false);
      _resetForm();
    } catch (err) {
      _showSnackbar(err.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

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

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💳 Credit Card Payment'),
        backgroundColor: const Color(0xff1e3a8a),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth < 720 ? constraints.maxWidth : 720,
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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

                          _buildLabel('Bank / Company Name', const Color(0xff1e3a8a)),
                          _buildDropdown(),
                          const SizedBox(height: 20),

                          _buildLabel('Account / Credit Card Number', const Color(0xff1e3a8a)),
                          _buildTextField(
                            controller: _billingIdController,
                            hint: 'Enter card number / billing ID',
                            validator: (value) => value == null || value.isEmpty ? 'Credit card number is required.' : null,
                          ),
                          const SizedBox(height: 20),

                          _buildLabel('Amount', const Color(0xff1e3a8a)),
                          _buildTextField(
                            controller: _amountController,
                            hint: 'Enter amount',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Amount is required.';
                              if (double.tryParse(value) == null || double.parse(value) < 1) return 'Amount must be at least 1.';
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),

                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: ElevatedButton(
                                    onPressed: _token.isNotEmpty ? _onSubmit : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff1e3a8a),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    ),
                                    child: const Text('💳 Pay Bill', style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ),
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

                          if (_token.isEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.yellow.shade100,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.yellow.shade400),
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
          );
        },
      ),
    );
  }

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
      onChanged: (value) => _saveForm(),
    );
  }

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
          child: Text(value, overflow: TextOverflow.ellipsis),
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
