import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/chapter_service.dart';
import '../services/localization_service.dart';
import '../widgets/main_title.dart';
import '../widgets/markdown_builders/header_builder.dart';
import '../widgets/markdown_builders/right_align_text_builder.dart';
import '../widgets/markdown_builders/underline_text_builder.dart';

class SupportPage extends StatelessWidget {
  final log = Logger('SupportPage');
  final ChapterService _sectionService = ChapterService();

  SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainTitle(title: LocalizationService().get('support')),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          _sectionService.fetchChapterContent('pages/contacts/content_${LocalizationService().currentLanguage}.md'),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
          } else if (snapshot.hasError) {
            return Center(child: Text(LocalizationService().get("error_loading_support")));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(LocalizationService().get("no_support")));
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
                          onTapLink: (text, href, title) async {
                            if (href == null) return;

                            final Uri uri = Uri.parse(href);

                            await launchUrl(
                              uri,
                              mode: LaunchMode.platformDefault, // Leaves the decision of how to launch the URL to the platform
                            );
                          }
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