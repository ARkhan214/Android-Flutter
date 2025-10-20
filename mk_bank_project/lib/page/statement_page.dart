import 'package:flutter/material.dart';
import 'package:mk_bank_project/dto/transactiondto.dart';
import 'package:mk_bank_project/service/transaction_statement_service.dart';
import 'package:mk_bank_project/service/transaction_totals.dart';
import 'package:mk_bank_project/service/authservice.dart'; // আপনার AuthService-এর পাথ
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

// PdfUtility ক্লাসটি এখানে ইম্পোর্ট করা নেই, কিন্তু ধরে নিচ্ছি এটি অন্য ফাইলে আছে
// এবং সেটি কাজ করছে। এখানে শুধু StatementPage.dart-এর সমাধান দেওয়া হলো।
// import 'package:mk_bank_project/utils/pdf_utility.dart';

class StatementPage extends StatefulWidget {
  const StatementPage({super.key});

  @override
  State<StatementPage> createState() => _StatementPageState();
}

class _StatementPageState extends State<StatementPage> {
  // AuthService কে DI করার জন্য একটি ডামি ইনস্ট্যান্স,
  final TransactionStatementService _service = TransactionStatementService(authService: AuthService());

  List<TransactionDTO> _transactions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Filter Variables
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType; // DEBIT, CREDIT, or null (All)
  String _transactionTypeFilter = ''; // e.g., TRANSFER

  // Totals
  double _totalWithdraw = 0;
  double _totalDeposit = 0;
  double _totalBalance = 0;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  // Angular এর computeTotals লজিক
  void _computeTotals() {
    // Angular কোড অনুযায়ী running balance গণনা
    double runningBalance = 0;
    _totalWithdraw = 0;
    _totalDeposit = 0;
    _totalBalance = 0;


    // আমরা লেনদেনগুলোকে সর্ট করে নেব (যদি API সর্টেড না দেয়)
    // এবং running balance গণনা করব।
    _transactions.sort((a, b) => DateTime.parse(a.transactionTime!).compareTo(DateTime.parse(b.transactionTime!)));


    for (int i = 0; i < _transactions.length; i++) {
      TransactionDTO tx = _transactions[i];
      final amount = tx.amount ?? 0;

      if (tx.type == 'DEBIT') {
        _totalWithdraw += amount;
        runningBalance -= amount;
      } else if (tx.type == 'CREDIT') {
        _totalDeposit += amount;
        runningBalance += amount;
      }

      // runningBalance আপডেট করা
      _transactions[i] = tx.copyWith(runningBalance: runningBalance);
    }

    _totalBalance = runningBalance;

    // Last transactian fast a dekhar jonno
    // _transactions = _transactions.reversed.toList();
  }

  // API থেকে ট্রানজেকশন আনার ফাংশন
  void _fetchTransactions() async {
    // End Date কে দিনের শেষে সেট করুন (23:59:59)
    DateTime? adjustedEndDate = _endDate != null
        ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59)
        : null;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final formattedStartDate = _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : null;
    final formattedEndDate = adjustedEndDate != null ? DateFormat('yyyy-MM-dd').format(adjustedEndDate) : null;

    try {
      final data = await _service.getTransactionsWithFilterForAccountHolder(
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        type: _selectedType,
        transactionType: _transactionTypeFilter.toUpperCase().trim().isEmpty
            ? null
            : _transactionTypeFilter.toUpperCase().trim(),
      );

      setState(() {
        _transactions = data;
        _computeTotals(); // ডেটা আসার পর টোটাল এবং running balance গণনা
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        // print(e); // ডিবাগিং এর জন্য
        _errorMessage = 'Failed to load transactions: ${e.toString()}';
        _transactions = [];
        _isLoading = false;
      });
    }
  }

  // PDF জেনারেট এবং ডাউনলোডের ফাংশন
  void _exportPDF() async {
    if (_transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export.')),
      );
      return;
    }

    try {
      final totals = TransactionTotals(_totalWithdraw, _totalDeposit, _totalBalance);

      // ✅ এখানে আপনার PdfUtility ক্লাসের generateTransactionStatement ফাংশন কল করতে হবে
      // যেহেতু আপনার পুরো কোডে PdfUtility ইমপোর্ট করা নেই, তাই আমরা এখানে ধরে নিচ্ছি:
       final pdfBytes = await PdfUtility.generateTransactionStatement(_transactions, totals);

      // ডেমো হিসেবে খালি বাইট ব্যবহার করা হলো, আপনাকে উপরের লাইনটি আনকমেন্ট করতে হবে
      //final pdfBytes = await Printing.convertHtml(html: "<html><body><h1>Transaction Statement</h1></body></html>");

      await Printing.sharePdf(bytes: pdfBytes, filename: 'transaction-statement.pdf');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Statement', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Loading & Error Messages ---
            if (_isLoading) _buildLoadingOrError(true),
            if (_errorMessage.isNotEmpty) _buildLoadingOrError(false),

            // --- Filter Section (Responsive) ---
            _buildFilterSection(),

            const SizedBox(height: 15),

            // --- PDF Export Button ---
            if (_transactions.isNotEmpty && !_isLoading)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _exportPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Save as PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            const SizedBox(height: 15),

            // --- Transaction Table (Responsive) ---
            if (_transactions.isNotEmpty && !_isLoading)
              _buildTransactionTable(),

            if (_transactions.isEmpty && !_isLoading && _errorMessage.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('No transactions found.', style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Loading/Error Indicator
  Widget _buildLoadingOrError(bool isLoading) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.teal)
            : Text(_errorMessage, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ফিল্টার UI তৈরি করার জন্য (Responsive)
  Widget _buildFilterSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 10),

            // Wrap ব্যবহার করা হয়েছে, যাতে ছোট স্ক্রিন বা বড় স্ক্রিন উভয়েই সঠিক দেখায়
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.start,
              children: [
                _buildDatePicker('Start Date', _startDate, (date) => setState(() => _startDate = date)),
                _buildDatePicker('End Date', _endDate, (date) => setState(() => _endDate = date)),
                _buildTypeDropdown(),
                _buildTransactionTypeInput(),

                // Apply Button
                Container(
                  alignment: Alignment.bottomCenter,
                  height: 48, // অন্যান্য ফিল্ডের উচ্চতার সাথে মেলানোর জন্য
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _fetchTransactions,
                    icon: const Icon(Icons.search, size: 20),
                    label: const Text('Apply Filter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? selectedDate, Function(DateTime?) onDateSelected) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null) {
                onDateSelected(picked);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(8),
                isDense: true,
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
                // ছোট স্ক্রিনের জন্য ফন্ট সাইজ ছোট করে দিলাম
                hintStyle: Theme.of(context).textTheme.bodySmall,
              ),
              child: Text(selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate) : 'Select Date',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              isDense: true,
            ),
            value: _selectedType,
            hint: const Text('All'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: 'DEBIT', child: Text('Debit')),
              DropdownMenuItem(value: 'CREDIT', child: Text('Credit')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTypeInput() {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trans. Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: _transactionTypeFilter,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(8),
              isDense: true,
              hintText: 'e.g. TRANSFER',
            ),
            onChanged: (value) {
              _transactionTypeFilter = value;
            },
          ),
        ],
      ),
    );
  }


  // ট্রানজেকশন টেবিল তৈরি করার জন্য (Responsive)
  Widget _buildTransactionTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isSmallScreen = constraints.maxWidth < 600;

        // ছোট স্ক্রিনের জন্য শুধু প্রয়োজনীয় কলামগুলো রাখব
        final columns = [
          'Trans Date',
          'Particulars',
          if (!isSmallScreen) 'Inst. No',
          'Type',
          'Withdraw',
          'Deposit',
          'Balance',
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              columnSpacing: isSmallScreen ? 8 : 15,
              horizontalMargin: 10,
              border: TableBorder.all(color: Colors.grey.shade300),
              headingRowColor: MaterialStateProperty.all(Colors.teal.shade700),
              headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              dataRowMinHeight: 30,
              dataRowMaxHeight: 50,
              columns: columns.map((label) => DataColumn(label: Text(label, textAlign: TextAlign.center))).toList(),

              // ✅ ফিক্সড rows ব্লক
              rows: [
                ..._transactions.map((tx) {
                  // ✅ চূড়ান্ত ফিক্স: ?? '' ব্যবহার করে নিশ্চিত করা হলো যে এটি non-nullable String হবে।
                  final String withdraw = tx.type == 'DEBIT'
                      ? tx.amount?.toStringAsFixed(2) ?? ''
                      : '';
                  final String deposit = tx.type == 'CREDIT'
                      ? tx.amount?.toStringAsFixed(2) ?? ''
                      : '';

                  final cells = [
                    DataCell(Text(DateFormat('dd MMM yy').format(DateTime.parse(tx.transactionTime!)), style: const TextStyle(fontSize: 12))),
                    DataCell(Text(tx.description ?? '', style: const TextStyle(fontSize: 12))),
                    if (!isSmallScreen) DataCell(Text('${tx.id ?? ''}', style: const TextStyle(fontSize: 12))),
                    DataCell(Text(tx.type ?? '', style: TextStyle(color: tx.type == 'DEBIT' ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12))),

                    // ✅ এখন কোনো এরর আসবে না
                    DataCell(Text(withdraw, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),
                    DataCell(Text(deposit, textAlign: TextAlign.right, style: const TextStyle(fontSize: 12))),

                    DataCell(Text(tx.runningBalance?.toStringAsFixed(2) ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ];

                  return DataRow(cells: cells);
                }).toList(),

                // Totals Row
                DataRow(
                  color: MaterialStateProperty.all(Colors.grey.shade300),
                  cells: [
                    DataCell(const Text('Totals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(const Text('', style: TextStyle(fontWeight: FontWeight.bold))),
                    if (!isSmallScreen) DataCell(const Text('', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(const Text('', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(Text(_totalWithdraw.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text(_totalDeposit.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    DataCell(Text(_totalBalance.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}