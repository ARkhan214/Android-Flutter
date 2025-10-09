import 'dart:convert';
import 'dart:io';

// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';

//Wright by manualy
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:mk_bank_project/entity/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://localhost:8085";

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/user/login');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({'email': email, 'password': password});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      Map<String, dynamic> payload = Jwt.parseJwt(token);
      String role = payload['role'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('userRole', role);

      return true;
    } else {
      print('Failed to login: ${response.body}');
      return false;
    }
  }

  Future<bool> registerAccount({
    required Map<String, dynamic> user,
    required Map<String, dynamic> account,
    File? photofile,
    Uint8List? photoByte,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/account/'),
    );

    request.fields['user'] = jsonEncode(user);

    request.fields['account'] = jsonEncode(account);

    if (photoByte != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoByte,
          filename: 'profile.png',
        ),
      );
    } else if (photofile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', photofile.path),
      );
    }
    var response = await request.send();

    return response.statusCode == 200;
  }

  //getUserRole method
  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userRole'));
    return prefs.getString('userRole');
  }

  //getToken Token Method
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  //isTokenExpired method
  Future<bool> isTokenExpired() async {
    String? token = await getToken();

    if (token != null) {
      DateTime expiryDate = Jwt.getExpiryDate(token)!;
      return DateTime.now().isAfter(expiryDate);
    }
    return true;
  }

  //isLoggedIN method
  Future<bool> isLoggeIn() async {
    String? token = await getToken();
    if (token != null && !(await isTokenExpired())) {
      return true;
    } else {
      await logout();
      return false;
    }
  }

  //logout methode
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userRole');
  }

  //hasRole method
  Future<bool> hasRole(List<String> roles) async {
    String? role = await getUserRole();
    return role != null && role.contains(role);
  }

  //isAdmin methode
  Future<bool> isAdmin() async {
    return await hasRole(['ADMIN']);
  }

  Future<bool> isUser() async {
    return await hasRole(['USER']);
  }

  Future<bool> isEmployee() async {
    return await hasRole(['EMPLOYEE']);
  }

  // Future<Profile> fetchUserProfile() async {
  //   final response = await http.get(Uri.parse('$baseUrl/api/user/profile'));
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return Profile.fromJson(data);
  //   } else {
  //     throw Exception('Failed to load profile');
  //   }
  // }


  //===For Account Holder Profile
  Future<Profile> fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No token found. Please login again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/user/profile'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Profile.fromJson(data);
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  //===For Employee Profile
  Future<Profile> fetchEmployeeProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('No token found. Please login again.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/employees/profile'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Profile.fromJson(data);
    } else if (response.statusCode == 403 || response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  //last
}
