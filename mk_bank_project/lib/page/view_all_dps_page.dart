import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewAllDPSPage extends StatefulWidget {
  const ViewAllDPSPage({Key? key}) : super(key: key);

  @override
  _ViewAllDPSPageState createState() => _ViewAllDPSPageState();
}

class _ViewAllDPSPageState extends State<ViewAllDPSPage> {
  List<dynamic> dpsList = [];
  List<dynamic> filteredDPSList = []; // filtered list
  bool loading = false;
  String message = '';
  String searchQuery = ''; // search text

  final currencyFormatter = NumberFormat('#,##0.00', 'en_US');

  @override
  void initState() {
    super.initState();
    loadAllDPS();
  }

  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }

  Future<void> loadAllDPS() async {
    setState(() {
      loading = true;
      message = '';
    });

    final token = await _getAuthToken();
    if (token.isEmpty) {
      setState(() {
        message = 'Authentication token not found. Please login.';
        loading = false;
      });
      return;
    }

    final url = Uri.parse('http://localhost:8085/api/dps/my-dps');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          dpsList = data;
          filteredDPSList = data; // initially all
          loading = false;
        });
      } else {
        setState(() {
          message = 'Failed to load DPS accounts';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error: $e';
        loading = false;
      });
    }
  }

  void filterDPS(String query) {
    List<dynamic> temp = [];
    if (query.isEmpty) {
      temp = dpsList;
    } else {
      temp = dpsList.where((dps) {
        final idString = dps['id'].toString();
        final amountString = (dps['monthlyAmount'] ?? 0).toString();
        return idString.contains(query) || amountString.contains(query);
      }).toList();
    }
    setState(() {
      searchQuery = query;
      filteredDPSList = temp;
    });
  }

  Widget _buildDPSCard(dynamic dps) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DPS ID: ${dps['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Account Name: ${dps['accountName']}'),
            Text('Monthly Amount: ${currencyFormatter.format(dps['monthlyAmount'] ?? 0)}'),
            Text('Term (Months): ${dps['termMonths']}'),
            Text('Missed Count: ${dps['missedCount'] ?? 0}'),
            Text('Maturity Amount: ${currencyFormatter.format(dps['maturityAmount'] ?? 0)}'),
            Text('Status: ${dps['status']}'),
            Text('Months Paid: ${dps['monthsPaid']}'),
            Text('Next Debit Date: ${dps['nextDebitDate'] ?? '-'}'),
            Text('Start Date: ${dps['startDate'] ?? '-'}'),
            Text('Total Deposited: ${currencyFormatter.format(dps['totalDeposited'] ?? 0)}'),
            Text('Interest Rate: ${dps['annualInterestRate'] ?? 0}%'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All DPS Accounts'),
        backgroundColor: Colors.indigo,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by DPS ID or Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterDPS,
            ),
          ),
          Expanded(
            child: filteredDPSList.isEmpty
                ? Center(child: Text(searchQuery.isEmpty ? 'No DPS accounts found.' : 'No results for "$searchQuery"'))
                : RefreshIndicator(
              onRefresh: loadAllDPS,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: filteredDPSList.length,
                itemBuilder: (context, index) {
                  return _buildDPSCard(filteredDPSList[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
