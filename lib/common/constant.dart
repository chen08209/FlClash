import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/material.dart';

const appName = "FlClash";
const appHelperService = "FlClashHelperService";
const coreName = "clash.meta";
const packageName = "com.follow.clash";
final unixSocketPath = "/tmp/FlClashSocket_${Random().nextInt(10000)}.sock";
const helperPort = 47890;
const helperTag = "2024125";
const baseInfoEdgeInsets = EdgeInsets.symmetric(
  vertical: 16,
  horizontal: 16,
);
const httpTimeoutDuration = Duration(milliseconds: 5000);
const moreDuration = Duration(milliseconds: 100);
const animateDuration = Duration(milliseconds: 100);
const commonDuration = Duration(milliseconds: 300);
const defaultUpdateDuration = Duration(days: 1);
const mmdbFileName = "geoip.metadb";
const asnFileName = "ASN.mmdb";
const geoIpFileName = "GeoIP.dat";
const geoSiteFileName = "GeoSite.dat";
final double kHeaderHeight = system.isDesktop
    ? !Platform.isMacOS
        ? 40
        : 28
    : 0;
const GeoXMap defaultGeoXMap = {
  "mmdb":
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.metadb",
  "asn":
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb",
  "geoip":
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip.dat",
  "geosite":
      "https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
};
const profilesDirectoryName = "profiles";
const localhost = "127.0.0.1";
const clashConfigKey = "clash_config";
const configKey = "config";
const listItemPadding = EdgeInsets.symmetric(horizontal: 16);
const double dialogCommonWidth = 300;
const repository = "chen08209/FlClash";
const defaultExternalController = "127.0.0.1:9090";
const maxMobileWidth = 600;
const maxLaptopWidth = 840;
const geodataLoaderMemconservative = "memconservative";
const geodataLoaderStandard = "standard";
const defaultTestUrl = "https://www.gstatic.com/generate_204";
final filter = ImageFilter.blur(
  sigmaX: 5,
  sigmaY: 5,
  tileMode: TileMode.mirror,
);

const navigationItemListEquality = ListEquality<NavigationItem>();
const connectionListEquality = ListEquality<Connection>();
const stringListEquality = ListEquality<String>();
const logListEquality = ListEquality<Log>();
const groupListEquality = ListEquality<Group>();
const externalProviderListEquality = ListEquality<ExternalProvider>();
const packageListEquality = ListEquality<Package>();
const hotKeyActionListEquality = ListEquality<HotKeyAction>();
const stringAndStringMapEquality = MapEquality<String, String>();
const stringAndStringMapEntryIterableEquality =
    IterableEquality<MapEntry<String, String>>();
const delayMapEquality = MapEquality<String, Map<String, int?>>();
const stringSetEquality = SetEquality<String>();
const keyboardModifierListEquality = SetEquality<KeyboardModifier>();

const viewModeColumnsMap = {
  ViewMode.mobile: [2, 1],
  ViewMode.laptop: [3, 2],
  ViewMode.desktop: [4, 3],
};

const defaultPrimaryColor = Colors.brown;

double getWidgetHeight(num lines) {
  return max(lines * 84 + (lines - 1) * 16, 0);
}

final mainIsolate = "FlClashMainIsolate";

final serviceIsolate = "FlClashServiceIsolate";
