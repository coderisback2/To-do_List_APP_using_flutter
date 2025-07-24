import 'package:flutter/material.dart';
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('About This App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'To-Do App v1.0\n\n'
              'Hi, I am Harshit Kumar Singh, a passionate tech enthusiast and a proud student of GLA University. I have created this To-Do app with the aim of helping individuals stay organized, focused, and productive in their daily lives.\n\n'

       ' This is just the beginning! I’m constantly learning and improving, and I plan to bring more powerful features in upcoming updates — like smart suggestions, calendar sync, cloud backup, and AI-powered task organization.\n\n'

        'Your feedback drives this journey forward. So if you have suggestions or ideas, don’t hesitate to reach out!\n\n'

        'Thank you for supporting this project!\n\n'

       ' — Harshit Kumar Singh\n\n'
        'Developer & Student | GLA University '
              '\n\n'
              'Built with ❤️ using Flutter.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
