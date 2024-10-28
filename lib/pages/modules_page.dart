import 'package:flutter/material.dart';

import '../widgets/app_title_bar.dart';

class ModulesPage extends StatelessWidget {
  const ModulesPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Module X', leadingIcon: Icons.arrow_back_ios,),
      body: Center(child: Text('ModulesPage Page')),
    );
  }
}
