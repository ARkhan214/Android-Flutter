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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double fontScale = screenWidth / 390; // responsive scaling

    final String baseUrl = "http://localhost:8085/images/account/";
    final String? photoName = profile['photo'];
    final String? photoUrl =
    (photoName != null && photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

    final bool isActive = profile['accountActiveStatus'] == true;
    final String statusText = isActive ? 'Active' : 'Inactive';
    final Color statusColor =
    isActive ? Colors.green.shade600 : Colors.red.shade600;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text(
            "MK Bank",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18 * fontScale,
            ),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17 * fontScale,
                  ),
                ),
                accountEmail: Text(
                  profile['user']?['email'] ?? 'N/A',
                  style: TextStyle(fontSize: 14 * fontScale),
                ),
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
                title: Text(
                  'View Profile',
                  style: TextStyle(fontSize: 15 * fontScale),
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
                title: Text(
                  'Logout',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 15 * fontScale,
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
          padding: EdgeInsets.all(16.0 * fontScale),
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
                  padding: EdgeInsets.all(16.0 * fontScale),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 75 * fontScale,
                            height: 75 * fontScale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor, width: 2),
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
                                    'assets/images/default_avatar.png')
                                as ImageProvider,
                              ),
                            ),
                          ),
                          SizedBox(width: 12 * fontScale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 18 * fontScale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4 * fontScale),
                                Text(
                                  "Account No: ${profile['id'] ?? 'N/A'}",
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13 * fontScale),
                                ),
                                SizedBox(height: 6 * fontScale),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10 * fontScale,
                                    vertical: 3 * fontScale,
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
                                      fontSize: 13 * fontScale,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "Balance",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13 * fontScale,
                                ),
                              ),
                              SizedBox(height: 4 * fontScale),
                              Text(
                                "৳ ${profile['balance']?.toStringAsFixed(2) ?? 'N/A'}",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18 * fontScale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 15 * fontScale),
                      ExpansionTile(
                        title: Text(
                          "View Account Details",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16 * fontScale,
                          ),
                        ),
                        children: [
                          _buildDetailTile(context, "NID", profile['nid'], fontScale),
                          _buildDetailTile(
                              context, "Phone", profile['phoneNumber'], fontScale),
                          _buildDetailTile(
                              context, "Address", profile['address'], fontScale),
                          _buildDetailTile(context, "Date of Birth",
                              profile['dateOfBirth'], fontScale,
                              isDate: true),
                          _buildDetailTile(context, "Opening Date",
                              profile['accountOpeningDate'], fontScale,
                              isDate: true),
                          _buildDetailTile(context, "Role",
                              profile['role'] ?? 'User', fontScale),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20 * fontScale),

              // ------------------ Dashboard Buttons ------------------
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0 * fontScale),
                  child: Column(
                    children: [
                      SizedBox(height: 10 * fontScale),

                      // --------- Rows ----------
                      ..._buildDashboardRows(context, fontScale),
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

  // -------------- Reusable Dashboard Rows ------------------
  List<Widget> _buildDashboardRows(BuildContext context, double fontScale) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildDashboardButton(context, "Send Money",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/10614/10614665.png",
                color: Colors.brown,
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferMoneyPage()),
                  );
                }),
          ),
          SizedBox(width: 8 * fontScale),
          Expanded(
            child: _buildDashboardButton(context, "Mobile Recharge",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/7732/7732360.png",
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransferMoneyPage()),
                  );
                }),
          ),
          SizedBox(width: 8 * fontScale),
          Expanded(
            child: _buildDashboardButton(context, "Cash Out",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/8552/8552942.png",
                color: Colors.deepOrange,
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WithdrawPage()),
                  );
                }),
          ),
        ],
      ),
      SizedBox(height: 12 * fontScale),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildDashboardButton(context, "Transactions",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/16993/16993830.png",
                color: Colors.deepOrange,
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WithdrawPage()),
                  );
                }),
          ),
          SizedBox(width: 8 * fontScale),
          Expanded(
            child: _buildDashboardButton(context, "Pay Bill",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/2058/2058414.png",
                color: Colors.black54,
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WithdrawPage()),
                  );
                }),
          ),
          SizedBox(width: 8 * fontScale),
          Expanded(
            child: _buildDashboardButton(context, "Savings",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/12771/12771603.png",
                color: Colors.blueGrey,
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WithdrawPage()),
                  );
                }),
          ),
        ],
      ),
      SizedBox(height: 12 * fontScale),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildDashboardButton(context, "Loan",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/5571/5571405.png",
                color: Colors.green,
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WithdrawPage()),
                  );
                }),
          ),
          SizedBox(width: 8 * fontScale),
          Expanded(
            child: _buildDashboardButton(context, "Education Fee",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/6926/6926264.png",
                color: Colors.blueGrey,
                fontScale: fontScale,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WithdrawPage()),
                  );
                }),
          ),
          SizedBox(width: 8 * fontScale),
          Expanded(
            child: _buildDashboardButton(context, "Logout",
                imageUrl:
                "https://cdn-icons-png.flaticon.com/128/1828/1828479.png",
                color: Colors.red,
                fontScale: fontScale,
                onPressed: () async {
                  await _authService.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                }),
          ),
        ],
      ),
    ];
  }

  // ---------------- Dashboard Button ----------------
  Widget _buildDashboardButton(
      BuildContext context,
      String title, {
        IconData? icon,
        String? imageUrl,
        Color? color,
        required double fontScale,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Theme.of(context).primaryColor,
        padding:
        EdgeInsets.symmetric(vertical: 16 * fontScale, horizontal: 8 * fontScale),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (imageUrl != null)
            Image.network(imageUrl,
                height: 25 * fontScale, width: 25 * fontScale, color: Colors.white)
          else if (icon != null)
            Icon(icon, size: 25 * fontScale, color: Colors.white),
          SizedBox(height: 6 * fontScale),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13 * fontScale, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ---------------- Detail Tile ----------------
  Widget _buildDetailTile(
      BuildContext context,
      String label,
      dynamic value,
      double fontScale, {
        bool isDate = false,
      }) {
    String displayValue = 'N/A';
    if (value != null) {
      displayValue =
      isDate ? value.toString().substring(0, 10) : value.toString();
    }

    return Padding(
      padding:
      EdgeInsets.symmetric(horizontal: 14.0 * fontScale, vertical: 3.0 * fontScale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              fontSize: 14 * fontScale,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14 * fontScale,
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