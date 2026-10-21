import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/pages/scan.dart';
import 'package:fl_clash/plugins/app.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/profiles/custom/custom.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The ways to add a profile, in a menu out of the control [builder] makes.
class AddProfileMenu extends ConsumerWidget {
  const AddProfileMenu({super.key, required this.builder});

  final Widget Function(PopupOpen open) builder;

  Future<void> _handleAddProfileFormFile(WidgetRef ref) async {
    unawaited(ref.read(profilesActionProvider.notifier).addProfileFormFile());
  }

  Future<void> _toScan(BuildContext context, WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (system.isDesktop) {
      unawaited(profilesAction.addProfileFormQrCode());
      return;
    }
    final url = await BaseNavigator.push(context, const ScanPage());
    if (url == null) {
      return;
    }
    if (context.mounted) {
      await whenRouteUncovered(context);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(profilesAction.addProfileFromLink(url));
    });
  }

  Future<void> _toAdd(BuildContext context, WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    final appLocalizations = context.appLocalizations;
    final res = await showNamedUrlsForm(
      context,
      title: appLocalizations.importFromLink,
      urlLabel: appLocalizations.link,
      batchTip: appLocalizations.batchLinkInputTip,
      urlValidator: (value) {
        if (value == null || value.isEmpty) {
          return appLocalizations.emptyTip(appLocalizations.link);
        }
        if (!value.isUrl && !value.isShareLink) {
          return appLocalizations.invalidLinkTip;
        }
        return null;
      },
      existingUrls: {
        for (final profile in ref.read(profilesProvider))
          if (profile.url.isNotEmpty) profile.url,
      },
      withAgeSecretKey: true,
    );
    switch (res) {
      case null:
        return;
      case [final single]:
        unawaited(
          profilesAction.addProfileFromLink(
            single.url,
            label: single.label,
            ageSecretKey: single.ageSecretKey,
          ),
        );
      default:
        unawaited(
          profilesAction.addProfilesFromLinks([
            for (final item in res) item.url,
          ]),
        );
    }
  }

  Future<void> _toSendFromPhone(WidgetRef ref) async {
    final profilesAction = ref.read(profilesActionProvider.notifier);
    if (!(await app?.requestLocalNetworkPermission() ?? true)) {
      final appLocalizations = currentAppLocalizations;
      final res = await dialogs.showMessage(
        message: TextSpan(text: appLocalizations.sendFromPhonePermissionDenied),
        confirmText: appLocalizations.settings,
      );
      if (res == true) {
        await app?.openAppSettings();
      }
      return;
    }
    final link = await dialogs.showCommonDialog<String>(
      child: const _SendFromPhoneDialog(),
    );
    if (link == null) {
      return;
    }
    final appLocalizations = currentAppLocalizations;
    final confirmed = await dialogs.showMessage(
      title: appLocalizations.sendFromPhoneConfirmTitle,
      message: TextSpan(text: link),
      confirmText: appLocalizations.import,
    );
    if (confirmed == true) {
      unawaited(profilesAction.addProfileFromLink(link));
    }
  }

  void _toAddCustom(BuildContext context, WidgetRef ref) {
    final profileId = ref
        .read(profilesActionProvider.notifier)
        .addCustomProfile(context.appLocalizations.unnamed);
    unawaited(
      BaseNavigator.push(
        context,
        CustomProfileView(profileId: profileId, isNew: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLocalizations = context.appLocalizations;
    return CommonPopupBox(
      targetBuilder: builder,
      popupBuilder: (_) => CommonPopupMenu(
        items: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.qrCode,
            label: appLocalizations.qrcode,
            onPressed: () => _toScan(context, ref),
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.importFile,
            label: appLocalizations.file,
            onPressed: () => _handleAddProfileFormFile(ref),
          ),
          CommonPopupMenuItem(
            glyph: AppGlyphs.cloudDownload,
            label: appLocalizations.link,
            onPressed: () => _toAdd(context, ref),
          ),
          if (system.isTV)
            CommonPopupMenuItem(
              glyph: AppGlyphs.devices,
              label: appLocalizations.sendFromPhone,
              onPressed: () => _toSendFromPhone(ref),
            ),
          CommonPopupMenuItem(
            section: const CommonPopupMenuSection(),
            glyph: AppGlyphs.customize,
            label: appLocalizations.customProfile,
            onPressed: () => _toAddCustom(context, ref),
          ),
        ],
      ),
    );
  }
}

class _SendFromPhoneDialog extends StatefulWidget {
  const _SendFromPhoneDialog();

  @override
  State<_SendFromPhoneDialog> createState() => _SendFromPhoneDialogState();
}

class _SendFromPhoneDialogState extends State<_SendFromPhoneDialog> {
  LinkReceiver? _receiver;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    final appLocalizations = currentAppLocalizations;
    final receiver = await LinkReceiver.start((
      title: appLocalizations.sendFromPhonePageTitle,
      hint: appLocalizations.sendFromPhonePageHint,
      send: appLocalizations.send,
      sent: appLocalizations.sendFromPhonePageSent,
      invalid: appLocalizations.invalidLinkTip,
    )).catchError((Object _) => null);
    if (!mounted) {
      unawaited(receiver?.close());
      return;
    }
    setState(() {
      _receiver = receiver;
      _failed = receiver == null;
    });
    final link = await receiver?.link;
    if (link != null && mounted) {
      Navigator.of(context).pop(link);
    }
  }

  @override
  void dispose() {
    unawaited(_receiver?.close());
    super.dispose();
  }

  Widget _buildContent(BuildContext context) {
    final appLocalizations = context.appLocalizations;
    if (_failed) {
      return Text(
        appLocalizations.sendFromPhoneNoNetwork,
        textAlign: TextAlign.center,
      );
    }
    final address = _receiver?.address.toString();
    if (address == null) {
      return const SizedBox.square(
        dimension: 96,
        child: Center(child: CommonCircleLoading()),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        QrCodeView(data: address, size: 200),
        SelectableText(address, textAlign: TextAlign.center),
        Text(appLocalizations.sendFromPhoneTip, textAlign: TextAlign.center),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: context.appLocalizations.sendFromPhone,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.appLocalizations.cancel),
        ),
      ],
      child: _buildContent(context),
    );
  }
}
