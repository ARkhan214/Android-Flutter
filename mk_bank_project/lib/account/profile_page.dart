import 'package:flutter/material.dart';
import 'package:mk_bank_project/entity/profile_model.dart';
import '../service/authservice.dart';

// ----------------------------------------------------------------------
// কাস্টম থিম কালারগুলি সংজ্ঞায়িত করা হলো (আগের উত্তর থেকে)
// ----------------------------------------------------------------------

// Dark Teal (Banking Look)
const int _primaryValue = 0xFF004D40;
const MaterialColor primaryColor = MaterialColor(
  _primaryValue,
  <int, Color>{
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
  },
);
// Light Red/Coral for accent or status indicators
const Color accentColor = Color(0xFFE57373);

// ----------------------------------------------------------------------

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  late Future<Profile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _authService.fetchUserProfile();
  }

  // ডেটা ডিসপ্লে করার জন্য একটি কাস্টম উইজেট তৈরি করা হলো
  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
      trailing: Text(
        value.isEmpty ? 'N/A' : value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ মনে রাখবেন, এই বেস ইউআরএলটি শুধুমাত্র লোকালহোস্টের জন্য।
    // লাইভ অ্যাপে ব্যবহারের জন্য এটিকে পরিবর্তন করতে হবে।
    final String baseUrl = "http://localhost:8085/images/user/";

    return Scaffold(
      backgroundColor: Colors.grey.shade100, // হালকা ব্যাকগ্রাউন্ড
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0, // প্রোফাইলের সাথে মিশে যাওয়ার জন্য
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found.'));
          }

          final profile = snapshot.data!;

          // Photo URL logic
          final String? photoName = profile.photo;
          final String? photoUrl = (photoName != null && photoName.isNotEmpty)
              ? "$baseUrl$photoName"
              : null;

          // Date Formatting
          final String dob = profile.dateOfBirth.split("T")[0];

          // Status colors
          final Color statusColor = profile.enabled ? primaryColor.shade600 : accentColor;
          final String statusText = profile.enabled ? "Account Enabled" : "Account Disabled";

          return Column(
            children: [
              // 1. Header/Photo Section (Top colored area)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 10, bottom: 40),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Photo Part
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4), // সাদা রঙের বর্ডার
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: (photoUrl != null)
                              ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover, // ✅ fixes zoom
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/default_avatar.png',
                                fit: BoxFit.cover,
                              );
                            },
                          )
                              : Image.asset(
                            'assets/images/default_avatar.png',
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Details Section (Scrollable)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Status Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          leading: Icon(
                            profile.enabled ? Icons.check_circle_outline : Icons.cancel_outlined,
                            color: statusColor,
                            size: 30,
                          ),
                          title: const Text("Account Status", style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Personal Information Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              _buildDetailRow(Icons.phone, "Phone Number", profile.phoneNumber ?? '', primaryColor.shade400),
                              const Divider(indent: 16, endIndent: 16, height: 0),
                              _buildDetailRow(Icons.cake, "Date of Birth", dob, primaryColor.shade400),
                              const Divider(indent: 16, endIndent: 16, height: 0),
                              _buildDetailRow(Icons.work, "User Role", profile.role, primaryColor.shade400),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Account Information Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              _buildDetailRow(Icons.credit_card, "User ID", profile.id?.toString() ?? '', primaryColor.shade400),
                              const Divider(indent: 16, endIndent: 16, height: 0),
                              _buildDetailRow(Icons.verified_user, "Active Session", profile.active.toString() == 'true' ? 'Yes' : 'No', primaryColor.shade400),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Action Button (Example)
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Profile এডিট করার ফাংশনালিটি যোগ করুন
                        },
                        icon: const Icon(Icons.edit, size: 24, color: Colors.white),
                        label: const Text(
                          "Edit Profile",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                        ),
                      ),

                      SizedBox(height: 5,),
                      ElevatedButton(
                        onPressed: () {
                          // এই ফাংশনটি আপনাকে আগের স্ক্রিনে ফিরিয়ে নিয়ে যাবে
                          Navigator.pop(context);
                        },
                        child: const Text('Go Back'),
                      ),

                      SizedBox(height: 5,),
                      ElevatedButton(
                        onPressed: () => print('Clicked!'),
                        child: const Text('Submit'),
                      )

                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}