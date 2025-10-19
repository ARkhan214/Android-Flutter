import 'package:flutter/material.dart';
// আপনার DTO এবং Service ফাইলের path সঠিক আছে ধরে নিলাম
import 'package:mk_bank_project/dto/loan_dto.dart';
import 'package:mk_bank_project/service/loan_service.dart';
// AccountsDTO-কে সরাসরি ব্যবহার করার জন্য import করা ভালো (যদি প্রয়োজন হয়)
// import 'package:mk_bank_project/dto/accounts_dto.dart';


class ViewLoanPage extends StatefulWidget {
  const ViewLoanPage({super.key});

  @override
  State<ViewLoanPage> createState() => _ViewLoanPageState();
}

class _ViewLoanPageState extends State<ViewLoanPage> {
  // Basic code same রাখা হলো
  late Future<List<LoanDTO>> _loansFuture;
  final LoanService _loanService = LoanService();

  @override
  void initState() {
    super.initState();
    _loansFuture = _loanService.getMyLoans();
  }

  // --- নতুন মোবাইল-ফ্রেন্ডলি কার্ড ভিউ ফাংশন ---
  Widget _buildLoanCardList(List<LoanDTO> loans) {
    // SingleChildScrollView + ListView.builder ব্যবহার করা হয়েছে ১০০% রেসপনসিভনেসের জন্য
    return ListView.builder(
      itemCount: loans.length,
      itemBuilder: (context, index) {
        final loan = loans[index];
        // স্ট্যাটাস অনুযায়ী রঙের লজিক
        Color statusColor = loan.status == 'APPROVED'
            ? Colors.green.shade700
            : (loan.status == 'PENDING' ? Colors.orange.shade700 : Colors.red.shade700);

        // কার্ডের অভ্যন্তরে প্রতিটি ডেটা Row আকারে দেখানো হবে
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            // স্ট্যাটাস অনুযায়ী কার্ডের বর্ডারেও হালকা রঙ দেওয়া হলো
            side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Loan ID এবং Status (প্রথম লাইন)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Loan ID: ${loan.id}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
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

                // মূল অর্থনৈতিক তথ্য
                _buildInfoRow(Icons.monetization_on, 'Loan Amount', loan.loanAmount.toStringAsFixed(2)),
                _buildInfoRow(Icons.payments, 'EMI Amount', loan.emiAmount.toStringAsFixed(2)),
                _buildInfoRow(Icons.account_balance_wallet, 'Remaining Amount', loan.remainingAmount.toStringAsFixed(2)),
                _buildInfoRow(Icons.check_circle, 'Already Paid', loan.totalAlreadyPaidAmount.toStringAsFixed(2)),

                const Divider(height: 20, thickness: 0.5),

                // লোনের ধরণ ও তারিখ
                _buildInfoRow(Icons.category, 'Loan Type', loan.loanType),
                _buildInfoRow(Icons.percent, 'Interest Rate', '${loan.interestRate}%'),
                _buildInfoRow(Icons.calendar_today, 'Start Date', loan.loanStartDate),
                _buildInfoRow(Icons.calendar_month, 'Complete Date', loan.loanMaturityDate),

                const Divider(height: 20, thickness: 1.5, color: Colors.blueGrey),

                // অ্যাকাউন্ট হোল্ডার তথ্য (Account Info)
                const Text(
                  'Account Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),

                _buildInfoRow(Icons.person, 'Name', loan.account.name),
                _buildInfoRow(Icons.account_circle, 'Account ID', loan.account.id?.toString() ?? 'N/A'),
                _buildInfoRow(Icons.verified_user, 'NID', loan.account.nid ?? 'N/A'),
                _buildInfoRow(Icons.call, 'Phone', loan.account.phoneNumber),
                _buildInfoRow(Icons.location_on, 'Address', loan.account.address),
                _buildInfoRow(Icons.account_balance, 'A/C Type', loan.account.accountType),
                // balance nullable, তাই null check নিশ্চিত করা হলো
                _buildInfoRow(Icons.attach_money, 'Balance', loan.account.balance?.toStringAsFixed(2) ?? '0.00'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Row তৈরির জন্য একটি সহায়ক উইজেট (Helper Widget)
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              textAlign: TextAlign.end,
            ),
          ),
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
        child: FutureBuilder<List<LoanDTO>>(
          future: _loansFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // ত্রুটি হ্যান্ডলিং আগের মতোই রাখা হলো
              final errorMessage = snapshot.error.toString().replaceFirst('Exception: ', '');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 10),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _loansFuture = _loanService.getMyLoans();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('পুনরায় চেষ্টা করুন'),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              // এখন টেবিলের বদলে কার্ড লিস্ট দেখানো হবে
              return _buildLoanCardList(snapshot.data!);
            } else {
              // কোনো লোন না পাওয়া গেলে মেসেজ দেখানো
              return const Center(
                child: Text(
                  'কোনো লোন পাওয়া যায়নি।',
                  style: TextStyle(fontSize: 18, color: Colors.orange),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}