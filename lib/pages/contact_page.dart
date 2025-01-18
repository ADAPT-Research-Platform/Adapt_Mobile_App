import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../utils/app_colors.dart';
import '../utils/app_font_sizes.dart';
import '../widgets/main_title.dart';
import '../widgets/sub_title.dart';

class ContactPage extends StatelessWidget {
  final log = Logger('ContactPage');

  ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainTitle(title: 'Contact'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            const Text(
              '''Wenn du feststellst, dass du dich durch deine Ängste sehr unwohl oder beklemmt fühlst und das Gefühl hast nicht alleine zurechtzukommen, findest du hier Telefonnummern an die du dich wenden kannst. Dort bekommst du weitere Unterstützung.''',
              style: TextStyle(fontSize: AppFontSizes.small),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Divider(
              color: AppColors.lightGrey,
              thickness: 2.5,
            ),
            ContactSection(
              title: 'TelefonSeelsorge',
              sections: [
                Section(name: 'Kosten', value: 'kostenfrei'),
                Section(
                  name: 'Tel.',
                  value:
                      '+49 800 111 0 111\n+49 800 111 0 222\n+49 116 123 0 333',
                ),
                Section(name: 'Sprechzeiten', value: 'rund um die Uhr'),
                Section(name: 'Webseite', value: 'www.telefonseelsorge.de'),
              ],
            ),
            const Divider(
              color: AppColors.lightGrey,
              thickness: 2.5,
            ),
            ContactSection(
              title: 'NummergegenKummer',
              sections: [
                Section(name: 'Kosten', value: 'kostenfrei'),
                Section(name: 'Eltern-Telefon', value: '+49 800 111 0 550'),
                Section(
                  name: 'Eltern-Telefon\nSprechzeiten',
                  value:
                      'Mo-Fr – 9.00 bis 17.00 Uhr\nDi und Do – 17.00 bis 19.00 Uhr',
                ),
                Section(name: 'Webseite', value: 'www.nummergegenkummer.de'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Section {
  final String name;
  final String value;

  Section({
    required this.name,
    required this.value,
  });
}

class ContactSection extends StatelessWidget {
  final String title;
  final List<Section> sections;

  const ContactSection({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SubTitle(text: title),
        const SizedBox(height: 8),
        for (var section in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  flex: 2,
                  child: Text(
                    section.name,
                    style: const TextStyle(
                      color: AppColors.fontColor,
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: Text(
                    section.value,
                    style: const TextStyle(
                      color: AppColors.fontColor,
                      fontSize: AppFontSizes.small,
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }
}
