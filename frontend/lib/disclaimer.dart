import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showDisclaimerPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<String>(
        future: _loadDisclaimerText(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AlertDialog(
              title: const Text('Terms and Conditions'),
              content: SingleChildScrollView(
                child: Text(snapshot.data ?? ''),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          } else {
            return const AlertDialog(
              title: Text('Disclaimer'),
              content: Text('Loading...'),
            );
          }
        },
      );
    },
  );
}

Future<String> _loadDisclaimerText(BuildContext context) async {
  try {
    final disclaimerFile = await rootBundle
        .loadString('assets/BBSVC_Ventura-Youth-Room-Terms.txt');
    return disclaimerFile;
  } catch (e) {
    print('Error loading disclaimer text: $e');
    return 'Error loading disclaimer text';
  }
}
