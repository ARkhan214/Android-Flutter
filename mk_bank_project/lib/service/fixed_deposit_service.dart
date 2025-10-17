import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mk_bank_project/entity/fixed_deposit.dart';
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

  // Angular এর getMyFDs() এর সমতুল্য
  // lib/model/fixed_deposit.dart ফাইলে অবস্থিত FixedDepositForView ক্লাসটি ধরে নেওয়া হলো।
// Fixed Deposit Service-এর মধ্যে এই মেথডটি থাকবে:

  Future<List<FixedDepositForView>> getMyFD() async {
    // মেথডটি চালানোর জন্য কিছু প্রয়োজনীয় ভেরিয়েবল ইম্পোর্ট করা হয়েছে ধরে নেওয়া হচ্ছে,
    // যেমন: http, baseUrl, _getHeaders(), ইত্যাদি।

    final url = Uri.parse('$baseUrl/my-fds');
    final headers = await _getHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);

      // 💡 মূল পরিবর্তন: FixedDeposit এর পরিবর্তে FixedDepositForView.fromJson ব্যবহার করা হয়েছে।
      return jsonList.map((json) => FixedDepositForView.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Unauthorized! Please login again.');
    } else {
      throw Exception('Failed to load Fixed Deposits: ${response.statusCode}');
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

  //========For View=
// Angular এর getAuthToken() এর মত একটি ফাংশন
//   Future<String> _getAuthToken() async {
//     // এখানে আপনি localStorage এর বদলে SharedPreferences ব্যবহার করবেন
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('authToken') ?? '';
//   }
//
//   Future<Map<String, String>> _getAuthHeaders() async {
//     final token = await _getAuthToken();
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };
//   }
//

//
//   // Angular এর closeFD() এর সমতুল্য
//   Future<void> closeFD(int fdId, int accountId) async {
//     final url = Uri.parse('$_baseUrl/close/$fdId/$accountId');
//     final headers = await _getAuthHeaders();
//
//     final response = await http.post(
//       url,
//       headers: headers,
//       body: json.encode({}), // POST রিকোয়েস্ট কিন্তু বডি খালি
//     );
//
//     if (response.statusCode == 200) {
//       // সফলভাবে বন্ধ হয়েছে
//     } else if (response.statusCode == 403) {
//       throw Exception('Unauthorized! Please login again.');
//     } else {
//       throw Exception('Failed to close FD: Status ${response.statusCode}');
//     }
//   }



}
