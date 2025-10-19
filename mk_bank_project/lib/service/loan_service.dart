import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mk_bank_project/api/environment.dart';
import 'package:mk_bank_project/dto/loan_dto.dart';
import 'package:mk_bank_project/service/authservice.dart';


class LoanService {
  // আপনার API URL
  final String _apiUrl = '${Environment.springUrl}/api/loans/myloans';
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
}