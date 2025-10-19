import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Timer ব্যবহারের জন্য

// ------------------------------------------------------------------
// DATA MODEL FOR INITIAL ACCOUNT INFO
// ------------------------------------------------------------------
class AccountInfo {
  final int id;
  final String name;
  final double balance;
  final String accountType;
  final String nid;
  final String phoneNumber;
  final String address;

  AccountInfo({
    required this.id,
    required this.name,
    required this.balance,
    required this.accountType,
    required this.nid,
    required this.phoneNumber,
    required this.address,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      balance: (json['balance'] as num).toDouble(),
      accountType: json['accountType'] as String,
      nid: json['nid'] as String,
      phoneNumber: json['phoneNumber'] as String,
      address: json['address'] as String,
    );
  }
}

// ------------------------------------------------------------------
// FLUTTER COMPONENT: LoanApplyPage
// ------------------------------------------------------------------

class LoanApplyPage extends StatefulWidget {
  const LoanApplyPage({super.key});

  @override
  State<LoanApplyPage> createState() => _LoanApplyPageState();
}

class _LoanApplyPageState extends State<LoanApplyPage> {
  final _formKey = GlobalKey<FormState>();

  // Angular User input Controllers
  final TextEditingController _loanAmountController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _loanType;

  // Base URL
  final String _baseUrl = 'http://localhost:8085/api/loans';

  // Angular Pre-filled data
  AccountInfo? _accountInfo;
  bool _isLoadingInit = true; // Initial data loading state

  // Angular Calculated fields
  double _emi = 0.0;
  double _totalPayable = 0.0;
  double _interestRate = 0.0;

  // Loading/message states
  String? _message;
  bool _isApplying = false;
  bool _isCalculating = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadInitData(); // Angular ngOnInit এর সমতুল্য

    // Listeners to call EMI calculation whenever input changes
    _loanAmountController.addListener(_onInputChanged);
    _durationController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _durationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Angular getAuthToken() এর সমতুল্য
  Future<String> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') ?? '';
  }

  // Angular AlertService.success/error এর সমতুল্য
  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- API Functions ---

  // Angular loadInitData() এর সমতুল্য
  Future<void> _loadInitData() async {
    final token = await _getAuthToken();
    if (token.isEmpty) {
      _showSnackbar('Authentication token not found. Please login again.', isError: true);
      setState(() => _isLoadingInit = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/apply/init'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = json.decode(response.body);
        setState(() {
          // Pre-fill account info (similar to Angular component)
          _accountInfo = AccountInfo(
            id: res['account']['id'],
            name: res['account']['name'],
            balance: (res['account']['balance'] as num).toDouble(),
            accountType: res['account']['accountType'],
            nid: res['account']['nid'],
            phoneNumber: res['account']['phoneNumber'],
            address: res['account']['address'],
          );
        });
      } else {
        _showSnackbar('Failed to load initial data. Status: ${response.statusCode}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Network Error: Could not load initial data.', isError: true);
    } finally {
      setState(() {
        _isLoadingInit = false;
      });
    }
  }

  // Input Change Handler (Debounce for EMI calculation)
  void _onInputChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Dropdown value (loanType) must be selected before calculation
    final amount = double.tryParse(_loanAmountController.text);
    final duration = int.tryParse(_durationController.text);

    if (amount != null && duration != null && _loanType != null) {
      // 500ms debounce to prevent spamming the API on every keystroke
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _calculateEmi();
      });
    } else {
      // Clear calculated fields if any input is missing
      setState(() {
        _emi = 0.0;
        _totalPayable = 0.0;
        _interestRate = 0.0;
      });
    }
  }

  // Angular calculateEmi() এর সমতুল্য
  Future<void> _calculateEmi() async {
    final token = await _getAuthToken();
    if (token.isEmpty) return;

    final loanAmount = double.tryParse(_loanAmountController.text) ?? 0;
    final durationInMonths = int.tryParse(_durationController.text) ?? 0;

    if (loanAmount <= 0 || durationInMonths <= 0 || _loanType == null) {
      // Inputs are invalid, cleared in _onInputChanged
      return;
    }

    setState(() => _isCalculating = true);

    final payload = {
      'loanAmount': loanAmount,
      'durationInMonths': durationInMonths,
      'loanType': _loanType,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/calculate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = json.decode(response.body);
        setState(() {
          _emi = (res['emi'] as num).toDouble();
          _totalPayable = (res['totalPayable'] as num).toDouble();
          _interestRate = (res['interestRate'] as num).toDouble();
        });
      } else {
        _showSnackbar('EMI calculation failed: ${response.reasonPhrase}', isError: true);
      }
    } catch (e) {
      _showSnackbar('Network Error during EMI calculation.', isError: true);
    } finally {
      setState(() => _isCalculating = false);
    }
  }

  // Angular applyLoan() এর সমতুল্য
  Future<void> _applyLoan() async {
    if (!_formKey.currentState!.validate() || _loanType == null) {
      _showSnackbar('All required fields must be filled.', isError: true);
      return;
    }

    final loanAmount = double.tryParse(_loanAmountController.text) ?? 0;
    final durationInMonths = int.tryParse(_durationController.text) ?? 0;

    if (loanAmount <= 0 || durationInMonths <= 0) {
      _showSnackbar('Loan amount and duration must be greater than zero.', isError: true);
      return;
    }

    final token = await _getAuthToken();
    if (token.isEmpty) {
      _showSnackbar('Authentication token not found. Please login again.', isError: true);
      return;
    }

    setState(() {
      _isApplying = true;
      _message = null;
    });

    final payload = {
      'loanAmount': loanAmount,
      'durationInMonths': durationInMonths,
      'loanType': _loanType,
    };

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/apply'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> res = json.decode(response.body);
        final successMessage = 'Loan Applied Successfully! Loan ID: ${res['id']}';
        _showSnackbar(successMessage, isError: false);

        setState(() {
          _message = successMessage;
          _resetForm(); // ফর্ম রিসেট
        });

        // Angular router.navigate(['/view-all-loan']) এর সমতুল্য
        // Navigator.pushReplacementNamed(context, '/view-all-loan');
      } else {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Error applying for loan';
        _showSnackbar(errorMessage, isError: true);
        setState(() {
          _message = errorMessage;
        });
      }
    } catch (e) {
      const errorMessage = 'Network Error: Failed to submit loan application.';
      _showSnackbar(errorMessage, isError: true);
      setState(() {
        _message = errorMessage;
      });
    } finally {
      setState(() {
        _isApplying = false;
      });
    }
  }

  void _resetForm() {
    _loanAmountController.clear();
    _durationController.clear();
    setState(() {
      _loanType = null;
      _emi = 0.0;
      _totalPayable = 0.0;
      _interestRate = 0.0;
    });
  }

  // --- UI Build Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Loan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720), // Angular max-width: 720px
            child: _isLoadingInit
                ? const Center(child: CircularProgressIndicator())
                : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Loan Application Form',
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  // Account Info Section
                  _buildSectionTitle('Account Information'),
                  _buildAccountInfoCard(),

                  const SizedBox(height: 30),

                  // Loan Details Section
                  _buildSectionTitle('Loan Details'),
                  _buildLoanDetailsForm(),

                  const SizedBox(height: 30),

                  // EMI Summary
                  _buildEMISummary(),

                  const SizedBox(height: 40),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isApplying ? null : _applyLoan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 8,
                    ),
                    child: _isApplying
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                        : Text(
                      'Apply Now',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Response Message
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _message!.contains('Success') ? Colors.green.shade50 : Colors.red.shade50,
                          border: Border.all(color: _message!.contains('Success') ? Colors.green.shade300 : Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _message!,
                          style: TextStyle(color: _message!.contains('Success') ? Colors.green.shade900 : Colors.red.shade900),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Renders the section title
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade600,
          ),
        ),
        const Divider(color: Colors.grey, thickness: 0.5, height: 10),
      ],
    );
  }

  // Renders the Account Information in a Card
  Widget _buildAccountInfoCard() {
    if (_accountInfo == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow('Account Name:', _accountInfo!.name),
            _buildInfoRow('Account ID:', _accountInfo!.id.toString()),
            _buildInfoRow('Balance:', '৳ ${_accountInfo!.balance.toStringAsFixed(2)}', valueColor: Colors.green.shade700),
            _buildInfoRow('Account Type:', _accountInfo!.accountType),
            _buildInfoRow('NID:', _accountInfo!.nid),
            _buildInfoRow('Phone Number:', _accountInfo!.phoneNumber),
            _buildInfoRow('Address:', _accountInfo!.address),
          ],
        ),
      ),
    );
  }

  // Helper for single row info display
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Renders the Loan Details Input Form
  Widget _buildLoanDetailsForm() {
    return Column(
      children: [
        // Loan Amount and Duration
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInputFormField(
                controller: _loanAmountController,
                label: 'Loan Amount (৳)',
                placeholder: 'e.g. 100000',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildInputFormField(
                controller: _durationController,
                label: 'Duration (Months)',
                placeholder: 'e.g. 12',
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Loan Type Dropdown
        DropdownButtonFormField<String>(
          value: _loanType,
          decoration: InputDecoration(
            labelText: 'Loan Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          ),
          hint: const Text('Select type'),
          items: const [
            'PERSONAL',
            'HOME',
            'CAR',
            'EDUCATION',
            'BUSINESS',
          ].map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _loanType = newValue;
            });
            _onInputChanged(); // Call EMI calculation on change
          },
          validator: (value) => value == null ? 'Please select a loan type' : null,
        ),
      ],
    );
  }

  // Helper for text input fields
  Widget _buildInputFormField({required TextEditingController controller, required String label, required String placeholder}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'This field is required';
        if (double.tryParse(value) == null || double.parse(value) <= 0) return 'Enter a valid positive number';
        return null;
      },
      // Note: _onInputChanged is handled by the controller listener in initState
    );
  }

  // Renders the EMI Summary
  Widget _buildEMISummary() {
    if (_emi <= 0 && !_isCalculating) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      color: Colors.brown.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Loan Summary', style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown.shade700)),
                if (_isCalculating)
                  const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  )
              ],
            ),
            const Divider(),
            _buildSummaryRow('Interest Rate:', '${_interestRate.toStringAsFixed(2)}%', Colors.red.shade600),
            _buildSummaryRow('Total Payable:', '৳ ${_totalPayable.toStringAsFixed(2)}', Colors.black87),
            _buildSummaryRow('Monthly EMI:', '৳ ${_emi.toStringAsFixed(2)}', Colors.green.shade700),
          ],
        ),
      ),
    );
  }

  // Helper for summary row display
  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.roboto(fontSize: 15, color: Colors.black54)),
          Text(
            value,
            style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
