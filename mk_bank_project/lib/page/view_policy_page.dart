import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mk_bank_project/service/authservice.dart';

class ViewPolicyPage extends StatefulWidget {
  const ViewPolicyPage({super.key});

  @override
  State<ViewPolicyPage> createState() => _ViewPolicyPageState();
}

class _ViewPolicyPageState extends State<ViewPolicyPage> {
  final AuthService _authService = AuthService();
  List<dynamic> policies = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchPolicies();
  }

  // 🔹 Fire Policy Data Load
  Future<void> fetchPolicies() async {
    const String apiUrl = 'http://localhost:8084/api/firepolicy';
    try {
      final token = await _authService.getToken(); // <-- Get Token From AuthService

      if (token == null) {
        throw Exception("No token found. Please login again.");
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          policies = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading policies: $e');
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // 🔹 Delete Fire Policy
  Future<void> deletePolicy(int id) async {
    try {
      final token = await _authService.getToken(); // <-- Get Token Again

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login again 🔑')),
        );
        return;
      }

      final url = Uri.parse('http://localhost:8084/api/firepolicy/$id');

      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Policy deleted successfully')),
        );
        fetchPolicies(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Delete failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Error deleting policy')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('ইনস্যুরেন্স পলিসি'),
        backgroundColor: Colors.cyan,
        elevation: 3,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : hasError
          ? const Center(child: Text('ডেটা লোড করতে সমস্যা হয়েছে 😢'))
          : RefreshIndicator(
        onRefresh: fetchPolicies,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: policies.length,
          itemBuilder: (context, index) {
            final pol = policies[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              margin: const EdgeInsets.symmetric(
                  vertical: 8, horizontal: 4),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pol['bankName'] ?? 'Unknown Bank',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          onPressed: () =>
                              deletePolicy(pol['id']),
                        ),
                      ],
                    ),
                    const Divider(),
                    buildDataRow('Policy Holder',
                        pol['policyholder'] ?? 'N/A'),
                    buildDataRow(
                        'Address', pol['address'] ?? 'N/A'),
                    buildDataRow('Stock Insured',
                        '${pol['stockInsured'] ?? 'N/A'}'),
                    buildDataRow('Sum Insured',
                        '${pol['sumInsured'] ?? 'N/A'} Tk'),
                    buildDataRow(
                        'Coverage', pol['coverage'] ?? 'N/A'),
                    buildDataRow('Period',
                        '${pol['periodFrom']} → ${pol['periodTo']}'),
                    buildDataRow('Owner', pol['owner'] ?? 'N/A'),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyan,
        onPressed: () {
          // 👉 Future enhancement: Add new policy page navigation
        },
        label: const Text('Add Policy'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget buildDataRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
