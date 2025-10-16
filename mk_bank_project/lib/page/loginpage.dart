import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mk_bank_project/admin/admin_profile_page.dart';
import 'package:mk_bank_project/employee/employee_profile_page.dart';
import 'package:mk_bank_project/page/registrationpage.dart';
import 'package:mk_bank_project/account/accounts_profile.dart';
import 'package:mk_bank_project/service/account_service.dart';
import 'package:mk_bank_project/service/admin_service.dart';
import 'package:mk_bank_project/service/authservice.dart';
import 'package:mk_bank_project/service/employee_service.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final storage = const FlutterSecureStorage();
  AuthService authService = AuthService();
  AccountService accountService = AccountService();
  EmployeeService employeeService = EmployeeService();
  AdminService adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),

            // Logo and Title Section
            Column(
              children: [
                // Image.asset(
                //   'assets/images/default_avater.png', // Replace with your own MK logo
                //   height: 100,
                // ),
                Image.asset(
                  'assets/images/login_logo.png',
                  height: 120,
                  width: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 10),

                // const Text(
                //   "MK Bank Smart",
                //   style: TextStyle(
                //     fontSize: 22,
                //     fontWeight: FontWeight.w500,
                //     color: Colors.blueAccent,
                //   ),
                // ),

                // App Title
                Text(
                  "Bank Smart",
                  style: GoogleFonts.pacifico(
                    fontSize: 24,
                    color: Colors.blueAccent,
                  ),
                ),

                const SizedBox(height: 5),
                const Text(
                  "vP7.9",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Subtitle - Login
                Text(
                  "Login to",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "MK Bank",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),

            // Login Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Username",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: email,
                        decoration: InputDecoration(
                          hintText: 'Enter Username',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Username?",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: const UnderlineInputBorder(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF9B208),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "REGISTER BIOMETRICS",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => loginUser(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                "LOGIN",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
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

            const SizedBox(height: 25),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 10,
                children: [
                  bottomCard(Icons.fingerprint, "Sign up for Astha"),
                  bottomCard(Icons.account_balance, "Open a Bank Account"),
                  bottomCard(Icons.credit_card, "Apply for Cards/Loans"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // Bottom Menu
            Container(
              color: const Color(0xFFF9B208),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  bottomMenu(Icons.location_on_outlined, "ATM/Branch\nNear Me"),
                  bottomMenu(Icons.local_offer_outlined, "Offers\nNear Me"),
                  bottomMenu(Icons.phone_in_talk_outlined, "Contact\nUs"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomCard(IconData icon, String title) {
    return Container(
      width: 105,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.blueAccent),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget bottomMenu(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ],
    );
  }

  Future<void> loginUser(BuildContext context) async {
    try {
      final response = await authService.login(email.text, password.text);
      final role = await authService.getUserRole();

      if (role == 'ADMIN') {
        final adminProfile = await adminService.getAdminProfile();
        if (adminProfile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AdminPage(profile: adminProfile)),
          );
        }
      } else if (role == 'EMPLOYEE') {
        final employeeProfile = await employeeService.getEmployeeProfile();
        if (employeeProfile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EmployeePage(profile: employeeProfile)),
          );
        }
      } else if (role == 'USER') {
        final profile = await accountService.getAccountsProfile();
        if (profile != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AccountsProfile(profile: profile)),
          );
        }
      } else {
        print('Unknown role: $role');
      }
    } catch (error) {
      print('Login failed: $error');
    }
  }
}
