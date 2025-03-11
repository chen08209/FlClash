// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// این فایل کتابخانه‌ای برای ارائه پیام‌ها برای لوکال en است. تمام پیام‌های برنامه اصلی باید در اینجا با همان نام‌های تابع دوباره تعریف شوند.

// مشکلات رایج lint در این فایل نادیده گرفته می‌شوند.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'fa';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("درباره"),
    "accessControl": MessageLookupByLibrary.simpleMessage("کنترل دسترسی"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "فقط برنامه‌های مشخص‌شده می‌توانند از VPN استفاده کنند",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم مجوزهای دسترسی پروکسی برای برنامه‌ها",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "برنامه‌های انتخاب‌شده نمی‌توانند از VPN استفاده کنند",
    ),
    "account": MessageLookupByLibrary.simpleMessage("حساب کاربری"),
    "accountTip": MessageLookupByLibrary.simpleMessage(
      "فیلد حساب کاربری نمی‌تواند خالی باشد",
    ),
    "action": MessageLookupByLibrary.simpleMessage("عملیات"),
    "action_mode": MessageLookupByLibrary.simpleMessage("تغییر حالت"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("پروکسی سیستم"),
    "action_start": MessageLookupByLibrary.simpleMessage("شروع/توقف"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("نمایش/مخفی کردن"),
    "add": MessageLookupByLibrary.simpleMessage("افزودن"),
    "address": MessageLookupByLibrary.simpleMessage("آدرس"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "آدرس سرور WebDAV",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک آدرس WebDAV معتبر وارد کنید",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی خودکار با دسترسی مدیر",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی خودکار با مجوزهای مدیر",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("پیش"),
    "agree": MessageLookupByLibrary.simpleMessage("موافقم"),
    "allApps": MessageLookupByLibrary.simpleMessage("همه برنامه‌ها"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "اجازه دور زدن VPN به برنامه‌ها",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، برخی برنامه‌ها می‌توانند VPN را دور بزنند",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("اجازه LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه دسترسی به پروکسی از طریق LAN",
    ),
    "app": MessageLookupByLibrary.simpleMessage("برنامه"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "کنترل دسترسی برنامه‌ها",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "مدیریت تنظیمات مرتبط با برنامه‌ها",
    ),
    "application": MessageLookupByLibrary.simpleMessage("برنامه"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم تنظیمات مرتبط با برنامه‌ها",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("خودکار"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "بررسی خودکار به‌روزرسانی",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "بررسی خودکار به‌روزرسانی‌ها هنگام راه‌اندازی برنامه",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "بستن خودکار اتصال‌ها",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "بستن خودکار اتصال‌های موجود هنگام تغییر گره",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("راه‌اندازی خودکار"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی خودکار با سیستم",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("اجرای خودکار"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "اجرای خودکار هنگام شروع برنامه",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("به‌روزرسانی خودکار"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "فاصله به‌روزرسانی خودکار (دقیقه)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("پشتیبان‌گیری"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری و بازیابی",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "همگام‌سازی داده‌ها از طریق WebDAV یا فایل‌ها",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("پشتیبان‌گیری موفق"),
    "bind": MessageLookupByLibrary.simpleMessage("اتصال"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سیاه"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("دور زدن دامنه"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "فقط در صورت فعال بودن پروکسی سیستم اعمال می‌شود",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "حافظه کش خراب شده است. پاک شود؟",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("لغو"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "لغو فیلتر برنامه‌های سیستمی",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "لغو انتخاب همه",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("بررسی خطا"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("بررسی به‌روزرسانی"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "نسخه فعلی برنامه آخرین نسخه است",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("در حال بررسی…"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("صادر کردن به کلیپ‌بورد"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("وارد کردن از کلیپ‌بورد"),
    "columns": MessageLookupByLibrary.simpleMessage("ستون‌ها"),
    "compatible": MessageLookupByLibrary.simpleMessage("حالت سازگاری"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، برخی ویژگی‌های برنامه‌ها برای پشتیبانی کامل از Clash فدا می‌شوند",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("تأیید"),
    "connections": MessageLookupByLibrary.simpleMessage("اتصال‌ها"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده اطلاعات اتصال فعلی",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("وضعیت اتصال:"),
    "copy": MessageLookupByLibrary.simpleMessage("کپی"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "کپی متغیرهای محیطی",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("کپی لینک"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("کپی موفق"),
    "core": MessageLookupByLibrary.simpleMessage("هسته"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("اطلاعات هسته"),
    "country": MessageLookupByLibrary.simpleMessage("کشور/منطقه"),
    "create": MessageLookupByLibrary.simpleMessage("ایجاد"),
    "cut": MessageLookupByLibrary.simpleMessage("برش"),
    "dark": MessageLookupByLibrary.simpleMessage("تیره"),
    "dashboard": MessageLookupByLibrary.simpleMessage("داشبورد"),
    "days": MessageLookupByLibrary.simpleMessage("روز"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "سرور نام پیش‌فرض",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "سرور مورد استفاده برای رزولوشن DNS",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی پیش‌فرض"),
    "defaultText": MessageLookupByLibrary.simpleMessage("پیش‌فرض"),
    "delay": MessageLookupByLibrary.simpleMessage("تأخیر"),
    "delaySort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی بر اساس تأخیر"),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteProfileTip": MessageLookupByLibrary.simpleMessage(
      "پروفایل فعلی حذف شود؟",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "یک کلاینت پروکسی چندسکویی مبتنی بر ClashMeta، ساده، متن‌باز و بدون تبلیغات",
    ),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "وابسته به API شخص ثالث است و نتایج فقط برای مرجع هستند",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("اتصال مستقیم"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("سلب مسئولیت"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "این نرم‌افزار فقط برای استفاده‌های آموزشی، پژوهشی و غیرتجاری محدود شده است. استفاده تجاری اکیداً ممنوع است. هرگونه فعالیت تجاری (در صورت وجود) به این نرم‌افزار مربوط نیست",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "نسخه جدید کشف شد",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "نسخه جدید کشف شد",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "به‌روزرسانی تنظیمات مرتبط با DNS",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("حالت DNS"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "آیا مطمئن هستید که می‌خواهید ادامه دهید؟",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("دامنه"),
    "download": MessageLookupByLibrary.simpleMessage("دانلود"),
    "edit": MessageLookupByLibrary.simpleMessage("ویرایش"),
    "en": MessageLookupByLibrary.simpleMessage("انگلیسی"),
    "entries": MessageLookupByLibrary.simpleMessage("ورودی‌ها"),
    "exclude": MessageLookupByLibrary.simpleMessage("مخفی کردن از وظایف اخیر"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "مخفی کردن برنامه از لیست وظایف اخیر هنگام اجرا در پس‌زمینه",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("خروج"),
    "expand": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("زمان انقضا"),
    "exportFile": MessageLookupByLibrary.simpleMessage("صادر کردن فایل"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("صادر کردن لاگ‌ها"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("صادرات موفق"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "کنترل‌کننده خارجی",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، هسته Clash از طریق پورت 9090 قابل کنترل است",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("لینک خارجی"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "منابع خارجی",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("فیلتر Fake IP"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("محدوده Fake IP"),
    "fallback": MessageLookupByLibrary.simpleMessage("بازگشتی"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "معمولاً از یک سرور DNS خارجی استفاده می‌شود",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("فیلتر بازگشتی"),
    "file": MessageLookupByLibrary.simpleMessage("فایل"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("بارگذاری مستقیم فایل پروفایل"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "فایل تغییر کرده است. تغییرات ذخیره شوند؟",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "فیلتر برنامه‌های سیستمی",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("حالت جستجوی فرآیند"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، ممکن است خطر خرابی برنامه وجود داشته باشد",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("خانواده فونت"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("چهار ستون"),
    "general": MessageLookupByLibrary.simpleMessage("عمومی"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "مدیریت تنظیمات عمومی",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("داده‌های جغرافیایی"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "حالت کم‌حافظه داده‌های جغرافیایی",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، از بارگذار داده‌های جغرافیایی با حافظه کم استفاده می‌شود",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("کد GeoIP"),
    "global": MessageLookupByLibrary.simpleMessage("جهانی"),
    "go": MessageLookupByLibrary.simpleMessage("برو"),
    "goDownload": MessageLookupByLibrary.simpleMessage("رفتن به دانلود"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "تغییرات حافظه کش ذخیره شوند؟",
    ),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("افزودن تنظیمات هاست"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("تداخل کلید میانبر"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "مدیریت کلیدهای میانبر",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "کنترل برنامه با کلیدهای میانبر کیبورد",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("ساعت"),
    "icon": MessageLookupByLibrary.simpleMessage("آیکون"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "پیکربندی آیکون",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("سبک آیکون"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("وارد کردن از URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("نامحدود"),
    "init": MessageLookupByLibrary.simpleMessage("راه‌اندازی اولیه"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک کلید میانبر معتبر وارد کنید",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "انتخاب هوشمند",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP شبکه داخلی"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، ترافیک IPv6 قابل دریافت است",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "اجازه ترافیک ورودی IPv6",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("ژاپنی"),
    "just": MessageLookupByLibrary.simpleMessage("همین حالا"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "فاصله نگه‌داری زنده TCP",
    ),
    "key": MessageLookupByLibrary.simpleMessage("کلید"),
    "ko": MessageLookupByLibrary.simpleMessage("کره‌ای"),
    "fr": MessageLookupByLibrary.simpleMessage("فرانسوی"),
    "de": MessageLookupByLibrary.simpleMessage("آلمانی"),
    "ar": MessageLookupByLibrary.simpleMessage("عربی"),
    "fa": MessageLookupByLibrary.simpleMessage("پارسی"),
    "language": MessageLookupByLibrary.simpleMessage("زبان"),
    "layout": MessageLookupByLibrary.simpleMessage("چیدمان"),
    "light": MessageLookupByLibrary.simpleMessage("روشن"),
    "list": MessageLookupByLibrary.simpleMessage("لیست"),
    "listen": MessageLookupByLibrary.simpleMessage("گوش دادن"),
    "local": MessageLookupByLibrary.simpleMessage("محلی"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری داده‌ها به صورت محلی",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "بازیابی داده‌ها از فایل محلی",
    ),
    "logLevel": MessageLookupByLibrary.simpleMessage("سطح لاگ"),
    "logcat": MessageLookupByLibrary.simpleMessage("ضبط لاگ"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت غیرفعال‌سازی، محتوای لاگ‌ها مخفی می‌شود",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("لاگ‌ها"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("مشاهده سوابق لاگ"),
    "loopback": MessageLookupByLibrary.simpleMessage("ابزار باز کردن Loopback"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "برای باز کردن محدودیت‌های Loopback در UWP استفاده می‌شود",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("آزاد"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("اطلاعات حافظه"),
    "min": MessageLookupByLibrary.simpleMessage("دقیقه"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("کوچک کردن هنگام خروج"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "تغییر رفتار پیش‌فرض خروج به کوچک کردن",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("دقیقه"),
    "mode": MessageLookupByLibrary.simpleMessage("حالت"),
    "months": MessageLookupByLibrary.simpleMessage("ماه"),
    "more": MessageLookupByLibrary.simpleMessage("بیشتر"),
    "name": MessageLookupByLibrary.simpleMessage("نام"),
    "nameSort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی بر اساس نام"),
    "nameserver": MessageLookupByLibrary.simpleMessage("سرور نام"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "سرور مورد استفاده برای رزولوشن دامنه",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "سیاست سرور نام",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "مشخص کردن سیاست سرور نام مربوطه",
    ),
    "network": MessageLookupByLibrary.simpleMessage("شبکه"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم تنظیمات مرتبط با شبکه",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "تشخیص شبکه",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("سرعت شبکه"),
    "noData": MessageLookupByLibrary.simpleMessage("بدون داده"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("بدون کلید میانبر"),
    "noIcon": MessageLookupByLibrary.simpleMessage("بدون آیکون"),
    "noInfo": MessageLookupByLibrary.simpleMessage("بدون اطلاعات"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("اطلاعات بیشتری نیست"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("بدون اتصال شبکه"),
    "noProxy": MessageLookupByLibrary.simpleMessage("بدون پروکسی"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "یک پروفایل ایجاد کنید یا یک پروفایل معتبر اضافه کنید",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("نمی‌تواند خالی باشد"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "گروه پروکسی فعلی قابل انتخاب نیست",
    ),
    "nullConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "بدون اتصال",
    ),
    "nullCoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "عدم توانایی در دریافت اطلاعات هسته",
    ),
    "nullLogsDesc": MessageLookupByLibrary.simpleMessage("بدون سوابق لاگ"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "بدون پروفایل، لطفاً یک پروفایل اضافه کنید",
    ),
    "nullProxies": MessageLookupByLibrary.simpleMessage("بدون پروکسی"),
    "nullRequestsDesc": MessageLookupByLibrary.simpleMessage("بدون سوابق درخواست"),
    "oneColumn": MessageLookupByLibrary.simpleMessage("یک ستون"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("فقط آیکون"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "فقط برنامه‌های شخص ثالث",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "آمار فقط ترافیک پروکسی",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، فقط ترافیک مرتبط با پروکسی ثبت می‌شود",
    ),
    "options": MessageLookupByLibrary.simpleMessage("گزینه‌ها"),
    "other": MessageLookupByLibrary.simpleMessage("دیگر"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "سایر مشارکت‌کنندگان",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("حالت خروجی"),
    "override": MessageLookupByLibrary.simpleMessage("بازنویسی"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "بازنویسی تنظیمات مرتبط با پروکسی",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("بازنویسی DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، تنظیمات DNS در پروفایل بازنویسی می‌شوند",
    ),
    "password": MessageLookupByLibrary.simpleMessage("رمز عبور"),
    "passwordTip": MessageLookupByLibrary.simpleMessage(
      "فیلد رمز عبور نمی‌تواند خالی باشد",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("چسباندن"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "لطفاً WebDAV را متصل کنید",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "لطفاً رمز عبور مدیر را وارد کنید",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک فایل بارگذاری کنید",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک کد QR معتبر بارگذاری کنید",
    ),
    "port": MessageLookupByLibrary.simpleMessage("پورت"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "ترجیح DOH از طریق HTTP/3",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "یک کلید کیبورد را فشار دهید",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("پیش‌نمایش"),
    "profile": MessageLookupByLibrary.simpleMessage("پروفایل"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "لطفاً فرمت فاصله زمانی معتبر وارد کنید",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "لطفاً فاصله زمانی به‌روزرسانی خودکار را وارد کنید",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "پروفایل تغییر کرده است. به‌روزرسانی خودکار غیرفعال شود؟",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً نام پروفایل را وارد کنید",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "تجزیه پروفایل ناموفق بود",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً یک URL پروفایل معتبر وارد کنید",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "لطفاً URL پروفایل را وارد کنید",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("پروفایل‌ها"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی پروفایل‌ها"),
    "project": MessageLookupByLibrary.simpleMessage("پروژه"),
    "providers": MessageLookupByLibrary.simpleMessage("ارائه‌دهندگان"),
    "proxies": MessageLookupByLibrary.simpleMessage("پروکسی‌ها"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("تنظیمات پروکسی"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("گروه پروکسی"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("سرور نام پروکسی"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "سرور مورد استفاده برای رزولوشن دامنه‌های گره پروکسی",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("پورت پروکسی"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم پورت گوش دادن برای Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("ارائه‌دهندگان پروکسی"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("حالت سیاه خالص"),
    "qrcode": MessageLookupByLibrary.simpleMessage("کد QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "اسکن کد QR برای وارد کردن پروفایل",
    ),
    "recovery": MessageLookupByLibrary.simpleMessage("بازیابی"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("بازیابی همه داده‌ها"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "بازیابی فقط پروفایل‌ها",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("بازیابی موفق"),
    "regExp": MessageLookupByLibrary.simpleMessage("عبارت منظم"),
    "remote": MessageLookupByLibrary.simpleMessage("دور"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "پشتیبان‌گیری داده‌ها در WebDAV",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "بازیابی داده‌ها از WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("حذف"),
    "requests": MessageLookupByLibrary.simpleMessage("درخواست‌ها"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "مشاهده سوابق درخواست‌های اخیر",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("بازنشانی"),
    "resetTip": MessageLookupByLibrary.simpleMessage("تنظیمات بازنشانی شوند؟"),
    "resources": MessageLookupByLibrary.simpleMessage("منابع"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "اطلاعات درباره منابع خارجی",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("رعایت قوانین"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "اتصال‌های DNS قوانین را رعایت می‌کنند، نیاز به تنظیم پروکسی و سرور نام دارد",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("آدرس مسیر"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم آدرس مسیر برای گوش دادن",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("حالت مسیر"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "دور زدن آدرس‌های مسیر خصوصی",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("استفاده از پروفایل"),
    "ru": MessageLookupByLibrary.simpleMessage("روسی"),
    "rule": MessageLookupByLibrary.simpleMessage("قانون"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("ارائه‌دهندگان قانون"),
    "save": MessageLookupByLibrary.simpleMessage("ذخیره"),
    "search": MessageLookupByLibrary.simpleMessage("جستجو"),
    "seconds": MessageLookupByLibrary.simpleMessage("ثانیه"),
    "selectAll": MessageLookupByLibrary.simpleMessage("انتخاب همه"),
    "selected": MessageLookupByLibrary.simpleMessage("انتخاب‌شده"),
    "settings": MessageLookupByLibrary.simpleMessage("تنظیمات"),
    "show": MessageLookupByLibrary.simpleMessage("نمایش"),
    "shrink": MessageLookupByLibrary.simpleMessage("کوچک کردن"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("راه‌اندازی بی‌صدا"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "راه‌اندازی برنامه در پس‌زمینه",
    ),
    "size": MessageLookupByLibrary.simpleMessage("اندازه"),
    "sort": MessageLookupByLibrary.simpleMessage("مرتب‌سازی"),
    "source": MessageLookupByLibrary.simpleMessage("منبع"),
    "stackMode": MessageLookupByLibrary.simpleMessage("حالت پشته"),
    "standard": MessageLookupByLibrary.simpleMessage("استاندارد"),
    "start": MessageLookupByLibrary.simpleMessage("شروع"),
    "startVpn": MessageLookupByLibrary.simpleMessage("در حال شروع VPN…"),
    "status": MessageLookupByLibrary.simpleMessage("وضعیت"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت خاموش بودن، از DNS سیستم استفاده می‌شود",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("توقف"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("در حال توقف VPN…"),
    "style": MessageLookupByLibrary.simpleMessage("سبک"),
    "submit": MessageLookupByLibrary.simpleMessage("ارسال"),
    "sync": MessageLookupByLibrary.simpleMessage("همگام‌سازی"),
    "system": MessageLookupByLibrary.simpleMessage("سیستم"),
    "systemFont": MessageLookupByLibrary.simpleMessage("فونت سیستم"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("پروکسی سیستم"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "افزودن پروکسی HTTP به VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("تب"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("انیمیشن تب"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، تغییر تب‌ها در صفحه اصلی با انیمیشن نمایش داده می‌شود",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP هم‌زمان"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، انتقال هم‌زمان TCP مجاز است",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL آزمایشی"),
    "theme": MessageLookupByLibrary.simpleMessage("تم"),
    "themeColor": MessageLookupByLibrary.simpleMessage("رنگ تم"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم حالت تیره یا تنظیم رنگ‌ها",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("حالت تم"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("سه ستون"),
    "tight": MessageLookupByLibrary.simpleMessage("فشرده"),
    "time": MessageLookupByLibrary.simpleMessage("زمان"),
    "tip": MessageLookupByLibrary.simpleMessage("نکته"),
    "toggle": MessageLookupByLibrary.simpleMessage("تغییر وضعیت"),
    "tools": MessageLookupByLibrary.simpleMessage("ابزارها"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("استفاده از ترافیک"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "فقط در حالت مدیر کار می‌کند",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("دو ستون"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "عدم توانایی در به‌روزرسانی پروفایل فعلی",
    ),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("تأخیر یکپارچه"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "حذف تأخیرهای اضافی مانند دست‌دهی",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("ناشناخته"),
    "update": MessageLookupByLibrary.simpleMessage("به‌روزرسانی"),
    "upload": MessageLookupByLibrary.simpleMessage("بارگذاری"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "دریافت پروفایل از طریق URL",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("استفاده از تنظیمات هاست"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("استفاده از هاست‌های سیستم"),
    "value": MessageLookupByLibrary.simpleMessage("مقدار"),
    "view": MessageLookupByLibrary.simpleMessage("مشاهده"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "تنظیم تنظیمات مرتبط با VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "در صورت فعال‌سازی، تمام ترافیک سیستم به‌طور خودکار از طریق VpnService هدایت می‌شود",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "ادغام پروکسی HTTP در VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "تنظیمات پس از راه‌اندازی مجدد VPN اعمال می‌شوند",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "پیکربندی WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("حالت لیست سفید"),
    "years": MessageLookupByLibrary.simpleMessage("سال"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("چینی ساده‌شده"),
    "zh_TW": MessageLookupByLibrary.simpleMessage("چینی سنتی"),
  };
}
