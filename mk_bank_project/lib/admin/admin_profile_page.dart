import 'package:flutter/material.dart';
import 'package:mk_bank_project/page/admin_loan_approve_page.dart';
import 'package:mk_bank_project/page/loginpage.dart';
import 'package:mk_bank_project/page/view_all_loan_admin_page.dart';
import 'package:mk_bank_project/page/view_policy_page.dart';
// import 'package:mk_bank_project/page/viewpolicy_page.dart'; // ← 🔹 এই ইমপোর্ট যুক্ত করো
import 'package:mk_bank_project/service/authservice.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AuthService _authService = AuthService();

  AdminPage({super.key, required this.profile});

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value,
      {Color valueColor = Colors.black87}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Colors.blueAccent.shade700, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: valueColor,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent.shade700, size: 28),
          const SizedBox(width: 10),
          Text(title,
              style: GoogleFonts.archivoNarrow(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent.shade700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String baseUrl = "http://localhost:8085/images/user/";
    final String photoName = profile['photo'] ?? '';
    final String? photoUrl = (photoName.isNotEmpty) ? "$baseUrl$photoName" : null;

    final String name = profile['name'] ?? 'Admin User';
    final String email = profile['email'] ?? 'N/A';
    final String phone = profile['phoneNumber'] ?? 'N/A';
    final String dob = _formatDate(profile['dateOfBirth']);
    final String role = profile['role'] ?? 'N/A';
    final bool isActive = profile['active'] ?? false;
    final bool isLocked = profile['lock'] ?? false;
    final bool isEnabled = profile['enabled'] ?? false;
    final String userId = '${profile['id'] ?? 'N/A'}';
    final String statusText = isActive ? 'Active' : 'Inactive';
    final Color statusColor =
    isActive ? Colors.green.shade600 : Colors.red.shade600;

    final Widget profilePictureWidget = Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
        color: Colors.white,
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(photoUrl,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.shield, size: 60, color: Colors.blueGrey))
            : const Icon(Icons.shield, size: 60, color: Colors.blueGrey),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Admin Profile',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(name,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              accountEmail: Text(role, style: GoogleFonts.roboto()),
              currentAccountPicture: profilePictureWidget,
              decoration: const BoxDecoration(color: Colors.blueAccent),
            ),
            ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard Overview'),
                onTap: () => Navigator.pop(context)),
            ListTile(
              leading: const Icon(Icons.create),
              title: const Text('View all loans'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewAllLoansPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.create),
              title: const Text('View Pending Loan'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLoanApprovePage()),
                );
              },
            ),
            ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Manage Employees'),
                onTap: () => Navigator.pop(context)),
            ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Transaction Reports'),
                onTap: () => Navigator.pop(context)),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text('Logout',
                  style: GoogleFonts.roboto(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
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
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(color: Colors.blueAccent.shade700),
              child: Column(
                children: [
                  profilePictureWidget,
                  const SizedBox(height: 15),
                  Text(name,
                      style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25)),
                    child: Text('SYSTEM $role',
                        style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildSectionHeader(
                            'Contact & Personal Info', Icons.person),
                        const Divider(),
                        _buildProfileInfoRow(
                            Icons.email, 'Email Address (Username)', email),
                        _buildProfileInfoRow(Icons.phone, 'Contact Number', phone),
                        _buildProfileInfoRow(
                            Icons.calendar_today, 'Date of Birth (DOB)', dob),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _buildSectionHeader(
                            'Account Security & Status', Icons.lock),
                        const Divider(),
                        _buildProfileInfoRow(
                            Icons.check_circle, 'Account Status', statusText,
                            valueColor: statusColor),
                        _buildProfileInfoRow(Icons.key, 'Account Role', role,
                            valueColor: Colors.deepOrange.shade600),
                        _buildProfileInfoRow(
                            isLocked ? Icons.lock_open : Icons.lock,
                            'Is Locked',
                            isLocked ? 'No' : 'Yes',
                            valueColor: isLocked
                                ? Colors.green.shade600
                                : Colors.red.shade600),
                        _buildProfileInfoRow(
                            isEnabled ? Icons.toggle_on : Icons.toggle_off,
                            'Is Enabled',
                            isEnabled ? 'Yes' : 'No',
                            valueColor: isEnabled
                                ? Colors.green.shade600
                                : Colors.red.shade600),
                        _buildProfileInfoRow(Icons.vpn_key, 'Internal ID', userId),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ Insurance Button (Beautiful Design)
                ElevatedButton.icon(
                  icon: const Icon(Icons.health_and_safety_outlined, size: 26),
                  label: Text(
                    'ইনস্যুরেন্স',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.cyanAccent,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewPolicyPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
