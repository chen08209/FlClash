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
          providerType: provider.type,
        );
        appState.setProvider(
          clashCore.getExternalProvider(provider.name),
        );
      },
    );
    await Future.wait(updateProviders);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AppState, List<ExternalProvider>>(
      selector: (_, appState) => appState.providers,
      builder: (_, providers, ___) {
        return ListView.separated(
          itemBuilder: (_, index) {
            return ProviderItem(
              provider: providers[index],
            );
          },
          separatorBuilder: (_, index) {
            return const Divider(
              height: 0,
            );
          },
          itemCount: providers.length,
        );
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

  _handleUpdateProfile() async {
    await globalState.safeRun<void>(updateProvider);
  }

  updateProvider() async {
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
        providerType: provider.type,
      );
      if (message.isNotEmpty) throw message;
    });
    appState.setProvider(
      clashCore.getExternalProvider(provider.name),
    );
  }

  String _buildProviderDesc() {
    final baseInfo =
        "${provider.type}(${provider.vehicleType}) ·  ${provider.updateAt.lastUpdateTimeDesc}";
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
          Text(
            provider.path,
            style: context.textTheme.bodyMedium?.toLight,
          ),
          const SizedBox(
            height: 8,
          ),
          Wrap(
            runSpacing: 6,
            spacing: 12,
            children: [
              // CommonChip(
              //   avatar: const Icon(Icons.upload),
              //   label: appLocalizations.upload,
              //   onPressed: () {},
              // ),
              if (provider.vehicleType == "HTTP")
                CommonChip(
                  avatar: const Icon(Icons.sync),
                  label: appLocalizations.sync,
                  onPressed: () {
                    _handleUpdateProfile();
                  },
                ),
            ],
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
