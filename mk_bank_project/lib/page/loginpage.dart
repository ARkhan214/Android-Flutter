import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mk_bank_project/admin/admin_profile_page.dart';
import 'package:mk_bank_project/employee/employee_profile_page.dart';
import 'package:mk_bank_project/page/registrationpage.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:mk_bank_project/service/authservice.dart';

class LoginPage extends StatelessWidget {

  // =================Shortcut==========
  // Line Alaignment = ctrl+alt+L
  // Selection Duplicate = ctrl+D
  // Select each next match = Alt + J
  // All matches =  Ctrl + Alt + Shift + J
  //========================================

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final storage = new FlutterSecureStorage();
  AuthService authService = AuthService();
  AccountService accountService = AccountService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            SizedBox(
              height: 20.0,
            ),

            TextField(
              controller: password,
              obscureText:true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),

              ),
            ),

            SizedBox(
              height: 20.0,
            ),


            ElevatedButton(
                onPressed: (){
                  
                  loginUser(context);
                  
                    // String em = email.text;
                    // String pass = password.text;
                    // print('Email: $em,Password: $pass');
                },
                child: Text(
                    "Login",
                        style:TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w800,
                        ),
                ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white
              ),
            ),


            SizedBox(height: 20.0),

            TextButton(
                onPressed:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Registration()),
                  );
                },
                child: Text(
                  "Registration here",
                  style: TextStyle(
                      color: Colors.green,
                      decoration: TextDecoration.none
                  ),
                ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void>loginUser(BuildContext context) async{
    
    
    try{
      final response = await authService.login(email.text, password.text);

      final role = await authService.getUserRole();

      if(role == 'ADMIN'){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage()),
        );
      }

      else if(role == 'EMPLOYEE'){
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmployeePage()),
        );
      }

      else if(role == 'USER'){
        final profile = await accountService.getAccountsProfile();
if(profile != null){
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
        builder: (context) => AccountsProfile(profile: profile)
    ),
  );
}
      }

      else{
        print('Unknown role: $role');
        }


    }
    catch(error){
      print('Login failed: $error');
    }
    
  }




  //last
}
