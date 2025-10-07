
import 'dart:convert';

import 'package:mk_bank_project/service/authservice.dart';
import 'package:http/http.dart' as http;

class AccountService{

  final String baseUrl = "http://localhost:8085";


Future<Map<String,dynamic>?> getAccountsProfile()async{
  String? token = await AuthService().getToken();
  
  if(token == null){
    print('No token found,please login first.');
    return null; 
  }
  
  final url = Uri.parse('$baseUrl/api/account/profile');
  final response = await http.get(
    url,
    headers:{
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if(response.statusCode == 200){
    return jsonDecode(response.body);
    
  }
  else{
    print('Faild to load Profile: ${response.statusCode} - ${response.body}');
  }

}

//last
}