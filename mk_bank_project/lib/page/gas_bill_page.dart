import 'package:flutter/material.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../service/bill_payment_service.dart';

class GasBillPage extends StatefulWidget {
  const GasBillPage({super.key});

  @override
  State<GasBillPage> createState() => _GasBillPageState();
}

class _GasBillPageState extends State<GasBillPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _billingIdController = TextEditingController();
  String? _selectedCompany;
  String _token = '';

  final List<String> _companies = [
    'Titas Gas Transmission and Distribution Company Ltd.',
    'Bakhrabad Gas Distribution Company Ltd.',
    'Jalalabad Gas Transmission and Distribution System Ltd.',
    'Karnaphuli Gas Distribution Company Ltd.',
    'Pashchimanchal Gas Company Ltd.',
    'Sundarban Gas Company Ltd.',
    'Petrobangla (Bangladesh Oil, Gas & Mineral Corporation)',
  ];

  final BillPaymentService _billPaymentService = BillPaymentService();
  final primaryColor = const Color(0xff0d6efd);

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

    final savedForm = prefs.getString('gasBillForm');
    if (savedForm != null) {
      final data = jsonDecode(savedForm);
      _amountController.text = data['amount']?.toString() ?? '';
      _billingIdController.text = data['accountHolderBillingId'] ?? '';
      _selectedCompany = data['companyName'];
      setState(() {});
    }

    _amountController.addListener(_saveForm);
    _billingIdController.addListener(_saveForm);
  }

  void _saveForm() async {
    final prefs = await SharedPreferences.getInstance();
    final formData = {
      'amount': double.tryParse(_amountController.text) ?? 0,
      'companyName': _selectedCompany,
      'accountHolderBillingId': _billingIdController.text,
    };
    prefs.setString('gasBillForm', jsonEncode(formData));
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar('Form is invalid! Please fill all required fields.', isError: true);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackbar('Amount must be at least 1.', isError: true);
      return;
    }

    final transaction = Transaction(
      id: 0,
      type: 'GAS',
      amount: amount,
      companyName: _selectedCompany,
      accountHolderBillingId: _billingIdController.text,
      transactionTime: DateTime.now(),
      accountId: 0,
    );

    try {
      final res = await _billPaymentService.payGas(transaction.toJson(), _token);
      _showSnackbar('${res.amount.toStringAsFixed(2)} Taka GAS Bill Payment successful!', isError: false);
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
      _selectedCompany = null;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('gasBillForm');
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
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 500;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌬 Gas Bill Payment'),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 40, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 40, vertical: isSmallScreen ? 30 : 50),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '🌬 Gas Bill Payment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 22 : 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Divider(height: isSmallScreen ? 30 : 40, thickness: 1, color: primaryColor.withOpacity(0.3)),
                      _buildLabel('Gas Supplier Company', primaryColor),
                      _buildDropdown(),
                      SizedBox(height: isSmallScreen ? 15 : 20),
                      _buildLabel('Account / Consumer ID', primaryColor),
                      _buildTextField(
                        controller: _billingIdController,
                        hint: 'Enter consumer ID / billing ID',
                        validator: (value) => value == null || value.isEmpty ? 'Billing ID is required.' : null,
                      ),
                      SizedBox(height: isSmallScreen ? 15 : 20),
                      _buildLabel('Amount', primaryColor),
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
                      SizedBox(height: isSmallScreen ? 30 : 40),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ElevatedButton(
                                onPressed: _token.isNotEmpty ? _onSubmit : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: Text('💳 Pay Bill', style: TextStyle(fontSize: isSmallScreen ? 16 : 18)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: OutlinedButton(
                                onPressed: _resetForm,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  side: const BorderSide(color: Colors.black54),
                                ),
                                child: Text('Reset', style: TextStyle(fontSize: isSmallScreen ? 16 : 18, color: Colors.black54)),
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
      value: _selectedCompany,
      decoration: InputDecoration(
        hintText: '-- Select Gas Supplier --',
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      items: _companies.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCompany = newValue;
          _saveForm();
        });
      },
      validator: (value) => value == null || value.isEmpty ? 'Company name is required.' : null,
    );
  }
}
