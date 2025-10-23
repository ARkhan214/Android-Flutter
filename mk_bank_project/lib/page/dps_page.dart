import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DPSPage extends StatefulWidget {
  const DPSPage({Key? key}) : super(key: key);

  @override
  _DPSPageState createState() => _DPSPageState();
}

class _DPSPageState extends State<DPSPage> {
  // === User Input ===
  final TextEditingController _monthlyAmountController = TextEditingController();
  final TextEditingController _termMonthsController = TextEditingController();

  // === Calculated preview ===
  double calculatedInterestRate = 0;
  double estimatedMaturityAmount = 0;

  // === Account Info ===
  int accountId = 0;
  String accountName = '';
  double balance = 0;
  String accountType = '';
  String nid = '';
  String phoneNumber = '';
  String address = '';

  // === Message ===
  String message = '';

  // Formatter
  final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    loadAccountInfo();
  }


  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }

  // === Load Account Info from backend ===
  void loadAccountInfo() async {
    final token = await _getAuthToken(); // _getAuthToken methode ta Future and async dewar karone await lagbe ekhane.
    if (token.isEmpty) {
      setState(() {
        message = 'Authentication token not found. Please login.';
      });
      return;
    }

    final headers = {'Authorization': 'Bearer $token'};
    final url = Uri.parse('http://localhost:8085/api/dps/my-account');

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          accountId = data['id'];
          accountName = data['name'];
          balance = data['balance']?.toDouble() ?? 0;
          accountType = data['accountType'] ?? '';
          nid = data['nid'] ?? '';
          phoneNumber = data['phoneNumber'] ?? '';
          address = data['address'] ?? '';
        });
      } else {
        setState(() {
          message = 'Failed to load account info';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  // === Calculate Preview ===
  void calculatePreview() {
    final monthlyAmount = double.tryParse(_monthlyAmountController.text) ?? 0;
    final termMonths = int.tryParse(_termMonthsController.text) ?? 0;

    if (monthlyAmount <= 0 || termMonths <= 0) {
      setState(() {
        calculatedInterestRate = 0;
        estimatedMaturityAmount = 0;
      });
      return;
    }

    if (termMonths <= 6) calculatedInterestRate = 5;
    else if (termMonths <= 12) calculatedInterestRate = 6;
    else if (termMonths <= 24) calculatedInterestRate = 7;
    else calculatedInterestRate = 8;

    setState(() {
      estimatedMaturityAmount = monthlyAmount * termMonths * (1 + calculatedInterestRate / 100);
    });
  }

  // === Create DPS Start========================
  //===========================================
  void createDps() async {
    final monthlyAmount = double.tryParse(_monthlyAmountController.text) ?? 0;
    final termMonths = int.tryParse(_termMonthsController.text) ?? 0;

    if (monthlyAmount <= 0 || termMonths <= 0) {
      setState(() {
        message = 'All fields are required';
      });
      return;
    }

    final token = await _getAuthToken();  // _getAuthToken methode ta Future and async dewar karone await lagbe ekhane.
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final payload = {
      'monthlyAmount': monthlyAmount,
      'termMonths': termMonths,
    };

    final url = Uri.parse('http://localhost:8085/api/dps/create');

    try {
      final response = await http.post(url, headers: headers, body: json.encode(payload));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          message = 'DPS Created Successfully! DPS ID: ${data['id']}';
        });
        // Optionally clear form
        _monthlyAmountController.clear();
        _termMonthsController.clear();
        calculatePreview();
      } else {
        final err = json.decode(response.body);
        setState(() {
          message = err['error'] ?? 'Error creating DPS';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
      });
    }
  }

  //Create methode end===================
  //==========================================

  @override
  void dispose() {
    _monthlyAmountController.dispose();
    _termMonthsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ডিপিএস'), backgroundColor: Colors.indigo),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Account Info
            Card(
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('ID: $accountId'),
                    Text('Name: $accountName'),
                    Text('Balance: ${currencyFormatter.format(balance)}'),
                    Text('Account Type: $accountType'),
                    Text('NID: $nid'),
                    Text('Phone: $phoneNumber'),
                    Text('Address: $address'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // DPS Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _monthlyAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Monthly Amount'),
                      onChanged: (_) => calculatePreview(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _termMonthsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Duration (Months)'),
                      onChanged: (_) => calculatePreview(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: Text('Interest Rate: $calculatedInterestRate%')),
                        Expanded(child: Text('Estimated Maturity: ${currencyFormatter.format(estimatedMaturityAmount)}')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: createDps,
                      child: const Text('Create DPS'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    ),
                    if (message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(message, style: const TextStyle(color: Colors.red)),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
