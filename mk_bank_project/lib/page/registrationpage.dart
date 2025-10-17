import 'dart:convert';
import 'dart:io';

// import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart'
//     hide Uint8List;

import 'package:date_field/date_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:mk_bank_project/page/loginpage.dart';
import 'package:mk_bank_project/service/authservice.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as v2;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmpassword = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController address = TextEditingController();

  final RadioGroupController genderController = RadioGroupController();
  final DateTimeFieldPickerPlatform dob = DateTimeFieldPickerPlatform.material;

  final TextEditingController nid = TextEditingController();

  //TextFild
  // final TextEditingController accountType = TextEditingController();
  // Dropdown options
  final List<String> accountTypes = [
    'SAVINGS',
    'CURRENT',
    'STUDENT',
    'BUSINESS',
  ];

  final TextEditingController balance = TextEditingController();
  final DateTimeFieldPickerPlatform accountOpeningDate =
      DateTimeFieldPickerPlatform.material;

  final String baseUrl = "http://localhost:8085";

  String? selectedGender;

  DateTime? selectedDOB;
  DateTime? selectedOpeningDate;

  // Selected value For AccountTypeDropDown
  String? selectedType;

  XFile? selectedImage;
  Uint8List? webImage;

  final ImagePicker _picker = ImagePicker();

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Body Part Start=========
      // body: Padding(
      //   padding: EdgeInsets.all(16.0),
      //   child: SingleChildScrollView(
      //     child: Form(
      //       key: _formkey,
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //
      //         children: [
      //           TextField(
      //             controller: name,
      //             decoration: InputDecoration(
      //               labelText: "Full Name",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.person),
      //             ),
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           TextField(
      //             controller: email,
      //             decoration: InputDecoration(
      //               labelText: "Email",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.alternate_email),
      //             ),
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           TextField(
      //             controller: password,
      //             decoration: InputDecoration(
      //               labelText: "Password",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.lock),
      //             ),
      //             obscureText: true,
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           TextField(
      //             controller: confirmpassword,
      //             decoration: InputDecoration(
      //               labelText: "Confirm Password",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.lock),
      //             ),
      //             obscureText: true,
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           TextField(
      //             controller: phoneNumber,
      //             decoration: InputDecoration(
      //               labelText: "Cell Number",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.phone),
      //             ),
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           TextField(
      //             controller: address,
      //             decoration: InputDecoration(
      //               labelText: "Address",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.maps_home_work_rounded),
      //             ),
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           DateTimeFormField(
      //             decoration: const InputDecoration(labelText: "Date of Birth"),
      //
      //             mode: DateTimeFieldPickerMode.date,
      //             pickerPlatform: dob,
      //
      //             onChanged: (DateTime? value) {
      //               setState(() {
      //                 selectedDOB = value;
      //               });
      //             },
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           //=======================
      //           TextField(
      //             controller: nid,
      //             decoration: InputDecoration(
      //               labelText: "NID Number",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.credit_card),
      //             ),
      //           ),
      //
      //           SizedBox(height: 20.0),
      //           //Value pass by Textfild
      //           // TextField(
      //           //   controller: accountType,
      //           //   decoration: InputDecoration(
      //           //     labelText: "Account Type (e.g. SAVINGS/CURRENT)",
      //           //     border: OutlineInputBorder(),
      //           //     prefixIcon: Icon(Icons.account_balance),
      //           //   ),
      //           // ),
      //           //Value pass by DropDownFild
      //           DropdownButtonFormField<String>(
      //             value: selectedType,
      //             decoration: InputDecoration(
      //               labelText: "Account Type",
      //               border: OutlineInputBorder(
      //                 borderRadius: BorderRadius.circular(12),
      //               ),
      //               prefixIcon: const Icon(Icons.account_balance),
      //             ),
      //             items: accountTypes.map((type) {
      //               return DropdownMenuItem(value: type, child: Text(type));
      //             }).toList(),
      //             onChanged: (value) {
      //               setState(() {
      //                 selectedType = value;
      //               });
      //             },
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           TextField(
      //             controller: balance,
      //             decoration: InputDecoration(
      //               labelText: "Initial Deposit (৳)",
      //               border: OutlineInputBorder(),
      //               prefixIcon: Icon(Icons.attach_money),
      //             ),
      //             keyboardType: TextInputType.number,
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           DateTimeFormField(
      //             decoration: const InputDecoration(
      //               labelText: "Account Opening Date",
      //             ),
      //
      //             mode: DateTimeFieldPickerMode.date,
      //             pickerPlatform: accountOpeningDate,
      //
      //             onChanged: (DateTime? value) {
      //               setState(() {
      //                 selectedOpeningDate = value;
      //               });
      //             },
      //           ),
      //
      //           //========================
      //           SizedBox(height: 20.0),
      //
      //           TextButton.icon(
      //             icon: Icon(Icons.image),
      //             label: Text('Upload Image'),
      //             onPressed: pickImage,
      //           ),
      //
      //           if (kIsWeb && webImage != null)
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Image.memory(
      //                 webImage!,
      //                 height: 100,
      //                 width: 100,
      //                 fit: BoxFit.cover,
      //               ),
      //             )
      //           else if (!kIsWeb && selectedImage != null)
      //             Padding(
      //               padding: const EdgeInsets.all(8.0),
      //               child: Image.file(
      //                 File(selectedImage!.path),
      //                 height: 100,
      //                 width: 100,
      //                 fit: BoxFit.cover,
      //               ),
      //             ),
      //
      //           SizedBox(height: 20.0),
      //
      //           ElevatedButton(
      //             onPressed: () {
      //               _register();
      //             },
      //             child: Text(
      //               "Registration",
      //               style: TextStyle(
      //                 fontWeight: FontWeight.w600,
      //                 fontFamily: GoogleFonts.lato().fontFamily,
      //               ),
      //             ),
      //             style: ElevatedButton.styleFrom(
      //               backgroundColor: Colors.blueAccent,
      //               foregroundColor: Colors.white,
      //             ),
      //           ),
      //
      //           SizedBox(height: 20.0),
      //
      //           TextButton(
      //             onPressed: () {
      //               Navigator.push(
      //                 context,
      //                 MaterialPageRoute(builder: (context) => LoginPage()),
      //               );
      //             },
      //             child: Text(
      //               "Login",
      //               style: TextStyle(
      //                 color: Colors.blue,
      //                 decoration: TextDecoration.underline,
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      body: Padding(
        padding: EdgeInsets.all(20.0), // Slightly increased padding
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              // Fields take up full width
              children: [
                // Design element: A stylish title
                const Text(
                  "User Registration",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5), // Darker shade near BlueAccent
                  ),
                ),
                SizedBox(height: 30.0),

                // Full Name
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Rounded corners
                    ),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF1E88E5)),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Email
                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.alternate_email,
                      color: Color(0xFF1E88E5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Password
                TextField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF1E88E5)),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20.0),

                // Confirm Password
                TextField(
                  controller: confirmpassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF1E88E5)),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20.0),

                // Cell Number
                TextField(
                  controller: phoneNumber,
                  decoration: InputDecoration(
                    labelText: "Cell Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF1E88E5)),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Address
                TextField(
                  controller: address,
                  decoration: InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.maps_home_work_rounded,
                      color: Color(0xFF1E88E5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                  maxLines: 2, // Increased line count for address
                ),

                SizedBox(height: 20.0),

                // Date of Birth
                DateTimeFormField(
                  decoration: InputDecoration(
                    labelText: "Date of Birth",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.calendar_today,
                      color: Color(0xFF1E88E5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: dob,
                  onChanged: (DateTime? value) {
                    setState(() {
                      selectedDOB = value;
                    });
                  },
                ),

                SizedBox(height: 20.0),

                // NID Number
                TextField(
                  controller: nid,
                  decoration: InputDecoration(
                    labelText: "NID Number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: Color(0xFF1E88E5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                ),

                SizedBox(height: 20.0),

                // Account Type (Dropdown)
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: "Account Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10.0,
                      ), // Consistent rounded corners
                    ),
                    prefixIcon: const Icon(
                      Icons.account_balance,
                      color: Color(0xFF1E88E5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                  items: accountTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                ),

                SizedBox(height: 20.0),

                // Initial Deposit (Balance)
                TextField(
                  controller: balance,
                  decoration: InputDecoration(
                    labelText: "Initial Deposit (৳)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Color(0xFF1E88E5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),

                SizedBox(height: 20.0),

                // Account Opening Date
                DateTimeFormField(
                  decoration: InputDecoration(
                    labelText: "Account Opening Date",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: Icon(
                      Icons.date_range,
                      color: Color(0xFF1E88E5),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 18.0,
                      horizontal: 15.0,
                    ),
                  ),
                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: accountOpeningDate,
                  onChanged: (DateTime? value) {
                    setState(() {
                      selectedOpeningDate = value;
                    });
                  },
                ),

                SizedBox(height: 20.0),

                // Image Upload Section (Container Styling Added)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Column(
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.upload_file, color: Color(0xFF1E88E5)),
                        label: Text(
                          'Upload Profile Photo',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: pickImage,
                      ),

                      // Image Display Logic (unchanged)
                      if (kIsWeb && webImage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.memory(
                              webImage!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (!kIsWeb && selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.file(
                              File(selectedImage!.path),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 30.0),
                // Extra space above the registration button

                // Registration Button
                ElevatedButton(
                  onPressed: () {
                    _register();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1E88E5),
                    // Primary action color
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    // Increased button padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 4, // Added slight elevation
                  ),
                  child: Text(
                    "Registration",
                    style: TextStyle(
                      fontWeight: FontWeight.w700, // Increased font weight
                      fontSize: 18,
                      // GoogleFonts.lato().fontFamily is maintained as before
                    ),
                  ),
                ),

                SizedBox(height: 20.0),
                //For Back Screen
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                //   child: const Text('Go Back'),
                // ),

                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    shadowColor: Colors.greenAccent,
                  ),
                ),


                SizedBox(height: 20.0),

                // Login Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
                    style: TextStyle(
                      color: Color(0xFF1E88E5),
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      //Body Part End=========
    );
  }

  Future<void> pickImage() async {
    if (kIsWeb) {
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          webImage = pickedImage;
        });
      }
    } else {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }
  }

  Future<void> pickeImage() async {
    if (kIsWeb) {
      var pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          webImage = pickedImage;
        });
      }
    } else {
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedImage != null) {
        setState(() {
          selectedImage = pickedImage;
        });
      }
    }
  }

  void _register() async {
    if (_formkey.currentState!.validate()) {
      if (password.text != confirmpassword.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Password do not match!!!')));
        return;
      }

      if (kIsWeb) {
        if (webImage == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Please select an image.')));
          return;
        }
      }

      final user = {
        "name": name.text,
        "email": email.text,
        "phoneNumber": phoneNumber.text,
        "password": password.text,
        "dateOfBirth": selectedDOB?.toIso8601String() ?? "",
      };

      final account = {
        "name": name.text,
        // "email":email.text,
        "phoneNumber": phoneNumber.text,
        // "gender":selectedGender?? "other",
        "address": address.text,
        "dateOfBirth": selectedDOB?.toIso8601String() ?? "",
        "nid": nid.text,
        // "accountType": accountType.text,
        "accountType": selectedType ?? "", // dropdown
        "balance": double.tryParse(balance.text) ?? 0.0,
        "accountOpeningDate": selectedOpeningDate?.toIso8601String() ?? "",
        "user": user,
        "role": "USER",
      };

      final apiService = AuthService();

      bool success = false;

      if (kIsWeb && webImage != null) {
        success = await apiService.registerAccount(
          user: user,
          account: account,
          photoByte: webImage!,
        );
      } else if (selectedImage != null) {
        success = await apiService.registerAccount(
          user: user,
          account: account,
          photofile: File(selectedImage!.path),
        );
      }

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Registration Successful')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {}
    }
  }

  //last
}
