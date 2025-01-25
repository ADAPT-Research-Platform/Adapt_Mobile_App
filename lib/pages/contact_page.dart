import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';

import '../services/chapter_service.dart';
import '../services/localization_service.dart';
import '../utils/app_colors.dart';
import '../widgets/main_title.dart';
import '../widgets/markdown_builders/header_builder.dart';
import '../widgets/markdown_builders/right_align_text_builder.dart';
import '../widgets/markdown_builders/underline_text_builder.dart';

class ContactPage extends StatelessWidget {
  final log = Logger('ContactPage');
  final ChapterService _sectionService = ChapterService();

  ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(title: LocalizationService().get('contacts')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _sectionService.fetchChapterContent('pages/contacts/content_${LocalizationService().currentLanguage}.md'),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkYellow));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading content!"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No content available!"));
          }

          // Extract data
          final String markdownContent = snapshot.data![0];

          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                        child: MarkdownBody(
                          data: markdownContent,
                          inlineSyntaxes: [UnderlineSyntax(), RightAlignSyntax()],
                          selectable: false,
                          builders: <String, MarkdownElementBuilder>{
                            'h3': CenteredHeaderBuilder()
                          },
                        ),
                      ),
                  ),
                ],
              ));
        },
      )
    );
  }
}