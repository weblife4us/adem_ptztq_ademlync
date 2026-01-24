import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_delegate.dart';
import '../utils/custom_color_scheme.dart';
import '../utils/widgets/s_app_bar.dart';
import '../utils/widgets/s_card.dart';
import '../utils/widgets/s_text.dart';
import '../utils/widgets/smart_body_layout.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SAppBar(text: locale.faqString),
      body: SmartBodyLayout(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 0.0,
        child: SCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (_, i) {
                  final e = _faq.entries.toList()[i];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 4.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SText.titleMedium(e.key, softWrap: true),
                        const Gap(4.0),
                        SText.bodyMedium(
                          e.value,
                          softWrap: true,
                          color: colorScheme.grey,
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, _) {
                  return Divider(color: colorScheme.divider(context));
                },
                itemCount: _faq.entries.length,
              ),
              const Gap(12.0),
              const Divider(),
              const Gap(12.0),
              const SText.titleMedium('CONTACT INFO', softWrap: true),
              const Gap(12.0),
              const SText.bodyMedium(
                'We love hearing from you!',
                softWrap: true,
              ),
              const Gap(8.0),
              const SText.bodyMedium(
                'Send us a message and we\'ll get\nback to you as soon as we can.',
                softWrap: true,
              ),
              const Gap(24.0),
              _HyperlinkText(
                text: 'Email: <g>romet@rometlimited.com</g>',
                onPressed: () => _launch(true),
              ),
              const Gap(8.0),
              _HyperlinkText(
                text: 'Phone: <g>800-387-3201</g>',
                onPressed: () => _launch(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launch(bool isEmail) async {
    final url = Uri(
      scheme: isEmail ? 'mailto' : 'tel',
      path: isEmail ? 'romet@rometlimited.com' : '+1-800-387-3201',
    );
    await launchUrl(url);
  }
}

final _faq = {
  locale.faqQuestion1: locale.faqAnswer1,
  locale.faqQuestion2: locale.faqAnswer2,
  locale.faqQuestion3: locale.faqAnswer3,
  locale.faqQuestion3: locale.faqAnswer4,
  locale.faqQuestion5: locale.faqAnswer5,
  locale.faqQuestion6: locale.faqAnswer6,
  locale.faqQuestion7: locale.faqAnswer7,
  locale.faqQuestion8: locale.faqAnswer8,
  locale.faqQuestion9: locale.faqAnswer9,
  locale.faqQuestion10: locale.faqAnswer10,
};

class _HyperlinkText extends StatelessWidget {
  final String text;
  final void Function() onPressed;

  const _HyperlinkText({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: StyledText(
        text: text,
        style: STextStyle.bodyMedium.style,
        tags: {
          'g': StyledTextTag(
            style: STextStyle.bodyMedium.style.copyWith(color: Colors.blue),
          ),
        },
      ),
    );
  }
}
