import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/core.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef UpdatingMap = Map<String, bool>;

class ProvidersView extends ConsumerStatefulWidget {
  const ProvidersView({super.key});

  @override
  ConsumerState<ProvidersView> createState() => _ProvidersViewState();
}

class _ProvidersViewState extends ConsumerState<ProvidersView> {
  Future<void> _updateProviders() async {
    final ref = globalState.container;
    final providers = ref.read(providersProvider);
    final List<UpdatingMessage> messages = [];
    final updateProviders = providers.map<Future>((provider) async {
      final message = await ref
          .read(proxiesActionProvider.notifier)
          .updateProvider(provider);
      if (message.isNotEmpty) {
        messages.add(UpdatingMessage(label: provider.name, message: message));
      }
    });
    await Future.wait(updateProviders);
    ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
    if (messages.isNotEmpty) {
      globalState.showAllUpdatingMessagesDialog(messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = context.appLocalizations;
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
      actions: [IconButtonData(icon: Icons.sync, onPressed: _updateProviders)],
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
    final ref = globalState.container;
    await globalState.safeRun(() async {
      final message = await ref
          .read(proxiesActionProvider.notifier)
          .updateProvider(provider);
      if (message.isNotEmpty) throw message;
    }, silence: false);
    ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
  }

  Future<void> _handleSideLoadProvider() async {
    final ref = globalState.container;
    await globalState.safeRun<void>(() async {
      final platformFile = await picker.pickerFile();
      if (platformFile == null || provider.path == null) return;
      final bytes = await platformFile.readBytes();
      await File(provider.path!).safeWriteAsBytes(bytes);
      final providerName = provider.name;
      final message = await coreController.sideLoadExternalProvider(
        providerName: providerName,
        data: utf8.decode(bytes),
      );
      if (message.isNotEmpty) throw message;
      ref
          .read(providersProvider.notifier)
          .setProvider(await coreController.getExternalProvider(provider.name));
      if (message.isNotEmpty) throw message;
    });
    ref.read(proxiesActionProvider.notifier).updateGroupsDebounce();
  }

  String _buildProviderDesc(BuildContext context) {
    final baseInfo = provider.updateAt.getLastUpdateTimeDesc(context);
    final count = provider.count;
    return switch (count == 0) {
      true => baseInfo,
      false => '$baseInfo  ·  ${context.appLocalizations.entriesCount(count)}',
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
            Text(_buildProviderDesc(context)),
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
                label: context.appLocalizations.upload,
                onPressed: _handleSideLoadProvider,
              ),
              if (provider.vehicleType == 'HTTP')
                Consumer(
                  builder: (_, ref, _) {
                    final isUpdating = ref.watch(
                      isUpdatingProvider(provider.updatingKey),
                    );
                    return isUpdating
                        ? const SizedBox(
                            height: 30,
                            width: 30,
                            child: Padding(
                              padding: EdgeInsets.all(2),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : CommonChip(
                            avatar: const Icon(Icons.sync),
                            label: context.appLocalizations.sync,
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
