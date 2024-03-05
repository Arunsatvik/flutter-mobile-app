import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:login_app/disclaimer.dart';
import 'package:login_app/homepage.dart';
import 'signup_page.dart';
import 'env.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? emailError;
  String? passwordError;
  bool disclaimerChecked = false;
  String? disclaimerError;

  Future<void> _handleLogin(BuildContext context) async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      print('Permission denied');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      const String apiBaseUrl = Env.apiBaseUrl;
      final Uri loginUrl = Uri.parse('$apiBaseUrl/auth/login');

      final http.Response response = await http.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
          'disclaimerChecked': disclaimerChecked,
          'latitude': position.latitude.toString(),
          'longitude': position.longitude.toString(),
        }),
      );

      if (response.statusCode == 200) {
        // Login successful
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Login failed
        final Map<String, dynamic> errorBody = json.decode(response.body);
        // Display an error message or handle the login failure appropriately
        _showErrorDialog(context, 'Error', 'Error: ${errorBody['error']}');
      }
    } catch (e) {
      print('Error getting location: $e');
      _showErrorDialog(context, 'Error', 'Error: $e');
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check In")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
              _buildDisclaimerCheckbox(),
              ElevatedButton(
                onPressed: () {
                  if (_validateForm()) {
                    _handleLogin(context);
                  }
                },
                child: const Text('Check In'),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Navigate to the signup page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Signup",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateForm() {
    Map<String, String?> errorMap = {
      'Email': null,
      'Password': null,
      'Disclaimer': null,
    };

    RegExp emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');

    if (emailController.text.isEmpty) {
      errorMap['Email'] = 'Email required';
    } else if (!emailRegex.hasMatch(emailController.text)) {
      errorMap['Email'] = 'Please enter a valid email';
    }
    if (passwordController.text.isEmpty) {
      errorMap['Password'] = 'Password required';
    }
    if (!disclaimerChecked) {
      errorMap['Disclaimer'] = 'Please view the Disclaimer Text and check-in';
    }

    setState(() {
      emailError = errorMap['Email'];
      passwordError = errorMap['Password'];
      disclaimerError = errorMap['Disclaimer'];
    });

    return errorMap.values.every((element) => element == null);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
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
        obscureText: obscureText,
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
