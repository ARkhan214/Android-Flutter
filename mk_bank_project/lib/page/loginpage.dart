import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mk_bank_project/admin/admin_profile_page.dart';
import 'package:mk_bank_project/employee/employee_profile_page.dart';
import 'package:mk_bank_project/page/registrationpage.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:mk_bank_project/service/admin_service.dart';
import 'package:mk_bank_project/service/authservice.dart';
import 'package:mk_bank_project/service/employee_service.dart';

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
  EmployeeService employeeService = EmployeeService();
  AdminService adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      //Body Start====
      // body: Padding(
      //   padding: EdgeInsets.all(16.0),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       TextField(
      //         controller: email,
      //         decoration: InputDecoration(
      //           labelText: 'Email',
      //           border: OutlineInputBorder(),
      //           prefixIcon: Icon(Icons.email),
      //         ),
      //       ),
      //
      //       SizedBox(height: 20.0),
      //
      //       TextField(
      //         controller: password,
      //         obscureText: true,
      //         decoration: InputDecoration(
      //           labelText: 'Password',
      //           border: OutlineInputBorder(),
      //           prefixIcon: Icon(Icons.lock),
      //         ),
      //       ),
      //
      //       SizedBox(height: 20.0),
      //
      //       ElevatedButton(
      //         onPressed: () {
      //           loginUser(context);
      //
      //           // String em = email.text;
      //           // String pass = password.text;
      //           // print('Email: $em,Password: $pass');
      //         },
      //         child: Text(
      //           "Login",
      //           style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),
      //         ),
      //
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: Colors.blue,
      //           foregroundColor: Colors.white,
      //         ),
      //       ),
      //
      //       SizedBox(height: 20.0),
      //
      //       TextButton(
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => Registration()),
      //           );
      //         },
      //         child: Text(
      //           "Registration here",
      //           style: TextStyle(
      //             color: Colors.green,
      //             decoration: TextDecoration.none,
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),

        backgroundColor: const Color(0xFFF3F6FA),
        body: Center(
            child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo or App Name
                        Icon(
                          Icons.account_balance,
                          size: 70,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Welcome To MK Bank",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Login to your account",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Email
                        TextField(
                          controller: email,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password
                        TextField(
                          controller: password,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => loginUser(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Forgot Password
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Registration Redirect
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(color: Colors.black54),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Registration(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Register here",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ),
        ),



      //Body End====



    );
  }

  Future<void> loginUser(BuildContext context) async {
    try {
      final response = await authService.login(email.text, password.text);

      final role = await authService.getUserRole();

      if (role == 'ADMIN') {

        final adminProfile = await adminService.getAdminProfile();

        if(adminProfile != null){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminPage(profile: adminProfile,)),
          );
        }

      } else if (role == 'EMPLOYEE') {

        final employeeProfile = await employeeService.getEmployeeProfile();


        if(employeeProfile != null){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EmployeePage(profile: employeeProfile,)),
          );
        }

      } else if (role == 'USER') {
        final profile = await accountService.getAccountsProfile();
        if (profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AccountsProfile(profile: profile),
            ),
          );
        }
      } else {
        print('Unknown role: $role');
      }
    } catch (error) {
      print('Login failed: $error');
    }
  }

  //last
}
