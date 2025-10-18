import 'package:flutter/material.dart';
// ✅ Fikks: Used DTO instead of TransactionModel.
import 'package:mk_bank_project/dto/transactiondto.dart';
import 'package:mk_bank_project/dto/accountsdto.dart';
// ✅ Fikks: Imported necessary services and utilities.
import 'package:mk_bank_project/service/transaction_service.dart';
import 'package:mk_bank_project/service/authservice.dart';
import 'package:mk_bank_project/service/transaction_statement_service.dart';
import 'package:mk_bank_project/service/transaction_totals.dart'; // ধরে নিলাম এই ফাইলটি আছে
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';


class LastTransactionStatementPage extends StatefulWidget {
  const LastTransactionStatementPage({super.key});

  @override
  State<LastTransactionStatementPage> createState() => _LastTransactionStatementPageState();
}

class _LastTransactionStatementPageState extends State<LastTransactionStatementPage> {

  // ✅ Fix: Service class initialization restored.
  final TransactionStatementService _transactionService = TransactionStatementService(authService: AuthService());

  // Variable to hold all transactions (sorted and with running balance)
  List<TransactionDTO> _fullStatement = [];

  // Index to track the currently displayed transaction in _fullStatement
  int _currentIndex = -1; // -1 means no transaction loaded yet

  // Data holder for the currently displayed transaction
  TransactionDTO? _currentTransaction; // Changed from _lastTransaction

  // Loading state and error message
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTransactionsAndSetLast();
  }

  // --- Helper function to calculate the running balance for the entire statement ---
  void _computeRunningBalances() {
    if (_fullStatement.isEmpty) return;

    // 1. Sort transactions by time to ensure correct running balance calculation.
    _fullStatement.sort((a, b) => DateTime.parse(a.transactionTime!).compareTo(DateTime.parse(b.transactionTime!)));

    double runningBalance = 0;

    for (int i = 0; i < _fullStatement.length; i++) {
      TransactionDTO tx = _fullStatement[i];
      final amount = tx.amount ?? 0;

      if (tx.type == 'DEBIT') {
        runningBalance -= amount;
      } else if (tx.type == 'CREDIT') {
        runningBalance += amount;
      }

      // 2. Update the DTO in the list with the calculated running balance using copyWith
      _fullStatement[i] = tx.copyWith(runningBalance: runningBalance);
    }
  }


  // --- 1. The main API call function (fetches the full statement and sets the last transaction) ---
  Future<void> _fetchTransactionsAndSetLast() async {
    try {
      // Fetch the complete statement from the service.
      final List<TransactionDTO> statement = await _transactionService.getStatement();

      if (statement.isNotEmpty) {
        // Save the full statement
        _fullStatement = statement;

        // Calculate running balance for all transactions
        _computeRunningBalances();

        // Set the current index to the last transaction (latest)
        _currentIndex = _fullStatement.length - 1;
        // Set the currently displayed transaction for the UI
        _currentTransaction = _fullStatement[_currentIndex];
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'লেনদেন লোড করতে সমস্যা: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // --- NEW: Function to navigate to the previous transaction (older) ---
  void _goToPreviousTransaction() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentTransaction = _fullStatement[_currentIndex];
      });
    }
  }

  // --- NEW: Function to navigate to the next transaction (more recent) ---
  void _goToNextTransaction() {
    // Check if there are more recent transactions to view
    if (_currentIndex < _fullStatement.length - 1) {
      setState(() {
        _currentIndex++;
        _currentTransaction = _fullStatement[_currentIndex];
      });
    }
  }


  // --- 2. PDF Export Function (for the currently displayed transaction ONLY) ---
  void _exportPDF() async {
    if (_currentTransaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কোনো লেনদেন নেই।')),
      );
      return;
    }

    try {
      // Only the currently displayed transaction is needed for the PDF
      final List<TransactionDTO> transactionForPdf = [_currentTransaction!];

      // Calculate totals for the single transaction (just for consistency, although only balance matters)
      double totalWithdraw = _currentTransaction!.type == 'DEBIT' ? (_currentTransaction!.amount ?? 0) : 0;
      double totalDeposit = _currentTransaction!.type == 'CREDIT' ? (_currentTransaction!.amount ?? 0) : 0;
      double currentBalance = _currentTransaction!.runningBalance ?? 0;

      final totals = TransactionTotals(totalWithdraw, totalDeposit, currentBalance);

      // Send the single transaction list to PdfUtility
      // Note: PdfUtility class is assumed to be available and correctly implemented elsewhere
      final pdfBytes = await PdfUtility.generateTransactionStatement(transactionForPdf, totals);

      // Share or download the PDF
      final date = DateFormat('ddMMyy').format(DateTime.parse(_currentTransaction!.transactionTime!));
      await Printing.sharePdf(
          bytes: pdfBytes, filename: 'transaction_${date}_${_currentTransaction!.id}.pdf');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF তৈরি করতে সমস্যা: ${e.toString()}')),
      );
    }
  }

  // --- 3. UI Build Function (Responsive Design) ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('লেনদেনের স্টেটমেন্ট')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('লেনদেনের স্টেটমেন্ট')),
        body: Center(child: Text(_errorMessage!)),
      );
    }

    if (_currentTransaction == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('লেনদেনের স্টেটমেন্ট')),
        body: const Center(child: Text('কোনো লেনদেন পাওয়া যায়নি।')),
      );
    }

    // Use transaction data to build the UI
    final tx = _currentTransaction!;
    final AccountsDTO? account = tx.account;

    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('লেনদেনের স্টেটমেন্ট')),
        body: const Center(child: Text('অ্যাকাউন্টের তথ্য পাওয়া যায়নি।')),
      );
    }


    return Scaffold(
      appBar: AppBar(
        // Show current index and total transactions
        title: Text('লেনদেন: ${_currentIndex + 1} of ${_fullStatement.length}'),
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800), // Responsive maxWidth
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    const Text('MK Bank PLC.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                    const Divider(thickness: 2),

                    // --- Customer Details ---
                    const SizedBox(height: 10),
                    const Text('গ্রাহকের তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),

                    _buildCustomerDetails(account),

                    const Divider(height: 30),

                    // --- Transaction Details ---
                    const Text('লেনদেনের বিবরণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 10),

                    // The table shows the current transaction
                    _buildTransactionTable(tx),

                    const SizedBox(height: 20),

                    // --- Navigation and Save PDF Buttons (Responsive using Wrap) ---
                    Wrap(
                      spacing: 15.0, // Space between buttons
                      runSpacing: 10.0, // Space between lines if wrapped
                      alignment: WrapAlignment.center, // Center the buttons
                      children: [
                        // Previous Button
                        ElevatedButton.icon(
                          onPressed: _currentIndex > 0 ? _goToPreviousTransaction : null, // Disable if at the first transaction
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('পূর্ববর্তী লেনদেন', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          ),
                        ),

                        // Next Button (NEW)
                        ElevatedButton.icon(
                          onPressed: _currentIndex < _fullStatement.length - 1 ? _goToNextTransaction : null, // Disable if at the last transaction
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('পরবর্তী লেনদেন', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                          ),
                        ),

                        // Save PDF Button
                        ElevatedButton.icon(
                          onPressed: _exportPDF,
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('স্টেটমেন্ট সেভ করুন (PDF)', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "এই চালানটি MK Bank iBanking সিস্টেম থেকে তৈরি করা হয়েছে। স্বাক্ষরের প্রয়োজন নেই।",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Customer Details Helper (No changes) ---
  Widget _buildCustomerDetails(AccountsDTO account) {
    return Wrap(
      spacing: 40.0,
      runSpacing: 10.0,
      children: [
        _infoRow('Customer ID:', (account.id ?? 'N/A').toString()),
        _infoRow('Name:', account.name ?? 'N/A'),
        _infoRow('Address:', account.address ?? 'N/A'),
        _infoRow('Account Type:', account.accountType ?? 'N/A'),
        _infoRow('Phone:', account.phoneNumber ?? 'N/A'),
        _infoRow(
          'Opening Date:',
          account.accountOpeningDate != null
              ? DateFormat('dd MMM yyyy').format(DateTime.parse(account.accountOpeningDate!))
              : 'N/A',
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return SizedBox(
      width: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  // --- Transaction Table Helper (No changes) ---
  Widget _buildTransactionTable(TransactionDTO tx) {
    final bool isDebit = tx.type == 'DEBIT';
    final amountText = tx.amount != null ? NumberFormat('###,##0.00').format(tx.amount!) : '0.00';
    final balanceText = tx.runningBalance != null ? NumberFormat('###,##0.00').format(tx.runningBalance!) : '0.00';

    // সিঙ্গেল ট্রানজেকশনের জন্য টেবিল
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(1.5),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(2.0),
        3: FlexColumnWidth(2.0),
        4: FlexColumnWidth(2.0),
        5: FlexColumnWidth(2.0),
      },
      children: [
        // Header Row
        const TableRow(
          decoration: BoxDecoration(color: Colors.indigo),
          children: [
            _TableHeaderCell(text: 'তারিখ', color: Colors.white),
            _TableHeaderCell(text: 'বিবরণ', color: Colors.white),
            _TableHeaderCell(text: 'Withdraw (টাকা)', color: Colors.white),
            _TableHeaderCell(text: 'Deposit (টাকা)', color: Colors.white),
            _TableHeaderCell(text: 'ধরন', color: Colors.white),
            _TableHeaderCell(text: 'ব্যালেন্স (টাকা)', color: Colors.white),
          ],
        ),
        // Data Row
        TableRow(
          children: [
            _TableDataCell(tx.transactionTime != null ? DateFormat('dd MMM yy, hh:mm a').format(DateTime.parse(tx.transactionTime!)) : 'N/A'),
            _TableDataCell(tx.description ?? 'N/A'),
            _TableDataCell(isDebit ? amountText : ''),
            _TableDataCell(!isDebit ? amountText : ''),
            _TableDataCell(tx.transactionType ?? 'N/A'),
            _TableDataCell(balanceText, isNumeric: true, textColor: Colors.blue.shade900),
          ],
        ),
      ],
    );
  }
}

// --- কাস্টম টেবিল সেল উইজেট ---
class _TableHeaderCell extends StatelessWidget {
  final String text;
  final Color color;
  const _TableHeaderCell({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
      ),
    );
  }
}

class _TableDataCell extends StatelessWidget {
  final String text;
  final bool isNumeric;
  final Color? textColor;
  const _TableDataCell(this.text, {this.isNumeric = false, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: isNumeric ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 12, color: textColor),
      ),
    );
  }
}