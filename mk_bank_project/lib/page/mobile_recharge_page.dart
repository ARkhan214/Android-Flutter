import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// ⚠️ আপনার আসল ফাইল পাথ অনুযায়ী পরিবর্তন করুন
import '../../service/bill_payment_service.dart';
// import 'package:your_project/pages/invoice_page.dart'; // যদি ইনভয়েস পেজ থাকে
// import 'package:your_project/services/alert_service.dart'; // যদি একটি ডেডিকেটেড AlertService থাকে


class MobileRechargePage extends StatefulWidget {
  const MobileRechargePage({super.key});

  @override
  State<MobileRechargePage> createState() => _MobileRechargePageState();
}

class _MobileRechargePageState extends State<MobileRechargePage> {
  // 1. Angular Form এর সমতুল্য: GlobalKey
  final _formKey = GlobalKey<FormState>();

  // 2. Angular FormControls এর সমতুল্য: TextEditingController এবং ভ্যালু
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _billingIdController = TextEditingController();

  late AccountService accountService;
  String? _selectedOperator;
  String _token = '';

  // Mobile Operator তালিকা
  final List<String> _operators = [
    'Grameenphone', 'Skito', 'Airtle', 'Robi', 'Banglalink', 'Teletalk'
  ];

  // 3. Angular Services এর সমতুল্য: Instances
  final BillPaymentService _billPaymentService = BillPaymentService();
  // final AlertService _alertService = AlertService(); // যদি থাকে

  @override
  void initState() {
    super.initState();
    accountService = AccountService();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _billingIdController.dispose();
    super.dispose();
  }

  // --- LOCAL STORAGE লজিক (Angular ngOnInit-এর সমতুল্য) ---

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. টোকেন লোড
    setState(() {
      _token = prefs.getString('authToken') ?? '';
    });

    // 2. সেভ করা ফর্ম ডেটা লোড
    final savedForm = prefs.getString('mobileBillForm');
    if (savedForm != null) {
      final data = jsonDecode(savedForm);
      _amountController.text = data['amount']?.toString() ?? '';
      _billingIdController.text = data['accountHolderBillingId'] ?? '';
      _selectedOperator = data['companyName'];
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
      'companyName': _selectedOperator,
      'accountHolderBillingId': _billingIdController.text,
    };
    prefs.setString('mobileBillForm', jsonEncode(formData));
  }

  // --- SUBMIT লজিক (Angular onSubmit-এর সমতুল্য) ---

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

    // Angular Transaction মডেল তৈরি করা হলো
    final transaction = Transaction(
      // Note: Transaction মডেল অনুযায়ী এখানে প্রয়োজনীয় রিকোয়্যারড ফিল্ড দিতে হবে।
      // যেমন: type, amount, transactionTime
      id: 0, // অথবা আপনার মডেল অনুযায়ী সেট করুন
      type: 'MOBILE',
      amount: amount,
      companyName: _selectedOperator,
      accountHolderBillingId: _billingIdController.text,
      transactionTime: DateTime.now(), // সার্ভারে পাঠানোর সময় ISO format এ যাবে
      accountId: 0, // অথবা আপনার সোর্স Account ID দিন
    );

    try {
      // API কল
      final res = await _billPaymentService.payMobile(transaction.toJson(), _token);

      _showSnackbar('${res.amount.toStringAsFixed(2)} Taka Mobile Recharge successful!', isError: false);
      _resetForm();

      // Angular-এর router.navigate(['/invoice']) এর সমতুল্য
      // Navigator.of(context).pushReplacement(
      //   MaterialPageRoute(builder: (context) => const InvoicePage()),
      // );

    } catch (err) {
      _showSnackbar(err.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  // --- ফর্ম রিসেট লজিক (Angular resetForm-এর সমতুল্য) ---

  void _resetForm() async {
    _formKey.currentState?.reset();
    _amountController.clear();
    _billingIdController.clear();
    setState(() {
      _selectedOperator = null;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('mobileBillForm'); // localStorage.removeItem('mobileBillForm') এর সমতুল্য
  }

  // --- ইউটিলিটি ফাংশন ---

  void _showSnackbar(String message, {required bool isError}) {
    // Angular AlertService এর success/error/warning এর সমতুল্য
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- UI/ভিউ (Angular HTML টেমপ্লেটের সমতুল্য) ---

  @override
  Widget build(BuildContext context) {
    // Angular-এর max-width: 720px এবং shadow-lg এর জন্য
    return Scaffold(

      // appBar: AppBar(
      //   title: const Text('📱 Mobile Recharge'),
      //   backgroundColor: const Color(0xffd63384),
      // ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        // Title
        title: Text(
          'Mobile Recharge',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xffd63384), // Deep Pink
          ),
        ),
        centerTitle: true,

        // Leading: The back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0), // Little padding
          child: IconButton(
             icon:  const Icon(Icons.arrow_back_rounded, // A softer, modern back icon
              color: Color(0xFFFD8E3D),
             size: 28,
             ), // Orange accent color

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
              elevation: 8, // shadow-lg এর সমতুল্য
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
                        '📱 Mobile Recharge',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffd63384),
                        ),
                      ),
                      const Divider(height: 40, thickness: 1, color: Color(0x40d63384)),

                      // Mobile Operator
                      _buildLabel('Mobile Operator'),
                      _buildDropdown(),
                      const SizedBox(height: 20),

                      // Account / Billing ID (Mobile Number)
                      _buildLabel('Account / Billing ID (Mobile Number)'),
                      _buildTextField(
                        controller: _billingIdController,
                        hint: 'Enter mobile number / billing ID',
                        validator: (value) => value == null || value.isEmpty ? 'Billing ID is required.' : null,
                      ),
                      const SizedBox(height: 20),

                      // Amount
                      _buildLabel('Amount'),
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
                          // Recharge Button (Submit)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: _token.isNotEmpty ? _onSubmit : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                child: const Text('Recharge', style: TextStyle(fontSize: 18)),
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
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xffd63384),
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
      onChanged: (value) {
        // Dropdown ছাড়া অন্য কোনো ভ্যালু চেঞ্জ হলে লোকাল স্টোরেজে সেভ হবে
        _saveForm();
      },
    );
  }

  // Dropdown Helper Widget
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedOperator,
      decoration: InputDecoration(
        hintText: '-- Select Mobile Operator --',
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
      items: _operators.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedOperator = newValue;
          _saveForm(); // ড্রপডাউন ভ্যালু চেঞ্জ হলে সেভ হবে
        });
      },
      validator: (value) => value == null || value.isEmpty ? 'Company name is required.' : null,
    );
  }
}