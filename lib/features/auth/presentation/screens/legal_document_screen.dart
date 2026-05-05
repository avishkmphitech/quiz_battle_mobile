import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_battle/core/theme/app_palette.dart';

enum LegalDocumentKind { terms, privacy }

/// In-app legal copy (replace with hosted URLs later if needed).
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.kind});

  final LegalDocumentKind kind;

  String get _title => switch (kind) {
        LegalDocumentKind.terms => 'Terms & conditions',
        LegalDocumentKind.privacy => 'Privacy policy',
      };

  String get _body => switch (kind) {
        LegalDocumentKind.terms => _termsBody,
        LegalDocumentKind.privacy => _privacyBody,
      };

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: p.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Text(
            _body,
            style: textTheme.bodyMedium?.copyWith(
              color: p.textSecondary,
              height: 1.55,
            ),
          ),
        ),
      ),
    );
  }
}

const String _termsBody = '''
Quiz Battle lets you join quizzes and track your results. By using the app you agree to use it fairly, keep your login details private, and follow any rules shown for each quiz.

We may update these terms from time to time. Continued use after changes means you accept the updated terms.

If something in the app does not work as expected, contact your quiz organiser or support channel for your deployment.
''';

const String _privacyBody = '''
We process the data needed to run Quiz Battle: account details you provide, quiz attempts and scores, and technical data such as app version and device identifiers used for sign-in and optional notifications.

We use this information to authenticate you, deliver quizzes and results, improve reliability, and meet legal obligations. We do not sell your personal data.

You can request access or deletion of your account where your deployment supports it (for example via Delete account in the app). Retention may vary by organiser policy.

For deployment-specific questions (host region, subprocessors, or data export), refer to your organiser’s privacy notice or support contact.
''';
