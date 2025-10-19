import 'package:flutter/material.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ⚠️ আপনার আসল ফাইল পাথ অনুযায়ী পরিবর্তন করুন
import '../../service/bill_payment_service.dart';


class WaterBillPage extends StatefulWidget {
  const WaterBillPage({super.key});

  @override
  State<WaterBillPage> createState() => _WaterBillPageState();
}

class _WaterBillPageState extends State<WaterBillPage> {
  // GlobalKey
  final _formKey = GlobalKey<FormState>();

  // TextEditingController এবং ভ্যালু
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _billingIdController = TextEditingController();

  late AccountService accountService;
  String? _selectedCompany;
  String _token = '';

  // Water Supply Company তালিকা
  final List<Map<String, String>> _companies = [
    {'value': 'dhaka_wasa', 'label': 'Dhaka WASA'},
    {'value': 'chattogram_wasa', 'label': 'Chattogram WASA'},
    {'value': 'khulna_wasa', 'label': 'Khulna WASA'},
    {'value': 'rajshahi_wasa', 'label': 'Rajshahi WASA'},
    {'value': 'barishal_wasa', 'label': 'Barishal WASA'},
    {'value': 'sylhet_wasa', 'label': 'Sylhet WASA'},
  ];

  final BillPaymentService _billPaymentService = BillPaymentService();
  final primaryColor = const Color(0xff0dcaf0); // Bootstrap Info Blue

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    accountService = AccountService();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _billingIdController.dispose();
    super.dispose();
  }

  // --- LOCAL STORAGE & INIT লজিক ---

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. টোকেন লোড
    setState(() {
      _token = prefs.getString('authToken') ?? '';
    });

    // 2. সেভ করা ফর্ম ডেটা লোড
    final savedForm = prefs.getString('waterBillForm');
    if (savedForm != null) {
      final data = jsonDecode(savedForm);
      _amountController.text = data['amount']?.toString() ?? '';
      _billingIdController.text = data['accountHolderBillingId'] ?? '';
      _selectedCompany = data['companyName'];
      setState(() {});
    }

    // 3. ভ্যালু চেঞ্জ লজিক সেটআপ
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
    prefs.setString('waterBillForm', jsonEncode(formData));
  }

  // --- SUBMIT লজিক ---

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

    // Transaction মডেল তৈরি করা হলো
    final transaction = Transaction(
      id: 0,
      type: 'WATER', // Angular-এর type: 'WATER' এর সমতুল্য
      amount: amount,
      companyName: _selectedCompany,
      accountHolderBillingId: _billingIdController.text,
      transactionTime: DateTime.now(),
      accountId: 0, // আপনার সোর্স Account ID
    );

    try {
      // API কল: payWater ব্যবহার করা হয়েছে
      final res = await _billPaymentService.payWater(transaction.toJson(), _token);

      _showSnackbar('${res.amount.toStringAsFixed(2)} Taka Payment successful!', isError: false);
      _resetForm();

      // router.navigate(['/invoice']) এর সমতুল্য
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const AccountsProfile()),
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
      _selectedCompany = null;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('waterBillForm');
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
        title: const Text('💧 Water Bill Payment'),
        backgroundColor: primaryColor,

        centerTitle: true,

        leading: Padding(padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon:  const Icon(Icons.arrow_back_rounded, // A softer, modern back icon
                color: Color(0xFFFD8E3D)), // Orange accent color

            onPressed: () async{
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
                      Text(
                        '💧 Water Bill Payment',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Divider(height: 40, thickness: 1, color: primaryColor.withOpacity(0.3)),

                      // Water Supply Company
                      _buildLabel('Select Water Supply Company', primaryColor),
                      _buildDropdown(primaryColor),
                      const SizedBox(height: 20),

                      // Account / Consumer ID
                      _buildLabel('Account Holder / Billing ID', primaryColor),
                      _buildTextField(
                        controller: _billingIdController,
                        hint: 'Enter billing ID / consumer number',
                        validator: (value) => value == null || value.isEmpty ? 'Billing ID is required.' : null,
                      ),
                      const SizedBox(height: 20),

                      // Amount
                      _buildLabel('Amount', primaryColor),
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
                                  backgroundColor: primaryColor, // Info Blue
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  elevation: 4,
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
                                  side: const BorderSide(color: Colors.black54),
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
                              color: Colors.yellow.shade100, // Angular alert-warning এর কাছাকাছি
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
  Widget _buildDropdown(Color primaryColor) {
    return DropdownButtonFormField<String>(
      value: _selectedCompany,
      decoration: InputDecoration(
        hintText: '-- Select Company --',
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      items: _companies.map((Map<String, String> item) {
        return DropdownMenuItem<String>(
          value: item['value'],
          child: Text(item['label']!),
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