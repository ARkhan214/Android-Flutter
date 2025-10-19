import 'package:flutter/material.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/dto/loan_dto.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:mk_bank_project/service/loan_service.dart';

// --------------------------------------------------------------------------
// PayLoanPage (Angular Component-এর সমতুল্য)
// --------------------------------------------------------------------------

class PayLoanPage extends StatefulWidget {
  const PayLoanPage({super.key});

  @override
  State<PayLoanPage> createState() => _PayLoanPageState();
}

class _PayLoanPageState extends State<PayLoanPage> {
  final LoanService _loanService = LoanService();
  late AccountService accountService;

  // স্টেট ভ্যারিয়েবল (Angular-এর কম্পোনেন্ট প্রপার্টিগুলোর মতো)
  List<LoanDTO> _allLoans = [];
  int? _selectedLoanId;
  LoanDTO? _loanData;
  double? _amount;
  bool _loading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    accountService = AccountService();
    _loadUserLoans();
  }

  // ১. সমস্ত লোন লোড করা
  Future<void> _loadUserLoans() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final loans = await _loanService.loadUserLoans();
      setState(() {
        _allLoans = loans;
        if (_allLoans.isNotEmpty) {
          _selectedLoanId = _allLoans.first.id;
          _fetchLoanDetails(_selectedLoanId!);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'লোন লোড করতে ব্যর্থ: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // ২. নির্বাচিত লোনের বিবরণ লোড করা
  Future<void> _fetchLoanDetails(int loanId) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _loanData = null;
    });
    try {
      final details = await _loanService.fetchLoanDetails(loanId);
      setState(() {
        _loanData = details;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : 'লোন পাওয়া যায়নি বা কোনো ত্রুটি হয়েছে।';
        _loanData = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // ৩. পেমেন্ট ফাংশন
  Future<void> _payLoan() async {
    if (_selectedLoanId == null || _amount == null || _amount! <= 0) {
      setState(() {
        _errorMessage =
            'অনুগ্রহ করে একটি লোন নির্বাচন করুন এবং সঠিক পরিমাণ দিন।';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _loanService.payLoan(_selectedLoanId!, _amount!);
      setState(() {
        _successMessage = 'পরিশোধ সফল! ${_amount!.toStringAsFixed(2)} টাকা।';
        _amount = null; // ইনপুট খালি করা হলো
      });
      // অ্যাঙ্গুলার-এর router.navigate(['/invoice']) এর জন্য:
      // Navigator.of(context).pushNamed('/invoice');

      if (_selectedLoanId != null) {
        _fetchLoanDetails(_selectedLoanId!); // লোনের তথ্য রিফ্রেশ করা
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('Exception:')
            ? e.toString().split('Exception: ')[1]
            : 'পরিশোধ ব্যর্থ হয়েছে।';
        _successMessage = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // লোনের বিস্তারিত তথ্যের UI উইজেট
  Widget _buildLoanDetails(LoanDTO loan) {
    const String baseUrl = 'http://localhost:8085/images/account/';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'লোন সংক্রান্ত তথ্য',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Divider(),
              _buildDetailRow('একাউন্ট নাম', loan.account.name),
              _buildDetailRow(
                'লোনের পরিমাণ',
                '৳${loan.loanAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'ইএমআই পরিমাণ',
                '৳${loan.emiAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'অবশিষ্ট পরিমাণ',
                '৳${loan.remainingAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'মোট পরিশোধিত',
                '৳${loan.totalAlreadyPaidAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'স্থিতি',
                loan.status,
                color: loan.status == 'ACTIVE' ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 12),
              const Text('ফটো', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      '$baseUrl${loan.account.photo}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ডিটেইলস রো তৈরির জন্য সহায়ক উইজেট
  Widget _buildDetailRow(
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
        backgroundColor: Colors.brown,
        title: const Text(
          'লোন পরিশোধ',
          style: TextStyle(color: Colors.white),
        ),

        centerTitle: true,

        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0), // Little padding
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded, // A softer, modern back icon
              color: Color(0xFFFD8E3D),
              size: 28,
            ),
            onPressed: () async {
              final profile = await accountService.getAccountsProfile();
              if (profile != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountsProfile(profile: profile),
                  ),
                );
              }
            },
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'লোন পরিশোধের ফর্ম',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 30, color: Colors.grey),

                // লোন ড্রপডাউন
                const Text(
                  'আপনার লোন নির্বাচন করুন',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  value: _selectedLoanId,
                  hint: const Text('লোন আইডি নির্বাচন করুন'),
                  items: _allLoans.map((loan) {
                    return DropdownMenuItem<int>(
                      value: loan.id,
                      child: Text('লোন আইডি ${loan.id} - ${loan.status}'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedLoanId = newValue;
                      _loanData = null;
                    });
                    if (newValue != null) {
                      _fetchLoanDetails(newValue);
                    }
                  },
                  isExpanded: true,
                ),

                // লোডিং ইন্ডিকেটর
                if (_loading && _loanData == null && _allLoans.isNotEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                // লোনের বিস্তারিত তথ্য
                if (_loanData != null) _buildLoanDetails(_loanData!),

                // পরিশোধের পরিমাণ ইনপুট
                const SizedBox(height: 20),
                const Text(
                  'পরিশোধের পরিমাণ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'পরিমাণ লিখুন',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _amount = double.tryParse(value);
                    });
                  },
                ),

                const SizedBox(height: 20),

                // ইএমআই পরিশোধ করুন বাটন
                ElevatedButton(
                  onPressed: _loading ? null : _payLoan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'ইএমআই পরিশোধ করুন',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // সতর্কবার্তা (সফলতা/ত্রুটি)
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green.shade800),
                    ),
                  ),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade400),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
