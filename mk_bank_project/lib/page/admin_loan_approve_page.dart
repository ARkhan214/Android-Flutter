import 'package:flutter/material.dart';
import 'package:mk_bank_project/dto/loan_dto.dart';
import 'package:mk_bank_project/service/loan_service.dart';

class AdminLoanApprovePage extends StatefulWidget {
  const AdminLoanApprovePage({super.key});

  @override
  State<AdminLoanApprovePage> createState() => _AdminLoanApprovePageState();
}

class _AdminLoanApprovePageState extends State<AdminLoanApprovePage> {
  final LoanService _loanService = LoanService();
  List<LoanDTO> _pendingLoans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingLoans();
  }

  Future<void> _loadPendingLoans() async {
    setState(() => _isLoading = true);
    try {
      final loans = await _loanService.getPendingLoans();
      setState(() {
        _pendingLoans = loans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading loans: $e')),
      );
    }
  }

  Future<void> _approveLoan(int loanId) async {
    try {
      await _loanService.approveLoan(loanId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan Approved Successfully')),
      );
      _loadPendingLoans();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve loan: $e')),
      );
    }
  }

  Future<void> _rejectLoan(int loanId) async {
    try {
      await _loanService.rejectLoan(loanId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loan Rejected Successfully')),
      );
      _loadPendingLoans();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject loan: $e')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Loan Approvals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingLoans.isEmpty
          ? const Center(child: Text('No pending loans found'))
          : ListView.builder(
        itemCount: _pendingLoans.length,
        itemBuilder: (context, index) {
          final loan = _pendingLoans[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Loan ID: ${loan.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(loan.status, style: TextStyle(color: _getStatusColor(loan.status), fontWeight: FontWeight.bold)),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _approveLoan(loan.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Approve'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _rejectLoan(loan.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
