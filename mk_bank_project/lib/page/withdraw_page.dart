import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      appBar: AppBar(
        // Background: Subtle Gradient for a Premium Feel
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFE3F2FD), // Very light blue
                Color(0xFFF0F4F8), // Very light grey-blue
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Elevation and Shadow for depth
        elevation: 5,
        shadowColor: const Color(0xFF1B4D8D).withOpacity(0.3),
        // Lighter shadow

        // Title: Unique and bold font
        title: Text(
          'Cash Out',
          style: GoogleFonts.merriweather(
            // Unique, professional font
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1B4D8D), // Deep Professional Blue
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,

        // Leading: Custom Back Button
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded, // A prominent, clean back arrow
              color: Color(0xFFFD8E3D), // Orange Accent
              size: 32,
            ),
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

        // Action Icon (Optional, but adds completeness)
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Color(0xFF1B4D8D),
              size: 26,
            ),
            onPressed: () {
              // Handle Help Action
            },
          ),
          const SizedBox(width: 5),
        ],
      ),

      //==========================
      body: Container(
        // Custom Background (Very light green/white gradient)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF), // White
              Color(0xFFE8F5E9), // Very light mint green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center( // Center widget to center the content on large screens
          child: ConstrainedBox( // ConstrainedBox to limit maximum width
            constraints: const BoxConstraints(
              maxWidth: 600, // Maximum width for the form (e.g., tablet/desktop)
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0), // Increased Padding for spacious look
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch fields across width
                    children: [
                      // --- Form Title (Unique Font) ---
                      Text(
                        'Confirm Cashout',
                        style: GoogleFonts.zillaSlab( // Unique Slab Serif Font
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF004D40), // Dark Emerald Green
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Securely cash out your balance.',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      // --- Amount Field ---
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.openSans(color: Colors.black87, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          labelText: "Amount",
                          labelStyle: GoogleFonts.openSans(color: const Color(0xFF004D40)),
                          prefixIcon: const Icon(Icons.money_outlined, color: Color(0xFFFFC107)), // Gold Accent Icon
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFF004D40), width: 2.5), // Focused Emerald Border
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter amount";
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return "Amount must be greater than 0";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 25),

                      // --- Agent Number Field ---
                      TextFormField(
                        controller: _agentNumberController,
                        style: GoogleFonts.openSans(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: "Agent Number",
                          labelStyle: GoogleFonts.openSans(color: const Color(0xFF004D40)),
                          prefixIcon: const Icon(Icons.person_pin_circle_outlined, color: Color(0xFFFFC107)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFF004D40), width: 2.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- Description Field ---
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: GoogleFonts.openSans(color: Colors.black87),
                        decoration: InputDecoration(
                          labelText: "Description (Optional)",
                          labelStyle: GoogleFonts.openSans(color: const Color(0xFF004D40)),
                          prefixIcon: const Icon(Icons.description_outlined, color: Color(0xFFFFC107)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Color(0xFF004D40), width: 2.5),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- Buttons ---
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00796B)), // Emerald loading
                        )
                            : ElevatedButton.icon(
                          onPressed: _submitWithdraw,
                          icon: const Icon(Icons.send_rounded, size: 24),
                          label: Text(
                            "Submit",
                            style: GoogleFonts.openSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00796B), // Darker Emerald Green Button
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 10,
                            shadowColor: const Color(0xFF004D40).withOpacity(0.7),
                          ),
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
      //======
    );
  }
}
