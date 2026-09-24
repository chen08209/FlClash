import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:material_ui/material_ui.dart';

extension IpTypeLabel on IpType {
  String label(BuildContext context) {
    final localizations = context.appLocalizations;
    return switch (this) {
      IpType.residential => localizations.ipTypeResidential,
      IpType.mobile => localizations.ipTypeMobile,
      IpType.business => localizations.ipTypeBusiness,
      IpType.hosting => localizations.ipTypeHosting,
    };
  }
}

extension IpQualityLevelView on IpQualityLevel {
  String label(BuildContext context) {
    final localizations = context.appLocalizations;
    return switch (this) {
      IpQualityLevel.good => localizations.ipQualityGood,
      IpQualityLevel.normal => localizations.ipQualityNormal,
      IpQualityLevel.risky => localizations.ipQualityRisky,
    };
  }

  Color? color(BuildContext context) {
    return switch (this) {
      IpQualityLevel.good => context.colorScheme.success,
      IpQualityLevel.normal => null,
      IpQualityLevel.risky => context.colorScheme.error,
    };
  }
}

extension IpQualitySourceStatusLabel on IpQualitySourceStatus {
  String label(BuildContext context) {
    final localizations = context.appLocalizations;
    return switch (this) {
      IpQualitySourceStatus.noType => localizations.ipSourceNoType,
      IpQualitySourceStatus.timeout => localizations.timeout,
      IpQualitySourceStatus.rateLimited => localizations.ipSourceRateLimited,
      IpQualitySourceStatus.failed => localizations.serviceFailed,
      IpQualitySourceStatus.ipMismatch => localizations.ipSourceIpMismatch,
    };
  }
}
