import 'package:flutter/material.dart';
import 'package:mk_bank_project/dto/loan_dto.dart';
import 'package:mk_bank_project/service/loan_service.dart';

class ViewLoanPage extends StatefulWidget {
  const ViewLoanPage({super.key});

  @override
  State<ViewLoanPage> createState() => _ViewLoanPageState();
}

class _ViewLoanPageState extends State<ViewLoanPage> {
  late Future<List<LoanDTO>> _loansFuture;
  final LoanService _loanService = LoanService();

  List<LoanDTO> _allLoans = [];
  List<LoanDTO> _filteredLoans = [];
  String _searchQuery = '';
  String _statusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loansFuture = _loanService.getMyLoans().then((loans) {
      _allLoans = loans;
      _filteredLoans = loans;
      return loans;
    });
  }

  void _filterLoans(String query) {
    List<LoanDTO> temp = _allLoans.where((loan) {
      final idString = loan.id.toString();
      final amountString = loan.loanAmount.toStringAsFixed(2);
      final matchesQuery = idString.contains(query) || amountString.contains(query);
      final matchesStatus = _statusFilter == 'ALL' || loan.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredLoans = temp;
    });
  }

  void _filterByStatus(String status) {
    List<LoanDTO> temp = _allLoans.where((loan) {
      final matchesQuery = loan.id.toString().contains(_searchQuery) ||
          loan.loanAmount.toStringAsFixed(2).contains(_searchQuery);
      final matchesStatus = status == 'ALL' || loan.status == status;
      return matchesQuery && matchesStatus;
    }).toList();

    setState(() {
      _statusFilter = status;
      _filteredLoans = temp;
    });
  }

  Widget _buildLoanCardList(List<LoanDTO> loans) {
    return ListView.builder(
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        Color statusColor = loan.status == 'ACTIVE'
            ? Colors.green.shade700
            : (loan.status == 'PENDING' ? Colors.orange.shade700 : Colors.red.shade700);

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loan ID: ${loan.id}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        loan.status,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                _buildInfoRow(Icons.monetization_on, 'Loan Amount', loan.loanAmount.toStringAsFixed(2)),
                _buildInfoRow(Icons.payments, 'EMI Amount', loan.emiAmount.toStringAsFixed(2)),
                _buildInfoRow(Icons.account_balance_wallet, 'Remaining Amount', loan.remainingAmount.toStringAsFixed(2)),
                _buildInfoRow(Icons.check_circle, 'Already Paid', loan.totalAlreadyPaidAmount.toStringAsFixed(2)),
                const Divider(height: 20, thickness: 0.5),
                _buildInfoRow(Icons.category, 'Loan Type', loan.loanType),
                _buildInfoRow(Icons.percent, 'Interest Rate', '${loan.interestRate}%'),
                _buildInfoRow(Icons.calendar_today, 'Start Date', loan.loanStartDate),
                _buildInfoRow(Icons.calendar_month, 'Complete Date', loan.loanMaturityDate),
                const Divider(height: 20, thickness: 1.5, color: Colors.blueGrey),
                const Text('Account Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person, 'Name', loan.account.name),
                _buildInfoRow(Icons.account_circle, 'Account ID', loan.account.id?.toString() ?? 'N/A'),
                _buildInfoRow(Icons.verified_user, 'NID', loan.account.nid ?? 'N/A'),
                _buildInfoRow(Icons.call, 'Phone', loan.account.phoneNumber),
                _buildInfoRow(Icons.location_on, 'Address', loan.account.address),
                _buildInfoRow(Icons.account_balance, 'A/C Type', loan.account.accountType),
                _buildInfoRow(Icons.attach_money, 'Balance', loan.account.balance?.toStringAsFixed(2) ?? '0.00'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(flex: 4, child: Text('$title:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54))),
          Expanded(flex: 6, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার লোন সমূহ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Loan ID or Amount',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterLoans,
            ),
            const SizedBox(height: 12),
            // Status Filter Dropdown
            Row(
              children: [
                const Text('Filter by Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _statusFilter,
                  items: ['ALL', 'ACTIVE', 'PENDING', 'REJECTED']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) _filterByStatus(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<LoanDTO>>(
                future: _loansFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    final errorMessage = snapshot.error.toString().replaceFirst('Exception: ', '');
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 60),
                          const SizedBox(height: 10),
                          Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 18), textAlign: TextAlign.center),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () { setState(() { _loansFuture = _loanService.getMyLoans(); }); },
                            icon: const Icon(Icons.refresh),
                            label: const Text('পুনরায় চেষ্টা করুন'),
                          ),
                        ],
                      ),
                    );
                  } else if (_filteredLoans.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty && _statusFilter == 'ALL'
                            ? 'কোনো লোন পাওয়া যায়নি।'
                            : 'No results for "${_searchQuery}" and status "${_statusFilter}"',
                        style: const TextStyle(fontSize: 18, color: Colors.orange),
                      ),
                    );
                  } else {
                    return _buildLoanCardList(_filteredLoans);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
