// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fa locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'fa';

  static String m0(count) =>
      "${Intl.plural(count, one: '1 روز پیش', other: '${count} روز پیش')}";

  static String m1(label) =>
      "آیا مطمئن هستید که می‌خواهید ${label} انتخاب شده را حذف کنید؟";

  static String m2(label) =>
      "آیا مطمئن هستید که می‌خواهید ${label} فعلی را حذف کنید؟";

  static String m3(label) => "جزئیات ${label}";

  static String m4(label) => "${label} نمی‌تواند خالی باشد";

  static String m5(label) => "${label} فعلی از قبل وجود دارد";

  static String m6(count) =>
      "${Intl.plural(count, one: '1 ساعت پیش', other: '${count} ساعت پیش')}";

  static String m7(target) => "${target} یک خط‌مشی نامعتبر است";

  static String m8(proxyName) => "${proxyName} یک پراکسی نامعتبر است";

  static String m9(providerName) =>
      "${providerName} یک ارائه‌دهنده پراکسی نامعتبر است";

  static String m10(subRule) => "${subRule} یک SUB_RULE نامعتبر است";

  static String m11(appName) =>
      "۱. تنظیمات سیستم > حریم خصوصی و امنیت را باز کنید\n۲. خدمات موقعیت مکانی را انتخاب کنید\n۳. ${appName} را در لیست سمت راست پیدا کرده و علامت بزنید\n\nپس از اتمام تنظیمات، به برنامه بازگشته و به طور عادی استفاده کنید. از همکاری شما متشکریم.";

  static String m12(count) =>
      "${Intl.plural(count, one: '1 دقیقه پیش', other: '${count} دقیقه پیش')}";

  static String m13(count) =>
      "${Intl.plural(count, one: '1 ماه پیش', other: '${count} ماه پیش')}";

  static String m14(label) => "هنوز ${label} وجود ندارد";

  static String m15(label) => "${label} باید یک عدد باشد";

  static String m16(label) => "${label} باید بین ۱۰۲۴ و ۴۹۱۵۱ باشد";

  static String m17(count) => "${count} مورد انتخاب شده است";

  static String m18(label) => "${label} باید یک آدرس اینترنتی باشد";

  static String m19(count) =>
      "${Intl.plural(count, one: '1 سال پیش', other: '${count} سال پیش')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("درباره"),
    "accessControl": MessageLookupByLibrary.simpleMessage("کنترل دسترسی"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "فقط به برنامه‌های انتخاب شده اجازه ورود به VPN داده شود",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "پیکربندی دسترسی برنامه‌ها به پراکسی",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "برنامه‌های انتخاب شده از VPN مستثنی خواهند شد",
    ),
    "accessControlSettings": MessageLookupByLibrary.simpleMessage(
      "تنظیمات کنترل دسترسی",
    ),
    "account": MessageLookupByLibrary.simpleMessage("حساب کاربری"),
    "action": MessageLookupByLibrary.simpleMessage("عملیات"),
    "action_mode": MessageLookupByLibrary.simpleMessage("تغییر حالت"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("پراکسی سیستم"),
    "action_start": MessageLookupByLibrary.simpleMessage("شروع/توقف"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("نمایش/مخفی کردن"),
    "add": MessageLookupByLibrary.simpleMessage("افزودن"),
    "addProfile": MessageLookupByLibrary.simpleMessage("افزودن پروفایل"),
    "addProxies": MessageLookupByLibrary.simpleMessage("افزودن پراکسی‌ها"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage(
      "افزودن گروه پراکسی",
    ),
    "addProxyProviders": MessageLookupByLibrary.simpleMessage(
      "افزودن ارائه‌دهندگان پراکسی",
    ),
    "addRule": MessageLookupByLibrary.simpleMessage("افزودن قانون"),
    "addSsid": MessageLookupByLibrary.simpleMessage("افزودن SSID"),
    "addedRules": MessageLookupByLibrary.simpleMessage("قوانین اضافه شده"),
    "additionalParameters": MessageLookupByLibrary.simpleMessage(
      "پارامترهای اضافی",
    ),
    "address": MessageLookupByLibrary.simpleMessage("آدرس"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("آدرس سرور WebDAV"),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک آدرس WebDAV معتبر وارد کنید",
    ),
    "advancedConfig": MessageLookupByLibrary.simpleMessage(
      "پیکربندی پیشرفته",
    ),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "ارائه گزینه‌های متنوع پیکربندی",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("موافقم"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "اجازه عبور برنامه‌ها از VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "برخی برنامه‌ها می‌توانند هنگام روشن بودن از VPN عبور کنند",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("اجازه شبکه محلی"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه دسترسی به پراکسی از طریق شبکه محلی",
    ),
    "app": MessageLookupByLibrary.simpleMessage("برنامه"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "کنترل دسترسی برنامه",
    ),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("الحاق DNS سیستم"),
    "appendSystemDnsTip": MessageLookupByLibrary.simpleMessage(
      "الحاق اجباری DNS سیستم به پیکربندی",
    ),
    "application": MessageLookupByLibrary.simpleMessage("برنامه"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر تنظیمات مربوط به برنامه",
    ),
    "authorized": MessageLookupByLibrary.simpleMessage("مجاز"),
    "auto": MessageLookupByLibrary.simpleMessage("خودکار"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "بررسی خودکار به‌روزرسانی",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "هنگام شروع برنامه به صورت خودکار به‌روزرسانی بررسی شود",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "بستن خودکار اتصالات",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "بستن خودکار اتصالات پس از تغییر گره",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("اجرای خودکار"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "همراه با راه‌اندازی سیستم اجرا شود",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("اجرای خودکار"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "هنگام باز شدن برنامه به صورت خودکار اجرا شود",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage(
      "تنظیم خودکار DNS سیستم",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("به‌روزرسانی خودکار"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "فاصله به‌روزرسانی خودکار (دقیقه)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("پشتیبان‌گیری"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری و بازیابی",
    ),
    "backupAndRestoreDesc": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی داده‌ها از طریق WebDAV یا فایل",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("پشتیبان‌گیری موفق"),
    "basicConfig": MessageLookupByLibrary.simpleMessage("پیکربندی پایه"),
    "basicConfigDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر پیکربندی پایه به صورت سراسری",
    ),
    "basicInfo": MessageLookupByLibrary.simpleMessage("اطلاعات پایه"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("استراتژی پایه"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "برای اطمینان از عملکرد در پس‌زمینه، لطفاً بهینه‌سازی باتری را برای این برنامه غیرفعال کنید. برای رفتن به تنظیمات ضربه بزنید.",
    ),
    "batteryOptimizationStatusTip": MessageLookupByLibrary.simpleMessage(
      "تحت تأثیر سیستم، این وضعیت ممکن است همیشه دقیق نباشد.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("اتصال"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سیاه"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("دامنه دور زدن"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "فقط هنگامی که پراکسی سیستم فعال است اثر می‌گذارد",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "حافظه پنهان خراب شده است. آیا می‌خواهید آن را پاک کنید؟",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("لغو"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "لغو انتخاب همه",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("بررسی به‌روزرسانی"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "برنامه فعلی آخرین نسخه است",
    ),
    "clearData": MessageLookupByLibrary.simpleMessage("پاک کردن داده‌ها"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage(
      "برون‌ریزی به حافظه موقت",
    ),
    "clipboardImport": MessageLookupByLibrary.simpleMessage(
      "درون‌ریزی از حافظه موقت",
    ),
    "color": MessageLookupByLibrary.simpleMessage("رنگ"),
    "colorSchemes": MessageLookupByLibrary.simpleMessage("طرح‌های رنگی"),
    "columns": MessageLookupByLibrary.simpleMessage("ستون‌ها"),
    "compatible": MessageLookupByLibrary.simpleMessage("حالت سازگاری"),
    "configDataDetected": MessageLookupByLibrary.simpleMessage(
      "داده در پیکربندی شناسایی شد",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("تأیید"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "آیا مطمئن هستید که می‌خواهید تمام داده‌ها را پاک کنید؟",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "آیا مطمئن هستید که می‌خواهید گروه پراکسی فعلی را حذف کنید؟",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage(
      "آیا مطمئن هستید که می‌خواهید از پنجره فعلی خارج شوید؟",
    ),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "آیا مطمئن هستید که می‌خواهید هسته را به اجبار خراب کنید؟",
    ),
    "confirmOverwriteTip": MessageLookupByLibrary.simpleMessage(
      "پس از تأیید داده‌های موجود بازنویسی خواهند شد",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("متصل"),
    "connecting": MessageLookupByLibrary.simpleMessage("در حال اتصال..."),
    "connection": MessageLookupByLibrary.simpleMessage("اتصال"),
    "connections": MessageLookupByLibrary.simpleMessage("اتصالات"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده داده‌های اتصالات فعلی",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("اتصال:"),
    "content": MessageLookupByLibrary.simpleMessage("محتوا"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage(
      "محتوا نمی‌تواند خالی باشد",
    ),
    "contentScheme": MessageLookupByLibrary.simpleMessage("Content"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "کنترل قوانین سراسری اضافه شده",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("کپی"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("کپی متغیرهای محیطی"),
    "copyLink": MessageLookupByLibrary.simpleMessage("کپی لینک"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("کپی موفق"),
    "core": MessageLookupByLibrary.simpleMessage("هسته"),
    "coreStatus": MessageLookupByLibrary.simpleMessage("وضعیت هسته"),
    "country": MessageLookupByLibrary.simpleMessage("کشور"),
    "crashTest": MessageLookupByLibrary.simpleMessage("آزمایش خرابی"),
    "crashlytics": MessageLookupByLibrary.simpleMessage("تحلیل خرابی"),
    "crashlyticsTip": MessageLookupByLibrary.simpleMessage(
      "هنگام فعال بودن، به صورت خودکار گزارش‌های خرابی بدون اطلاعات حساس هنگام خرابی برنامه بارگذاری می‌شوند",
    ),
    "create": MessageLookupByLibrary.simpleMessage("ایجاد"),
    "createProfile": MessageLookupByLibrary.simpleMessage("ایجاد پروفایل"),
    "creationTime": MessageLookupByLibrary.simpleMessage("زمان ایجاد"),
    "custom": MessageLookupByLibrary.simpleMessage("سفارشی"),
    "cut": MessageLookupByLibrary.simpleMessage("برش"),
    "dark": MessageLookupByLibrary.simpleMessage("تاریک"),
    "dashboard": MessageLookupByLibrary.simpleMessage("داشبورد"),
    "dataChangedSave": MessageLookupByLibrary.simpleMessage(
      "تغییرات داده شناسایی شد، آیا می‌خواهید ذخیره کنید؟",
    ),
    "dataCollectionContent": MessageLookupByLibrary.simpleMessage(
      "این برنامه از Firebase Crashlytics برای جمع‌آوری اطلاعات خرابی جهت بهبود پایداری برنامه استفاده می‌کند.\nداده‌های جمع‌آوری شده شامل اطلاعات دستگاه و جزئیات خرابی است، اما حاوی داده‌های حساس شخصی نیست.\nمی‌توانید این قابلیت را در تنظیمات غیرفعال کنید.",
    ),
    "dataCollectionTip": MessageLookupByLibrary.simpleMessage(
      "اطلاعیه جمع‌آوری داده",
    ),
    "daysAgo": m0,
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "سرور نام پیش‌فرض",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "برای تجزیه سرور DNS",
    ),
    "defaultText": MessageLookupByLibrary.simpleMessage("پیش‌فرض"),
    "delay": MessageLookupByLibrary.simpleMessage("تأخیر"),
    "delayTest": MessageLookupByLibrary.simpleMessage("آزمایش تأخیر"),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteMultipTip": m1,
    "deleteTip": m2,
    "desc": MessageLookupByLibrary.simpleMessage(
      "یک کلاینت پراکسی چندسکویی مبتنی بر ClashMeta، ساده و آسان برای استفاده، متن‌باز و بدون تبلیغات.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("مقصد"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("GeoIP مقصد"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("IPASN مقصد"),
    "details": m3,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "اتکا به API شخص ثالث فقط برای مرجع است",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("حالت توسعه‌دهنده"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "حالت توسعه‌دهنده فعال شد.",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("مستقیم"),
    "disableUDP": MessageLookupByLibrary.simpleMessage("غیرفعال کردن UDP"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("سلب مسئولیت"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "این نرم‌افزار فقط برای مقاصد غیرتجاری مانند تبادل یادگیری و تحقیقات علمی استفاده می‌شود. استفاده تجاری از این نرم‌افزار اکیداً ممنوع است. هرگونه فعالیت تجاری، در صورت وجود، هیچ ارتباطی با این نرم‌افزار ندارد.",
    ),
    "disconnected": MessageLookupByLibrary.simpleMessage("قطع شده"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "نسخه جدید کشف شد",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "به‌روزرسانی تنظیمات مربوط به DNS",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("ربودن DNS"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("حالت DNS"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "آیا می‌خواهید عبور کنید",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("دامنه"),
    "download": MessageLookupByLibrary.simpleMessage("بارگیری"),
    "edit": MessageLookupByLibrary.simpleMessage("ویرایش"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage(
      "ویرایش قوانین سراسری",
    ),
    "editProxy": MessageLookupByLibrary.simpleMessage("ویرایش پراکسی"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage(
      "ویرایش گروه پراکسی",
    ),
    "editRule": MessageLookupByLibrary.simpleMessage("ویرایش قانون"),
    "editSsid": MessageLookupByLibrary.simpleMessage("ویرایش SSID"),
    "emptyTip": m4,
    "en": MessageLookupByLibrary.simpleMessage("انگلیسی"),
    "entries": MessageLookupByLibrary.simpleMessage(" مورد"),
    "exclude": MessageLookupByLibrary.simpleMessage(
      "مخفی کردن از وظایف اخیر",
    ),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "هنگامی که برنامه در پس‌زمینه است، از وظایف اخیر مخفی می‌شود",
    ),
    "excludeProxyFilter": MessageLookupByLibrary.simpleMessage(
      "مستثنی کردن فیلتر پراکسی",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("مستثنی کردن SSID‌ها"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "هنگام اتصال به Wi-Fi SSID مستثنی شده، وضعیت اجرای برنامه به صورت خودکار تغییر می‌کند.",
    ),
    "excludeType": MessageLookupByLibrary.simpleMessage("نوع استثنا"),
    "existsTip": m5,
    "exit": MessageLookupByLibrary.simpleMessage("خروج"),
    "expand": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("وضعیت مورد انتظار"),
    "exportFile": MessageLookupByLibrary.simpleMessage("برون‌ریزی فایل"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("برون‌ریزی گزارش‌ها"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("برون‌ریزی موفق"),
    "expressiveScheme": MessageLookupByLibrary.simpleMessage("Expressive"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "کنترل‌کننده خارجی",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "پس از فعال‌سازی، هسته Clash از طریق پورت ۹۰۹۰ قابل کنترل خواهد بود",
    ),
    "externalFetch": MessageLookupByLibrary.simpleMessage("واکشی خارجی"),
    "externalLink": MessageLookupByLibrary.simpleMessage("لینک خارجی"),
    "fa": MessageLookupByLibrary.simpleMessage("فارسی"),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("فیلتر Fakeip"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("محدوده Fakeip"),
    "fallback": MessageLookupByLibrary.simpleMessage("Fallback"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "معمولاً از DNS خارج از کشور استفاده می‌شود",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("فیلتر Fallback"),
    "fidelityScheme": MessageLookupByLibrary.simpleMessage("Fidelity"),
    "file": MessageLookupByLibrary.simpleMessage("فایل"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("بارگذاری مستقیم پروفایل"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "فایل تغییر کرده است. آیا می‌خواهید تغییرات را ذخیره کنید؟",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("یافتن فرآیند"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "پس از باز شدن مقداری افت عملکرد وجود دارد",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("خانواده فونت"),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "آیا مطمئن هستید که می‌خواهید هسته را به اجبار راه‌اندازی مجدد کنید؟",
    ),
    "fruitSaladScheme": MessageLookupByLibrary.simpleMessage("FruitSalad"),
    "general": MessageLookupByLibrary.simpleMessage("عمومی"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage("حالت کم‌حافظه Geo"),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "فعال‌سازی از بارگذار کم‌حافظه Geo استفاده می‌کند",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("کد Geoip"),
    "global": MessageLookupByLibrary.simpleMessage("سراسری"),
    "go": MessageLookupByLibrary.simpleMessage("برو"),
    "goDownload": MessageLookupByLibrary.simpleMessage("رفتن به صفحه دانلود"),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage(
      "رفتن به پیکربندی اسکریپت",
    ),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "آیا می‌خواهید تغییرات را در حافظه پنهان ذخیره کنید؟",
    ),
    "hideFromList": MessageLookupByLibrary.simpleMessage("مخفی کردن از لیست"),
    "host": MessageLookupByLibrary.simpleMessage("میزبان"),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("افزودن Hosts"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("تداخل کلید میانبر"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "مدیریت کلید میانبر",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "استفاده از صفحه‌کلید برای کنترل برنامه‌ها",
    ),
    "hoursAgo": m6,
    "icon": MessageLookupByLibrary.simpleMessage("آیکون"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("سوابق آیکون"),
    "iconStyle": MessageLookupByLibrary.simpleMessage("سبک آیکون"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("آدرس آیکون"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "نادیده گرفتن بهینه‌سازی باتری",
    ),
    "import": MessageLookupByLibrary.simpleMessage("درون‌ریزی"),
    "importFile": MessageLookupByLibrary.simpleMessage("درون‌ریزی از فایل"),
    "importFromURL": MessageLookupByLibrary.simpleMessage(
      "درون‌ریزی از آدرس اینترنتی",
    ),
    "importUrl": MessageLookupByLibrary.simpleMessage(
      "درون‌ریزی از آدرس اینترنتی",
    ),
    "includeAllProxies": MessageLookupByLibrary.simpleMessage(
      "شامل تمام پراکسی‌ها",
    ),
    "includeAllProxiesTip": MessageLookupByLibrary.simpleMessage(
      "درون‌ریزی تمام پراکسی‌هایی که گروه پراکسی ندارند، گروه‌های پراکسی اضافی را می‌توان در زیر اضافه کرد",
    ),
    "includeAllProxyProviders": MessageLookupByLibrary.simpleMessage(
      "شامل تمام ارائه‌دهندگان پراکسی",
    ),
    "includeAllProxyProvidersTip": MessageLookupByLibrary.simpleMessage(
      "هنگام فعال بودن، ارائه‌دهندگان پراکسی وارد شده را بازنویسی می‌کند",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage(
      "دارای اعتبار بلندمدت",
    ),
    "init": MessageLookupByLibrary.simpleMessage("راه‌اندازی"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید میانبر صحیح را وارد کنید",
    ),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "نام گروه پراکسی را وارد کنید",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage(
      "محتوای قانون را وارد کنید",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("انتخاب هوشمند"),
    "internet": MessageLookupByLibrary.simpleMessage("اینترنت"),
    "interval": MessageLookupByLibrary.simpleMessage("فاصله"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP داخلی"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage(
      "فایل پشتیبان نامعتبر",
    ),
    "invalidPolicy": m7,
    "invalidProxy": m8,
    "invalidProxyProvider": m9,
    "invalidSubRule": m10,
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "هنگام روشن شدن ترافیک IPv6 دریافت خواهد شد",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه ورودی IPv6",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("ژاپنی"),
    "justNow": MessageLookupByLibrary.simpleMessage("همین الان"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "فاصله نگهداری اتصال TCP",
    ),
    "key": MessageLookupByLibrary.simpleMessage("کلید"),
    "language": MessageLookupByLibrary.simpleMessage("زبان"),
    "layout": MessageLookupByLibrary.simpleMessage("چیدمان"),
    "light": MessageLookupByLibrary.simpleMessage("روشن"),
    "list": MessageLookupByLibrary.simpleMessage("لیست"),
    "listen": MessageLookupByLibrary.simpleMessage("شنود"),
    "loadTest": MessageLookupByLibrary.simpleMessage("آزمایش بارگذاری"),
    "loading": MessageLookupByLibrary.simpleMessage("در حال بارگذاری..."),
    "local": MessageLookupByLibrary.simpleMessage("محلی"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری از داده‌های محلی به صورت محلی",
    ),
    "locationPermission": MessageLookupByLibrary.simpleMessage(
      "مجوز موقعیت مکانی",
    ),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "مجوز موقعیت مکانی رد شد، بنابراین نام Wi-Fi فعلی قابل دریافت نیست. لطفاً مجوز موقعیت مکانی را به صورت دستی در تنظیمات سیستم باز کنید.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "طبق الزامات سیستم، دریافت نام Wi-Fi نیاز به اعطای مجوز موقعیت مکانی دارد.",
    ),
    "locationPermissionGuide": m11,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "مجوز موقعیت مکانی لازم است",
    ),
    "log": MessageLookupByLibrary.simpleMessage("گزارش"),
    "logLevel": MessageLookupByLibrary.simpleMessage("سطح گزارش"),
    "logcat": MessageLookupByLibrary.simpleMessage("ثبت رویداد"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "غیرفعال کردن، ورودی گزارش را مخفی می‌کند",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("گزارش‌ها"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("سوابق ثبت گزارش"),
    "logsTest": MessageLookupByLibrary.simpleMessage("آزمایش گزارش‌ها"),
    "loopback": MessageLookupByLibrary.simpleMessage(
      "ابزار باز کردن حلقه‌برگشت",
    ),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "برای باز کردن حلقه‌برگشت UWP استفاده می‌شود",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("شل"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("تطبیق IP مبدأ"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage(
      "حداکثر دفعات ناموفق",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("اطلاعات حافظه"),
    "messageTest": MessageLookupByLibrary.simpleMessage("آزمایش پیام"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage(
      "این یک پیام است.",
    ),
    "min": MessageLookupByLibrary.simpleMessage("حداقل"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage(
      "کوچک‌سازی هنگام خروج",
    ),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر رویداد پیش‌فرض خروج سیستم",
    ),
    "minutesAgo": m12,
    "mixedPort": MessageLookupByLibrary.simpleMessage("پورت ترکیبی"),
    "mode": MessageLookupByLibrary.simpleMessage("حالت"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("Monochrome"),
    "monthsAgo": m13,
    "more": MessageLookupByLibrary.simpleMessage("بیشتر"),
    "name": MessageLookupByLibrary.simpleMessage("نام"),
    "nameserver": MessageLookupByLibrary.simpleMessage("سرور نام"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "برای تجزیه دامنه",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "خط‌مشی سرور نام",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "تعیین خط‌مشی مربوطه سرور نام",
    ),
    "network": MessageLookupByLibrary.simpleMessage("شبکه"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر تنظیمات مربوط به شبکه",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage("تشخیص شبکه"),
    "networkException": MessageLookupByLibrary.simpleMessage(
      "خطای شبکه، لطفاً اتصال خود را بررسی کنید و دوباره تلاش کنید",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("سرعت شبکه"),
    "networkType": MessageLookupByLibrary.simpleMessage("نوع شبکه"),
    "neutralScheme": MessageLookupByLibrary.simpleMessage("Neutral"),
    "noData": MessageLookupByLibrary.simpleMessage("بدون داده"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("بدون کلید میانبر"),
    "noInfo": MessageLookupByLibrary.simpleMessage("بدون اطلاعات"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage(
      "دوباره یادآوری نکن",
    ),
    "noNetwork": MessageLookupByLibrary.simpleMessage("بدون شبکه"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("برنامه بدون شبکه"),
    "noRecords": MessageLookupByLibrary.simpleMessage("بدون سابقه"),
    "noResolve": MessageLookupByLibrary.simpleMessage("بدون تجزیه IP"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage(
      "بدون تجزیه نام میزبان",
    ),
    "none": MessageLookupByLibrary.simpleMessage("هیچ"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "گروه پراکسی فعلی قابل انتخاب نیست.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "پروفایلی وجود ندارد، لطفاً یک پروفایل اضافه کنید",
    ),
    "nullTip": m14,
    "numberTip": m15,
    "onDemand": MessageLookupByLibrary.simpleMessage("در صورت نیاز"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "پیکربندی وضعیت اجرای برنامه برای سناریوهای خاص",
    ),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("آیکون"),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "فقط آمار پراکسی",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "هنگام روشن شدن، فقط ترافیک پراکسی آمارگیری می‌شود",
    ),
    "optional": MessageLookupByLibrary.simpleMessage("اختیاری"),
    "options": MessageLookupByLibrary.simpleMessage("گزینه‌ها"),
    "other": MessageLookupByLibrary.simpleMessage("سایر"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "سایر مشارکت‌کنندگان",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("حالت خروجی"),
    "override": MessageLookupByLibrary.simpleMessage("بازنویسی"),
    "overrideDns": MessageLookupByLibrary.simpleMessage("بازنویسی DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "روشن کردن، گزینه‌های DNS در پروفایل را بازنویسی می‌کند",
    ),
    "overrideMode": MessageLookupByLibrary.simpleMessage("حالت بازنویسی"),
    "overrideScript": MessageLookupByLibrary.simpleMessage("اسکریپت بازنویسی"),
    "overwriteTypeCustom": MessageLookupByLibrary.simpleMessage("سفارشی"),
    "overwriteTypeCustomDesc": MessageLookupByLibrary.simpleMessage(
      "حالت سفارشی، سفارشی‌سازی کامل گروه‌های پراکسی و قوانین",
    ),
    "palette": MessageLookupByLibrary.simpleMessage("پالت"),
    "password": MessageLookupByLibrary.simpleMessage("رمز عبور"),
    "paste": MessageLookupByLibrary.simpleMessage("جای‌گذاری"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "لطفاً WebDAV را متصل کنید",
    ),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "لطفاً نام اسکریپت را وارد کنید",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "لطفاً رمز عبور مدیر را وارد کنید",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک کد QR معتبر بارگذاری کنید",
    ),
    "port": MessageLookupByLibrary.simpleMessage("پورت"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک پورت متفاوت وارد کنید",
    ),
    "portTip": m16,
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "اولویت استفاده از http/3 DOH",
    ),
    "prerequisites": MessageLookupByLibrary.simpleMessage("پیش‌نیازها"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "لطفاً کلید را فشار دهید.",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("پیش‌نمایش"),
    "process": MessageLookupByLibrary.simpleMessage("فرآیند"),
    "profile": MessageLookupByLibrary.simpleMessage("پروفایل"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "لطفاً قالب زمانی معتبری وارد کنید",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "لطفاً زمان فاصله به‌روزرسانی خودکار را وارد کنید",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "پروفایل تغییر کرده است. آیا می‌خواهید به‌روزرسانی خودکار را غیرفعال کنید؟",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً نام پروفایل را وارد کنید",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک آدرس اینترنتی معتبر وارد کنید",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً آدرس اینترنتی پروفایل را وارد کنید",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("پروفایل‌ها"),
    "profilesSort": MessageLookupByLibrary.simpleMessage(
      "مرتب‌سازی پروفایل‌ها",
    ),
    "project": MessageLookupByLibrary.simpleMessage("پروژه"),
    "providers": MessageLookupByLibrary.simpleMessage("ارائه‌دهندگان"),
    "proxies": MessageLookupByLibrary.simpleMessage("پراکسی‌ها"),
    "proxiesEmpty": MessageLookupByLibrary.simpleMessage(
      "پراکسی‌ها خالی هستند",
    ),
    "proxyChains": MessageLookupByLibrary.simpleMessage("زنجیره پراکسی"),
    "proxyDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "پراکسی‌های انتخاب شده غیرعادی شناسایی شدند",
    ),
    "proxyFilter": MessageLookupByLibrary.simpleMessage("فیلتر پراکسی"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("گروه پراکسی"),
    "proxyGroupDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "گروه پراکسی فعلی غیرعادی شناسایی شد",
    ),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage(
      "گروه پراکسی خالی است",
    ),
    "proxyGroupNameDuplicate": MessageLookupByLibrary.simpleMessage(
      "نام گروه پراکسی تکراری است",
    ),
    "proxyGroupNameEmpty": MessageLookupByLibrary.simpleMessage(
      "نام گروه پراکسی نمی‌تواند خالی باشد",
    ),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage(
      "سرور نام پراکسی",
    ),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "دامنه برای تجزیه گره‌های پراکسی",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("پورت پراکسی"),
    "proxyProviderDetectedAbnormal": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان پراکسی انتخاب شده غیرعادی شناسایی شدند",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان پراکسی",
    ),
    "proxyProvidersEmpty": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان پراکسی خالی هستند",
    ),
    "proxyProvidersNotEmpty": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان پراکسی نمی‌توانند خالی باشند",
    ),
    "proxyType": MessageLookupByLibrary.simpleMessage("نوع پراکسی"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("پاکسازی حافظه پنهان"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("حالت مشکی خالص"),
    "qrcode": MessageLookupByLibrary.simpleMessage("کد QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "اسکن کد QR برای دریافت پروفایل",
    ),
    "quickFill": MessageLookupByLibrary.simpleMessage("پر کردن سریع"),
    "rainbowScheme": MessageLookupByLibrary.simpleMessage("Rainbow"),
    "redirPort": MessageLookupByLibrary.simpleMessage("پورت Redir"),
    "redo": MessageLookupByLibrary.simpleMessage("انجام مجدد"),
    "remote": MessageLookupByLibrary.simpleMessage("راه‌دور"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری از داده‌های محلی به WebDAV",
    ),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("مقصد راه‌دور"),
    "remove": MessageLookupByLibrary.simpleMessage("حذف"),
    "rename": MessageLookupByLibrary.simpleMessage("تغییر نام"),
    "request": MessageLookupByLibrary.simpleMessage("درخواست"),
    "requests": MessageLookupByLibrary.simpleMessage("درخواست‌ها"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده سوابق درخواست‌های اخیر",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("بازنشانی"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "صفحه فعلی تغییراتی دارد. آیا مطمئن هستید که می‌خواهید بازنشانی کنید؟",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage(
      "از بازنشانی اطمینان حاصل کنید",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("منابع"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "اطلاعات مربوط به منابع خارجی",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("رعایت قوانین"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "اتصال DNS مطابق با قوانین، نیاز به پیکربندی proxy-server-nameserver",
    ),
    "restart": MessageLookupByLibrary.simpleMessage("راه‌اندازی مجدد"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage(
      "آیا مطمئن هستید که می‌خواهید هسته را راه‌اندازی مجدد کنید؟",
    ),
    "restore": MessageLookupByLibrary.simpleMessage("بازیابی"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage(
      "بازیابی تمام داده‌ها",
    ),
    "restoreException": MessageLookupByLibrary.simpleMessage("خطای بازیابی"),
    "restoreFromFileDesc": MessageLookupByLibrary.simpleMessage(
      "بازیابی داده‌ها از طریق فایل",
    ),
    "restoreFromWebDAVDesc": MessageLookupByLibrary.simpleMessage(
      "بازیابی داده‌ها از طریق WebDAV",
    ),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage(
      "بازیابی فقط فایل‌های پیکربندی",
    ),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage(
      "استراتژی بازیابی",
    ),
    "restoreStrategy_compatible": MessageLookupByLibrary.simpleMessage("سازگار"),
    "restoreStrategy_override": MessageLookupByLibrary.simpleMessage("بازنویسی"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("بازیابی موفق"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("آدرس مسیر"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "پیکربندی آدرس مسیر شنود",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("حالت مسیریابی"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "دور زدن آدرس مسیر خصوصی",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage(
      "استفاده از پیکربندی",
    ),
    "ru": MessageLookupByLibrary.simpleMessage("روسی"),
    "rule": MessageLookupByLibrary.simpleMessage("قانون"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage(
      "قانون منطقی AND",
    ),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق دامنه کامل",
    ),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق کلمه کلیدی دامنه",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق الگوی wildcard، فقط از * و ? پشتیبانی می‌کند",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق پسوند دامنه",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق علامت DSCP (فقط ورودی UDP tproxy)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق محدوده پورت مقصد درخواست",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق کد کشور IP",
    ),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق دامنه‌ها در Geosite",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق نام ورودی",
    ),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق پورت ورودی",
    ),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق نوع ورودی",
    ),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق نام کاربری ورودی، از چندین نام کاربری جدا شده با / پشتیبانی می‌کند",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق ASN IP",
    ),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "تطبیق محدوده آدرس IP، IP-CIDR6 فقط یک نام مستعار است",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق محدوده آدرس IP",
    ),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق محدوده پسوند IP",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق تمام درخواست‌ها، نیازی به شرط نیست",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق TCP یا UDP",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage(
      "قانون منطقی NOT",
    ),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("قانون منطقی OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق با استفاده از نام فرآیند، در Android با نام بسته تطبیق می‌کند",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق با استفاده از regex نام فرآیند، در Android با نام بسته تطبیق می‌کند",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق با استفاده از مسیر کامل فرآیند",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق با استفاده از regex مسیر فرآیند",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "ارجاع مجموعه قوانین، نیاز به پیکربندی rule-providers",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق کد کشور IP مبدأ",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق ASN IP مبدأ",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق محدوده آدرس IP مبدأ",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق محدوده پسوند IP مبدأ",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق محدوده پورت مبدأ درخواست",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق با زیرقانون، به استفاده از پرانتز توجه کنید",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "تطبیق شناسه کاربری لینوکس",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("قانون خالی است"),
    "ruleName": MessageLookupByLibrary.simpleMessage("نام قانون"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage(
      "ارائه‌دهندگان قانون",
    ),
    "ruleSet": MessageLookupByLibrary.simpleMessage("مجموعه قوانین"),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("هدف قانون"),
    "save": MessageLookupByLibrary.simpleMessage("ذخیره"),
    "saveChanges": MessageLookupByLibrary.simpleMessage(
      "آیا می‌خواهید تغییرات را ذخیره کنید؟",
    ),
    "script": MessageLookupByLibrary.simpleMessage("اسکریپت"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "حالت اسکریپت، استفاده از اسکریپت‌های افزونه خارجی، ارائه قابلیت بازنویسی یک‌کلیکه پیکربندی",
    ),
    "search": MessageLookupByLibrary.simpleMessage("جستجو"),
    "seconds": MessageLookupByLibrary.simpleMessage("ثانیه"),
    "selectAll": MessageLookupByLibrary.simpleMessage("انتخاب همه"),
    "selectProxies": MessageLookupByLibrary.simpleMessage("انتخاب پراکسی‌ها"),
    "selectProxyProviders": MessageLookupByLibrary.simpleMessage(
      "انتخاب ارائه‌دهندگان پراکسی",
    ),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage(
      "لطفاً مجموعه قوانین را انتخاب کنید",
    ),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage(
      "لطفاً استراتژی تقسیم را انتخاب کنید",
    ),
    "selectSubRule": MessageLookupByLibrary.simpleMessage(
      "لطفاً زیرقانون را انتخاب کنید",
    ),
    "selected": MessageLookupByLibrary.simpleMessage("انتخاب شده"),
    "selectedCountTitle": m17,
    "settings": MessageLookupByLibrary.simpleMessage("تنظیمات"),
    "show": MessageLookupByLibrary.simpleMessage("نمایش"),
    "shrink": MessageLookupByLibrary.simpleMessage("جمع شدن"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("اجرای خاموش"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "در پس‌زمینه اجرا شود",
    ),
    "size": MessageLookupByLibrary.simpleMessage("اندازه"),
    "socksPort": MessageLookupByLibrary.simpleMessage("پورت Socks"),
    "sort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی"),
    "source": MessageLookupByLibrary.simpleMessage("منبع"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("IP مبدأ"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("پراکسی ویژه"),
    "specialRules": MessageLookupByLibrary.simpleMessage("قوانین ویژه"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("آمار سرعت"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("استراتژی تقسیم"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "استراتژی تقسیم نمی‌تواند خالی باشد",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSID‌ها خالی هستند"),
    "stackMode": MessageLookupByLibrary.simpleMessage("حالت پشته"),
    "standard": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "حالت استاندارد، بازنویسی پیکربندی پایه، ارائه قابلیت افزودن ساده قوانین",
    ),
    "start": MessageLookupByLibrary.simpleMessage("شروع"),
    "startVpn": MessageLookupByLibrary.simpleMessage("در حال راه‌اندازی VPN..."),
    "status": MessageLookupByLibrary.simpleMessage("وضعیت"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "هنگام خاموش بودن از DNS سیستم استفاده می‌شود",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("توقف"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("در حال توقف VPN..."),
    "style": MessageLookupByLibrary.simpleMessage("سبک"),
    "subRule": MessageLookupByLibrary.simpleMessage("زیرقانون"),
    "subRuleEmpty": MessageLookupByLibrary.simpleMessage("زیرقانون خالی است"),
    "subRuleNotEmpty": MessageLookupByLibrary.simpleMessage(
      "زیرقانون نمی‌تواند خالی باشد",
    ),
    "submit": MessageLookupByLibrary.simpleMessage("ارسال"),
    "suspended": MessageLookupByLibrary.simpleMessage("معلق..."),
    "sync": MessageLookupByLibrary.simpleMessage("همگام‌سازی"),
    "system": MessageLookupByLibrary.simpleMessage("سیستم"),
    "systemApp": MessageLookupByLibrary.simpleMessage("برنامه سیستمی"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("پراکسی سیستم"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "اتصال پراکسی HTTP به VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("زبانه"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("انیمیشن زبانه"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "فقط در نمای موبایل مؤثر است",
    ),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage(
      "برای مجوز ضربه بزنید",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("همزمانی TCP"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "فعال‌سازی اجازه همزمانی TCP را می‌دهد",
    ),
    "testInterval": MessageLookupByLibrary.simpleMessage("فاصله آزمایش"),
    "testUrl": MessageLookupByLibrary.simpleMessage("آدرس آزمایش"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("آزمایش هنگام استفاده"),
    "textScale": MessageLookupByLibrary.simpleMessage("مقیاس متن"),
    "theme": MessageLookupByLibrary.simpleMessage("پوسته"),
    "themeColor": MessageLookupByLibrary.simpleMessage("رنگ پوسته"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم حالت تاریک، تغییر رنگ",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("حالت پوسته"),
    "tight": MessageLookupByLibrary.simpleMessage("فشرده"),
    "time": MessageLookupByLibrary.simpleMessage("زمان"),
    "timeout": MessageLookupByLibrary.simpleMessage("مهلت زمانی"),
    "tip": MessageLookupByLibrary.simpleMessage("نکته"),
    "toggle": MessageLookupByLibrary.simpleMessage("تغییر وضعیت"),
    "tonalSpotScheme": MessageLookupByLibrary.simpleMessage("TonalSpot"),
    "tools": MessageLookupByLibrary.simpleMessage("ابزارها"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("پورت Tproxy"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("مصرف ترافیک"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "فقط در حالت مدیر سیستم مؤثر است",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("خاموش کردن"),
    "turnOn": MessageLookupByLibrary.simpleMessage("روشن کردن"),
    "undo": MessageLookupByLibrary.simpleMessage("واگرد"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("تأخیر یکپارچه"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "حذف تأخیرهای اضافی مانند دست‌دادن",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("ناشناخته"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "خطای ناشناخته شبکه",
    ),
    "unnamed": MessageLookupByLibrary.simpleMessage("بدون نام"),
    "update": MessageLookupByLibrary.simpleMessage("به‌روزرسانی"),
    "upload": MessageLookupByLibrary.simpleMessage("بارگذاری"),
    "url": MessageLookupByLibrary.simpleMessage("آدرس اینترنتی"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "دریافت پروفایل از طریق آدرس اینترنتی",
    ),
    "urlTip": m18,
    "useHosts": MessageLookupByLibrary.simpleMessage("استفاده از hosts"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage(
      "استفاده از hosts سیستم",
    ),
    "value": MessageLookupByLibrary.simpleMessage("مقدار"),
    "vibrantScheme": MessageLookupByLibrary.simpleMessage("Vibrant"),
    "view": MessageLookupByLibrary.simpleMessage("مشاهده"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "تغییر پیکربندی VPN شناسایی شد",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "مسیریابی خودکار تمام ترافیک سیستم از طریق VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "تغییرات پس از راه‌اندازی مجدد VPN اعمال می‌شوند",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "پیکربندی WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سفید"),
    "yearsAgo": m19,
    "zh_CN": MessageLookupByLibrary.simpleMessage("چینی ساده‌شده"),
  };
}
