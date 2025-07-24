import 'package:flutter/material.dart';

class FollowUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Follow Us')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Follow us on Instagram:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            SelectableText(
              'https://www.instagram.com/iamharshit_70?igsh=ZTdiemhtcHVsM2po',
              style: TextStyle(fontSize: 18, color: Colors.blue),
            ),
            SizedBox(height: 20),
            Text(
              '\n\nCopy the above link and open it in your browser.',
              style: TextStyle(fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }
}
