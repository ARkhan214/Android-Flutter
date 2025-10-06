import 'dart:convert';
import 'dart:io';

// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';
import 'dart:typed_data';

//Wright by manualy
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
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
        await http.MultipartFile.fromPath(
            'photo',
            photofile.path
        ),
      );
    }
    var response = await request.send();

    return response.statusCode == 200;
  }

  Future<String?> getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userRole'));
    return prefs.getString('userRole');
  }

  //last
}
