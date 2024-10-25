import 'package:flutter/material.dart';

import '../widgets/app_title_bar.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Contacts'),
      body: Center(child: Text('Contact Page')),
    );
  }
}
