import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef UpdatingMap = Map<String, bool>;

class ProvidersView extends ConsumerStatefulWidget {
  final SheetType type;

  const ProvidersView({super.key, required this.type});

  @override
  ConsumerState<ProvidersView> createState() => _ProvidersViewState();
}

class _ProvidersViewState extends ConsumerState<ProvidersView> {
  Future<void> _updateProviders() async {
    final providers = ref.read(providersProvider);
    final List<UpdatingMessage> messages = [];
    final updateProviders = providers.map<Future>((provider) async {
      final message = await appController.updateProvider(provider);
      if (message.isNotEmpty) {
        messages.add(UpdatingMessage(label: provider.name, message: message));
      }
    });
    await Future.wait(updateProviders);
    appController.updateGroupsDebounce();
    if (messages.isNotEmpty) {
      globalState.showAllUpdatingMessagesDialog(messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = ref.watch(providersProvider);
    final proxyProviders = providers
        .where((item) => item.type == 'Proxy')
        .map((item) => ProviderItem(provider: item));
    final ruleProviders = providers
        .where((item) => item.type == 'Rule')
        .map((item) => ProviderItem(provider: item));
    final proxySection = generateSection(
      title: appLocalizations.proxyProviders,
      items: proxyProviders,
    );
    final ruleSection = generateSection(
      title: appLocalizations.ruleProviders,
      items: ruleProviders,
    );
    return AdaptiveSheetScaffold(
      actions: [
        IconButton(
          onPressed: () {
            _updateProviders();
          },
          icon: const Icon(Icons.sync),
        ),
      ],
      type: widget.type,
      body: generateListView([...proxySection, ...ruleSection]),
      title: appLocalizations.providers,
    );
  }
}

class ProviderItem extends StatelessWidget {
  final ExternalProvider provider;

  const ProviderItem({super.key, required this.provider});

  Future<void> _handleUpdateProvider() async {
    if (provider.vehicleType != 'HTTP') return;
    await appController.safeRun(() async {
      final message = await appController.updateProvider(provider);
      if (message.isNotEmpty) throw message;
    }, silence: false);
    appController.updateGroupsDebounce();
  }

  Future<void> _handleSideLoadProvider() async {
    await appController.safeRun<void>(() async {
      final platformFile = await picker.pickerFile();
      final bytes = platformFile?.bytes;
      if (bytes == null || provider.path == null) return;
      await File(provider.path!).safeWriteAsBytes(bytes);
      final providerName = provider.name;
      var message = await coreController.sideLoadExternalProvider(
        providerName: providerName,
        data: utf8.decode(bytes),
      );
      if (message.isNotEmpty) throw message;
      appController.setProvider(
        await coreController.getExternalProvider(provider.name),
      );
      if (message.isNotEmpty) throw message;
    });
    appController.updateGroupsDebounce();
  }

  String _buildProviderDesc() {
    final baseInfo = provider.updateAt.lastUpdateTimeDesc;
    final count = provider.count;
    return switch (count == 0) {
      true => baseInfo,
      false => '$baseInfo  ·  $count${appLocalizations.entries}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListItem(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(provider.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          if (provider.updateAt.microsecondsSinceEpoch > 0)
            Text(_buildProviderDesc()),
          const SizedBox(height: 4),
          if (provider.subscriptionInfo != null)
            SubscriptionInfoView(subscriptionInfo: provider.subscriptionInfo),
          const SizedBox(height: 8),
          Wrap(
            runSpacing: 6,
            spacing: 12,
            runAlignment: WrapAlignment.center,
            children: [
              CommonChip(
                avatar: const Icon(Icons.upload),
                label: appLocalizations.upload,
                onPressed: _handleSideLoadProvider,
              ),
              if (provider.vehicleType == 'HTTP')
                Consumer(
                  builder: (_, ref, _) {
                    final isUpdating = ref.watch(
                      isUpdatingProvider(provider.updatingKey),
                    );
                    return isUpdating
                        ? SizedBox(
                            height: 30,
                            width: 30,
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : CommonChip(
                            avatar: const Icon(Icons.sync),
                            label: appLocalizations.sync,
                            onPressed: _handleUpdateProvider,
                          );
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
