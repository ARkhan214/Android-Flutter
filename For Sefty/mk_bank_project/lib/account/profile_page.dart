import 'package:flutter/material.dart';
import 'package:mk_bank_project/entity/profile_model.dart';
import '../service/authservice.dart';

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

  @override
  Widget build(BuildContext context) {
    final String baseUrl = "http://localhost:8085/images/user/";

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found.'));
          }

          final profile = snapshot.data!;

          // Photo URL logic
          final String? photoName = profile.photo;
          final String? photoUrl = (photoName != null && photoName.isNotEmpty)
              ? "$baseUrl$photoName"
              : null;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Circle Avatar with shadow & border
                // Container(
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black26,
                //         blurRadius: 8,
                //         offset: Offset(0, 4),
                //       ),
                //     ],
                //     border: Border.all(color: Colors.purple, width: 3),
                //   ),
                //   child: CircleAvatar(
                //     radius: 60,
                //     backgroundColor: Colors.grey[200],
                //     backgroundImage: (photoUrl != null)
                //         ? NetworkImage(photoUrl)
                //         : const AssetImage('assets/images/default_avatar.png')
                //               as ImageProvider,
                //   ),
                // ),


                // Fixed Photo Part: Circular, shadow, border, proper fit
                // Container(
                //   width: 120,
                //   height: 120,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     border: Border.all(color: Colors.purple, width: 3),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black26,
                //         blurRadius: 8,
                //         offset: Offset(0, 4),
                //       ),
                //     ],
                //     image: DecorationImage(
                //       image: (photoUrl != null)
                //           ? NetworkImage(photoUrl)
                //           : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                //       fit: BoxFit.cover, // <-- ensures zoomed image fits properly
                //     ),
                //   ),
                // ),


                // Fixed Photo Part: proper circular & zoom
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: (photoUrl != null)
                          ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover, // <-- fixes zoom
                        width: 120,
                        height: 120,
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

                const SizedBox(height: 20),

                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text("Email: ${profile.email}"),
                Text("Phone: ${profile.phoneNumber}"),
                Text("Role: ${profile.role}"),
                Text("Active: ${profile.active}"),
                Text("Enabled: ${profile.enabled}"),
                Text("Date of Birth: ${profile.dateOfBirth.split("T")[0]}"),
              ],
            ),
          );
        },
      ),
    );
  }
}
