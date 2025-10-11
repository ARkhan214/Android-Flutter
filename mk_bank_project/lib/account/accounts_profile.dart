import 'package:flutter/material.dart';
import 'package:mk_bank_project/account/profile_page.dart';
import 'package:mk_bank_project/page/loginpage.dart';
import 'package:mk_bank_project/page/transfer_money_page.dart';
import 'package:mk_bank_project/page/withdraw_page.dart';
import 'package:mk_bank_project/service/authservice.dart';

// ----------------------------------------------------------------------
// Custom Color Setup
// ----------------------------------------------------------------------

const int _primaryValue = 0xFF004D40; // Dark Teal/Green

const MaterialColor primaryColor = MaterialColor(_primaryValue, <int, Color>{
  50: Color(0xFFE0F2F1),
  100: Color(0xFFB2DFDB),
  200: Color(0xFF80CBC4),
  300: Color(0xFF4DB6AC),
  400: Color(0xFF26A69A),
  500: Color(_primaryValue),
  600: Color(0xFF00897B),
  700: Color(0xFF00796B),
  800: Color(0xFF00695C),
  900: Color(0xFF004D40),
});

const Color accentColor = Color(0xFFE57373); // Light Red/Coral

// ----------------------------------------------------------------------

class AccountsProfile extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AuthService _authService = AuthService();

  AccountsProfile({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://localhost:8085/images/account/";
    final String? photoName = profile['photo'];
    final String? photoUrl = (photoName != null && photoName.isNotEmpty)
        ? "$baseUrl$photoName"
        : null;

    final bool isActive = profile['accountActiveStatus'] == true;
    final String statusText = isActive ? 'Active' : 'Inactive';
    final Color statusColor = isActive
        ? Colors.green.shade600
        : Colors.red.shade600;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text(
            "MK Bank",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: primaryColor,
          centerTitle: true,
          elevation: 8,
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // Drawer Menu
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: primaryColor.shade700),
                accountName: Text(
                  profile['name'] ?? 'Unknown User',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: Text(profile['user']?['email'] ?? 'N/A'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundImage: (photoUrl != null)
                        ? NetworkImage(photoUrl)
                        : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: primaryColor),
                title: const Text(
                  'View Profile',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: accentColor),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  await _authService.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),

        // ------------------ Body Section ------------------
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 85,
                            height: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: CircleAvatar(
                                backgroundImage: (photoUrl != null)
                                    ? NetworkImage(photoUrl)
                                    : const AssetImage(
                                            'assets/images/default_avatar.png',
                                          )
                                          as ImageProvider,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Account No: ${profile['id'] ?? 'N/A'}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: statusColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "Status: $statusText",
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                "Balance",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "৳ ${profile['balance']?.toStringAsFixed(2) ?? 'N/A'}",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ExpansionTile(
                        title: Text(
                          "View Account Details",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        children: [
                          _buildDetailTile(context, "NID", profile['nid']),
                          _buildDetailTile(
                            context,
                            "Phone",
                            profile['phoneNumber'],
                          ),
                          _buildDetailTile(
                            context,
                            "Address",
                            profile['address'],
                          ),
                          _buildDetailTile(
                            context,
                            "Date of Birth",
                            profile['dateOfBirth'],
                            isDate: true,
                          ),
                          _buildDetailTile(
                            context,
                            "Opening Date",
                            profile['accountOpeningDate'],
                            isDate: true,
                          ),
                          _buildDetailTile(
                            context,
                            "Role",
                            profile['role'] ?? 'User',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ------------------ Dashboard Buttons ------------------
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildDashboardButton(
                            context,
                            "Money Transfer",
                            Icons.send,
                            primaryColor,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TransferMoneyPage(),
                                ),
                              );
                            },
                          ),
                          _buildDashboardButton(
                            context,
                            "Deposit",
                            Icons.account_balance_wallet,
                            Colors.teal,
                            () {},
                          ),
                          _buildDashboardButton(
                            context,
                            "Withdraw",
                            Icons.money_off,
                            Colors.deepOrange,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WithdrawPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildDashboardButton(
                            context,
                            "Transactions",
                            Icons.history,
                            Colors.indigo,
                            () {},
                          ),
                          _buildDashboardButton(
                            context,
                            "Profile",
                            Icons.person,
                            Colors.blueGrey,
                            () {},
                          ),
                          _buildDashboardButton(
                            context,
                            "Check Balance",
                            Icons.account_balance,
                            Colors.green,
                            () {},
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildDashboardButton(
                            context,
                            "Account Info",
                            Icons.info,
                            Colors.purple,
                            () {},
                          ),
                          _buildDashboardButton(
                            context,
                            "Settings",
                            Icons.settings,
                            Colors.brown,
                            () {},
                          ),
                          _buildDashboardButton(
                            context,
                            "Logout",
                            Icons.logout,
                            Colors.red,
                            () async {
                              await _authService.logout();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Dashboard Button Builder Method (এটা build() এর বাইরে থাকবে)
  Widget _buildDashboardButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: Icon(icon, size: 20),
          label: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  // ✅ Detail Tile Builder
  Widget _buildDetailTile(
    BuildContext context,
    String label,
    dynamic value, {
    bool isDate = false,
  }) {
    String displayValue = 'N/A';
    if (value != null) {
      displayValue = isDate
          ? value.toString().substring(0, 10)
          : value.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
