import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _submitTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

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
    }finally {
      // ✅ লোডিং শেষ, কাজ সফল হোক বা ব্যর্থ
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // White background makes the content pop
        title: Text(
          'Transfer Money', // A more professional title
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color:  Colors.green, // Deep Blue color
          ),
        ),
        centerTitle: true, // Center the title for a balanced look

        // Leading: The back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0), // Little padding for better spacing
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded, // A softer, modern back icon
              color: Color(0xFFFD8E3D), // Orange accent color for the icon
              size: 28, // Slightly larger size
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

        // Actions: Add a subtle icon (e.g., for help or history) for completeness
        actions: [
          IconButton(
            icon: const Icon(
              Icons.history_toggle_off_rounded,
              color: Color(0xFF1B4D8D), // Deep Blue color
              size: 24,
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
          const SizedBox(width: 10),
        ],
      ),


      // appBar: AppBar(
      //   title: const Text('Transfer Money'),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios),
      //     onPressed: () async {
      //       final profile = await accountService.getAccountsProfile();
      //
      //       if (profile != null) {
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(
      //             builder: (context) => AccountsProfile(profile: profile),
      //           ),
      //         );
      //       }
      //     },
      //   ),
      // ),
      // body: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Form(
      //     key: _formKey,
      //     child: Column(
      //       children: [
      //         TextFormField(
      //           controller: _receiverIdController,
      //           decoration: const InputDecoration(
      //             labelText: 'Receiver Account ID',
      //           ),
      //           keyboardType: TextInputType.number,
      //           validator: (val) =>
      //               val == null || val.isEmpty ? 'Required' : null,
      //         ),
      //         const SizedBox(height: 16),
      //         TextFormField(
      //           controller: _amountController,
      //           decoration: const InputDecoration(labelText: 'Amount'),
      //           keyboardType: TextInputType.number,
      //           validator: (val) =>
      //               val == null || val.isEmpty ? 'Required' : null,
      //         ),
      //         const SizedBox(height: 16),
      //         TextFormField(
      //           controller: _descriptionController,
      //           decoration: const InputDecoration(
      //             labelText: 'Description (Optional)',
      //           ),
      //         ),
      //         const SizedBox(height: 24),
      //         ElevatedButton(
      //           onPressed: _submitTransfer,
      //           child: const Text('Submit Transfer'),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),

      //=======
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // For Scroll
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Form Title (More Elegant) ---
                Text(
                  'Secure Transfer By MK Bank',
                  style: GoogleFonts.pacifico( // Attractive Font
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1B4D8D), // Deep Professional Blue
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter transaction details below.',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // --- Input Field Style Helper Function ---
                // NOTE: In a real project, you would define this style globally or in a separate file.
                // I'm defining it here for a single-file solution.
                // Define the focused and default borders using a "squircle" shape (more rounded than circle)
                // Input Field 1: Receiver Account ID
                TextFormField(
                  controller: _receiverIdController,
                  style: GoogleFonts.montserrat( // Elegant font for input text
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Receiver Account ID',
                    labelStyle: GoogleFonts.montserrat(
                      color: const Color(0xFF1B4D8D), // Blue label
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFD8E3D)), // Orange Accent Icon
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15), // Squircle shape
                      borderSide: BorderSide.none, // Initially no visible border line
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF1B4D8D), width: 2.5), // Focused Blue
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9), // Very light background
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Account ID is mandatory' : null,
                ),
                const SizedBox(height: 25),

                // --- Input Field 2: Amount ---
                TextFormField(
                  controller: _amountController,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount to Transfer',
                    labelStyle: GoogleFonts.montserrat(
                      color: const Color(0xFF1B4D8D),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.currency_exchange, color: Color(0xFFFD8E3D)),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF1B4D8D), width: 2.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.red, width: 1.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) =>
                  val == null || val.isEmpty ? 'Amount is required' : null,
                ),
                const SizedBox(height: 25),

                // --- Input Field 3: Description (Optional) ---
                TextFormField(
                  controller: _descriptionController,
                  style: GoogleFonts.montserrat(
                    color: const Color(0xFF333333),
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    labelStyle: GoogleFonts.montserrat(
                      color: const Color(0xFF1B4D8D),
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: const Icon(Icons.notes_outlined, color: Color(0xFFFD8E3D)),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF1B4D8D), width: 2.5),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9F9F9),
                  ),
                  maxLines: 2, // Allow for multi-line input
                ),
                const SizedBox(height: 40),

                // --- Submit Button (Gradient/Shadow Effect) ---
                // ElevatedButton(
                //   onPressed: _submitTransfer,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: const Color(0xFF1B4D8D), // Solid background for better contrast
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     elevation: 10, // Enhanced shadow
                //     shadowColor: const Color(0xFF1B4D8D).withOpacity(0.5),
                //   ),
                //   child: Text(
                //     'Confirm Transfer',
                //     style: GoogleFonts.poppins(
                //       fontSize: 18,
                //       fontWeight: FontWeight.w600,
                //       letterSpacing: 0.8,
                //     ),
                //   ),
                // ),


                // --- Submit Button (পরিবর্তিত) ---
                ElevatedButton(
                  // ✅ যদি _isLoading হয়, তবে onPressed হবে null (বাটন ডিজেবল)
                  onPressed: _isLoading ? null : _submitTransfer,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4D8D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                    shadowColor: const Color(0xFF1B4D8D).withOpacity(0.5),
                    // লোডিং অবস্থায় বাটনকে হালকা দেখানোর জন্য
                    disabledBackgroundColor: const Color(0xFF1B4D8D).withOpacity(0.6),
                  ),

                  // ✅ Child পরিবর্তন
                  child: _isLoading
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: const CircularProgressIndicator(
                      color: Colors.white, // ইন্ডিকেটরের রং সাদা
                      strokeWidth: 3,
                    ),
                  )
                      : Text(
                    'Confirm Transfer',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
      //=======


    );
  }
}
