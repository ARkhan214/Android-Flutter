import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mk_bank_project/entity/fixed_deposit_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class FixedDepositService {
  final String baseUrl = "http://localhost:8085/api/fd";

  // 🔐 Get Auth Header
  Future<Map<String, String>> _getHeaders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  // 🏦 Create FD
  Future<FixedDeposit?> createFD(double depositAmount, int durationInMonths) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'depositAmount': depositAmount,
      'durationInMonths': durationInMonths,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return FixedDeposit.fromJson(data);
    } else {
      print('❌ Failed to create FD: ${response.body}');
      return null;
    }
  }

  // 📋 Get All My FDs
  Future<List<FixedDeposit>> getMyFDs() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/my-fds'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => FixedDeposit.fromJson(e)).toList();
    } else {
      print('❌ Failed to fetch FDs: ${response.body}');
      return [];
    }
  }

  // ❌ Close FD
  Future<bool> closeFD(int fdId, int accountId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/close/$fdId/$accountId'),
      headers: headers,
    );
    return response.statusCode == 200;
  }
}
