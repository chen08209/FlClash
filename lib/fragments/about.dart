import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutFragment extends StatelessWidget {
  const AboutFragment({super.key});

  _checkUpdate(BuildContext context) async {
    final commonScaffoldState = context.commonScaffoldState;
    if (commonScaffoldState?.mounted != true) return;
    final data =
        await commonScaffoldState?.loadingRun<Map<String, dynamic>?>(
      request.checkForUpdate,
      title: appLocalizations.checkUpdate,
    );
    globalState.appController.checkUpdateResultHandle(
      data: data,
      handleError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: kMaterialListPadding.copyWith(
        top: 16,
        bottom: 16,
      ),
      children: [
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/launch_icon.png',
                    width: 100,
                    height: 100,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      FutureBuilder<PackageInfo>(
                        future: appPackage.packageInfoCompleter.future,
                        builder: (_, package) {
                          final version = package.data?.version;
                          if (version == null) return Container();
                          return Text(
                            version,
                            style: Theme.of(context).textTheme.labelLarge,
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                appLocalizations.desc,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        ListTile(
          title: Text(appLocalizations.checkUpdate),
          onTap: () {
            _checkUpdate(context);
          },
        ),
        ListTile(
          title: const Text("Telegram"),
          onTap: () {
            launchUrl(
              Uri.parse("https://t.me/+G-veVtwBOl4wODc1"),
            );
          },
          trailing: const Icon(Icons.launch),
        ),
        ListTile(
          title: Text(appLocalizations.project),
          onTap: () {
            launchUrl(
              Uri.parse("https://github.com/$repository"),
            );
          },
          trailing: const Icon(Icons.launch),
        ),
        ListTile(
          title: Text(appLocalizations.core),
          onTap: () {
            launchUrl(
              Uri.parse("https://github.com/chen08209/Clash.Meta/tree/FlClash"),
            );
          },
          trailing: const Icon(Icons.launch),
        ),
      ],
    );
  }
}
