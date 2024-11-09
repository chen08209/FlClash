import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/clash/clash.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/app.dart';
import 'package:fl_clash/models/ffi.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

typedef UpdatingMap = Map<String, bool>;

class Providers extends StatefulWidget {
  const Providers({
    super.key,
  });

  @override
  State<Providers> createState() => _ProvidersState();
}

class _ProvidersState extends State<Providers> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        globalState.appController.updateProviders();
        final commonScaffoldState =
            context.findAncestorStateOfType<CommonScaffoldState>();
        commonScaffoldState?.actions = [
          IconButton(
            onPressed: () {
              _updateProviders();
            },
            icon: const Icon(
              Icons.sync,
            ),
          )
        ];
      },
    );
  }

  _updateProviders() async {
    final appState = globalState.appController.appState;
    final providers = globalState.appController.appState.providers;
    final updateProviders = providers.map<Future>(
      (provider) async {
        appState.setProvider(
          provider.copyWith(isUpdating: true),
        );
        await clashCore.updateExternalProvider(
          providerName: provider.name,
        );
        appState.setProvider(
          clashCore.getExternalProvider(provider.name),
        );
      },
    );
    await Future.wait(updateProviders);
    await globalState.appController.updateGroupDebounce();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, List<ExternalProvider>>(
      selector: (_, appState) => appState.providers,
      builder: (_, providers, ___) {
        final proxyProviders =
            providers.where((item) => item.type == "Proxy").map(
                  (item) => ProviderItem(
                    provider: item,
                  ),
                );
        final ruleProviders =
            providers.where((item) => item.type == "Rule").map(
                  (item) => ProviderItem(
                    provider: item,
                  ),
                );
        final proxySection = generateSection(
          title: appLocalizations.proxyProviders,
          items: proxyProviders,
        );
        final ruleSection = generateSection(
          title: appLocalizations.ruleProviders,
          items: ruleProviders,
        );
        return generateListView([
          ...proxySection,
          ...ruleSection,
        ]);
      },
    );
  }
}

class ProviderItem extends StatelessWidget {
  final ExternalProvider provider;

  const ProviderItem({
    super.key,
    required this.provider,
  });

  _handleUpdateProvider() async {
    await globalState.safeRun<void>(() async {
      final appState = globalState.appController.appState;
      if (provider.vehicleType != "HTTP") return;
      await globalState.safeRun(() async {
        appState.setProvider(
          provider.copyWith(
            isUpdating: true,
          ),
        );
        final message = await clashCore.updateExternalProvider(
          providerName: provider.name,
        );
        if (message.isNotEmpty) throw message;
      });
      appState.setProvider(
        clashCore.getExternalProvider(provider.name),
      );
    });
    await globalState.appController.updateGroupDebounce();
  }

  _handleSideLoadProvider() async {
    await globalState.safeRun<void>(() async {
      final platformFile = await picker.pickerFile();
      final appState = globalState.appController.appState;
      final bytes = platformFile?.bytes;
      if (bytes == null || provider.path == null) return;
      final file = await File(provider.path!).create(recursive: true);
      await file.writeAsBytes(bytes);
      final providerName = provider.name;
      var message = await clashCore.sideLoadExternalProvider(
        providerName: providerName,
        data: utf8.decode(bytes),
      );
      if (message.isNotEmpty) throw message;
      appState.setProvider(
        clashCore.getExternalProvider(provider.name),
      );
      if (message.isNotEmpty) throw message;
    });
    await globalState.appController.updateGroupDebounce();
  }

  String _buildProviderDesc() {
    final baseInfo = provider.updateAt.lastUpdateTimeDesc;
    final count = provider.count;
    return switch (count == 0) {
      true => baseInfo,
      false => "$baseInfo  ·  $count${appLocalizations.entries}",
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      title: Text(provider.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 4,
          ),
          Text(
            _buildProviderDesc(),
          ),
          const SizedBox(
            height: 4,
          ),
          if (provider.subscriptionInfo != null)
            SubscriptionInfoView(
              subscriptionInfo: provider.subscriptionInfo,
            ),
          const SizedBox(
            height: 8,
          ),
          Wrap(
            runSpacing: 6,
            spacing: 12,
            children: [
              CommonChip(
                avatar: const Icon(Icons.upload),
                label: appLocalizations.upload,
                onPressed: _handleSideLoadProvider,
              ),
              if (provider.vehicleType == "HTTP")
                CommonChip(
                  avatar: const Icon(Icons.sync),
                  label: appLocalizations.sync,
                  onPressed: _handleUpdateProvider,
                ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
        ],
      ),
      trailing: SizedBox(
        height: 48,
        width: 48,
        child: FadeBox(
          child: provider.isUpdating
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(),
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
