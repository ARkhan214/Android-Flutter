import 'package:flutter/material.dart';
import 'package:mk_bank_project/page/loginpage.dart';
import 'package:mk_bank_project/page/registrationpage.dart';
// import 'package:mk_bank_project/page/transaction_statement_page_for_employee.dart';
import 'package:mk_bank_project/service/authservice.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:animations/animations.dart';

class EmployeePage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final AuthService _authService = AuthService();

  EmployeePage({super.key, required this.profile});

  // Date Formatting Function
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'N/A';
    }
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMMM, yyyy').format(date);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  // Info Row Widget - Using Google Fonts
  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: Colors.indigo.shade700, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget to create clear section headers - Using Google Fonts
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent.shade700, size: 28),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.archivoNarrow(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Animated Profile Card
  Widget _buildProfileHeaderCard({
    required String name,
    required String position,
    required String status,
    required Color statusColor,
    required String employeeId,
    required Widget profilePicture,
  }) {
    // Accepts the animated picture

    // Using OpenContainer for a neat reveal of the whole header
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 600),
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      closedElevation: 8,
      closedColor: Colors.white,
      closedBuilder: (context, action) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            profilePicture, // Animated Picture
            const SizedBox(height: 20),
            Text(
              name,
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              position,
              style: GoogleFonts.raleway(
                fontSize: 18,
                color: Colors.deepOrange.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Employee ID: $employeeId',
              style: GoogleFonts.roboto(
                fontSize: 15,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: statusColor, width: 1.5),
              ),
              child: Text(
                'Status: $status',
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
      openBuilder:
          (context, action) => // Simple Modal for full detail view
          Scaffold(
            appBar: AppBar(title: Text('${name}\'s Details')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    profilePicture,
                    const SizedBox(height: 20),
                    Text(
                      'Full Profile View for ${name}',
                      style: GoogleFonts.poppins(fontSize: 24),
                    ),
                    // You can add more detailed info here if needed
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Data Extraction
    const String baseUrl = "http://localhost:8085/images/employee/";
    final String photoName = profile['photo'] ?? '';
    final String? photoUrl = (photoName.isNotEmpty)
        ? "$baseUrl$photoName"
        : null;
    final String name = profile['name'] ?? 'N/A';
    final String position = profile['position'] ?? 'N/A';
    final String nid = profile['nid'] ?? 'N/A';
    final String phone = profile['phoneNumber'] ?? 'N/A';
    final String address = profile['address'] ?? 'N/A';
    final double salary = profile['salary'] is num
        ? profile['salary'].toDouble()
        : 0.0;
    final String doj = _formatDate(profile['dateOfJoining']);
    final String dob = _formatDate(profile['dateOfBirth']);
    final String retirementDate = _formatDate(profile['retirementDate']);
    final String status = profile['status'] ?? 'N/A';
    final String role = profile['role'] ?? 'N/A';
    final String userId = '${profile['userId'] ?? 'N/A'}';
    final String employeeId = '${profile['id'] ?? 'N/A'}';
    final Color statusColor = status == 'ACTIVE'
        ? Colors.green.shade600
        : Colors.red.shade600;

    // Profile Picture Widget (Used in the header)
    final Widget profilePictureWidget = Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blueAccent.shade700, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
        color: Colors.white,
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                width: 120,
                height: 120,
                // Lottie for Error/Placeholder
                errorBuilder: (context, error, stackTrace) => Lottie.asset(
                  'assets/lottie/loading_animation.json',
                  // You need to add this asset
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.person_4, size: 60, color: Colors.blueGrey),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade200, // Slightly lighter background
      appBar: AppBar(
        title: Text(
          'Employee Profile',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0, // Removed elevation for a flat, modern look
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer is kept simple
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // UserAccountsDrawerHeader... (Drawer content remains the same)
            UserAccountsDrawerHeader(
              accountName: Text(name),
              accountEmail: Text(position),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: photoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          width: 90,
                          height: 90,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.blueGrey,
                              ),
                        ),
                      )
                    : const Icon(Icons.person, size: 50),
              ),
              decoration: const BoxDecoration(color: Colors.blueAccent),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),

            ListTile(
              leading: const Icon(Icons.create),
              title: const Text('Create Account'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Registration()),
                );
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.create),
            //   title: const Text('Transaction Statement'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const TransactionStatementPageForEmployee()),
            //     );
            //   },
            // ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.redAccent,
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

      // Changed to CustomScrollView for smooth scrolling (Sliver Effect)
      body: CustomScrollView(
        slivers: <Widget>[
          // SliverToBoxAdapter for the main header (Profile Picture, Name, Status)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildProfileHeaderCard(
                name: name,
                position: position,
                status: status,
                statusColor: statusColor,
                employeeId: employeeId,
                profilePicture: profilePictureWidget,
              ),
            ),
          ),

          // Sliver Padding for the main Info Card
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 30.0,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Main Info Card
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // --- Identity and System Info ---
                        _buildSectionHeader(
                          'System & Identity Info',
                          Icons.fingerprint,
                        ),
                        _buildProfileInfoRow(
                          Icons.person_pin,
                          'Employee ID',
                          employeeId,
                        ),
                        _buildProfileInfoRow(
                          Icons.lock_person,
                          'Access Role',
                          role,
                        ),
                        _buildProfileInfoRow(
                          Icons.person_outline,
                          'System User ID',
                          userId,
                        ),

                        const Divider(height: 30),

                        // --- Contact Details ---
                        _buildSectionHeader(
                          'Contact & Address',
                          Icons.contact_mail,
                        ),
                        _buildProfileInfoRow(
                          Icons.phone,
                          'Contact Number',
                          phone,
                        ),
                        _buildProfileInfoRow(
                          Icons.location_on,
                          'Current Address',
                          address,
                        ),
                        _buildProfileInfoRow(
                          Icons.credit_card,
                          'National ID (NID)',
                          nid,
                        ),

                        const Divider(height: 30),

                        // --- Work & Financial Details ---
                        _buildSectionHeader('Employment Details', Icons.work),
                        _buildProfileInfoRow(
                          Icons.money,
                          'Monthly Salary',
                          NumberFormat.currency(
                            locale: 'bn_BD',
                            symbol: '৳',
                          ).format(salary),
                        ),
                        _buildProfileInfoRow(
                          Icons.date_range,
                          'Date of Joining',
                          doj,
                        ),
                        _buildProfileInfoRow(
                          Icons.exit_to_app,
                          'Target Retirement Date',
                          retirementDate,
                        ),
                        _buildProfileInfoRow(
                          Icons.calendar_today,
                          'Date of Birth (DOB)',
                          dob,
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
