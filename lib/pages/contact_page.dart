import 'package:flutter/material.dart';

import '../utils/app_font_sizes.dart';
import '../widgets/app_title_bar.dart';
import '../utils/app_colors.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTitleBar(title: 'Contact'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            Container(
                padding: const EdgeInsets.only(bottom: 4),
                decoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.lightGrey, width: 2.5))),
                child: const Text(
                  '''Wenn du feststellst, dass du dich durch deine Ängste sehr unwohl oder beklemmt fühlst und das Gefühl hast nicht alleine zurechtzukommen, findest du hier Telefonnummern an die du dich wenden kannst. Dort bekommst du weitere Unterstützung.''',
                  style: TextStyle(fontSize: AppFontSizes.small),
                  textAlign: TextAlign.center,
                )),
            ContactSection(
              title: 'TelefonSeelsorge',
              sections: [
                Section(name: 'Kosten', value: 'kostenfrei'),
                Section(
                    name: 'Tel.',
                    value: '+49 800 111 0 111\n+49 800 111 0 222\n+49 116 123 0 333'),
                Section(name: 'Sprechzeiten', value: 'rund um die Uhr'),
                Section(name: 'Webseite', value: 'www.telefonseelsorge.de'),
              ],
            ),
            Container(
                padding: const EdgeInsets.only(bottom: 10),
                decoration: const BoxDecoration(
                    color: Colors.transparent,
                    border: Border(
                        bottom: BorderSide(
                            color: AppColors.lightGrey, width: 2.5)))
            ),
            ContactSection(
              title: 'NummergegenKummer',
              sections: [
                Section(name: 'Kosten', value: 'kostenfrei'),
                Section(name: 'Eltern-Telefon', value: '+49 800 111 0 550'),
                Section(
                    name: 'Eltern-Telefon\nSprechzeiten',
                    value:
                        'Mo-Fr – 9.00 bis 17.00 Uhr\n Di und Do – 17.00 bis 19.00 Uhr'),
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
        Center(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.darkYellow, // Static text color
              fontSize: AppFontSizes.medium, // Static font size
              fontWeight: FontWeight.bold, // Static font weight
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var section in sections)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120, // Set your fixed width here
                child: Text(
                  '${section.name}',
                  overflow: TextOverflow.ellipsis, // Optional: handle overflow
                  style: const TextStyle(
                    color: AppColors.fontColor, // Static text color
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.bold, // Static font size
                  ),
                ),
              ),
              const Text(':  ',style: TextStyle(
                color: AppColors.fontColor, // Static text color
                fontSize: AppFontSizes.small,
                fontWeight: FontWeight.bold, // Static font size
              ),),
              Expanded(
                  child: Text(
                section.value,
                style: const TextStyle(
                  color: AppColors.fontColor, // Static text color
                  fontSize: AppFontSizes.small, // Static font size
                ),
              )),
            ],
          ),
      ],
    );
  }
}
