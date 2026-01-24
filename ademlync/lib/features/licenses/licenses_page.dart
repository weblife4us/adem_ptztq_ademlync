import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../oss_licenses.dart';
import '../../utils/app_delegate.dart';
import '../../utils/custom_color_scheme.dart';
import '../../utils/widgets/s_app_bar.dart';
import '../../utils/widgets/s_loading.dart';
import '../../utils/widgets/s_text.dart';
import '../../utils/widgets/smart_body_layout.dart';
import '../../utils/widgets/svg_image.dart';
import 'licenses_page_bloc.dart';

class LicensesPage extends StatefulWidget {
  const LicensesPage({super.key});

  @override
  State<LicensesPage> createState() => _LicensesPageState();
}

class _LicensesPageState extends State<LicensesPage> {
  late final _bloc = BlocProvider.of<LicensesBloc>(context);
  List<Package>? _info;

  @override
  void initState() {
    super.initState();
    _bloc.add(LPBFetchEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _bloc,
      listener: (_, state) {
        if (state is LPBReadyState) {
          setState(() => _info = state.info);
        } else if (state is LPBFailedState) {
          context.pop();
        }
      },
      builder: (_, state) {
        return Scaffold(
          appBar: const SAppBar(text: 'Licenses'),
          body: SmartBodyLayout(
            enableDefaultPadding: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 36.0, bottom: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SText.bodyMedium(
                    'Copyright (c) 2024 Romet Limited. All rights reserved.\n\nPermission to use, copy, modify, and distribute this software and its documentation for internal use within Romet Limited is hereby granted, provided that the above copyright notice and this permission notice appear in all copies of the software and related documentation.\n\nTHIS SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.',
                    softWrap: true,
                  ),
                  const Gap(24.0),
                  const SText.titleMedium('Open Source Licenses'),
                  const Gap(12.0),
                  state is LPBReadyState && _info != null
                      ? Card(
                          child: Container(
                            height: 360.0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: ListView.separated(
                              physics: const ClampingScrollPhysics(),
                              itemBuilder: (_, i) {
                                final o = _info![i];
                                return InkWell(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          _LicensePage(package: o),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: SText.titleMedium(o.name),
                                        ),
                                        const Gap(24.0),
                                        SvgImage(
                                          'arrow-right',
                                          width: 20.0,
                                          height: 20.0,
                                          color: colorScheme.text(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, _) => const Divider(),
                              itemCount: _info!.length,
                            ),
                          ),
                        )
                      : const SLoading(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LicensePage extends StatelessWidget {
  final Package package;

  const _LicensePage({required this.package});

  @override
  Widget build(BuildContext context) {
    final Package(:name, :version, :description, :homepage, :license) = package;

    final text = license
        ?.split('\n')
        .map((line) {
          if (line.startsWith('//')) line = line.substring(2);
          line = line.trim();
          return line;
        })
        .join('\n');

    return Scaffold(
      appBar: const SAppBar(text: 'License'),
      body: SmartBodyLayout(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SText.titleLarge('$name $version'),
              const Gap(12.0),
              Column(
                spacing: 12.0,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description.isNotEmpty)
                    SText.titleMedium(description, softWrap: true),
                  if (homepage != null)
                    InkWell(
                      child: Text(
                        homepage,
                        softWrap: true,
                        style: STextStyle.titleMedium.style.copyWith(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        ),
                      ),
                      onTap: () => launchUrl(Uri.parse(homepage)),
                    ),
                  if (text != null) ...[
                    if (description.isNotEmpty || homepage != null)
                      const Divider(),
                    SText.bodyMedium(text, softWrap: true),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
