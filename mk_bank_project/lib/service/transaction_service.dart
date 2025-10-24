import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mk_bank_project/api/environment.dart';
import 'package:mk_bank_project/dto/transactiondto.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';
import 'authservice.dart';

class TransactionService {
  final String baseUrl = "http://localhost:8085/api/transactions";
  final AuthService authService;

  TransactionService({required this.authService});

  // Deposit / Withdraw / Initial Balance
  Future<Transaction> makeTransaction(Transaction transaction) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('No token found!');

    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Transaction Failed: ${response.body}');
    }
  }

  // Transfer money
  Future<Transaction> transfer(Transaction transaction, int receiverId) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('No token found!');

    final response = await http.post(
      Uri.parse('$baseUrl/tr/transfer/$receiverId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Transaction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Transfer Failed: ${response.body}');
    }
  }

  // Fetch all transactions by account ID
  Future<List<Transaction>> getTransactionsByAccountId(int accountId) async {
    final token = await authService.getToken();
    if (token == null) throw Exception('No token found!');

    final response = await http.get(
      Uri.parse('$baseUrl/account/$accountId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Transaction.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch transactions: ${response.body}');
    }
  }



  //==========For Employee======Transaction Statement==========




}
