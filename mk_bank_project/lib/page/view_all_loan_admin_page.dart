import 'package:flutter/material.dart';
import 'package:mk_bank_project/dto/loan_dto.dart';
import 'package:mk_bank_project/service/loan_service.dart';

class ViewAllLoansPage extends StatefulWidget {
  const ViewAllLoansPage({super.key});

  @override
  State<ViewAllLoansPage> createState() => _ViewAllLoansPageState();
}

class _ViewAllLoansPageState extends State<ViewAllLoansPage> {
  final LoanService _loanService = LoanService();
  List<LoanDTO> _loans = [];
  List<LoanDTO> _filteredLoans = [];

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _accountIdController = TextEditingController();
  final TextEditingController _loanAmountController = TextEditingController();
  String _selectedLoanType = '';

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    try {
      final loans = await _loanService.getAllLoans();
      setState(() {
        _loans = loans;
        _filteredLoans = List.from(loans);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading loans: $e')),
      );
    }
  }

  void _filterLoans() {
    setState(() {
      _filteredLoans = _loans.where((loan) {
        final matchId = _idController.text.isEmpty || loan.id.toString() == _idController.text;
        final matchAccountId = _accountIdController.text.isEmpty || loan.account.id.toString() == _accountIdController.text;
        final matchLoanType = _selectedLoanType.isEmpty || loan.loanType.toLowerCase().contains(_selectedLoanType.toLowerCase());
        final matchAmount = _loanAmountController.text.isEmpty || loan.loanAmount.toString() == _loanAmountController.text;
        return matchId && matchAccountId && matchLoanType && matchAmount;
      }).toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View All Loans')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 🔍 Search Fields
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'Loan ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    onChanged: (_) => _filterLoans(),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _accountIdController,
                    decoration: const InputDecoration(
                      labelText: 'Account ID',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    onChanged: (_) => _filterLoans(),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _loanAmountController,
                    decoration: const InputDecoration(
                      labelText: 'Loan Amount',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                    onChanged: (_) => _filterLoans(),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: _selectedLoanType.isEmpty ? null : _selectedLoanType,
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All Types')),
                      DropdownMenuItem(value: 'PERSONAL', child: Text('PERSONAL')),
                      DropdownMenuItem(value: 'HOME', child: Text('HOME')),
                      DropdownMenuItem(value: 'CAR', child: Text('CAR')),
                      DropdownMenuItem(value: 'EDUCATION', child: Text('EDUCATION')),
                      DropdownMenuItem(value: 'BUSINESS', child: Text('BUSINESS')),
                    ],
                    onChanged: (val) {
                      _selectedLoanType = val ?? '';
                      _filterLoans();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Loan Type',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredLoans.isEmpty
                  ? const Center(child: Text('No loans found', style: TextStyle(fontSize: 16)))
                  : ListView.builder(
                itemCount: _filteredLoans.length,
                itemBuilder: (context, index) {
                  final loan = _filteredLoans[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Loan ID: ${loan.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                loan.status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(loan.status),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              Text('Account: ${loan.account.name} (ID: ${loan.account.id})'),
                              Text('Amount: ৳ ${loan.loanAmount.toStringAsFixed(2)}'),
                              Text('Interest: ${loan.interestRate}%'),
                              Text('EMI: ৳ ${loan.emiAmount.toStringAsFixed(2)}'),
                              Text('Paid: ৳ ${loan.totalAlreadyPaidAmount.toStringAsFixed(2)}'),
                              Text('Remaining: ৳ ${loan.remainingAmount.toStringAsFixed(2)}'),
                              Text('Type: ${loan.loanType}'),
                              Text('Start: ${loan.loanStartDate}'),
                              Text('Maturity: ${loan.loanMaturityDate}'),
                              Text('Balance: ৳ ${loan.account.balance?.toStringAsFixed(2) ?? '0'}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
