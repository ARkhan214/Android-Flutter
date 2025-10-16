import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // ** Google Fonts Import **
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/service/account_service.dart';
import '../service/fixed_deposit_service.dart';

// ** কাস্টম কালার কনস্ট্যান্ট **
const Color kPrimaryTeal = Color(0xFF009688); // Teal Color
const Color kAccentBlue = Color(0xFF2196F3); // Blue Accent
const Color kGreyBackground = Color(0xFFF5F5F5);

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
  // late AccountsProfile accountsProfile; // এটি এখানে প্রয়োজন নেই

  final List<int> monthsList = const [12, 24, 36, 48, 60, 72, 84, 96, 108, 120];

  @override
  void initState() {
    super.initState();
    accountService = AccountService();
  }

  // লজিক অপরিবর্তিত
  void _calculatePreview() {
    double? amount = double.tryParse(_amountController.text);
    int? months = _selectedMonths;

    if (amount == null || months == null) {
      setState(() {
        _estimatedInterestRate = null;
        _maturityAmount = null;
      });
      return;
    }

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

  // লজিক অপরিবর্তিত
  Future<void> _createFD() async {
    double? amount = double.tryParse(_amountController.text);
    if (amount == null || _selectedMonths == null) {
      setState(() => _message = "⚠️ অনুগ্রহ করে সঠিক পরিমাণ ও সময়কাল লিখুন!");
      return;
    }

    if (amount < 50000) {
      setState(() => _message = "⚠️ সর্বনিম্ন ডিপোজিট ৫০,০০০ টাকা।");
      return;
    }

    // প্রিভিউ না দেখে কনফার্ম করলে মেসেজ আপডেট করা
    if (_estimatedInterestRate == null || _maturityAmount == null) {
      _calculatePreview();
    }

    final fd = await _service.createFD(amount, _selectedMonths!);

    if (fd != null) {
      setState(() {
        _message = "✅ FD সফলভাবে তৈরি হয়েছে! FD ID: ${fd.id}";
      });
    } else {
      setState(() {
        _message = "❌ FD তৈরি করা যায়নি। আবার চেষ্টা করুন।";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontScale = screenWidth / 390;

    return Scaffold(
      backgroundColor: kGreyBackground,
      appBar: AppBar(
        // ** AppBar কালার পরিবর্তন এবং ফন্ট স্টাইল **
        backgroundColor: kPrimaryTeal,
        title: Text(
          "ফিক্সড ডিপোজিট",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20 * fontScale,
          ),
        ),
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
        padding: EdgeInsets.all(16 * fontScale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ** 1. Deposit Amount Input **
            _buildAmountTextField(fontScale),
            SizedBox(height: 20 * fontScale),

            // ** 2. Duration Dropdown **
            _buildDurationDropdown(fontScale),
            SizedBox(height: 25 * fontScale),

            // ** 3. FD Preview Card **
            if (_estimatedInterestRate != null && _maturityAmount != null)
              _buildPreviewCard(fontScale),

            SizedBox(height: 30 * fontScale),

            // ** 4. Confirm Button **
            _buildConfirmButton(fontScale),

            SizedBox(height: 20 * fontScale),

            // ** 5. Message/Status Text **
            Center(
              child: Text(
                _message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14 * fontScale,
                  color: _message.startsWith('✅') ? kPrimaryTeal : Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------ UI Helper Widgets ------------------

  Widget _buildAmountTextField(double fontScale) {
    return TextField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: "ডিপোজিট অ্যামাউন্ট (BDT)",
        labelStyle: GoogleFonts.poppins(color: kPrimaryTeal, fontSize: 14 * fontScale),
        hintText: "ন্যূনতম 50,000",
        prefixIcon: const Icon(Icons.currency_bitcoin, color: kPrimaryTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryTeal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kPrimaryTeal.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryTeal, width: 2),
        ),
      ),
      keyboardType: TextInputType.number,
      style: GoogleFonts.poppins(fontSize: 16 * fontScale, fontWeight: FontWeight.w500),
      onChanged: (_) => _calculatePreview(),
    );
  }

  Widget _buildDurationDropdown(double fontScale) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "সময়কাল (মাস)",
        labelStyle: GoogleFonts.poppins(color: kPrimaryTeal, fontSize: 14 * fontScale),
        prefixIcon: const Icon(Icons.calendar_today, color: kPrimaryTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryTeal),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kPrimaryTeal.withOpacity(0.5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryTeal, width: 2),
        ),
      ),
      items: monthsList
          .map(
            (m) => DropdownMenuItem(
          value: m,
          child: Text(
            "$m মাস",
            style: GoogleFonts.poppins(fontSize: 16 * fontScale),
          ),
        ),
      )
          .toList(),
      value: _selectedMonths,
      onChanged: (val) {
        setState(() => _selectedMonths = val);
        _calculatePreview();
      },
      style: GoogleFonts.poppins(color: Colors.black, fontSize: 16 * fontScale),
    );
  }

  Widget _buildPreviewCard(double fontScale) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: kPrimaryTeal, width: 2),
      ),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(18 * fontScale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ডিপোজিট প্রিভিউ",
              style: GoogleFonts.poppins(
                fontSize: 18 * fontScale,
                fontWeight: FontWeight.bold,
                color: kPrimaryTeal,
              ),
            ),
            const Divider(color: kPrimaryTeal, thickness: 0.5),
            _buildPreviewRow(
              "সুদের হার:",
              "${_estimatedInterestRate!}%",
              kAccentBlue,
              fontScale,
            ),
            SizedBox(height: 10 * fontScale),
            _buildPreviewRow(
              "ম্যাচিউরিটি অ্যামাউন্ট:",
              "${_maturityAmount!.toStringAsFixed(2)} BDT",
              kPrimaryTeal,
              fontScale,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(
      String label, String value, Color color, double fontScale,
      {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 15 * fontScale,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16 * fontScale,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(double fontScale) {
    return ElevatedButton.icon(
      onPressed: _createFD,
      icon: Icon(Icons.check_circle_outline, color: Colors.white, size: 20 * fontScale),
      label: Text(
        "ফিক্সড ডিপোজিট নিশ্চিত করুন",
        style: GoogleFonts.poppins(
          fontSize: 16 * fontScale,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryTeal,
        padding: EdgeInsets.symmetric(
          horizontal: 20 * fontScale,
          vertical: 15 * fontScale,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10 * fontScale),
        ),
        elevation: 5,
      ),
    );
  }
}