// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// Этот файл является библиотекой сообщений для локали en. Все сообщения из основного приложения должны быть здесь повторно определены с теми же именами функций.

// Игнорируем распространённые проблемы lint в этом файле.
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
  String get localeName => 'ru';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("О программе"),
    "accessControl": MessageLookupByLibrary.simpleMessage("Контроль доступа"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Только указанные приложения могут использовать VPN",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка прав доступа приложений к прокси",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "Выбранные приложения не смогут использовать VPN",
    ),
    "account": MessageLookupByLibrary.simpleMessage("Учётная запись"),
    "accountTip": MessageLookupByLibrary.simpleMessage(
      "Поле учётной записи не может быть пустым",
    ),
    "action": MessageLookupByLibrary.simpleMessage("Действие"),
    "action_mode": MessageLookupByLibrary.simpleMessage("Переключение режима"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "action_start": MessageLookupByLibrary.simpleMessage("Запуск/Остановка"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("Показать/Скрыть"),
    "add": MessageLookupByLibrary.simpleMessage("Добавить"),
    "address": MessageLookupByLibrary.simpleMessage("Адрес"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "Адрес сервера WebDAV",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "Введите действительный адрес WebDAV",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "Автозапуск от имени администратора",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматический запуск с правами администратора",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("назад"),
    "agree": MessageLookupByLibrary.simpleMessage("Согласен"),
    "allApps": MessageLookupByLibrary.simpleMessage("Все приложения"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "Разрешить приложениям обходить VPN",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "При активации некоторые приложения смогут обходить VPN",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("Разрешить LAN"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить доступ к прокси через локальную сеть",
    ),
    "app": MessageLookupByLibrary.simpleMessage("Приложение"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "Контроль доступа приложений",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "Управление настройками приложений",
    ),
    "application": MessageLookupByLibrary.simpleMessage("Приложение"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка параметров приложений",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("Автоматически"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "Автоматическая проверка обновлений",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "Проверка обновлений при запуске программы",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "Автоматическое закрытие соединений",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Закрытие существующих соединений при смене узла",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("Автозапуск"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запуск вместе с системой",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("Автостарт"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "Автоматический запуск при старте приложения",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("Автообновление"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "Интервал автообновления (в минутах)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("Резервная копия"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование и восстановление",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Синхронизация данных через WebDAV или файлы",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("Резервная копия создана"),
    "bind": MessageLookupByLibrary.simpleMessage("Привязка"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("Режим чёрного списка"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("Обход домена"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "Применяется только при включённом системном прокси",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "Кэш повреждён. Очистить?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("Отмена"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Отключить фильтр системных приложений",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "Снять выделение со всех",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("Проверка ошибок"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("Проверить обновления"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "Текущая версия приложения является последней",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("Проверка…"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("Экспорт в буфер обмена"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("Импорт из буфера обмена"),
    "columns": MessageLookupByLibrary.simpleMessage("Столбцы"),
    "compatible": MessageLookupByLibrary.simpleMessage("Режим совместимости"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "При активации некоторые функции приложений будут ограничены для полной поддержки Clash",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("Подтвердить"),
    "connections": MessageLookupByLibrary.simpleMessage("Соединения"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр информации о текущих соединениях",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("Состояние соединения:"),
    "copy": MessageLookupByLibrary.simpleMessage("Копировать"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "Копировать переменные окружения",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("Копировать ссылку"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("Копирование успешно"),
    "core": MessageLookupByLibrary.simpleMessage("Ядро"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("Информация о ядре"),
    "country": MessageLookupByLibrary.simpleMessage("Страна/регион"),
    "create": MessageLookupByLibrary.simpleMessage("Создать"),
    "cut": MessageLookupByLibrary.simpleMessage("Вырезать"),
    "dark": MessageLookupByLibrary.simpleMessage("Тёмный"),
    "dashboard": MessageLookupByLibrary.simpleMessage("Панель управления"),
    "days": MessageLookupByLibrary.simpleMessage("дней"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "Сервер имён по умолчанию",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер для разрешения DNS",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("Сортировка по умолчанию"),
    "defaultText": MessageLookupByLibrary.simpleMessage("По умолчанию"),
    "delay": MessageLookupByLibrary.simpleMessage("Задержка"),
    "delaySort": MessageLookupByLibrary.simpleMessage("Сортировка по задержке"),
    "delete": MessageLookupByLibrary.simpleMessage("Удалить"),
    "deleteProfileTip": MessageLookupByLibrary.simpleMessage(
      "Удалить текущий профиль?",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "Мультиплатформенный прокси-клиент на основе ClashMeta, простой в использовании, с открытым исходным кодом и без рекламы",
    ),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "Зависит от стороннего API, результаты только для справки",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("Прямое соединение"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Отказ от ответственности"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "Данное ПО предназначено только для учебных и научных целей, некоммерческого использования. Использование в коммерческих целях строго запрещено. Любые коммерческие действия (если таковые имеются) не связаны с этим ПО",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "Обнаружена новая версия",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "Обнаружена новая версия",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "Обновление настроек DNS",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("Режим DNS"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "Вы уверены, что хотите пройти?",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("Домен"),
    "download": MessageLookupByLibrary.simpleMessage("Скачать"),
    "edit": MessageLookupByLibrary.simpleMessage("Редактировать"),
    "en": MessageLookupByLibrary.simpleMessage("Английский"),
    "entries": MessageLookupByLibrary.simpleMessage("Записи"),
    "exclude": MessageLookupByLibrary.simpleMessage("Скрыть из недавних задач"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "Скрытие приложения из списка недавних задач при работе в фоновом режиме",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("Выход"),
    "expand": MessageLookupByLibrary.simpleMessage("Стандарт"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("Срок действия"),
    "exportFile": MessageLookupByLibrary.simpleMessage("Экспорт файла"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("Экспорт логов"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("Экспорт успешен"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "Внешний контроллер",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "При активации управление ядром Clash возможно через порт 9090",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("Внешняя ссылка"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "Внешние ресурсы",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Фильтр Fake IP"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Диапазон Fake IP"),
    "fallback": MessageLookupByLibrary.simpleMessage("Резервный"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "Обычно используется зарубежный DNS-сервер",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("Фильтр резервного копирования"),
    "file": MessageLookupByLibrary.simpleMessage("Файл"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("Прямая загрузка файла профиля"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "Файл изменён. Сохранить изменения?",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "Фильтр системных приложений",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("Режим поиска процессов"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "При активации возможны сбои в работе программ",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("Семейство шрифтов"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("Четыре столбца"),
    "general": MessageLookupByLibrary.simpleMessage("Общие"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "Управление общими настройками",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("Геоданные"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "Режим загрузки геоданных с низким потреблением памяти",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "При активации используется загрузчик геоданных с низким потреблением памяти",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("Код GeoIP"),
    "global": MessageLookupByLibrary.simpleMessage("Глобальный"),
    "go": MessageLookupByLibrary.simpleMessage("Перейти"),
    "goDownload": MessageLookupByLibrary.simpleMessage("Перейти к загрузке"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "Сохранить изменения в кэше?",
    ),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("Добавление настроек хоста"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("Конфликт горячих клавиш"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "Управление горячими клавишами",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "Управление приложением с помощью горячих клавиш",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("часов"),
    "icon": MessageLookupByLibrary.simpleMessage("Иконка"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройка иконок",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("Стиль иконок"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("Импорт из URL"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("Бессрочный"),
    "init": MessageLookupByLibrary.simpleMessage("Инициализация"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "Введите действительную горячую клавишу",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "Умный выбор",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("IP интрасети"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "При активации возможно получение трафика IPv6",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "Разрешить входящий трафик IPv6",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("Японский"),
    "just": MessageLookupByLibrary.simpleMessage("только что"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "Интервал поддержания соединения TCP",
    ),
    "key": MessageLookupByLibrary.simpleMessage("Ключ"),
    "ko": MessageLookupByLibrary.simpleMessage("Корейский"),
    "fr": MessageLookupByLibrary.simpleMessage("Французский"),
    "de": MessageLookupByLibrary.simpleMessage("Немецкий"),
    "ar": MessageLookupByLibrary.simpleMessage("Арабский"),
    "fa": MessageLookupByLibrary.simpleMessage("Персидский"),
    "language": MessageLookupByLibrary.simpleMessage("Язык"),
    "layout": MessageLookupByLibrary.simpleMessage("Макет"),
    "light": MessageLookupByLibrary.simpleMessage("Светлый"),
    "list": MessageLookupByLibrary.simpleMessage("Список"),
    "listen": MessageLookupByLibrary.simpleMessage("Слушать"),
    "local": MessageLookupByLibrary.simpleMessage("Локальный"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование данных локально",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановление данных из локального файла",
    ),
    "logLevel": MessageLookupByLibrary.simpleMessage("Уровень логов"),
    "logcat": MessageLookupByLibrary.simpleMessage("Захват логов"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "При отключении содержимое логов будет скрыто",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("Логи"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("Просмотр записей логов"),
    "loopback": MessageLookupByLibrary.simpleMessage("Инструмент разблокировки Loopback"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "Используется для снятия ограничений Loopback в UWP",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("Свободный"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("Информация о памяти"),
    "min": MessageLookupByLibrary.simpleMessage("мин"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("Свернуть при выходе"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "Изменение поведения по умолчанию на сворачивание при выходе",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("минут"),
    "mode": MessageLookupByLibrary.simpleMessage("Режим"),
    "months": MessageLookupByLibrary.simpleMessage("месяцев"),
    "more": MessageLookupByLibrary.simpleMessage("Ещё"),
    "name": MessageLookupByLibrary.simpleMessage("Имя"),
    "nameSort": MessageLookupByLibrary.simpleMessage("Сортировка по имени"),
    "nameserver": MessageLookupByLibrary.simpleMessage("Сервер имён"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер для разрешения доменов",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "Политика сервера имён",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "Указание соответствующей политики сервера имён",
    ),
    "network": MessageLookupByLibrary.simpleMessage("Сеть"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка сетевых параметров",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "Обнаружение сети",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("Скорость сети"),
    "noData": MessageLookupByLibrary.simpleMessage("Нет данных"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("Нет горячих клавиш"),
    "noIcon": MessageLookupByLibrary.simpleMessage("Нет иконки"),
    "noInfo": MessageLookupByLibrary.simpleMessage("Нет информации"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("Больше информации нет"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("Нет подключения к сети"),
    "noProxy": MessageLookupByLibrary.simpleMessage("Нет прокси"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Создайте профиль или добавьте действительный профиль",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("Не может быть пустым"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "Текущая группа прокси не может быть выбрана",
    ),
    "nullConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "Нет соединений",
    ),
    "nullCoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "Не удалось получить информацию о ядре",
    ),
    "nullLogsDesc": MessageLookupByLibrary.simpleMessage("Нет записей логов"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Нет профиля, добавьте профиль",
    ),
    "nullProxies": MessageLookupByLibrary.simpleMessage("Нет прокси"),
    "nullRequestsDesc": MessageLookupByLibrary.simpleMessage("Нет записей запросов"),
    "oneColumn": MessageLookupByLibrary.simpleMessage("Один столбец"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("Только иконка"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "Только сторонние приложения",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "Статистика только прокси-трафика",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "При активации записывается только трафик, связанный с прокси",
    ),
    "options": MessageLookupByLibrary.simpleMessage("Опции"),
    "other": MessageLookupByLibrary.simpleMessage("Другое"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "Другие участники",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("Режим исходящего трафика"),
    "override": MessageLookupByLibrary.simpleMessage("Переопределение"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "Переопределение настроек прокси",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("Переопределение DNS"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "При активации настройки DNS в профиле будут переопределены",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Пароль"),
    "passwordTip": MessageLookupByLibrary.simpleMessage(
      "Поле пароля не может быть пустым",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("Вставить"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "Привяжите WebDAV",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "Введите пароль администратора",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "Загрузите файл",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "Загрузите действительный QR-код",
    ),
    "port": MessageLookupByLibrary.simpleMessage("Порт"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "Приоритет использования DOH через HTTP/3",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "Нажмите клавишу на клавиатуре",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("Предпросмотр"),
    "profile": MessageLookupByLibrary.simpleMessage("Профиль"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Введите корректный формат интервала",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "Введите интервал автообновления",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "Профиль изменён. Отключить автообновление?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите имя профиля",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "Ошибка разбора профиля",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите действительный URL профиля",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "Введите URL профиля",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("Профили"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("Сортировка профилей"),
    "project": MessageLookupByLibrary.simpleMessage("Проект"),
    "providers": MessageLookupByLibrary.simpleMessage("Провайдеры"),
    "proxies": MessageLookupByLibrary.simpleMessage("Прокси"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("Настройки прокси"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("Группа прокси"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("Сервер имён прокси"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "Сервер для разрешения доменов узлов прокси",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("Порт прокси"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка порта прослушивания Clash",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("Провайдеры прокси"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("Чисто чёрный режим"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR-код"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "Сканируйте QR-код для импорта профиля",
    ),
    "recovery": MessageLookupByLibrary.simpleMessage("Восстановление"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("Восстановить все данные"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "Восстановить только профили",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("Восстановление успешно"),
    "regExp": MessageLookupByLibrary.simpleMessage("Регулярное выражение"),
    "remote": MessageLookupByLibrary.simpleMessage("Удалённый"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "Резервное копирование данных в WebDAV",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "Восстановление данных из WebDAV",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("Удалить"),
    "requests": MessageLookupByLibrary.simpleMessage("Запросы"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "Просмотр недавних записей запросов",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Сброс"),
    "resetTip": MessageLookupByLibrary.simpleMessage("Сбросить настройки?"),
    "resources": MessageLookupByLibrary.simpleMessage("Ресурсы"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "Информация о внешних ресурсах",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("Следовать правилам"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "Соединения DNS следуют правилам, требуется настройка прокси и серверов имён",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("Адрес маршрутизации"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка адреса прослушивания маршрутизации",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("Режим маршрутизации"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "Обход частных адресов маршрутизации",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("Использовать профиль"),
    "ru": MessageLookupByLibrary.simpleMessage("Русский"),
    "rule": MessageLookupByLibrary.simpleMessage("Правило"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("Провайдеры правил"),
    "save": MessageLookupByLibrary.simpleMessage("Сохранить"),
    "search": MessageLookupByLibrary.simpleMessage("Поиск"),
    "seconds": MessageLookupByLibrary.simpleMessage("секунд"),
    "selectAll": MessageLookupByLibrary.simpleMessage("Выбрать всё"),
    "selected": MessageLookupByLibrary.simpleMessage("Выбрано"),
    "settings": MessageLookupByLibrary.simpleMessage("Настройки"),
    "show": MessageLookupByLibrary.simpleMessage("Показать"),
    "shrink": MessageLookupByLibrary.simpleMessage("Сжать"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("Тихий запуск"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "Запуск приложения в фоновом режиме",
    ),
    "size": MessageLookupByLibrary.simpleMessage("Размер"),
    "sort": MessageLookupByLibrary.simpleMessage("Сортировка"),
    "source": MessageLookupByLibrary.simpleMessage("Источник"),
    "stackMode": MessageLookupByLibrary.simpleMessage("Режим стека"),
    "standard": MessageLookupByLibrary.simpleMessage("Стандартный"),
    "start": MessageLookupByLibrary.simpleMessage("Запуск"),
    "startVpn": MessageLookupByLibrary.simpleMessage("Запуск VPN…"),
    "status": MessageLookupByLibrary.simpleMessage("Статус"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "При выключении используется системный DNS",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("Остановить"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("Остановка VPN…"),
    "style": MessageLookupByLibrary.simpleMessage("Стиль"),
    "submit": MessageLookupByLibrary.simpleMessage("Отправить"),
    "sync": MessageLookupByLibrary.simpleMessage("Синхронизация"),
    "system": MessageLookupByLibrary.simpleMessage("Система"),
    "systemFont": MessageLookupByLibrary.simpleMessage("Системный шрифт"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("Системный прокси"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Добавление HTTP-прокси в VpnService",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("Вкладка"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("Анимация вкладок"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "При активации переключение вкладок на главной странице будет с анимацией",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("Параллельный TCP"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "При активации разрешается параллельная передача TCP",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("Тестовый URL"),
    "theme": MessageLookupByLibrary.simpleMessage("Тема"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Цвет темы"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка тёмного режима или изменение цветов",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Режим темы"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("Три столбца"),
    "tight": MessageLookupByLibrary.simpleMessage("Компактный"),
    "time": MessageLookupByLibrary.simpleMessage("Время"),
    "tip": MessageLookupByLibrary.simpleMessage("Подсказка"),
    "toggle": MessageLookupByLibrary.simpleMessage("Переключить"),
    "tools": MessageLookupByLibrary.simpleMessage("Инструменты"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("Использование трафика"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "Работает только в режиме администратора",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("Два столбца"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "Не удалось обновить текущий профиль",
    ),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("Унифицированная задержка"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "Удаление дополнительных задержек, таких как рукопожатие",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("Неизвестно"),
    "update": MessageLookupByLibrary.simpleMessage("Обновить"),
    "upload": MessageLookupByLibrary.simpleMessage("Загрузить"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "Получение профиля через URL",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("Использовать настройки хоста"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("Использовать системные хосты"),
    "value": MessageLookupByLibrary.simpleMessage("Значение"),
    "view": MessageLookupByLibrary.simpleMessage("Просмотр"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "Настройка параметров VPN",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "При активации весь системный трафик будет автоматически маршрутизироваться через VpnService",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "Интеграция HTTP-прокси в VpnService",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "Настройки вступят в силу после перезапуска VPN",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "Настройки WebDAV",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("Режим белого списка"),
    "years": MessageLookupByLibrary.simpleMessage("лет"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("Упрощённый китайский"),
    "zh_TW": MessageLookupByLibrary.simpleMessage("Традиционный китайский"),
  };
}
