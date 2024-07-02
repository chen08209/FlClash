import 'dart:ui';

import 'package:flutter/material.dart';

const appName = "FlClash";
const coreName = "clash.meta";
const packageName = "FlClash";
const httpTimeoutDuration = Duration(milliseconds: 5000);
const moreDuration = Duration(milliseconds: 100);
const animateDuration = Duration(milliseconds: 100);
const defaultUpdateDuration = Duration(days: 1);
const mmdbFileName = "geoip.metadb";
const geoSiteFileName = "GeoSite.dat";
const asnFileName = "ASN.mmdb";
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

const defaultPrimaryColor = Colors.brown;
