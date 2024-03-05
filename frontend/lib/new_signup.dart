import 'package:flutter/material.dart';
import 'package:login_app/disclaimer.dart';
import 'package:login_app/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'env.dart';

class newSignUpPage extends StatefulWidget {
  final String email;
  final String password;
  final String zipCode;
  final String phoneNumber;

  const newSignUpPage({
    Key? key,
    required this.email,
    required this.password,
    required this.zipCode,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  _newSignUpPageState createState() => _newSignUpPageState();
}

class _newSignUpPageState extends State<newSignUpPage> {
  final TextEditingController studentFirstNameController =
      TextEditingController();
  final TextEditingController studentLastNameController =
      TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController alternateEmailController =
      TextEditingController();
  final TextEditingController addressLine1Controller = TextEditingController();
  final TextEditingController addressLine2Controller = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController parentGuardianController =
      TextEditingController();
  final TextEditingController secondaryParentGuardianController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String? studentFirstNameError;
  String? studentLastNameError;
  String? ageError;
  String? emailError;
  String? passwordError;
  String? addressLine1Error;
  String? zipCodeError;
  String? phoneNumberError;
  String? parentGuardianError;
  String? dinnerSelection;
  String? dinnerError;
  bool disclaimerChecked = false;
  String? disclaimerError;

  bool isParentGuardianVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  void _initializeFormFields() {
    emailController.text = widget.email;
    passwordController.text = widget.password;
    zipCodeController.text = widget.zipCode;
    phoneNumberController.text = widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: studentFirstNameController,
                labelText: 'First Name*',
                errorText: studentFirstNameError,
              ),
              _buildTextField(
                controller: studentLastNameController,
                labelText: 'Last Name*',
                errorText: studentLastNameError,
              ),
              _buildTextField(
                controller: ageController,
                labelText: 'Age*',
                keyboardType: TextInputType.number,
                errorText: ageError,
                onChanged: (value) {
                  if (int.tryParse(value) != null) {
                    int age = int.parse(value);
                    setState(() {
                      isParentGuardianVisible = age <= 12;
                    });
                  }
                },
              ),
              _buildTextField(
                controller: emailController,
                labelText: 'Email*',
                errorText: emailError,
                readOnly: true,
              ),
              _buildTextField(
                controller: passwordController,
                labelText: 'Password*',
                obscureText: true,
                errorText: passwordError,
                readOnly: true,
              ),
              _buildTextField(
                controller: alternateEmailController,
                labelText: 'Alternate Email',
              ),
              _buildTextField(
                controller: addressLine1Controller,
                labelText: 'Address Line 1*',
                errorText: addressLine1Error,
              ),
              _buildTextField(
                controller: addressLine2Controller,
                labelText: 'Address Line 2',
              ),
              _buildTextField(
                controller: zipCodeController,
                labelText: 'Zip Code*',
                errorText: zipCodeError,
                readOnly: true,
              ),
              _buildTextField(
                controller: parentGuardianController,
                labelText: 'Parent / Guardian',
                errorText: parentGuardianError,
              ),
              _buildTextField(
                controller: secondaryParentGuardianController,
                labelText: 'Secondary Parent/Guardian',
              ),
              _buildTextField(
                controller: phoneNumberController,
                labelText: 'Phone Number*',
                errorText: phoneNumberError,
                readOnly: true,
              ),
              _buildDisclaimerCheckbox(),
              ElevatedButton(
                onPressed: () {
                  if (_validateForm()) {
                    _performCheckIn();
                  }
                },
                child: const Text('Check In'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? errorText,
    void Function(String)? onChanged,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: errorText != null ? Colors.red : Colors.black,
            ),
          ),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.red),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        readOnly: readOnly,
        style: TextStyle(
          color: errorText != null ? Colors.red : null,
        ),
        validator: (value) {
          if (errorText != null && value!.isEmpty) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  bool _validateForm() {
    Map<String, String?> errorMap = {
      'First Name': null,
      'Last Name': null,
      'Age': null,
      'Email': null,
      'Password': null,
      'Address Line 1': null,
      'Zip Code': null,
      'Phone Number': null,
      'Parent/Guardian': null,
      'Disclaimer': null,
    };
    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    RegExp phoneNumberRegex = RegExp(r'^[0-9]{10}$');
    RegExp zipCodeRegex = RegExp(r'^[0-9]{5}$');

    if (studentFirstNameController.text.isEmpty) {
      errorMap['First Name'] = 'First Name required';
    }
    if (studentLastNameController.text.isEmpty) {
      errorMap['Last Name'] = 'Last Name required';
    }
    if (ageController.text.isEmpty) {
      errorMap['Age'] = 'Age required';
    }
    if (emailController.text.isEmpty) {
      errorMap['Email'] = 'Email required';
    } else if (!emailRegex.hasMatch(emailController.text)) {
      errorMap['Email'] = 'Please enter a valid email';
    }
    if (passwordController.text.isEmpty) {
      errorMap['Password'] = 'Password required';
    }
    if (addressLine1Controller.text.isEmpty) {
      errorMap['Address Line 1'] = 'Address required';
    }
    if (zipCodeController.text.isEmpty) {
      errorMap['Zip Code'] = 'Zip code required';
    } else if (!zipCodeRegex.hasMatch(zipCodeController.text)) {
      errorMap['Zip Code'] = 'Invalid zip code format';
    }
    if (phoneNumberController.text.isEmpty) {
      errorMap['Phone Number'] = 'Phone Number required';
    } else if (!phoneNumberRegex.hasMatch(phoneNumberController.text)) {
      errorMap['Phone Number'] = 'Please enter a valid phone number';
    }
    if (isParentGuardianVisible && parentGuardianController.text.isEmpty) {
      errorMap['Parent/Guardian'] =
          'Parent/Guardian required for students of age 12 and below';
    }
    if (!disclaimerChecked) {
      errorMap['Disclaimer'] = 'Please view the Disclaimer Text and check-in';
    }
    setState(() {
      studentFirstNameError = errorMap['First Name'];
      studentLastNameError = errorMap['Last Name'];
      ageError = errorMap['Age'];
      emailError = errorMap['Email'];
      passwordError = errorMap['Password'];
      parentGuardianError = errorMap['Parent/Guardian'];
      addressLine1Error = errorMap['Address Line 1'];
      zipCodeError = errorMap['Zip Code'];
      phoneNumberError = errorMap['Phone Number'];
      disclaimerError = errorMap['Disclaimer'];
    });

    return errorMap.values.every((element) => element == null);
  }

  void _performCheckIn() async {
    Map<String, dynamic> formData = {
      'student_First_Name': studentFirstNameController.text,
      'student_Last_Name': studentLastNameController.text,
      'Age': ageController.text,
      'Email': emailController.text,
      'Password': passwordController.text,
      'Alternate_Email': alternateEmailController.text,
      'Address_line_1': addressLine1Controller.text,
      'Address_line_2': addressLine2Controller.text,
      'Zip_code': zipCodeController.text,
      'parent_guardian': parentGuardianController.text,
      'secondary_parent_guardian': secondaryParentGuardianController.text,
      'phonenumber': phoneNumberController.text,
      'disclaimerChecked': disclaimerChecked,
    };

    try {
      const String apiBaseUrl = Env.apiBaseUrl;
      http.Response profileResponse = await http.post(
        Uri.parse('$apiBaseUrl/signup/createStudentProfile'),
        body: jsonEncode(formData),
        headers: {'Content-Type': 'application/json'},
      );

      if (profileResponse.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Success'),
              content: Text('Sign-Up successful!'),
            );
          },
        );
        Future.delayed(Duration(seconds: 3), () {
          _resetFormFields();

          // Navigate to StudentCheckInPage
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
            (route) => false, // This removes all routes below MyApp
          );
        });
      } else {
        _showErrorDialog('Error during student profile creation.');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Error during student profile creation.');
    }
  }

  void _resetFormFields() {
    studentFirstNameController.clear();
    studentLastNameController.clear();
    ageController.clear();
    emailController.clear();
    passwordController.clear();
    alternateEmailController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    zipCodeController.clear();
    parentGuardianController.clear();
    secondaryParentGuardianController.clear();
    phoneNumberController.clear();
    setState(() {
      isParentGuardianVisible = false;
      disclaimerChecked = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDisclaimerCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Checkbox(
            value: disclaimerChecked,
            onChanged: (value) {
              setState(() {
                disclaimerChecked = value ?? false;
              });
            },
          ),
          Expanded(
            // Add Expanded widget
            child: GestureDetector(
              onTap: () {
                showDisclaimerPopup(context);
              },
              child: Text(
                'By clicking below, the user confirms that the information provided is true and correct and affirms:\n\n'
                'I have read and understand the above statements. I understand the application process and my responsibilities as a BBSVC youth participant as defined by these statements. '
                'I also understand that any breach of this agreement may result in being asked to leave the BBSVC@Ventura Youth Room or the ongoing activities, and I may not return without BBSVC approval. '
                'Further, I understand that any breach of this agreement may result in my being asked to permanently leave the program.*',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: disclaimerError != null ? Colors.red : Colors.blue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
