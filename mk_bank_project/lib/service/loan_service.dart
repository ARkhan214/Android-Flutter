import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mk_bank_project/api/environment.dart';
import 'package:mk_bank_project/dto/loan_dto.dart';
import 'package:mk_bank_project/service/authservice.dart';
import 'package:mk_bank_project/service/loan_payment_request.dart';


class LoanService {
  // আপনার API URL (getMyLoans-এর জন্য ব্যবহৃত)
  final String _apiUrl = '${Environment.springUrl}/api/loans/myloans';
  // আপনার API URL (loadUserLoans, fetchLoanDetails, payLoan-এর জন্য ব্যবহৃত)
  final String _baseUrl = 'http://localhost:8085/api/loans';

  final String _adminBaseUrl = '${Environment.springUrl}/api/admin/loans';

  final AuthService _authService = AuthService();

  Future<List<LoanDTO>> getMyLoans() async {
    // ১. টোকেন সংগ্রহ করা
    final String? token = await _authService.getToken();

    if (token == null) {
      // টোকেন না থাকলে Unauthorized Exception throw করা
      throw Exception('Unauthorized! Please login again.');
    }

    // ২. হেডার সেট করা: Content-Type এবং Authorization (Bearer Token)
    final Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };

    // ৩. API কল করা
    final response = await http.get(
      Uri.parse(_apiUrl),
      headers: headers,
    );

    // ৪. রেসপন্স হ্যান্ডেল করা
    if (response.statusCode == 200) {
      // JSON Array-কে ডিকোড করা
      final List<dynamic> jsonList = jsonDecode(response.body);
      // প্রতিটি আইটেমকে LoanDTO অবজেক্টে ম্যাপ করা
      return jsonList.map((json) => LoanDTO.fromJson(json)).toList();
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      // Unauthorized বা Forbidden Error হ্যান্ডেল করা (Angular-এর মতো)
      throw Exception('Unauthorized! Please login again.');
    } else {
      // অন্য কোনো ত্রুটি
      throw Exception('Failed to load loans: ${response.statusCode}');
    }
  }
  //=================

  // ডামি টোকেন বাদ দিয়ে আসল AuthService থেকে টোকেন নেওয়া হলো।
  Future<String?> _getAuthToken() async {
    return await _authService.getToken();
  }

  // API কল করার জন্য হেডার তৈরি করা।
  Future<Map<String, String>> _getHeaders() async {
    // এখন আসল টোকেন ব্যবহার করা হচ্ছে।
    final String? token = await _getAuthToken();

    if (token == null) {
      // টোকেন না পেলে ত্রুটি দেওয়া হলো।
      throw Exception('Authentication token not found. Please login again.');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ব্যবহারকারীর সমস্ত লোন লোড করা।
  Future<List<LoanDTO>> loadUserLoans() async {
    // যদি টোকেন না থাকে, _getHeaders() নিজেই Exception ছুঁড়বে।
    final headers = await _getHeaders();

    final url = Uri.parse('$_baseUrl/myloans');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => LoanDTO.fromJson(json)).toList();
    } else {
      // ত্রুটি বার্তা যাতে ইউজার দেখতে পায়
      throw Exception('Failed to load loans: ${response.statusCode}');
    }
  }

  // নির্বাচিত লোনের বিবরণ লোড করা।
  Future<LoanDTO> fetchLoanDetails(int loanId) async {
    final headers = await _getHeaders();

    final url = Uri.parse('$_baseUrl/$loanId');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return LoanDTO.fromJson(jsonDecode(response.body));
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Loan not found');
    }
  }

  // লোনের পেমেন্ট করা।
  Future<void> payLoan(int loanId, double amount) async {
    final headers = await _getHeaders();

    final requestBody = LoanPaymentRequest(loanId: loanId, amount: amount);
    final url = Uri.parse('$_baseUrl/pay');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(requestBody.toJson()),
    );

    if (response.statusCode == 200) {
      // পেমেন্ট সফল
      return;
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(errorBody['message'] ?? 'Payment failed');
    }
  }


  //====================================================================
  // *** Admin Specific API Calls ***
  // Angular-এর 'getAll()' মেথডটির সমতুল্য
  //====================================================================

  Future<List<LoanDTO>> getAllLoans() async {
    final headers = await _getHeaders();

    // অ্যাডমিন এন্ডপয়েন্ট ব্যবহার করা হচ্ছে
    final url = Uri.parse('$_adminBaseUrl/all');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => LoanDTO.fromJson(json)).toList();
    } else {
      // ত্রুটি বার্তা যাতে ইউজার দেখতে পায়
      throw Exception('Failed to load all loans for admin: ${response.statusCode}');
    }
  }

  //===============Admin Aproval part===========

  Future<List<LoanDTO>> getPendingLoans() async {
    final allLoans = await getAllLoans();
    return allLoans.where((loan) => loan.status.toUpperCase() == 'PENDING').toList();
  }

  Future<void> approveLoan(int loanId) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_adminBaseUrl/$loanId/approve');
    final response = await http.post(url, headers: headers);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to approve loan: ${response.statusCode}');
    }
  }

  Future<void> rejectLoan(int loanId) async {
    final headers = await _getHeaders();
    final url = Uri.parse('$_adminBaseUrl/$loanId/reject');
    final response = await http.post(url, headers: headers);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to reject loan: ${response.statusCode}');
    }
  }

}
