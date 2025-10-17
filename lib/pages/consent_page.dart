import 'package:adapt/enums/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:logging/logging.dart';

import '../services/chapter_service.dart';
import '../services/localization_service.dart';
import '../utils/app_keys.dart';
import '../widgets/main_title.dart';
import '../widgets/markdown_builders/header_builder.dart';
import '../widgets/markdown_builders/right_align_text_builder.dart';
import '../widgets/markdown_builders/underline_text_builder.dart';

class ConsentPage extends StatelessWidget {
  final log = Logger('ConsentPage');
  final ChapterService _sectionService = ChapterService();

  ConsentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MainTitle(
            title: 'Consent',
            leadingIcon: Icons.arrow_back_ios_rounded,
            onIconPressed: () {
              mainNavigator.currentState!.pop(); //Go Backwards
            }),
        body: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _sectionService.fetchChapterContent('pages/consent/content_${LocalizationService().getSelectedLanguage().code}.md'),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColorDark));
            } else if (snapshot.hasError) {
              return Center(child: Text(LocalizationService().get("error_loading_consent")));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text(LocalizationService().get("no_consent")));
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
