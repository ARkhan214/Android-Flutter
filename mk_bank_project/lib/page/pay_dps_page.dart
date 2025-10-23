import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mk_bank_project/page/fixed_deposit_page.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../account/accounts_profile.dart';

class PayDpsPage extends StatefulWidget {
  const PayDpsPage({super.key});

  @override
  State<PayDpsPage> createState() => _PayDpsPageState();
}

class _PayDpsPageState extends State<PayDpsPage> {
  int? selectedDpsId;
  List<dynamic> allDpsList = [];
  Map<String, dynamic>? dpsData;

  String successMessage = '';
  String errorMessage = '';
  bool loading = false;

  late AccountService accountService;

  @override
  void initState() {
    super.initState();
    accountService = AccountService();
    loadAllDps();
  }

  // Replace this with your actual method to get auth token
  // String getAuthToken() {
  //   // Example: return your shared_preferences token
  //   // return MyAuthService.getToken();
  //   return ''; // implement your actual logic
  // }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }


  // Load all DPS
  Future<void> loadAllDps() async {
    final token =await _getAuthToken();
    if (token.isEmpty) {
      showError('Authentication token not found. Please login again.');
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('http://localhost:8085/api/dps/my-dps'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          allDpsList = json.decode(res.body) ?? [];
        });
      } else {
        showError('Failed to load DPS list.');
      }
    } catch (e) {
      showError('Error loading DPS list.');
      print(e);
    }
  }

  // Fetch selected DPS details
  Future<void> fetchDpsDetails() async {
    if (selectedDpsId == null) return;

    final token =await _getAuthToken();
    if (token.isEmpty) {
      showError('Authentication token not found. Please login again.');
      return;
    }

    try {
      final res = await http.get(
        Uri.parse('http://localhost:8085/api/dps/$selectedDpsId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          dpsData = json.decode(res.body);
          errorMessage = '';
          successMessage = 'DPS details loaded successfully!';
        });
      } else {
        final err = json.decode(res.body);
        showError(err.toString());
        setState(() => dpsData = null);
      }
    } catch (e) {
      showError('Error fetching DPS details.');
      print(e);
      setState(() => dpsData = null);
    }
  }

  // Pay DPS
  Future<void> payDps() async {
    if (selectedDpsId == null) {
      showError('Please select a valid DPS');
      return;
    }

    final token =await _getAuthToken();
    if (token.isEmpty) {
      showError('Authentication token not found. Please login again.');
      return;
    }

    setState(() {
      loading = true;
      successMessage = '';
      errorMessage = '';
    });

    try {
      final res = await http.post(
        Uri.parse('http://localhost:8085/api/dps/pay/$selectedDpsId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        setState(() {
          successMessage = res.body.isNotEmpty ? res.body : 'Monthly DPS payment successful!';
          dpsData = null;
          selectedDpsId = null;
        });
        await loadAllDps(); // refresh dropdown
      } else {
        if (res.statusCode == 500 && res.body.contains('DPS is closed')) {
          showError('This DPS is already closed. No further payments allowed.');
        } else {
          showError(res.body.isNotEmpty ? res.body : 'Payment failed. Please try again.');
        }
      }
    } catch (e) {
      showError('Payment failed. Please try again.');
      print(e);
    } finally {
      setState(() => loading = false);
    }
  }

  void resetForm() {
    setState(() {
      selectedDpsId = null;
      dpsData = null;
      successMessage = '';
      errorMessage = '';
      loading = false;
    });
    showSuccess('DPS form reset successfully.');
  }

  void showError(String msg) {
    setState(() {
      errorMessage = msg;
      successMessage = '';
    });
  }

  void showSuccess(String msg) {
    setState(() {
      successMessage = msg;
      errorMessage = '';
    });
  }

  Widget buildDpsDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedDpsId,
      decoration: const InputDecoration(
        labelText: 'Select DPS',
        border: OutlineInputBorder(),
      ),
      items: allDpsList.map((dps) {
        return DropdownMenuItem<int>(
          value: dps['id'],
          child: Text('DPS #${dps['id']} — ${dps['status']} (৳${dps['monthlyAmount']})'),
        );
      }).toList(),
      onChanged: (val) async {
        setState(() => selectedDpsId = val);
        await fetchDpsDetails();
      },
    );
  }

  Widget buildDpsDetails() {
    if (dpsData == null) return const SizedBox();

    return Column(
      children: [
        const SizedBox(height: 12),
        buildReadOnlyField('Account Name', dpsData!['accountName']),
        buildReadOnlyField('Monthly Amount', dpsData!['monthlyAmount'].toString()),
        buildReadOnlyField('Term (Months)', dpsData!['termMonths'].toString()),
        buildReadOnlyField('Months Paid', dpsData!['monthsPaid'].toString()),
        buildReadOnlyField('Status', dpsData!['status']),
        buildReadOnlyField('Total Deposited', dpsData!['totalDeposited'].toString()),
        buildReadOnlyField('Next Debit Date', dpsData!['nextDebitDate']),
      ],
    );
  }

  Widget buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double fontScale = screenWidth / 390;
    return Scaffold(

      // appBar: AppBar(
      //   title: const Text('Pay DPS Monthly'),
      //   backgroundColor: Colors.green.shade700,
      // ),

      appBar: AppBar(
        // ** AppBar কালার পরিবর্তন এবং ফন্ট স্টাইল **
        backgroundColor: kPrimaryTeal,
        title: Text(
          "Pay DPS Monthly",
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildDpsDropdown(),
            buildDpsDetails(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: dpsData == null || loading ? null : payDps,
                    child: Text(loading ? 'Processing...' : 'Pay Monthly'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: resetForm,
                  child: const Text('Reset'),
                ),
              ],
            ),
            if (successMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(successMessage, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
