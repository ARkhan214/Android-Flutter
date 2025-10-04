

import 'dart:convert';
//Wright by manualy
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{

  final String baseUrl = "http://localhost:8085";

  Future<bool> login(String email,String password) async{

    final url=Uri.parse('$baseUrl/api/user/login');
    final headers = {'Content-Type': 'application/json'};

    final body = jsonEncode({'email': email,'password': password});

    final response = await http.post(url,headers:headers,body:body);

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      String token = data['token'];

      Map<String,dynamic>payload = Jwt.parseJwt(token);
      String role = payload['role'];


      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setString('userRole', role);

      return true;

    }

    else{
      print('Failed to login: ${response.body}');
      return false;
    }

  }

  Future<String?>getUserRole()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('userRole'));
    return prefs.getString('userRole');
  }






//last
}