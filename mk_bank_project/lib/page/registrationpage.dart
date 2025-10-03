import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mk_bank_project/page/loginpage.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as v2;

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
  final TextEditingController cell = TextEditingController();
  final TextEditingController address = TextEditingController();


  final RadioGroupController genderController = RadioGroupController();
  final DateTimeFieldPickerPlatform dob = DateTimeFieldPickerPlatform.material;

  String? selectedGender;

  DateTime? selectedDOB;

  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                TextField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: confirmpassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: cell,
                  decoration: InputDecoration(
                    labelText: "Cell Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),

                SizedBox(height: 20.0),

                TextField(
                  controller: address,
                  decoration: InputDecoration(
                    labelText: "Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.maps_home_work_rounded),
                  ),
                ),

                SizedBox(height: 20.0),

                DateTimeFormField(
                  decoration: const InputDecoration(
                    labelText: "Date of Birth"
                  ),

                  mode: DateTimeFieldPickerMode.date,
                  pickerPlatform: dob,

                  onChanged: (DateTime? value){
                    setState(() {
                      selectedDOB = value;
                    });
                  },

                ),

                SizedBox(height: 20.0),



                // Row(
                //   children: [
                //     Text('Gender'),
                //     Expanded(
                //         child:
                //         Radio<String>(
                //             value: 'Male',
                //           groupValue: selectedGender,
                //         )
                //     )
                //   ],
                // )


                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,


                    children: [
                      const Text("Gender: ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                      v2.RadioGroup(
                        controller: genderController,
                        values: const["Male","Female","other"],
                        indexOfDefault: 0,
                        orientation: RadioGroupOrientation.horizontal,
                        onChanged: (newValue){
                          setState(() {
                            selectedGender = newValue.toString();
                          });
                        },
                      ),
                    ],


                  ),
                ),

                SizedBox(height: 20.0),

                ElevatedButton(
                    onPressed: (){

                    },
                    child: Text(
                      "Registration",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: GoogleFonts.lato().fontFamily
                      ),
                    ),
                  
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                  ),

                ),

                SizedBox(height: 20.0),

                TextButton(
                    onPressed:(){
                    Navigator.push(
                        context, 
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                    },
                    child: Text(
                        "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline
                      ),
                    ),
                ),



              ],
            ),
          ),
        ),
      ),
    );
  }
}
