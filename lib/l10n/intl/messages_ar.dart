// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// هذا الملف عبارة عن مكتبة توفر الرسائل للغة الإنجليزية. يجب إعادة تعريف جميع رسائل البرنامج الرئيسي هنا بنفس أسماء الدوال.

// يتم تجاهل مشكلات lint الشائعة في هذا الملف.
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
  String get localeName => 'ar';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("حول"),
    "accessControl": MessageLookupByLibrary.simpleMessage("التحكم في الوصول"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "يمكن فقط للتطبيقات المحددة استخدام VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "ضبط أذونات الوصول للبروكسي للتطبيقات",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "التطبيقات المختارة لا يمكنها استخدام VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("الحساب"),
    "accountTip": MessageLookupByLibrary.simpleMessage(
      "لا يمكن أن يكون حقل الحساب فارغًا",
    ),
    "action": MessageLookupByLibrary.simpleMessage("إجراء"),
    "action_mode": MessageLookupByLibrary.simpleMessage("تبديل الوضع"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("بروكسي النظام"),
    "action_start": MessageLookupByLibrary.simpleMessage("بدء/إيقاف"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("إظهار/إخفاء"),
    "add": MessageLookupByLibrary.simpleMessage("إضافة"),
    "address": MessageLookupByLibrary.simpleMessage("العنوان"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "عنوان خادم WebDAV",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال عنوان WebDAV صالح",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "التشغيل التلقائي للمسؤول",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "التشغيل التلقائي بصلاحيات المسؤول",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("منذ"),
    "agree": MessageLookupByLibrary.simpleMessage("موافق"),
    "allApps": MessageLookupByLibrary.simpleMessage("جميع التطبيقات"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "السماح للتطبيقات بتجاوز VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، يمكن لبعض التطبيقات تجاوز VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("السماح بـ LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "السماح بالوصول إلى البروكسي عبر LAN",
    ),
    "app": MessageLookupByLibrary.simpleMessage("تطبيق"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "التحكم في وصول التطبيقات",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "إدارة الإعدادات المتعلقة بالتطبيقات",
    ),
    "application": MessageLookupByLibrary.simpleMessage("تطبيق"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "تعديل الإعدادات المتعلقة بالتطبيقات",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("تلقائي"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "التحقق التلقائي من التحديثات",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "التحقق من التحديثات تلقائيًا عند بدء تشغيل البرنامج",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "إغلاق الاتصالات تلقائيًا",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "إغلاق الاتصالات الحالية تلقائيًا عند تبديل العقد",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("التشغيل التلقائي"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "التشغيل تلقائيًا مع النظام",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("التشغيل التلقائي"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "التشغيل تلقائيًا عند بدء التطبيق",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("التحديث التلقائي"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "فاصل التحديث التلقائي (بالدقائق)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("نسخ احتياطي"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "نسخ احتياطي واستعادة",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "مزامنة البيانات عبر WebDAV أو الملفات",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("نجاح النسخ الاحتياطي"),
    "bind": MessageLookupByLibrary.simpleMessage("ربط"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("وضع القائمة السوداء"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("تجاوز النطاق"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "يتم تطبيقه فقط عندما يكون بروكسي النظام مفعلاً",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "الذاكرة المؤقتة تالفة. هل تريد مسحها؟",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "إلغاء تصفية تطبيقات النظام",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "إلغاء تحديد الكل",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("التحقق من الخطأ"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("التحقق من التحديث"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "التطبيق الحالي هو الإصدار الأحدث",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("جارٍ التحقق…"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("تصدير إلى الحافظة"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("استيراد من الحافظة"),
    "columns": MessageLookupByLibrary.simpleMessage("أعمدة"),
    "compatible": MessageLookupByLibrary.simpleMessage("وضع التوافق"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، يتم التضحية ببعض ميزات التطبيقات لدعم Clash بالكامل",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("تأكيد"),
    "connections": MessageLookupByLibrary.simpleMessage("الاتصالات"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "عرض معلومات الاتصال الحالية",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("الاتصال:"),
    "copy": MessageLookupByLibrary.simpleMessage("نسخ"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "نسخ متغيرات البيئة",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("نسخ الرابط"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("نسخ ناجح"),
    "core": MessageLookupByLibrary.simpleMessage("النواة"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("معلومات النواة"),
    "country": MessageLookupByLibrary.simpleMessage("الدولة/المنطقة"),
    "create": MessageLookupByLibrary.simpleMessage("إنشاء"),
    "cut": MessageLookupByLibrary.simpleMessage("قص"),
    "dark": MessageLookupByLibrary.simpleMessage("داكن"),
    "dashboard": MessageLookupByLibrary.simpleMessage("لوحة التحكم"),
    "days": MessageLookupByLibrary.simpleMessage("أيام"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "خادم الأسماء الافتراضي",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "الخادم المستخدم لحل DNS",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("الفرز الافتراضي"),
    "defaultText": MessageLookupByLibrary.simpleMessage("افتراضي"),
    "delay": MessageLookupByLibrary.simpleMessage("تأخير"),
    "delaySort": MessageLookupByLibrary.simpleMessage("فرز حسب التأخير"),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteProfileTip": MessageLookupByLibrary.simpleMessage(
      "حذف الملف الشخصي الحالي؟",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "عميل بروكسي متعدد المنصات يعتمد على ClashMeta، سهل الاستخدام، مفتوح المصدر، وخالٍ من الإعلانات",
    ),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "يعتمد على واجهة برمجة تطبيقات طرف ثالث، النتائج للإشارة فقط",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("اتصال مباشر"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("إخلاء المسؤولية"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "هذا البرنامج مقتصر على الاستخدامات التعليمية والبحثية وغير التجارية فقط. الاستخدام التجاري محظور تمامًا. أي أنشطة تجارية (إن وجدت) لا علاقة لها بهذا البرنامج",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "تم اكتشاف إصدار جديد",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "تم اكتشاف إصدار جديد",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "تحديث الإعدادات المتعلقة بـ DNS",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("وضع DNS"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من المتابعة؟",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("النطاق"),
    "download": MessageLookupByLibrary.simpleMessage("تنزيل"),
    "edit": MessageLookupByLibrary.simpleMessage("تعديل"),
    "en": MessageLookupByLibrary.simpleMessage("إنجليزي"),
    "entries": MessageLookupByLibrary.simpleMessage("المدخلات"),
    "exclude": MessageLookupByLibrary.simpleMessage("إخفاء من المهام الأخيرة"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "إخفاء التطبيق من قائمة المهام الأخيرة عند التشغيل في الخلفية",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("خروج"),
    "expand": MessageLookupByLibrary.simpleMessage("قياسي"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("وقت الانتهاء"),
    "exportFile": MessageLookupByLibrary.simpleMessage("تصدير ملف"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("تصدير السجلات"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("تصدير ناجح"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "وحدة تحكم خارجية",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، يمكن التحكم في نواة Clash عبر المنفذ 9090",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("رابط خارجي"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "موارد خارجية",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("مرشح Fake IP"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("نطاق Fake IP"),
    "fallback": MessageLookupByLibrary.simpleMessage("الاحتياطي"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "عادةً ما يستخدم خادم DNS خارجي",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("مرشح الاحتياطي"),
    "file": MessageLookupByLibrary.simpleMessage("ملف"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("رفع ملف تعريف مباشرة"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "تم تعديل الملف. حفظ التغييرات؟",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "تصفية تطبيقات النظام",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("وضع البحث عن العمليات"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، قد يكون هناك مخاطر تعطل التطبيق",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("عائلة الخط"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("أربعة أعمدة"),
    "general": MessageLookupByLibrary.simpleMessage("عام"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "إدارة الإعدادات العامة",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("بيانات جغرافية"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "وضع ذاكرة منخفضة لبيانات جغرافية",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، يتم استخدام محمل بيانات جغرافية بذاكرة منخفضة",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("رمز GeoIP"),
    "global": MessageLookupByLibrary.simpleMessage("عالمي"),
    "go": MessageLookupByLibrary.simpleMessage("اذهب"),
    "goDownload": MessageLookupByLibrary.simpleMessage("الذهاب إلى التنزيل"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "حفظ تغييرات الذاكرة المؤقتة؟",
    ),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("إضافة إعدادات المضيف"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("تعارض المفاتيح السريعة"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "إدارة المفاتيح السريعة",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "التحكم في التطبيق باستخدام مفاتيح الاختصار على لوحة المفاتيح",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("ساعات"),
    "icon": MessageLookupByLibrary.simpleMessage("أيقونة"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "تكوين الأيقونة",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("نمط الأيقونة"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("استيراد من URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("غير محدود"),
    "init": MessageLookupByLibrary.simpleMessage("تهيئة"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال مفتاح سريع صالح",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "اختيار ذكي",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP الشبكة الداخلية"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، يمكن استقبال حركة IPv6",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "السماح بحركة IPv6 الواردة",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("ياباني"),
    "just": MessageLookupByLibrary.simpleMessage("الآن"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "فاصل الإبقاء على اتصال TCP",
    ),
    "key": MessageLookupByLibrary.simpleMessage("مفتاح"),
    "ko": MessageLookupByLibrary.simpleMessage("كوري"),
    "fr": MessageLookupByLibrary.simpleMessage("فرنسي"),
    "de": MessageLookupByLibrary.simpleMessage("ألماني"),
    "ar": MessageLookupByLibrary.simpleMessage("عربي"),
    "fa": MessageLookupByLibrary.simpleMessage("فارسي"),
    "language": MessageLookupByLibrary.simpleMessage("اللغة"),
    "layout": MessageLookupByLibrary.simpleMessage("التخطيط"),
    "light": MessageLookupByLibrary.simpleMessage("فاتح"),
    "list": MessageLookupByLibrary.simpleMessage("قائمة"),
    "listen": MessageLookupByLibrary.simpleMessage("استماع"),
    "local": MessageLookupByLibrary.simpleMessage("محلي"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "نسخ احتياطي للبيانات محليًا",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "استعادة البيانات من ملف محلي",
    ),
    "logLevel": MessageLookupByLibrary.simpleMessage("مستوى السجل"),
    "logcat": MessageLookupByLibrary.simpleMessage("التقاط السجل"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "عند التعطيل، سيتم إخفاء محتويات السجل",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("السجلات"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("عرض سجلات التسجيل"),
    "loopback": MessageLookupByLibrary.simpleMessage("أداة فتح Loopback"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "تُستخدم لفتح قيود Loopback في UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("فضفاض"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("معلومات الذاكرة"),
    "min": MessageLookupByLibrary.simpleMessage("دقيقة"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("تصغير عند الخروج"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "تغيير سلوك الخروج الافتراضي إلى التصغير",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("دقائق"),
    "mode": MessageLookupByLibrary.simpleMessage("وضع"),
    "months": MessageLookupByLibrary.simpleMessage("أشهر"),
    "more": MessageLookupByLibrary.simpleMessage("المزيد"),
    "name": MessageLookupByLibrary.simpleMessage("الاسم"),
    "nameSort": MessageLookupByLibrary.simpleMessage("فرز حسب الاسم"),
    "nameserver": MessageLookupByLibrary.simpleMessage("خادم الأسماء"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "الخادم المستخدم لحل النطاقات",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "سياسة خادم الأسماء",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "تحديد سياسة خادم الأسماء المقابل",
    ),
    "network": MessageLookupByLibrary.simpleMessage("الشبكة"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "تعديل الإعدادات المتعلقة بالشبكة",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "كشف الشبكة",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("سرعة الشبكة"),
    "noData": MessageLookupByLibrary.simpleMessage("لا توجد بيانات"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("لا يوجد مفتاح سريع"),
    "noIcon": MessageLookupByLibrary.simpleMessage("لا توجد أيقونة"),
    "noInfo": MessageLookupByLibrary.simpleMessage("لا توجد معلومات"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("لا مزيد من المعلومات"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("لا يوجد اتصال بالشبكة"),
    "noProxy": MessageLookupByLibrary.simpleMessage("لا يوجد بروكسي"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "أنشئ ملف تعريف أو أضف ملف تعريف صالح",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("لا يمكن أن يكون فارغًا"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "مجموعة البروكسي الحالية لا يمكن اختيارها",
    ),
    "nullConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "لا توجد اتصالات",
    ),
    "nullCoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "غير قادر على استرجاع معلومات النواة",
    ),
    "nullLogsDesc": MessageLookupByLibrary.simpleMessage("لا توجد سجلات"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "لا يوجد ملف تعريف، يرجى إضافة ملف تعريف",
    ),
    "nullProxies": MessageLookupByLibrary.simpleMessage("لا توجد بروكسيات"),
    "nullRequestsDesc": MessageLookupByLibrary.simpleMessage("لا توجد سجلات طلبات"),
    "oneColumn": MessageLookupByLibrary.simpleMessage("عمود واحد"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("أيقونة فقط"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "تطبيقات الطرف الثالث فقط",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "إحصاءات حركة البروكسي فقط",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، يتم تسجيل حركة البروكسي فقط",
    ),
    "options": MessageLookupByLibrary.simpleMessage("خيارات"),
    "other": MessageLookupByLibrary.simpleMessage("أخرى"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "مساهمون آخرون",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("وضع الصادر"),
    "override": MessageLookupByLibrary.simpleMessage("تجاوز"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "تجاوز الإعدادات المتعلقة بالبروكسي",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("تجاوز DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، سيتم تجاوز إعدادات DNS في الملف الشخصي",
    ),
    "password": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "passwordTip": MessageLookupByLibrary.simpleMessage(
      "لا يمكن أن يكون حقل كلمة المرور فارغًا",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("لصق"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "يرجى ربط WebDAV",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال كلمة مرور المسؤول",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "يرجى رفع ملف",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "يرجى رفع رمز QR صالح",
    ),
    "port": MessageLookupByLibrary.simpleMessage("المنفذ"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "تفضيل DOH عبر HTTP/3",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "اضغط على مفتاح لوحة المفاتيح",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("معاينة"),
    "profile": MessageLookupByLibrary.simpleMessage("ملف تعريف"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "يرجى إدخال تنسيق فاصل زمني صالح",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "يرجى إدخال فاصل التحديث التلقائي",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "تم تعديل الملف الشخصي. تعطيل التحديث التلقائي؟",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال اسم الملف الشخصي",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "فشل تحليل الملف الشخصي",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال URL صالح للملف الشخصي",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال URL للملف الشخصي",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("ملفات التعريف"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("فرز ملفات التعريف"),
    "project": MessageLookupByLibrary.simpleMessage("مشروع"),
    "providers": MessageLookupByLibrary.simpleMessage("المزودون"),
    "proxies": MessageLookupByLibrary.simpleMessage("البروكسيات"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("إعدادات البروكسي"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("مجموعة البروكسي"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("خادم أسماء البروكسي"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "الخادم المستخدم لحل نطاقات عقد البروكسي",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("منفذ البروكسي"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "ضبط منفذ الاستماع لـ Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("مزودو البروكسي"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("وضع الأسود النقي"),
    "qrcode": MessageLookupByLibrary.simpleMessage("رمز QR"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "مسح رمز QR لاستيراد ملف تعريف",
    ),
    "recovery": MessageLookupByLibrary.simpleMessage("استعادة"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("استعادة جميع البيانات"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "استعادة ملفات التعريف فقط",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("استعادة ناجحة"),
    "regExp": MessageLookupByLibrary.simpleMessage("تعبير منتظم"),
    "remote": MessageLookupByLibrary.simpleMessage("بعيد"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "نسخ احتياطي للبيانات في WebDAV",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "استعادة البيانات من WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("إزالة"),
    "requests": MessageLookupByLibrary.simpleMessage("الطلبات"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "عرض سجلات الطلبات الأخيرة",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("إعادة تعيين"),
    "resetTip": MessageLookupByLibrary.simpleMessage("إعادة تعيين الإعدادات؟"),
    "resources": MessageLookupByLibrary.simpleMessage("الموارد"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "معلومات حول الموارد الخارجية",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("اتباع القواعد"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "اتصالات DNS تتبع القواعد، تتطلب إعداد البروكسي وخادم الأسماء",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("عنوان التوجيه"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "ضبط عنوان التوجيه للاستماع",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("وضع التوجيه"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "تجاوز عناوين التوجيه الخاصة",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("استخدام الملف الشخصي"),
    "ru": MessageLookupByLibrary.simpleMessage("روسي"),
    "rule": MessageLookupByLibrary.simpleMessage("قاعدة"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("مزودو القواعد"),
    "save": MessageLookupByLibrary.simpleMessage("حفظ"),
    "search": MessageLookupByLibrary.simpleMessage("بحث"),
    "seconds": MessageLookupByLibrary.simpleMessage("ثوانٍ"),
    "selectAll": MessageLookupByLibrary.simpleMessage("تحديد الكل"),
    "selected": MessageLookupByLibrary.simpleMessage("محدد"),
    "settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "show": MessageLookupByLibrary.simpleMessage("إظهار"),
    "shrink": MessageLookupByLibrary.simpleMessage("تقليص"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("تشغيل صامت"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "تشغيل التطبيق في الخلفية",
    ),
    "size": MessageLookupByLibrary.simpleMessage("الحجم"),
    "sort": MessageLookupByLibrary.simpleMessage("فرز"),
    "source": MessageLookupByLibrary.simpleMessage("المصدر"),
    "stackMode": MessageLookupByLibrary.simpleMessage("وضع المكدس"),
    "standard": MessageLookupByLibrary.simpleMessage("قياسي"),
    "start": MessageLookupByLibrary.simpleMessage("بدء"),
    "startVpn": MessageLookupByLibrary.simpleMessage("جارٍ بدء VPN…"),
    "status": MessageLookupByLibrary.simpleMessage("الحالة"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "عند الإيقاف، سيتم استخدام DNS النظام",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("إيقاف"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("جارٍ إيقاف VPN…"),
    "style": MessageLookupByLibrary.simpleMessage("النمط"),
    "submit": MessageLookupByLibrary.simpleMessage("إرسال"),
    "sync": MessageLookupByLibrary.simpleMessage("مزامنة"),
    "system": MessageLookupByLibrary.simpleMessage("النظام"),
    "systemFont": MessageLookupByLibrary.simpleMessage("خط النظام"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("بروكسي النظام"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "إضافة بروكسي HTTP إلى VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("علامة تبويب"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("حركة علامة التبويب"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، سيتم عرض حركة عند تبديل علامات التبويب في الصفحة الرئيسية",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP متزامن"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، يُسمح بالنقل المتزامن لـ TCP",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("URL اختبار"),
    "theme": MessageLookupByLibrary.simpleMessage("السمة"),
    "themeColor": MessageLookupByLibrary.simpleMessage("لون السمة"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "ضبط الوضع الداكن أو تعديل الألوان",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("وضع السمة"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("ثلاثة أعمدة"),
    "tight": MessageLookupByLibrary.simpleMessage("مضغوط"),
    "time": MessageLookupByLibrary.simpleMessage("الوقت"),
    "tip": MessageLookupByLibrary.simpleMessage("نصيحة"),
    "toggle": MessageLookupByLibrary.simpleMessage("تبديل"),
    "tools": MessageLookupByLibrary.simpleMessage("أدوات"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("استخدام الحركة"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "يعمل فقط في وضع المسؤول",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("عمودان"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "غير قادر على تحديث الملف الشخصي الحالي",
    ),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("تأخير موحد"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "إزالة التأخيرات الإضافية مثل المصافحة",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("غير معروف"),
    "update": MessageLookupByLibrary.simpleMessage("تحديث"),
    "upload": MessageLookupByLibrary.simpleMessage("رفع"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "استرجاع ملف تعريف عبر URL",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("استخدام إعدادات المضيف"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("استخدام مضيفات النظام"),
    "value": MessageLookupByLibrary.simpleMessage("القيمة"),
    "view": MessageLookupByLibrary.simpleMessage("عرض"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "تعديل الإعدادات المتعلقة بـ VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "عند التفعيل، سيتم توجيه كل حركة النظام تلقائيًا عبر VpnService",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "دمج بروكسي HTTP في VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "تُطبق الإعدادات بعد إعادة تشغيل VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "تكوين WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("وضع القائمة البيضاء"),
    "years": MessageLookupByLibrary.simpleMessage("سنوات"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("صيني مبسط"),
    "zh_TW": MessageLookupByLibrary.simpleMessage("صيني تقليدي"),
  };
}
