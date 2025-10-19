import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mk_bank_project/api/environment.dart';
import 'package:mk_bank_project/dto/transactiondto.dart';
import 'package:mk_bank_project/service/authservice.dart';


class TransactionStatementService {
  // আপনার environment.dart থেকে baseUrl নিন (যেমন: http://localhost:8085)
  final String _baseUrl = Environment.springUrl;
  final AuthService authService; // DI এর মাধ্যমে AuthService নিন

  // Constrctor এ AuthService নিতে হবে
  TransactionStatementService({required this.authService});

  // Headers তৈরি করার কমন ফাংশন
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await authService.getToken();
    if (token == null) throw Exception('Authentication token not found.');

    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }


  // ১. প্রাথমিক স্টেটমেন্ট লোড করার জন্য
  Future<List<TransactionDTO>> getStatement() async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl/api/transactions/statement');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TransactionDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transaction statement: ${response.statusCode}');
    }
  }

  // ২. ফিল্টার সহ স্টেটমেন্ট লোড করার জন্য
  Future<List<TransactionDTO>> getTransactionsWithFilterForAccountHolder({
    String? startDate,
    String? endDate,
    String? type,
    String? transactionType,
  }) async {
    final headers = await _getAuthHeaders();

    final Map<String, dynamic> queryParams = {};
    if (startDate?.isNotEmpty ?? false) queryParams['startDate'] = startDate;
    if (endDate?.isNotEmpty ?? false) queryParams['endDate'] = endDate;
    if (type?.isNotEmpty ?? false) queryParams['type'] = type;
    if (transactionType?.isNotEmpty ?? false) queryParams['transactionType'] = transactionType;

    // final url = Uri.parse('$_baseUrl/transactions/statement/filter').replace(queryParameters: queryParams);
    final url = Uri.parse('$_baseUrl/api/transactions/statement/filter').replace(queryParameters: queryParams);

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => TransactionDTO.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load filtered transactions: ${response.statusCode}');
    }
  }
}