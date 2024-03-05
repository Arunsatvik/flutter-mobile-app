import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:login_app/new_signup.dart';
import 'package:login_app/main.dart';
import 'dart:convert';
import 'env.dart';
import 'disclaimer.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController zipCodeController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String? emailError;
  String? passwordError;
  String? zipCodeError;
  String? phonenumberError;
  bool disclaimerChecked = false;
  String? disclaimerError;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: emailController,
                labelText: 'Email*',
                errorText: emailError,
              ),
              _buildTextField(
                controller: passwordController,
                labelText: 'Password*',
                obscureText: true,
                errorText: passwordError,
              ),
              _buildTextField(
                controller: zipCodeController,
                labelText: 'Zip Code*',
                errorText: zipCodeError,
              ),
              _buildTextField(
                controller: phoneNumberController,
                labelText: 'Phone Number*',
                errorText: phonenumberError,
              ),
              _buildDisclaimerCheckbox(),
              ElevatedButton(
                onPressed: () {
                  if (_validateForm()) {
                    _performCheckIn();
                  }
                },
                child: const Text('Sign Up'),
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
    TextInputType? keyboardType,
    bool obscureText = false, // Corrected parameter name
    String? errorText,
    void Function(String)? onChanged,
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
        obscureText: obscureText, // Corrected parameter name
        onChanged: onChanged,
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
      'Email': null,
      'Password': null,
      'Zip_code': null,
      'Phonenumber': null,
      'Disclaimer': null,
    };

    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    RegExp phoneNumberRegex = RegExp(r'^[0-9]{10}$');
    RegExp zipCodeRegex = RegExp(r'^[0-9]{5}$');

    if (emailController.text.isEmpty) {
      errorMap['Email'] = 'Email required';
    } else if (!emailRegex.hasMatch(emailController.text)) {
      errorMap['Email'] = 'Please enter a valid email';
    }
    if (passwordController.text.isEmpty) {
      errorMap['Password'] = 'Password required';
    }
    if (zipCodeController.text.isEmpty) {
      errorMap['Zip_code'] = 'Zip code required';
    } else if (!zipCodeRegex.hasMatch(zipCodeController.text)) {
      errorMap['Zip_code'] = 'Please enter a valid zip code';
    }
    if (phoneNumberController.text.isEmpty) {
      errorMap['Phonenumber'] = 'Phone Number required';
    } else if (!phoneNumberRegex.hasMatch(phoneNumberController.text)) {
      errorMap['Phonenumber'] = 'Please enter a valid phone number';
    }
    if (!disclaimerChecked) {
      errorMap['Disclaimer'] = 'Please view the Disclaimer Text and check-in';
    }

    setState(() {
      emailError = errorMap['Email'];
      passwordError = errorMap['Password'];
      zipCodeError = errorMap['Zip_code'];
      phonenumberError = errorMap['Phonenumber'];
      disclaimerError = errorMap['Disclaimer'];
    });

    return errorMap.values.every((element) => element == null);
  }

  void _resetFormFields() {
    emailController.clear();
    passwordController.clear();
    zipCodeController.clear();
    phoneNumberController.clear();
    setState(() {
      disclaimerChecked = false;
    });
  }

  void _performCheckIn() async {
    Map<String, dynamic> formData = {
      'Email': emailController.text,
      'Password': passwordController.text,
      'Zip_code': zipCodeController.text,
      'phonenumber': phoneNumberController.text,
      'disclaimerChecked': disclaimerChecked,
    };

    try {
      const String apiBaseUrl = Env.apiBaseUrl;
      http.Response profileResponse = await http.post(
        Uri.parse('$apiBaseUrl/signup/userexists'),
        body: jsonEncode(formData),
        headers: {'Content-Type': 'application/json'},
      );

      if (profileResponse.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Success'),
              content: Text('Sign-up successful!'),
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
      } else if (profileResponse.statusCode == 404) {
        _gotoNewStudent(
            'Student Profile Not found \nPlease Create a Student Profile');
      } else if (profileResponse.statusCode == 401) {
        final Map<String, dynamic> errorBody =
            json.decode(profileResponse.body);
        _showErrorDialog('Error: ${errorBody['error']}');
      } else if (profileResponse.statusCode == 409) {
        _showErrorDialog('Unauthorised: Student already Signed up');
      } else {
        _showErrorDialog('Error during Sign Up');
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog('Error during student profile creation or update.');
    }
  }

  void _gotoNewStudent(String message) {
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
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => newSignUpPage(
            email: emailController.text,
            password: passwordController.text,
            zipCode: zipCodeController.text,
            phoneNumber: phoneNumberController.text,
          ),
        ),
      );
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
