import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mk_bank_project/dto/transactiondto.dart';
import 'package:mk_bank_project/dto/accountsdto.dart';
import 'package:intl/intl.dart';

class TransactionTotals {
  final double totalWithdraw;
  final double totalDeposit;
  final double totalBalance;
  TransactionTotals(this.totalWithdraw, this.totalDeposit, this.totalBalance);
}

class PdfUtility {
  static TransactionTotals computeTotals(List<TransactionDTO> transactions) {
    double totalWithdraw = 0;
    double totalDeposit = 0;
    double runningBalance = 0;

    for (var tx in transactions) {
      final amount = tx.amount ?? 0;
      if (tx.type == 'DEBIT') {
        totalWithdraw += amount;
        runningBalance -= amount;
      } else if (tx.type == 'CREDIT') {
        totalDeposit += amount;
        runningBalance += amount;
      }
    }
    return TransactionTotals(totalWithdraw, totalDeposit, runningBalance);
  }

  static Future<Uint8List> generateTransactionStatement(
      List<TransactionDTO> transactions, TransactionTotals totals) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final boldFont = await PdfGoogleFonts.robotoBold();
    final PdfColor darkBlue = PdfColor.fromInt(0xFF003366);

    final AccountsDTO? account =
    transactions.isNotEmpty ? transactions.first.account : null;
    final generatedDate =
    DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now().toLocal());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: font, bold: boldFont),

        // ✅ Repeating header (on every page)
        header: (context) => _buildHeader(darkBlue),

        // ✅ Repeating footer (page numbers)
        footer: (ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),

        // ✅ Main content
        build: (context) => [
          if (account != null)
            _buildCustomerInfo(account, darkBlue, generatedDate),

          pw.SizedBox(height: 5),

          pw.Text(
            'Transaction Details',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 14,
              color: darkBlue,
            ),
          ),
          pw.SizedBox(height: 3),

          // ✅ Use spread operator to allow multi-page flow
          ..._buildTransactionTable(transactions, totals, darkBlue),

          pw.SizedBox(height: 12),
          pw.Text(
            "This report has been generated from MK Bank iBanking based on available data. No signature required.",
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // ================= HEADER =================
  static pw.Widget _buildHeader(PdfColor darkBlue) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'MK Bank PLC.',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 16,
            color: darkBlue,
          ),
        ),
        pw.Text('Head Office, Dhaka', style: const pw.TextStyle(fontSize: 10)),
        pw.Text(
          'Trusted Banking Partner Since 1990',
          style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 5),
        pw.Divider(color: darkBlue, thickness: 0.5),
      ],
    );
  }

  // ================= CUSTOMER INFO =================
  static pw.Widget _buildCustomerInfo(
      AccountsDTO account, PdfColor darkBlue, String generatedDate) {
    final String openingDate = account.accountOpeningDate != null
        ? DateFormat('yyyy-MM-dd')
        .format(DateTime.parse(account.accountOpeningDate!))
        : '---';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Customer Information',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 14,
                color: darkBlue,
              ),
            ),
            pw.Text(
              'Report generated: $generatedDate',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: darkBlue,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 5),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Customer ID:', '${account.id ?? '---'}'),
                _infoRow('Name:', account.name),
                _infoRow('Address:', account.address),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _infoRow('Account Type:', account.accountType),
                _infoRow('Opening Date:', openingDate),
                _infoRow('Telephone:', account.phoneNumber),
              ],
            ),
            pw.SizedBox(width: 40),
          ],
        ),
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 90,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // ================= TABLE =================
  static List<pw.Widget> _buildTransactionTable(
      List<TransactionDTO> transactions,
      TransactionTotals totals,
      PdfColor darkBlue) {
    final headers = [
      'Date',
      'Particulars',
      'Inst. No',
      'Type',
      'Withdraw',
      'Deposit',
      'Balance'
    ];

    final data = transactions.map((tx) {
      final dateString = tx.transactionTime != null
          ? DateFormat('dd MMM yy').format(DateTime.parse(tx.transactionTime!))
          : '---';
      final description = (tx.description ?? '').replaceAll('\n', ' ');
      final id = '${tx.id ?? ''}';
      final type = tx.type ?? '';
      final withdraw =
      tx.type == 'DEBIT' ? (tx.amount?.toStringAsFixed(2) ?? '') : '';
      final deposit =
      tx.type == 'CREDIT' ? (tx.amount?.toStringAsFixed(2) ?? '') : '';
      final balance = tx.runningBalance?.toStringAsFixed(2) ?? '';

      return [
        dateString,
        description,
        id,
        type,
        withdraw,
        deposit,
        balance,
      ];
    }).toList();

    // ✅ Auto page split handled by TableHelper
    final table = pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.35),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
        fontSize: 9,
      ),
      headerDecoration: pw.BoxDecoration(color: darkBlue),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(1),
      },
    );

    final totalRow = pw.Container(
      width: double.infinity,
      color: PdfColors.grey300,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 6, child: pw.Container()),
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              totals.totalWithdraw.toStringAsFixed(2),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              totals.totalDeposit.toStringAsFixed(2),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.SizedBox(
            width: 60,
            child: pw.Text(
              totals.totalBalance.toStringAsFixed(2),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: PdfColors.blue900,
              ),
            ),
          ),
        ],
      ),
    );

    // ✅ Return as list, not inside a Column
    return [table, pw.SizedBox(height: 6), totalRow];
  }
}
