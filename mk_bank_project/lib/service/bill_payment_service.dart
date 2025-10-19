import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:mk_bank_project/entity/transaction_model.dart';




class BillPaymentService {

  final String _baseUrl = 'http://localhost:8085/api/transactions/pay';

  // HTTP হেডার তৈরি করার জন্য ব্যক্তিগত হেল্পার ফাংশন
  Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      // Bearer Token Authorization
      'Authorization': 'Bearer $token',
    };
  }

  // সমস্ত পেমেন্ট কলের জন্য একটি সাধারণ (Generic) ফাংশন
  Future<Transaction> _payBill(String endpoint, Map<String, dynamic> payload, String token) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final headers = _getHeaders(token);
    final encodedBody = jsonEncode(payload);

    if (kDebugMode) {
      debugPrint('API Call: $uri');
      debugPrint('Headers: $headers');
    }

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: encodedBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // সফল সাড়া: আপনার আসল Transaction মডেলের fromJson ব্যবহার করে ডেটা ডিসিরিয়ালাইজ করা হচ্ছে
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        // HTTP এরর হ্যান্ডলিং (যেমন 400, 500)
        String errorMessage;
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 'Unknown error';
        } catch (_) {
          errorMessage = 'Server responded with status code: ${response.statusCode}';
        }
        throw Exception('Payment Failed ($endpoint): Message: $errorMessage');
      }
    } catch (e) {
      // নেটওয়ার্ক এরর বা অন্য কোনো ব্যতিক্রম হ্যান্ডলিং
      throw Exception('Network Error during $endpoint payment: $e');
    }
  }

  // -------------------------------------------------------------------
  //                  Angular এর সাথে একই নামের পেমেন্ট ফাংশনগুলো
  // -------------------------------------------------------------------

  Future<Transaction> payWater(Map<String, dynamic> payload, String token) {
    return _payBill('water', payload, token);
  }

  Future<Transaction> payElectricity(Map<String, dynamic> payload, String token) {
    return _payBill('electricity', payload, token);
  }

  Future<Transaction> payGas(Map<String, dynamic> payload, String token) {
    return _payBill('gas', payload, token);
  }

  Future<Transaction> payInternet(Map<String, dynamic> payload, String token) {
    return _payBill('internet', payload, token);
  }

  Future<Transaction> payMobile(Map<String, dynamic> payload, String token) {
    return _payBill('mobile', payload, token);
  }

  Future<Transaction> payCreditCard(Map<String, dynamic> payload, String token) {
    return _payBill('credit-card', payload, token);
  }
}