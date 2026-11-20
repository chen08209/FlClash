// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get rule => 'Правило';

  @override
  String get rules => 'Правила';

  @override
  String get global => 'Глобальный';

  @override
  String get direct => 'Прямой';

  @override
  String get dashboard => 'Панель';

  @override
  String get proxies => 'Прокси';

  @override
  String get profile => 'Профиль';

  @override
  String get profiles => 'Профили';

  @override
  String get tools => 'Инструменты';

  @override
  String get logs => 'Логи';

  @override
  String get resources => 'Ресурсы';

  @override
  String get trafficUsage => 'Статистика трафика';

  @override
  String get networkSpeed => 'Скорость сети';

  @override
  String get outboundMode => 'Режим исходящего трафика';

  @override
  String get serviceStatus => 'Состояние сервисов';

  @override
  String get serviceRestricted => 'Доступ ограничен';

  @override
  String get serviceAvailable => 'Доступен';

  @override
  String get serviceUnavailable => 'Недоступен';

  @override
  String get serviceFailed => 'Ошибка проверки';

  @override
  String get serviceDisallowedIsp => 'Недопустимый провайдер';

  @override
  String get serviceBlocked => 'Заблокировано';

  @override
  String get serviceUnsupportedRegion => 'Регион не поддерживается';

  @override
  String get serviceOriginalsOnly => 'Только оригиналы';

  @override
  String get serviceComingSoon => 'Скоро появится';

  @override
  String get servicePending => 'Не проверено';

  @override
  String get serviceManage => 'Управление сервисами';

  @override
  String get serviceCheckAll => 'Проверить все';

  @override
  String get upload => 'Отдача';

  @override
  String get download => 'Загрузка';

  @override
  String get usedTraffic => 'Использованный трафик';

  @override
  String get totalTraffic => 'Общий трафик';

  @override
  String get expireTime => 'Срок действия';

  @override
  String get nullProfileDesc => 'Добавьте профиль, чтобы начать';

  @override
  String get settings => 'Настройки';

  @override
  String get language => 'Язык';

  @override
  String get defaultText => 'По умолчанию';

  @override
  String get more => 'Ещё';

  @override
  String get other => 'Другое';

  @override
  String get about => 'О программе';

  @override
  String get en => 'Английский';

  @override
  String get es => 'Испанский';

  @override
  String get fr => 'Французский';

  @override
  String get ja => 'Японский';

  @override
  String get ko => 'Корейский';

  @override
  String get ru => 'Русский';

  @override
  String get zhCN => 'Упрощённый китайский';

  @override
  String get theme => 'Тема';

  @override
  String get extend => 'Расширение';

  @override
  String get runtimeConfig => 'Конфигурация выполнения';

  @override
  String get allowLan => 'Разрешить LAN';

  @override
  String get tun => 'TUN';

  @override
  String get tunDesc => 'TUN работает только в режиме администратора.';

  @override
  String get minimizeOnExit => 'Сворачивать при выходе';

  @override
  String get autoLaunch => 'Автозапуск';

  @override
  String get silentLaunch => 'Тихий запуск';

  @override
  String get autoRun => 'Автовключение';

  @override
  String get autoRunDesc =>
      'Автовключение запускает прокси при открытии приложения.';

  @override
  String get logcat => 'Захват логов';

  @override
  String get logcatDesc =>
      'При отключении захвата логов раздел логов скрывается.';

  @override
  String get autoCheckUpdate => 'Автопроверка обновлений';

  @override
  String get checkCertificate => 'Проверять TLS-сертификаты';

  @override
  String get checkCertificateDesc =>
      'Без проверки TLS-сертификатов подписки и резервные копии уязвимы для атаки «человек посередине».';

  @override
  String get accessControl => 'Контроль доступа';

  @override
  String get edit => 'Редактировать';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get update => 'Обновить';

  @override
  String get add => 'Добавить';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get seconds => 'секунд';

  @override
  String get qrcode => 'QR-код';

  @override
  String get qrcodeDesc => 'Сканируйте QR-код, чтобы получить профиль';

  @override
  String get url => 'URL';

  @override
  String get link => 'Ссылка';

  @override
  String get file => 'Файл';

  @override
  String get name => 'Название';

  @override
  String get profileNameNullValidationDesc => 'Введите название профиля';

  @override
  String get rename => 'Переименовать';

  @override
  String get profileUrlNullValidationDesc => 'Введите URL профиля';

  @override
  String get profileUrlInvalidValidationDesc =>
      'Введите корректный URL профиля';

  @override
  String get autoUpdate => 'Автообновление';

  @override
  String get autoUpdateInterval => 'Интервал автообновления';

  @override
  String get profileAutoUpdateIntervalNullValidationDesc =>
      'Введите интервал автообновления';

  @override
  String get profileAutoUpdateIntervalInvalidValidationDesc =>
      'Введите корректный интервал';

  @override
  String get themeMode => 'Режим темы';

  @override
  String get themeColor => 'Цвет темы';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get auto => 'Авто';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get importFromLink => 'Импорт по ссылке';

  @override
  String get sendFromPhone => 'Отправить с телефона';

  @override
  String get sendFromPhoneTip =>
      'Отсканируйте код камерой телефона и вставьте ссылку на открывшейся странице. Оба устройства должны быть в одной сети.';

  @override
  String get sendFromPhoneNoNetwork =>
      'Это устройство не подключено к локальной сети';

  @override
  String get sendFromPhonePermissionDenied =>
      'Чтобы получить ссылку с телефона, FlClash нужно разрешение «Устройства поблизости» для доступа к локальной сети. Включите его в настройках приложения.';

  @override
  String get sendFromPhonePageTitle => 'Отправить ссылку в FlClash';

  @override
  String get sendFromPhonePageHint => 'Ссылка на подписку или ссылка на прокси';

  @override
  String get send => 'Отправить';

  @override
  String get sendFromPhonePageSent =>
      'Отправлено. Подтвердите импорт на другом устройстве.';

  @override
  String get sendFromPhoneConfirmTitle => 'Импортировать ссылку с телефона?';

  @override
  String get shareQrcodeTip =>
      'Отсканируйте в FlClash на другом устройстве, чтобы импортировать этот профиль.';

  @override
  String get qrcodeTooLongTip =>
      'Ссылка слишком длинная для QR-кода. Используйте «Копировать ссылку».';

  @override
  String get submit => 'Отправить';

  @override
  String createProfileFromUrlTip(Object url) {
    return 'Создать профиль по ссылке $url?';
  }

  @override
  String get create => 'Создать';

  @override
  String get pleaseUploadValidQrcode => 'Загрузите корректный QR-код';

  @override
  String get blacklistMode => 'Режим чёрного списка';

  @override
  String get whitelistMode => 'Режим белого списка';

  @override
  String get selectAll => 'Выбрать всё';

  @override
  String get cancelSelectAll => 'Снять выделение';

  @override
  String get appAccessControl => 'Контроль доступа приложений';

  @override
  String get accessControlAllowDesc =>
      'Через VPN проходят только выбранные приложения';

  @override
  String get accessControlNotAllowDesc =>
      'Выбранные приложения исключаются из VPN';

  @override
  String get accessControlDisabledDesc =>
      'Контроль доступа приложений отключён';

  @override
  String accessControlSelectedCount(num count) {
    return 'Выбрано: $count';
  }

  @override
  String get port => 'Порт';

  @override
  String get logLevel => 'Уровень логов';

  @override
  String get show => 'Показать';

  @override
  String get exit => 'Выход';

  @override
  String get systemProxy => 'Системный прокси';

  @override
  String get safeMode => 'Безопасный режим';

  @override
  String safeModeAppTitle(Object appName) {
    return '$appName (Безопасный режим)';
  }

  @override
  String get project => 'Проект';

  @override
  String get core => 'Ядро';

  @override
  String get tabAnimation => 'Анимация вкладок';

  @override
  String get desc =>
      'Многоплатформенный прокси-клиент на основе ClashMeta: простой и удобный, с открытым исходным кодом и без рекламы.';

  @override
  String get startVpn => 'Запуск VPN…';

  @override
  String get stopVpn => 'Остановка VPN…';

  @override
  String get localNetworkDeniedTip =>
      'Доступ к локальной сети запрещён: используется стек gvisor, локальная сеть недоступна.';

  @override
  String get compatible => 'Режим совместимости';

  @override
  String get notSelectedTip => 'Текущую группу прокси нельзя выбрать';

  @override
  String get changeProxyFailedTip =>
      'Не удалось переключить прокси; восстановлен предыдущий выбор';

  @override
  String get databaseWriteFailedTip =>
      'Не удалось сохранить изменение; оно отменено';

  @override
  String get tip => 'Подсказка';

  @override
  String get account => 'Аккаунт';

  @override
  String get backup => 'Резервное копирование';

  @override
  String get backupSuccess => 'Резервная копия создана';

  @override
  String get noInfo => 'Нет информации';

  @override
  String get pleaseBindWebDAV => 'Привяжите WebDAV';

  @override
  String get bind => 'Привязать';

  @override
  String get connectivity => 'Подключение: ';

  @override
  String get webDAVConfiguration => 'Настройка WebDAV';

  @override
  String get address => 'Адрес';

  @override
  String get addressTip => 'Введите корректный адрес WebDAV';

  @override
  String get password => 'Пароль';

  @override
  String get authentication => 'Аутентификация';

  @override
  String get authenticationSystemProxyDesc =>
      'Пока включена аутентификация, системный прокси не применяется.';

  @override
  String get checkUpdate => 'Проверить обновления';

  @override
  String get discoverNewVersion => 'Доступна новая версия';

  @override
  String get checkUpdateError => 'У вас уже последняя версия';

  @override
  String get goDownload => 'Скачать';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get country => 'Регион';

  @override
  String get search => 'Поиск';

  @override
  String get allowBypass => 'Разрешить приложениям обходить VPN';

  @override
  String get externalController => 'Внешний контроллер';

  @override
  String get externalControllerDesc =>
      'Внешний контроллер позволяет управлять ядром через порт 9090.';

  @override
  String get externalControllerSecret => 'Секрет внешнего контроллера';

  @override
  String get ipv6Desc => 'Трафик IPv6 принимается, только когда IPv6 включён.';

  @override
  String get app => 'Приложение';

  @override
  String get general => 'Общие';

  @override
  String get startupAndBackground => 'Запуск и фоновая работа';

  @override
  String get requestsAndUpdates => 'Запросы и обновления';

  @override
  String get logsAndDiagnostics => 'Логи и диагностика';

  @override
  String get userAgent => 'User-Agent';

  @override
  String get unifiedDelay => 'Единая задержка';

  @override
  String get tcpConcurrent => 'Параллельный TCP';

  @override
  String get geodataLoader => 'Geo: экономия памяти';

  @override
  String get requests => 'Запросы';

  @override
  String get recentRequests => 'Последние запросы';

  @override
  String get alwaysFindProcess => 'Всегда искать процесс';

  @override
  String get init => 'Инициализация';

  @override
  String get infiniteTime => 'Бессрочно';

  @override
  String get connections => 'Соединения';

  @override
  String get liveConnections => 'Активные соединения';

  @override
  String get inbound => 'Входящие';

  @override
  String get intranetIP => 'Внутренний IP';

  @override
  String get view => 'Просмотр';

  @override
  String get cut => 'Вырезать';

  @override
  String get copy => 'Копировать';

  @override
  String get clipboardWriteFailed =>
      'Не удалось скопировать в буфер обмена. Возможно, выделение слишком велико';

  @override
  String get paste => 'Вставить';

  @override
  String get testUrl => 'URL для теста';

  @override
  String get delayTestTimeout => 'Тайм-аут теста задержки';

  @override
  String get sync => 'Синхронизация';

  @override
  String get exclude => 'Скрыть из недавних задач';

  @override
  String get compact => 'Компактный';

  @override
  String get tab => 'Вкладки';

  @override
  String get list => 'Список';

  @override
  String get delay => 'Задержка';

  @override
  String get style => 'Стиль';

  @override
  String get size => 'Размер';

  @override
  String get sort => 'Сортировка';

  @override
  String get columns => 'Столбцы';

  @override
  String get proxyGroup => 'Группа прокси';

  @override
  String get go => 'Перейти';

  @override
  String get externalLink => 'Внешняя ссылка';

  @override
  String get otherContributors => 'Другие участники';

  @override
  String get appIconDesign => 'Дизайн значка приложения';

  @override
  String get autoCloseConnections => 'Автозакрытие соединений';

  @override
  String get onlyStatisticsProxy => 'Учитывать только трафик прокси';

  @override
  String get showNotificationStopAction => 'Кнопка остановки в уведомлении';

  @override
  String get pureBlackMode => 'Чисто чёрный режим';

  @override
  String get sidebar => 'Боковая панель';

  @override
  String get backgroundBlur => 'Размытие фона';

  @override
  String get liquidGlass => 'Жидкое стекло';

  @override
  String get keepAliveIntervalDesc => 'Интервал TCP keep-alive';

  @override
  String get entries => ' записей';

  @override
  String get local => 'Локально';

  @override
  String get remote => 'Удалённо';

  @override
  String get mode => 'Режим';

  @override
  String get time => 'Время';

  @override
  String get source => 'Источник';

  @override
  String get action => 'Действие';

  @override
  String get intelligentSelected => 'Умный выбор';

  @override
  String get clipboardImport => 'Импорт из буфера обмена';

  @override
  String get clipboardNoPackageNames =>
      'В буфере обмена нет допустимых имён пакетов';

  @override
  String get clipboardExport => 'Экспорт в буфер обмена';

  @override
  String get layout => 'Макет';

  @override
  String get tight => 'Плотный';

  @override
  String get standard => 'Стандартный';

  @override
  String get ultra => 'Максимум';

  @override
  String get loose => 'Свободный';

  @override
  String get profilesSort => 'Сортировка профилей';

  @override
  String get start => 'Старт';

  @override
  String get runTime => 'Время работы';

  @override
  String get stop => 'Стоп';

  @override
  String get key => 'Ключ';

  @override
  String get value => 'Значение';

  @override
  String get options => 'Опции';

  @override
  String get enabled => 'Включено';

  @override
  String get disabled => 'Выключено';

  @override
  String get loopback => 'Снятие ограничения loopback для UWP';

  @override
  String get providers => 'Внешние ресурсы';

  @override
  String get proxyProviders => 'Провайдеры прокси';

  @override
  String get ruleProviders => 'Провайдеры правил';

  @override
  String get providerUrlTip => 'Поддерживаются только удалённые ресурсы';

  @override
  String get ruleSetEmptyTip => 'В наборе правил нет пригодных записей';

  @override
  String get ruleSetMixedTip =>
      'Набор правил смешивает домены и диапазоны IP, поэтому его тип не определить';

  @override
  String get ruleSetInvalidTip => 'Не удаётся прочитать этот файл mrs';

  @override
  String get subscriptionInfo => 'Информация о подписке';

  @override
  String get server => 'Сервер';

  @override
  String get ntpInterval => 'Интервал синхронизации (минуты)';

  @override
  String get dialerProxy => 'Прокси для подключения';

  @override
  String get writeToSystem => 'Записывать в систему';

  @override
  String get writeToSystemDesc =>
      '«Записывать в систему» также устанавливает системные часы; Android это игнорирует.';

  @override
  String get sniffer => 'Сниффер';

  @override
  String get overrideDestination => 'Подменять адрес назначения';

  @override
  String get forceDnsMapping => 'Принудительно для DNS-сопоставлений';

  @override
  String get forceDnsMappingDesc =>
      '«Принудительно для DNS-сопоставлений» анализирует и соединения, домен которых получен из DNS-сопоставления.';

  @override
  String get parsePureIp => 'Разбирать чистые IP';

  @override
  String get forceDomain => 'Принудительные домены';

  @override
  String get forceDomainDesc =>
      'Принудительные домены тоже анализируются; остальные соединения с доменом не затрагиваются.';

  @override
  String get skipDomain => 'Пропускаемые домены';

  @override
  String get skipSrcAddress => 'Пропускаемые адреса источника';

  @override
  String get skipDstAddress => 'Пропускаемые адреса назначения';

  @override
  String get sniffProtocols => 'Протоколы';

  @override
  String get ports => 'Порты';

  @override
  String get overrideEntries => 'Переопределяемые параметры';

  @override
  String get addOverrideEntry => 'Добавить параметр';

  @override
  String get dnsOverrideDesc =>
      'Добавленные здесь параметры заменяют DNS всех профилей из URL и файлов; остальные остаются такими, как в профиле. DNS пользовательского профиля задаётся в его содержимом.';

  @override
  String get settingEntries => 'параметры';

  @override
  String get addSettingEntry => 'Добавить параметр';

  @override
  String get profileSettingsDesc =>
      'Действует только для этого профиля; не добавленные параметры используют значения по умолчанию.';

  @override
  String get healthCheck => 'Проверка состояния';

  @override
  String get discardChanges => 'Отменить изменения?';

  @override
  String get quickEdit => 'Быстрое редактирование';

  @override
  String get status => 'Статус';

  @override
  String get statusDesc => 'При отключённом DNS используется системный DNS.';

  @override
  String get respectRules => 'Соблюдать правила';

  @override
  String get respectRulesDesc =>
      '«Соблюдать правила» направляет DNS-соединения по правилам; нужен Proxy Server Nameserver.';

  @override
  String get dnsMode => 'Режим DNS';

  @override
  String get fakeipRange => 'Диапазон Fake-IP';

  @override
  String get fakeipFilter => 'Фильтр Fake-IP';

  @override
  String get useHosts => 'Использовать hosts';

  @override
  String get useSystemHosts => 'Использовать системный hosts';

  @override
  String get fallbackFilter => 'Фильтр fallback';

  @override
  String get domain => 'Домен';

  @override
  String get listenRoutingMark => 'Метка маршрутизации';

  @override
  String get listenRoutingMarkDesc =>
      'Метка маршрутизации действует только в Linux.';

  @override
  String get ipv6Timeout => 'Тайм-аут IPv6 (мс)';

  @override
  String get cacheAlgorithm => 'Алгоритм кэша';

  @override
  String get cacheMaxSize => 'Размер кэша';

  @override
  String get fakeipRange6 => 'Диапазон Fake-IP (IPv6)';

  @override
  String get fakeipFilterMode => 'Режим фильтра Fake-IP';

  @override
  String get fakeipTtl => 'TTL Fake-IP';

  @override
  String get reset => 'Сброс';

  @override
  String get actionView => 'Показать/Скрыть';

  @override
  String get actionStart => 'Старт/Стоп';

  @override
  String get actionMode => 'Переключить режим';

  @override
  String get actionProxy => 'Системный прокси';

  @override
  String get actionTun => 'TUN';

  @override
  String get actionRuleMode => 'Режим правил';

  @override
  String get actionGlobalMode => 'Глобальный режим';

  @override
  String get actionDirectMode => 'Прямой режим';

  @override
  String get actionDelayTest => 'Проверить все задержки';

  @override
  String get actionUpdateProfiles => 'Обновить профили';

  @override
  String get disclaimer => 'Отказ от ответственности';

  @override
  String get disclaimerDesc =>
      'Перед использованием FlClash («Программа») внимательно прочитайте это заявление и убедитесь, что понимаете его. Нажимая «Согласен», вы подтверждаете, что прочитали и поняли изложенное ниже. Если не хотите продолжать, нажмите «Выход».';

  @override
  String get disclaimerSoftwareTitle => 'Характер программы';

  @override
  String get disclaimerSoftwareContent =>
      'Программа — это клиент сетевого прокси с открытым исходным кодом на основе ядра Clash.Meta (mihomo). Она предоставляет только локальные инструменты: управление конфигурациями, маршрутизацию по правилам и пересылку трафика.';

  @override
  String get disclaimerNoServiceStatement =>
      'Сама Программа не предоставляет прокси-серверы, узлы, подписки или услуги доступа к сети и не состоит в партнёрских, агентских или гарантийных отношениях с поставщиками таких услуг.';

  @override
  String get disclaimerUsageTitle => 'Об использовании';

  @override
  String get disclaimerUsageContent =>
      'Любая коммерческая деятельность с использованием Программы, включая платное распространение, продажу в комплекте или использование в составе коммерческого сервиса, не связана с разработчиками Программы, которые её не одобряют, не поддерживают и не гарантируют.\n\nВы сами отвечаете за соблюдение законов страны или региона, где находитесь, и несёте последствия любого незаконного использования Программы.';

  @override
  String get disclaimerResponsibilityTitle => 'Ваша ответственность';

  @override
  String get disclaimerResponsibilityContent =>
      'Вы самостоятельно убеждаетесь, что использование Программы законно в вашей стране или регионе, и единолично несёте юридическую ответственность за все действия с ней и их последствия.\n\nПодписки, узлы и конфигурации, которые вы импортируете, выбираете вы сами. Законность их источника, безопасность содержимого и надёжность сервиса — вопрос между вами и их поставщиками.';

  @override
  String get disclaimerThirdPartyTitle => 'Сторонний контент';

  @override
  String get disclaimerThirdPartyContent =>
      'Ссылки на подписки, файлы конфигурации, наборы правил, скрипты, внешние ресурсы и внешние ссылки предоставляются третьими лицами. Разработчики не могут проверять и не проверяют их законность, точность, безопасность и доступность и не дают на них никаких гарантий.\n\nУтечка данных, финансовые потери, блокировка аккаунта или иной ущерб, вызванные сторонним контентом, урегулируются между вами и третьим лицом; разработчики не несут за это никакой ответственности.';

  @override
  String get disclaimerWarrantyTitle => 'Отсутствие гарантий';

  @override
  String get disclaimerWarrantyContent =>
      'Программа предоставляется «как есть» и «по мере доступности», без каких-либо явных или подразумеваемых гарантий, включая, помимо прочего, гарантии товарной пригодности, пригодности для определённой цели, ненарушения прав, бесперебойной работы, отсутствия ошибок и уязвимостей.\n\nРазработчики не гарантируют, что Программа будет соответствовать вашим потребностям или работать без сбоев и ошибок.';

  @override
  String get disclaimerLiabilityTitle => 'Ограничение ответственности';

  @override
  String get disclaimerLiabilityContent =>
      'В максимальной степени, допустимой применимым законодательством, ни разработчики, ни участники проекта не несут ответственности за любой прямой, косвенный, случайный, особый, штрафной или последующий ущерб, возникший в результате использования или невозможности использования Программы, включая, помимо прочего, потерю данных, повреждение устройства, сбои сети, прерывание деятельности, упущенную выгоду или связанные с этим правовые споры, даже если они были предупреждены о возможности такого ущерба.';

  @override
  String get disclaimerPrivacyTitle => 'Сбор данных и конфиденциальность';

  @override
  String get disclaimerPrivacyContent =>
      'Программа не собирает и не отправляет адреса ваших подписок, сведения об узлах, содержимое конфигураций, посещённые сайты, записи о подключениях, содержимое трафика и журналы. Эти данные хранятся только на вашем устройстве, и у разработчиков нет к ним доступа.\n\nПрограмма обращается к сети только при использовании соответствующих функций, например загружает указанный вами адрес подписки при обновлении профиля или обращается к GitHub при проверке обновлений.\n\nПрограмма не содержит никаких сервисов статистики или отчётов о сбоях ни на одной платформе.';

  @override
  String get disclaimerLicenseTitle => 'Лицензия с открытым исходным кодом';

  @override
  String get disclaimerLicenseContent =>
      'Программа распространяется с открытым исходным кодом по лицензии GPL-3.0. По этой лицензии вы можете запускать, изучать, изменять и распространять её; распространяя Программу или её изменённую версию, вы должны также предоставить исходный код по GPL-3.0 и сохранить исходные уведомления об авторских правах.\n\nСторонние компоненты Программы, включая ядро Clash.Meta, распространяются по своим лицензиям. Исходные авторы не отвечают за проблемы версий, изменённых или распространяемых другими.';

  @override
  String get disclaimerChangesTitle => 'Изменения заявления';

  @override
  String get disclaimerChangesContent =>
      'Это заявление может меняться в следующих версиях; к каждой версии относится заявление, поставляемое с ней.';

  @override
  String get disclaimerAcceptTitle => 'Связь с открытой лицензией';

  @override
  String get disclaimerAcceptContent =>
      'Это заявление описывает характер, риски и ответственность при использовании Программы. Оно не является дополнительным условием к GPL-3.0 и не ограничивает никаких прав, которые даёт вам эта лицензия, включая право запускать, копировать, изменять и распространять Программу. При расхождении действует GPL-3.0.';

  @override
  String get disclaimerRestateTitle => 'Повторите заявление';

  @override
  String get disclaimerRestateTip =>
      'Чтобы подтвердить, что вы ознакомились с ним, полностью введите следующее заявление в поле ниже:';

  @override
  String get disclaimerRestateHint => 'Введите заявление выше';

  @override
  String get disclaimerRestateMismatch => 'Не совпадает с текстом заявления';

  @override
  String get disclaimerAcknowledgeTitle => 'Подтвердите заявление';

  @override
  String get disclaimerAcknowledgeTip =>
      'Чтобы подтвердить, что вы ознакомились с ним, прочитайте следующее заявление и отметьте пункт ниже:';

  @override
  String get disclaimerAcknowledgeLabel =>
      'Я прочитал(а) и понимаю это заявление';

  @override
  String get agree => 'Согласен';

  @override
  String get hotkeyManagement => 'Горячие клавиши';

  @override
  String get hotkeyDesc =>
      'Глобальные горячие клавиши работают, даже когда окно скрыто. Нажмите на действие, чтобы записать сочетание клавиш.';

  @override
  String get hotkeyNotSet => 'Не задано';

  @override
  String get pressKeyboard => 'Нажмите сочетание клавиш';

  @override
  String hotkeyNeedsModifier(Object modifiers) {
    return 'Добавьте хотя бы одну из клавиш: $modifiers';
  }

  @override
  String hotkeyConflictWith(Object action) {
    return 'Уже используется для «$action». При сохранении будет перенесено сюда.';
  }

  @override
  String get hotkeyUnavailable =>
      'Не зарегистрировано: сочетание может быть занято другим приложением';

  @override
  String get remove => 'Убрать';

  @override
  String get noNetwork => 'Нет сети';

  @override
  String get exportLogs => 'Экспорт логов';

  @override
  String get exportSuccess => 'Экспорт выполнен';

  @override
  String get iconStyle => 'Стиль значков';

  @override
  String get iconStyleFilled => 'С подложкой';

  @override
  String get iconStylePlain => 'Без подложки';

  @override
  String get iconStyleHidden => 'Скрыто';

  @override
  String get filter => 'Фильтр';

  @override
  String get groupBy => 'Группировка';

  @override
  String get hideTimeoutProxies => 'Скрывать прокси с таймаутом';

  @override
  String get stackMode => 'Режим стека';

  @override
  String get network => 'Сеть';

  @override
  String get bypassDomain => 'Исключённые домены';

  @override
  String get pacMode => 'Режим PAC';

  @override
  String get pacScript => 'Скрипт PAC';

  @override
  String get bypassDomainDesc =>
      'Исключённые домены действуют только при включённом системном прокси.';

  @override
  String get bypassLocalWindowsOnly => 'Только Windows: имена хостов без точки';

  @override
  String get resetTip => 'Вы уверены, что хотите выполнить сброс?';

  @override
  String get icon => 'Значок';

  @override
  String get noData => 'Нет данных';

  @override
  String get fontFamily => 'Шрифт';

  @override
  String get installedFonts => 'Установленные шрифты';

  @override
  String get toggle => 'Переключить';

  @override
  String get system => 'Система';

  @override
  String get routeAddress => 'Адреса маршрутов';

  @override
  String get interfaceNameMode => 'Исходящий интерфейс';

  @override
  String get interfaceNameModeClear => 'Очистить';

  @override
  String get interfaceNameModeFollow => 'Как в конфигурации';

  @override
  String get interfaceNameModeCustom => 'Вручную';

  @override
  String get interfaceName => 'Имя интерфейса';

  @override
  String get copyEnvVar => 'Копировать переменные окружения';

  @override
  String get memoryInfo => 'Память';

  @override
  String get total => 'Всего';

  @override
  String get releaseMemory => 'Освободить память';

  @override
  String get memoryCoreHeapInuse => 'Используемая куча';

  @override
  String get memoryCoreHeapIdle => 'Свободная куча';

  @override
  String get memoryCoreStack => 'Стеки горутин';

  @override
  String get memoryCoreRuntime => 'Накладные расходы среды';

  @override
  String get memoryCoreNotRunning => 'Ядро не запущено';

  @override
  String get memoryAppResident => 'Резидентная память';

  @override
  String get memoryAppShared => 'Приложение и общая';

  @override
  String get memoryEstimateDesc =>
      'Оценка по резидентной памяти процессов; может отличаться от данных системы.';

  @override
  String get memoryEstimateSharedDesc =>
      'Ядро работает в процессе приложения. Его доля оценивается по статистике среды выполнения, остальное относится к приложению и общей памяти.';

  @override
  String get memoryReleased => 'Память освобождена';

  @override
  String memoryReleasedSize(Object size) {
    return 'Освобождено $size';
  }

  @override
  String get releaseMemoryFailed => 'Не удалось освободить память';

  @override
  String get dialog => 'Диалог';

  @override
  String get cancel => 'Отмена';

  @override
  String get fileIsUpdate => 'Файл изменён. Сохранить изменения?';

  @override
  String get profileHasUpdate => 'Профиль изменён. Отключить автообновление?';

  @override
  String get hasCacheChange => 'Кэшировать изменения?';

  @override
  String get copySuccess => 'Скопировано';

  @override
  String get copyLink => 'Копировать ссылку';

  @override
  String get exportFile => 'Экспорт файла';

  @override
  String get cacheCorrupt => 'Кэш повреждён. Очистить его?';

  @override
  String get detectionTip => 'Использует сторонний API; только для справки';

  @override
  String get listen => 'Прослушивание';

  @override
  String get undo => 'Отменить';

  @override
  String get redo => 'Повторить';

  @override
  String get lineWrap => 'Перенос строк';

  @override
  String get none => 'Нет';

  @override
  String get advancedConfig => 'Расширенная конфигурация';

  @override
  String get addRule => 'Добавить правило';

  @override
  String get content => 'Содержимое';

  @override
  String get ruleTarget => 'Цель правила';

  @override
  String get exitDefault => 'По умолчанию';

  @override
  String get customExit => 'Свой выход';

  @override
  String get inputExitName => 'Введите название выхода';

  @override
  String get scriptFailed => 'Не удалось выполнить скрипт';

  @override
  String get sourceIp => 'IP источника';

  @override
  String get noResolve => 'Не разрешать IP';

  @override
  String get saveChanges => 'Сохранить изменения?';

  @override
  String get applyNow => 'Применить сейчас';

  @override
  String get applied => 'Применено';

  @override
  String get cannotSave => 'Не удалось сохранить';

  @override
  String get navigationBarStyle => 'Нижняя панель';

  @override
  String get floating => 'Плавающая';

  @override
  String get docked => 'Закреплённая';

  @override
  String get slide => 'Сдвиг';

  @override
  String get fade => 'Растворение';

  @override
  String get pureBlack => 'Чисто чёрный';

  @override
  String get customColor => 'Свой цвет';

  @override
  String get colorStyle => 'Стиль палитры';

  @override
  String get grid => 'Сетка';

  @override
  String get spectrum => 'Спектр';

  @override
  String get sliders => 'Ползунки';

  @override
  String get hue => 'Оттенок';

  @override
  String get saturation => 'Насыщенность';

  @override
  String get brightness => 'Яркость';

  @override
  String get hex => 'Hex';

  @override
  String get monochromeScheme => 'Монохром';

  @override
  String get vividStyle => 'Яркий';

  @override
  String get tintedStyle => 'Тонированный';

  @override
  String get softStyle => 'Мягкий';

  @override
  String get developerMode => 'Режим разработчика';

  @override
  String get developerModeEnableTip => 'Режим разработчика включён.';

  @override
  String get messageTest => 'Тест сообщения';

  @override
  String get messageTestTip => 'Это сообщение.';

  @override
  String get crashTest => 'Тест сбоя';

  @override
  String get crashDetected => 'Обнаружен сбой';

  @override
  String crashDetectedTip(Object name) {
    return 'Приложение два раза подряд не смогло завершить запуск. Чтобы разорвать цикл, профиль $name снят с выбора, а автоматическая настройка пропущена. Вы можете выбрать его снова в любой момент.';
  }

  @override
  String get launchInterrupted => 'Запуск не завершён';

  @override
  String get launchInterruptedTip =>
      'В прошлый раз приложение неожиданно завершилось во время запуска. Автоматическая настройка для этого запуска пропущена; вы можете запустить её вручную.';

  @override
  String get clearData => 'Очистить данные';

  @override
  String get textScale => 'Масштаб текста';

  @override
  String get textScalePreview => 'Так будет выглядеть текст в приложении';

  @override
  String get followSystem => 'Как в системе';

  @override
  String get internet => 'Интернет';

  @override
  String get systemApp => 'Системные приложения';

  @override
  String get noNetworkApp => 'Приложения без сети';

  @override
  String get restoreStrategy => 'Стратегия восстановления';

  @override
  String get restoreStrategyOverride => 'Перезапись';

  @override
  String get restoreStrategyCompatible => 'Совместимость';

  @override
  String get logsTest => 'Тест логов';

  @override
  String emptyTip(Object label) {
    return 'Поле «$label» не может быть пустым';
  }

  @override
  String urlTip(Object label) {
    return 'Значение «$label» должно быть URL';
  }

  @override
  String get invalidLinkTip =>
      'Это не ссылка на подписку и не ссылка на прокси';

  @override
  String numberTip(Object label) {
    return 'Значение «$label» должно быть числом';
  }

  @override
  String numberRangeTip(Object label, Object min, Object max) {
    return 'Значение «$label» должно быть от $min до $max';
  }

  @override
  String get interval => 'Интервал';

  @override
  String existsTip(Object label) {
    return '«$label» уже существует';
  }

  @override
  String maxLengthTip(Object label, Object max) {
    return '«$label» — не более $max символов';
  }

  @override
  String get singleImport => 'По одному';

  @override
  String get batchImport => 'Массовый импорт';

  @override
  String get batchUrlInputTip => 'По одному URL на строку';

  @override
  String get batchLinkInputTip => 'По одной ссылке на строку';

  @override
  String batchPreviewTip(Object count, Object skipped) {
    return 'Будет добавлено: $count, пропущено (уже есть): $skipped';
  }

  @override
  String lineIssueTip(Object line, Object message) {
    return 'Строка $line: $message';
  }

  @override
  String singleValueTip(Object label) {
    return '«$label» — только одно значение';
  }

  @override
  String deleteTip(Object label) {
    return 'Вы уверены, что хотите удалить «$label»?';
  }

  @override
  String deleteMultipTip(Object label) {
    return 'Вы уверены, что хотите удалить выбранные элементы ($label)?';
  }

  @override
  String nullTip(Object label) {
    return 'Пока нет: $label';
  }

  @override
  String get script => 'Скрипт';

  @override
  String get color => 'Цвет';

  @override
  String get unnamed => 'Без названия';

  @override
  String get pleaseEnterScriptName => 'Введите название скрипта';

  @override
  String get mixedPort => 'Смешанный порт';

  @override
  String get socksPort => 'Порт SOCKS';

  @override
  String get redirPort => 'Порт Redir';

  @override
  String get tproxyPort => 'Порт TProxy';

  @override
  String portTip(Object label) {
    return 'Значение «$label» должно быть от 1024 до 49151';
  }

  @override
  String get portConflictTip => 'Введите другой порт';

  @override
  String get import => 'Импорт';

  @override
  String get importFile => 'Импорт из файла';

  @override
  String get importUrl => 'Импорт по URL';

  @override
  String get startFromScratch => 'С нуля';

  @override
  String details(Object label) {
    return 'Сведения: $label';
  }

  @override
  String get creationTime => 'Время создания';

  @override
  String get process => 'Процесс';

  @override
  String get host => 'Хост';

  @override
  String get destination => 'Назначение';

  @override
  String get destinationGeoIP => 'GeoIP назначения';

  @override
  String get destinationIPASN => 'ASN IP назначения';

  @override
  String get specialProxy => 'Специальный прокси';

  @override
  String get specialRules => 'Специальные правила';

  @override
  String get remoteDestination => 'Удалённое назначение';

  @override
  String get networkType => 'Тип сети';

  @override
  String get proxyChains => 'Цепочка прокси';

  @override
  String get log => 'Лог';

  @override
  String get connection => 'Соединение';

  @override
  String get request => 'Запрос';

  @override
  String get connected => 'Подключено';

  @override
  String get disconnected => 'Отключено';

  @override
  String get connecting => 'Подключение…';

  @override
  String get restartCoreTip => 'Вы уверены, что хотите перезапустить ядро?';

  @override
  String get forceRestartCoreTip =>
      'Вы уверены, что хотите принудительно перезапустить ядро?';

  @override
  String get dnsHijacking => 'Перехват DNS';

  @override
  String get coreStatus => 'Статус ядра';

  @override
  String get appendSystemDns => 'Добавлять системный DNS';

  @override
  String get editRule => 'Редактировать правило';

  @override
  String get addedRules => 'Добавленные правила';

  @override
  String get addedRulesAfterScript =>
      'Добавляются после выполнения скрипта, перед правилами профиля';

  @override
  String get controlGlobalAddedRules =>
      'Управление глобальными добавленными правилами';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get rulePresetBlockQuic => 'Блокировать QUIC';

  @override
  String get rulePresetBlockStun => 'Блокировать STUN';

  @override
  String get rulePresetBlockDot => 'Блокировать DNS over TLS';

  @override
  String get rulePresetBlockLoopback => 'Защита от петли прокси';

  @override
  String get rulePresetSystemServicesDirect => 'Apple и Microsoft напрямую';

  @override
  String get rulePresetBittorrentDirect => 'BitTorrent напрямую';

  @override
  String get rulePresetLanDirect => 'Локальная сеть напрямую';

  @override
  String get extendScript => 'Скрипт расширения';

  @override
  String get goToConfigureScript => 'Перейти к настройке скрипта';

  @override
  String get goToConfigureAddedRules =>
      'Перейти к настройке добавленных правил';

  @override
  String get editGlobalRules => 'Редактировать глобальные правила';

  @override
  String get confirmForceCrashCore =>
      'Вы уверены, что хотите принудительно завершить ядро со сбоем?';

  @override
  String get confirmClearAllData =>
      'Вы уверены, что хотите удалить все данные?';

  @override
  String get loading => 'Загрузка…';

  @override
  String yearsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года назад',
      many: '$count лет назад',
      few: '$count года назад',
      one: '$count год назад',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца назад',
      many: '$count месяцев назад',
      few: '$count месяца назад',
      one: '$count месяц назад',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '$count час назад',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '$count минуту назад',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'Только что';

  @override
  String yearsAgoShort(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count г. назад',
      many: '$count л. назад',
      few: '$count г. назад',
      one: '$count г. назад',
    );
    return '$_temp0';
  }

  @override
  String monthsAgoShort(num count) {
    return '$count мес. назад';
  }

  @override
  String daysAgoShort(num count) {
    return '$count дн. назад';
  }

  @override
  String hoursAgoShort(num count) {
    return '$count ч назад';
  }

  @override
  String minutesAgoShort(num count) {
    return '$count мин назад';
  }

  @override
  String get noLongerRemind => 'Больше не напоминать';

  @override
  String get turnOn => 'Включить';

  @override
  String get turnOff => 'Выключить';

  @override
  String get vpnConfigChangeDetected =>
      'Настройки VPN изменены. Нажмите, чтобы перезапустить';

  @override
  String get restart => 'Перезапустить';

  @override
  String get speedStatistics => 'Статистика скорости';

  @override
  String get resetPageChangesTip =>
      'На этой странице есть изменения. Вы уверены, что хотите выполнить сброс?';

  @override
  String get customProfile => 'Пользовательский';

  @override
  String get customResources => 'Пользовательские';

  @override
  String get unknownNetworkError => 'Неизвестная сетевая ошибка';

  @override
  String get backupFromNewerVersion =>
      'Резервная копия создана более новой версией приложения. Обновите приложение перед восстановлением';

  @override
  String get networkTimeoutError =>
      'Время ожидания запроса истекло. Проверьте сеть или прокси и повторите попытку';

  @override
  String get networkHostLookupError =>
      'Не удалось определить адрес сервера. Проверьте правильность URL и работу DNS';

  @override
  String get monochromeIcon => 'Монохромный значок';

  @override
  String get networkConnectionError =>
      'Не удалось подключиться к серверу. Проверьте подключение к сети или настройки прокси';

  @override
  String get networkTlsError =>
      'Не удалось установить защищённое соединение. Сертификат сервера может быть недействителен, или соединение перехватывается';

  @override
  String get networkCancelledError => 'Запрос отменён';

  @override
  String networkAccessDeniedError(Object code) {
    return 'Сервер запретил доступ (HTTP $code). Возможно, ссылка устарела или учётные данные неверны';
  }

  @override
  String networkNotFoundError(Object code) {
    return 'По этому адресу ничего не найдено (HTTP $code). Проверьте правильность URL';
  }

  @override
  String get networkRateLimitedError =>
      'Слишком много запросов (HTTP 429). Подождите немного и повторите попытку';

  @override
  String networkServerError(Object code) {
    return 'На сервере произошла ошибка (HTTP $code). Повторите попытку позже';
  }

  @override
  String networkBadResponseError(Object code) {
    return 'Сервер отклонил запрос (HTTP $code)';
  }

  @override
  String networkRequestFailed(Object detail) {
    return 'Сетевой запрос не выполнен: $detail';
  }

  @override
  String get invalidBackupFile => 'Недопустимый файл резервной копии';

  @override
  String get pruneCache => 'Очистить кэш';

  @override
  String get backupAndRestore => 'Резервное копирование и восстановление';

  @override
  String get restore => 'Восстановить';

  @override
  String get restoreSuccess => 'Восстановление выполнено';

  @override
  String get restoreOnlyConfig => 'Восстановить только профили';

  @override
  String get restoreAllData => 'Восстановить все данные';

  @override
  String get addProfile => 'Добавить профиль';

  @override
  String get delayTest => 'Тест задержки';

  @override
  String get proxyGroupEmpty => 'Группа прокси пуста';

  @override
  String get confirmExitWindow =>
      'Вы уверены, что хотите закрыть текущее окно?';

  @override
  String get optional => 'Необязательно';

  @override
  String get maxFailedTimes => 'Макс. число неудач';

  @override
  String get testInterval => 'Интервал тестирования';

  @override
  String get excludeFilter => 'Фильтр исключения';

  @override
  String get expectedStatus => 'Ожидаемый статус';

  @override
  String get strategy => 'Стратегия';

  @override
  String get tolerance => 'Допуск';

  @override
  String get inputProxyGroupName => 'Введите название группы прокси';

  @override
  String get helperCorruptTip =>
      'Служба Helper недоступна, поэтому TUN-режим включить нельзя. Переустановите FlClash.';

  @override
  String get tunAuthorizationFailed =>
      'Не удалось получить права для TUN, поэтому он выключен.';

  @override
  String get sudoPasswordTitle => 'Введите пароль для sudo';

  @override
  String coreBlockedByPolicyTip(Object code) {
    return 'Windows отказалась запускать FlClashCore.exe (ошибка $code). Политики контроля приложений, такие как Smart App Control или AppLocker, блокируют неподписанные программы; разрешите FlClash в этой политике или отключите её и повторите попытку.';
  }

  @override
  String get coreBlockedBySmartAppControlTip =>
      'Smart App Control в Windows заблокировал неподписанный FlClashCore.exe. Откройте Безопасность Windows → Управление приложениями и браузером → Параметры Smart App Control, выберите «Выкл.» и снова запустите FlClash. Повторно включить Smart App Control без переустановки Windows нельзя.';

  @override
  String get hideFromList => 'Скрыть из списка';

  @override
  String get testWhenUsed => 'Тестировать при использовании';

  @override
  String get disableUDP => 'Отключить UDP';

  @override
  String get confirmDeleteProxyGroup =>
      'Вы уверены, что хотите удалить эту группу прокси?';

  @override
  String get ruleEmpty => 'Правило пусто';

  @override
  String get inputRuleContent => 'Введите содержимое правила';

  @override
  String get ruleSet => 'Набор правил';

  @override
  String get selectRuleSet => 'Выберите набор правил';

  @override
  String get splitStrategy => 'Стратегия распределения';

  @override
  String get selectSplitStrategy => 'Выберите стратегию распределения';

  @override
  String get noResolveHostname => 'Не разрешать имя хоста';

  @override
  String get matchSourceIp => 'Сопоставлять IP источника';

  @override
  String get basicInfo => 'Основная информация';

  @override
  String get additionalParameters => 'Дополнительные параметры';

  @override
  String get proxyType => 'Тип прокси';

  @override
  String get basicStrategy => 'Базовые политики';

  @override
  String get editProxy => 'Редактировать прокси';

  @override
  String get addNodes => 'Добавить узлы';

  @override
  String get addProxyGroup => 'Добавить группу прокси';

  @override
  String get editProxyGroup => 'Редактировать группу прокси';

  @override
  String get iconUrl => 'URL значка';

  @override
  String get iconRecords => 'История значков';

  @override
  String get custom => 'Вручную';

  @override
  String get ruleActionDomainDesc => 'Сопоставить полный домен';

  @override
  String get ruleActionDomainSuffixDesc => 'Сопоставить суффикс домена';

  @override
  String get ruleActionDomainKeywordDesc =>
      'Сопоставить ключевое слово в домене';

  @override
  String get ruleActionDomainRegexDesc =>
      'Сопоставить по регулярному выражению домена';

  @override
  String get ruleActionDomainWildcardDesc =>
      'Сопоставление по маске; поддерживаются только * и ?';

  @override
  String get ruleActionGeositeDesc => 'Сопоставить домены из Geosite';

  @override
  String get ruleActionIpCidrDesc => 'Сопоставить диапазон IP-адресов';

  @override
  String get ruleActionIpCidr6Desc =>
      'Сопоставить диапазон IP-адресов; IP-CIDR6 — просто псевдоним';

  @override
  String get ruleActionIpSuffixDesc => 'Сопоставить диапазон суффиксов IP';

  @override
  String get ruleActionIpAsnDesc => 'Сопоставить ASN, которой принадлежит IP';

  @override
  String get ruleActionGeoipDesc => 'Сопоставить код страны IP-адреса';

  @override
  String get ruleActionSrcGeoipDesc => 'Сопоставить код страны IP источника';

  @override
  String get ruleActionSrcIpAsnDesc => 'Сопоставить ASN IP источника';

  @override
  String get ruleActionSrcIpCidrDesc =>
      'Сопоставить диапазон IP-адресов источника';

  @override
  String get ruleActionSrcIpSuffixDesc =>
      'Сопоставить диапазон суффиксов IP источника';

  @override
  String get ruleActionDstPortDesc => 'Сопоставить диапазон портов назначения';

  @override
  String get ruleActionSrcPortDesc => 'Сопоставить диапазон портов источника';

  @override
  String get ruleActionInPortDesc => 'Сопоставить входящий порт';

  @override
  String get ruleActionInTypeDesc => 'Сопоставить тип входящего подключения';

  @override
  String get ruleActionInUserDesc =>
      'Сопоставить имя пользователя входящего подключения; несколько имён разделяются /';

  @override
  String get ruleActionInNameDesc => 'Сопоставить имя входящего подключения';

  @override
  String get ruleActionRematchNameDesc =>
      'Сопоставить имя повторного сопоставления; несколько имён разделяются /';

  @override
  String get ruleActionProcessPathDesc =>
      'Сопоставить по полному пути процесса';

  @override
  String get ruleActionProcessPathRegexDesc =>
      'Сопоставить по регулярному выражению пути процесса';

  @override
  String get ruleActionProcessPathWildcardDesc =>
      'Сопоставить по маске пути процесса; поддерживаются только * и ?';

  @override
  String get ruleActionProcessNameDesc =>
      'Сопоставить по имени процесса; на Android соответствует имени пакета';

  @override
  String get ruleActionProcessNameRegexDesc =>
      'Сопоставить по регулярному выражению имени процесса; на Android соответствует имени пакета';

  @override
  String get ruleActionProcessNameWildcardDesc =>
      'Сопоставить по маске имени процесса; поддерживаются только * и ?';

  @override
  String get ruleActionUidDesc => 'Сопоставить Linux USER ID';

  @override
  String get ruleActionNetworkDesc => 'Сопоставить TCP или UDP';

  @override
  String get ruleActionDscpDesc =>
      'Сопоставить метку DSCP (только для входящих tproxy UDP)';

  @override
  String get ruleActionRuleSetDesc =>
      'Ссылка на набор правил; требуется настроить rule-providers';

  @override
  String get ruleActionAndDesc => 'Логическое правило AND';

  @override
  String get ruleActionOrDesc => 'Логическое правило OR';

  @override
  String get ruleActionNotDesc => 'Логическое правило NOT';

  @override
  String get ruleActionSubRuleDesc =>
      'Переход к подправилу; обратите внимание на скобки';

  @override
  String get ruleActionMatchDesc =>
      'Сопоставляет все запросы, условия не нужны';

  @override
  String get contentNotEmpty => 'Содержимое не может быть пустым';

  @override
  String get splitStrategyNotEmpty =>
      'Стратегия распределения не может быть пустой';

  @override
  String get timeout => 'Тайм-аут';

  @override
  String get delayFailed => 'Сбой';

  @override
  String invalidSubRule(Object subRule) {
    return '$subRule — недопустимый SUB_RULE';
  }

  @override
  String invalidPolicy(Object target) {
    return '$target — недопустимая политика';
  }

  @override
  String invalidProxyProvider(Object providerName) {
    return '$providerName — недопустимый провайдер прокси';
  }

  @override
  String invalidRuleSet(Object ruleSet) {
    return '$ruleSet — недопустимый набор правил';
  }

  @override
  String get invalidNetworkContent => 'Поддерживаются только tcp и udp';

  @override
  String get invalidRangeContent =>
      'Введите числа или диапазоны, например 80 или 8000-9000, через /';

  @override
  String get invalidDscpContent => 'Метка DSCP не может превышать 63';

  @override
  String get invalidCidrContent =>
      'Введите диапазон IP в формате CIDR, например 192.168.0.0/16';

  @override
  String get invalidPortRangeContent =>
      'Введите порт или диапазон, например 443 или 8000-9000';

  @override
  String get invalidHostContent => 'Введите домен или IP-адрес';

  @override
  String get invalidListenContent =>
      'Введите адрес и порт, например 0.0.0.0:1053';

  @override
  String invalidProxy(Object proxyName) {
    return '$proxyName — недопустимый прокси';
  }

  @override
  String get locationPermissionRequired => 'Требуется разрешение на геолокацию';

  @override
  String locationPermissionGuide(Object appName) {
    return '1. Откройте Системные настройки > Конфиденциальность и безопасность\n2. Выберите Службы геолокации\n3. Найдите и отметьте $appName в списке\n\nПосле настройки вернитесь в приложение и продолжайте работу. Спасибо за сотрудничество.';
  }

  @override
  String get prerequisites => 'Предварительные условия';

  @override
  String get ignoreBatteryOptimization => 'Игнорировать оптимизацию батареи';

  @override
  String get locationPermission => 'Разрешение на геолокацию';

  @override
  String get locationPermissionDesc =>
      'По требованию системы для получения имени сети Wi-Fi необходимо разрешение на геолокацию. На Android выберите «Разрешить всегда», иначе имя сети Wi-Fi нельзя получить, пока приложение в фоне.';

  @override
  String get excludeSsids => 'Исключённые SSID';

  @override
  String get excludeSsidsDesc =>
      'При подключении к Wi-Fi с исключённым SSID состояние работы приложения переключается автоматически.';

  @override
  String get ssidsEmpty => 'Список SSID пуст';

  @override
  String get onDemand => 'По условию';

  @override
  String get locationPermissionDeniedMessage =>
      'Разрешение на геолокацию отклонено, поэтому невозможно получить имя текущей сети Wi-Fi. Включите разрешение на геолокацию вручную в системных настройках.';

  @override
  String get addSsid => 'Добавить SSID';

  @override
  String get editSsid => 'Изменить SSID';

  @override
  String get authorized => 'Разрешено';

  @override
  String get tapToAuthorize => 'Нажмите, чтобы разрешить';

  @override
  String get suspended => 'Приостановлено…';

  @override
  String get resourceUpdateInterval => 'Интервал автообновления';

  @override
  String get resourceUpdateIntervalTip =>
      'Интервал автообновления должен быть больше 0';

  @override
  String get hours => 'часов';

  @override
  String get minutes => 'минут';

  @override
  String get geoResources => 'Geo';

  @override
  String geoSkipped(Object name) {
    return '$name: уже последняя версия';
  }

  @override
  String geoUpdated(Object name) {
    return '$name: обновлено';
  }

  @override
  String secondsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count секунды',
      many: '$count секунд',
      few: '$count секунды',
      one: '$count секунда',
    );
    return '$_temp0';
  }

  @override
  String proxiesCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label прокси',
    );
    return '$_temp0';
  }

  @override
  String rulesCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label правила',
      many: '$label правил',
      few: '$label правила',
      one: '$label правило',
    );
    return '$_temp0';
  }

  @override
  String proxyGroupsCount(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$label группы прокси',
      many: '$label групп прокси',
      few: '$label группы прокси',
      one: '$label группа прокси',
    );
    return '$_temp0';
  }

  @override
  String get changelogBreaking => 'Важные изменения';

  @override
  String get changelogFeatures => 'Новые функции';

  @override
  String get changelogFixes => 'Исправления';

  @override
  String get changelogPerformance => 'Производительность';

  @override
  String get changelogReverts => 'Откаты';

  @override
  String get close => 'Закрыть';

  @override
  String get back => 'Назад';

  @override
  String get minimize => 'Свернуть';

  @override
  String get maximize => 'Развернуть';

  @override
  String get unmaximize => 'Свернуть в окно';

  @override
  String get pinWindow => 'Закрепить поверх всех окон';

  @override
  String get unpinWindow => 'Открепить окно';

  @override
  String get exitFullScreen => 'Выйти из полноэкранного режима';

  @override
  String get torch => 'Фонарик';

  @override
  String get pickFromAlbum => 'Выбрать из галереи';

  @override
  String get closeConnections => 'Закрыть соединения';

  @override
  String get scrollToSelected => 'Прокрутить к выбранному';

  @override
  String get showMore => 'Развернуть';

  @override
  String get showLess => 'Свернуть';

  @override
  String get previousMatch => 'Предыдущее совпадение';

  @override
  String get nextMatch => 'Следующее совпадение';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get noSearchResults => 'Ничего не найдено';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get authorize => 'Разрешить';

  @override
  String get installedAppsPermissionRequired =>
      'Требуется разрешение на список приложений';

  @override
  String get installedAppsPermissionDesc =>
      'Эта система не выдаёт список установленных приложений без разрешения. Предоставьте его, чтобы настроить прокси для отдельных приложений.';

  @override
  String get installedAppsPermissionDeniedMessage =>
      'Разрешение на список приложений отклонено, поэтому установленные приложения недоступны. Предоставьте его вручную в системных настройках.';

  @override
  String get outboundIp => 'Исходящий IP';

  @override
  String get ipAddress => 'IP-адрес';

  @override
  String get ipQualityLevel => 'Уровень';

  @override
  String get ipQualityGood => 'Хороший';

  @override
  String get ipQualityNormal => 'Обычный';

  @override
  String get ipQualityRisky => 'Рискованный';

  @override
  String get ipType => 'Тип';

  @override
  String get ipTypeResidential => 'Домашний';

  @override
  String get ipTypeMobile => 'Мобильная сеть';

  @override
  String get ipTypeBusiness => 'Бизнес';

  @override
  String get ipTypeHosting => 'Дата-центр';

  @override
  String get ipFlags => 'Метки';

  @override
  String get ipFlagProxy => 'Прокси';

  @override
  String get ipFlagVpn => 'VPN';

  @override
  String get ipFlagTor => 'Tor';

  @override
  String get ipFlagAbuser => 'Злоупотребления';

  @override
  String get ipOrganization => 'Организация';

  @override
  String get ipAsn => 'ASN';

  @override
  String get ipQualitySource => 'Источник ответа';

  @override
  String get ipQualitySources => 'Источники';

  @override
  String get ipQualityFailed => 'Не удалось определить тип IP';

  @override
  String get ipQualityRetry => 'Проверить снова';

  @override
  String get ipSourceNoType => 'Тип не определён';

  @override
  String get ipSourceRateLimited => 'Лимит запросов';

  @override
  String get ipSourceIpMismatch => 'Другой исходящий IP';

  @override
  String get hideIp => 'Скрыть IP';

  @override
  String get editorUnavailable => 'Редактор недоступен';

  @override
  String get replace => 'Заменить';

  @override
  String get replaceAll => 'Заменить все';

  @override
  String get cameraPermissionRequired => 'Требуется доступ к камере';

  @override
  String get cameraPermissionDesc =>
      'Разрешите доступ к камере в системных настройках, чтобы сканировать QR-коды, или выберите изображение QR-кода из галереи.';

  @override
  String get cameraUnavailable => 'Камера недоступна';

  @override
  String get retry => 'Повторить';

  @override
  String get invalidProfileQrcode =>
      'Этот QR-код не содержит ссылку на профиль';

  @override
  String get dnsQueries => 'DNS-запросы';

  @override
  String get recordType => 'Тип записи';

  @override
  String get answers => 'Ответы';

  @override
  String get responseCode => 'Код ответа';

  @override
  String get error => 'Ошибка';

  @override
  String get initiator => 'Инициатор';

  @override
  String get cache => 'Кэш';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get nonTextProviderFile =>
      'Этот внешний ресурс не является текстовым файлом';

  @override
  String get addCustomProxy => 'Добавить прокси';

  @override
  String get definitionNotMap =>
      'Конфигурация должна быть YAML-словарём с полями name и type';

  @override
  String get ruleTextInvalid =>
      'Правило должно начинаться с поддерживаемого типа, например DOMAIN,example.com,DIRECT';

  @override
  String get ruleListInvalid =>
      'Правила должны быть YAML-списком, по одному правилу в элементе, например - DOMAIN,example.com,DIRECT';

  @override
  String get shareLinksInvalid => 'Не удалось прочитать прокси из ссылок';

  @override
  String shareLinkUnreadable(Object link) {
    return 'Не удалось прочитать прокси из $link';
  }

  @override
  String proxiesProfileLabel(Object name, Object count) {
    return '$name и другие ($count прокси)';
  }

  @override
  String get singleShareLinkOnly =>
      'Здесь укажите одну ссылку, несколько можно задать в быстром редактировании списка';

  @override
  String get username => 'Имя пользователя';

  @override
  String get emptyFallback => 'Резерв для пустой группы';

  @override
  String get defaultSelected => 'Выбор по умолчанию';

  @override
  String get hashByInUser => 'Хешировать по пользователю входящего подключения';

  @override
  String get appProxiesEmpty => 'Нет локальных прокси';

  @override
  String get nodes => 'Узлы';

  @override
  String get localProxies => 'Локальные прокси';

  @override
  String get customIssueEmptyName => 'Имя не задано';

  @override
  String customIssueReservedName(Object name) {
    return '$name — встроенное имя политики, его нельзя использовать';
  }

  @override
  String customIssueDuplicateName(Object name) {
    return 'Имя $name уже занято другим прокси или группой прокси';
  }

  @override
  String customIssueCoreRejected(Object message) {
    return 'Ядро не может разобрать этот прокси: $message';
  }

  @override
  String customIssueMissingProxies(Object names) {
    return 'Эти прокси или политики не существуют: $names';
  }

  @override
  String customIssueMissingProviders(Object names) {
    return 'Эти провайдеры прокси не существуют: $names';
  }

  @override
  String get customIssueNoProxySource =>
      'Не выбраны ни прокси, ни провайдеры прокси, поэтому ядро отклонит эту группу';

  @override
  String customIssueGroupLoop(Object path) {
    return 'Группы прокси ссылаются друг на друга по кругу: $path';
  }

  @override
  String customIssueInvalidEmptyFallback(Object name) {
    return 'Резервом для пустой группы может быть только прокси, а $name не существует или является группой прокси';
  }

  @override
  String customIssueInvalidFilter(Object name, Object message) {
    return '$name: недопустимое регулярное выражение: $message';
  }

  @override
  String customIssueMissingDialer(Object name) {
    return 'Прокси для подключения $name не существует';
  }

  @override
  String customIssueDialerLoop(Object proxy, Object target) {
    return '$proxy подключается через $target, а $target снова ведёт к $proxy, поэтому подключение зацикливается';
  }

  @override
  String dialerProxyLoopStopped(Object name) {
    return 'Подключение через $name ведёт обратно к прокси, который его использует, поэтому соединение остановлено';
  }

  @override
  String customIssuesSummary(Object count) {
    return 'Проблем: $count, применение профиля может завершиться ошибкой';
  }

  @override
  String providerInUse(Object label, Object profiles) {
    return '«$label» всё ещё используется профилями: $profiles. После удаления они будут работать неправильно. Вы уверены, что хотите удалить его?';
  }

  @override
  String proxyGroupInUse(Object label) {
    return 'На «$label» всё ещё ссылаются правила, группы прокси, прокси для подключения, DNS или NTP этого профиля, и после удаления эти ссылки перестанут работать. Вы уверены, что хотите удалить её?';
  }

  @override
  String proxiesRemovedTip(Object removed) {
    return 'Будут удалены прокси: $removed. Строка с изменённым именем считается новым прокси, а пользовательские профили, ссылающиеся на удалённые, пометят их как отсутствующие. Применить?';
  }

  @override
  String proxiesReplacedTip(Object removed, Object added) {
    return 'Будут удалены прокси: $removed. Будут добавлены: $added. Строка с изменённым именем считается новым прокси, а пользовательские профили, ссылающиеся на удалённые, пометят их как отсутствующие. Применить?';
  }

  @override
  String get fontSize => 'Размер';

  @override
  String get large => 'Крупный';

  @override
  String get extraLarge => 'Очень крупный';

  @override
  String get switchProfile => 'Сменить профиль';

  @override
  String get lastUpdated => 'Последнее обновление';

  @override
  String get filters => 'Фильтры';

  @override
  String get label => 'Метка';

  @override
  String get regex => 'Регулярное выражение';

  @override
  String get matchCase => 'Учитывать регистр';

  @override
  String get iconSets => 'Наборы значков';

  @override
  String get invalidIconSet => 'Это не набор значков';

  @override
  String get recommendedIcons => 'Рекомендуемые';

  @override
  String get localImage => 'Локальное изображение';

  @override
  String get iconSetsEmptyTip =>
      'Наборов значков пока нет. Добавьте их в разделе «Ресурсы пользовательских профилей → Наборы значков»';

  @override
  String get outbound => 'Исходящие';

  @override
  String get strictRoute => 'Строгая маршрутизация';

  @override
  String get congestionController => 'Управление перегрузкой TCP';

  @override
  String get congestionControllerDesc =>
      'Управление перегрузкой TCP действует только со стеком mips.';

  @override
  String get routeExcludeAddress => 'Исключённые адреса маршрутов';

  @override
  String get keepAliveIdle => 'Простой TCP keep-alive';

  @override
  String get disableKeepAlive => 'Отключить TCP keep-alive';

  @override
  String get routingMark => 'Метка маршрутизации';

  @override
  String get strictRouteDesc =>
      'Строгая маршрутизация не даёт трафику вроде DNS обходить TUN, а при выключенном IPv6 блокирует IPv6-соединения этого устройства.';

  @override
  String get initFailed => 'Не удалось запустить';

  @override
  String get initFailedTip =>
      'При запуске FlClash произошла ошибка, и работа не может быть продолжена. Скопируйте подробности, чтобы сообщить о проблеме. Если ошибка повторяется, очистка данных обычно позволяет снова запустить приложение.';

  @override
  String get errorDetails => 'Подробности ошибки';

  @override
  String get stackTrace => 'Трассировка стека';

  @override
  String get clearDataAndExitTip =>
      'Все профили, настройки и локальные данные будут удалены, после чего приложение закроется. Откройте его снова, чтобы начать заново.';

  @override
  String clearDataFailed(Object detail) {
    return 'Не удалось очистить данные: $detail';
  }

  @override
  String get bypassPrivateRoute => 'Обходить частные адреса';

  @override
  String get disableIcmpForwarding => 'Отключить пересылку ICMP';

  @override
  String get disableIcmpForwardingDesc =>
      'При отключённой пересылке ICMP TUN сам отвечает на ping, поэтому ping больше не показывает реальную задержку.';

  @override
  String get excludeInterface => 'Исключённые интерфейсы';

  @override
  String get includeInterface => 'Включённые интерфейсы';

  @override
  String get includeInterfaceDesc =>
      'Через TUN идёт только трафик с включённых интерфейсов, а исключённые интерфейсы больше не действуют.';

  @override
  String get includeUid => 'Включённые ID пользователей';

  @override
  String get excludeUid => 'Исключённые ID пользователей';

  @override
  String get excludeSrcPort => 'Исключённые исходные порты';

  @override
  String get excludeDstPort => 'Исключённые порты назначения';

  @override
  String get udpTimeout => 'Тайм-аут UDP';

  @override
  String get udpTimeoutDesc =>
      'Тайм-аут UDP задаётся в секундах и действует только со стеками gvisor, system и mixed.';

  @override
  String get dnsHijackDesc =>
      'Без этого параметра TUN перехватывает все DNS-запросы на порт 53 (any:53).';

  @override
  String get tunOverrideDesc =>
      'Добавленные здесь параметры заменяют настройки TUN всех профилей; остальные остаются такими, как в профиле. Параметры, добавленные в самом пользовательском профиле, имеют приоритет.';

  @override
  String get generalOverrideDesc =>
      'Добавленные здесь параметры заменяют соответствующие настройки всех профилей; остальные остаются такими, как в профиле, а если профиль их не задаёт, действуют значения ядра по умолчанию.';

  @override
  String get profileTunSettingsDesc =>
      'Действует только для этого профиля и имеет приоритет над переопределяемыми параметрами TUN в настройках сети.';

  @override
  String settingsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count настройки',
      many: '$count настроек',
      few: '$count настройки',
      one: '$count настройка',
    );
    return '$_temp0';
  }

  @override
  String sectionsInEffect(Object count) {
    return 'Действуют: $count';
  }

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count элемента',
      many: '$count элементов',
      few: '$count элемента',
      one: '$count элемент',
    );
    return '$_temp0';
  }

  @override
  String get additionalPrefix => 'Префикс имени';

  @override
  String get additionalSuffix => 'Суффикс имени';

  @override
  String get skipCertVerify => 'Пропускать проверку сертификата';

  @override
  String get ipVersion => 'Версия IP';

  @override
  String get addFilters => 'Добавить фильтры';

  @override
  String failedItem(Object label, Object message) {
    return '$label: $message';
  }

  @override
  String failedCount(Object count) {
    return 'Ошибок: $count. Нажмите, чтобы посмотреть';
  }

  @override
  String get importConfigInvalid =>
      'Этот файл не является конфигурацией, которую можно импортировать';

  @override
  String get importConfigReplaceTip =>
      'Импорт заменит текущие группы прокси, правила и настройки этого профиля';

  @override
  String get networkName => 'Имя сети';

  @override
  String get networkSecret => 'Секрет сети';

  @override
  String get peers => 'Пиры';

  @override
  String get virtualIpv4 => 'Виртуальный IPv4';

  @override
  String get hostname => 'Имя хоста';

  @override
  String get exitNodes => 'Выходные узлы';

  @override
  String get cipher => 'Шифр';

  @override
  String get protocol => 'Протокол';

  @override
  String get protocolParam => 'Параметр протокола';

  @override
  String get obfs => 'Обфускация';

  @override
  String get obfsParam => 'Параметр обфускации';

  @override
  String get obfsPassword => 'Пароль обфускации';

  @override
  String get obfsMode => 'Режим обфускации';

  @override
  String get obfsHost => 'Хост обфускации';

  @override
  String get plugin => 'Плагин';

  @override
  String get pluginMode => 'Режим плагина';

  @override
  String get pluginHost => 'Хост плагина';

  @override
  String get pluginPath => 'Путь плагина';

  @override
  String get pluginUsername => 'Имя пользователя плагина';

  @override
  String get pluginPassword => 'Пароль плагина';

  @override
  String get pluginCipher => 'Шифр плагина';

  @override
  String get privateKey => 'Закрытый ключ';

  @override
  String get publicKey => 'Открытый ключ';

  @override
  String get privateKeyPassphrase => 'Пароль закрытого ключа';

  @override
  String get preSharedKey => 'Общий ключ';

  @override
  String get secretKey => 'Ключ';

  @override
  String get transport => 'Транспорт';

  @override
  String get uploadBandwidth => 'Скорость отдачи';

  @override
  String get downloadBandwidth => 'Скорость загрузки';

  @override
  String get protocolVersion => 'Версия протокола';

  @override
  String get portHopping => 'Перескок портов';

  @override
  String get hopInterval => 'Интервал перескока';

  @override
  String get congestionControl => 'Управление перегрузкой';

  @override
  String get udpRelayMode => 'Режим ретрансляции UDP';

  @override
  String get allowedIps => 'Разрешённые IP';

  @override
  String get remoteDnsResolve => 'Удалённое разрешение DNS';

  @override
  String get clientFingerprint => 'Отпечаток клиента';

  @override
  String get requestHeaders => 'Заголовки запроса';

  @override
  String transportHeaders(Object transport) {
    return 'Заголовки $transport';
  }

  @override
  String get required => 'Обязательно';

  @override
  String get ageSecretKey => 'Секретный ключ age';

  @override
  String get ageEncryptedProfile => 'Зашифрованный профиль';

  @override
  String get ageSecretKeyRequiredTip =>
      'Профиль зашифрован с помощью age, для расшифровки нужен секретный ключ age';

  @override
  String get currentOutboundDesc => 'Содержит кнопку запуска, удалить нельзя';

  @override
  String get running => 'Работает';

  @override
  String get root => 'Root';

  @override
  String get notRunning => 'Не запущено';

  @override
  String trafficPeak(Object value) {
    return 'Пик $value';
  }

  @override
  String trafficTotal(Object value) {
    return 'Всего $value';
  }

  @override
  String get ipQualityShort => 'Качество';

  @override
  String get ipTypeUnknown => 'Тип неизвестен';

  @override
  String get tapIconToRetry => 'Нажмите на значок, чтобы повторить';

  @override
  String get networkTakeover => 'Перехват трафика';

  @override
  String portValue(Object port) {
    return 'Порт $port';
  }

  @override
  String serviceAbnormalCount(num count) {
    return 'Проблем: $count';
  }

  @override
  String get serviceAllAvailable => 'Все доступны';

  @override
  String get serviceShownOnDashboard => 'Показан на панели';

  @override
  String groupTimeoutCount(Object count) {
    return 'Тайм-аут: $count';
  }

  @override
  String get groupCountUnit => 'групп';

  @override
  String groupCount(num count) {
    return 'Групп: $count';
  }

  @override
  String get proxyGroupsAfterStart =>
      'Группы появятся здесь после запуска ядра';

  @override
  String get usedShort => 'использовано';

  @override
  String profileUpdatedAt(Object time) {
    return 'Обновлено $time';
  }

  @override
  String profileExpiresIn(Object date, num days) {
    return 'Истекает $date, осталось дней: $days';
  }

  @override
  String profileDaysLeft(num days) {
    return 'Осталось дней: $days';
  }

  @override
  String get target => 'Цель';

  @override
  String get outboundExit => 'Выход';

  @override
  String get duration => 'Длительность';

  @override
  String get traffic => 'Трафик';

  @override
  String get totalDownload => 'Загружено';

  @override
  String get totalUpload => 'Отдано';

  @override
  String get initiatorShort => 'Источник';

  @override
  String get result => 'Результат';

  @override
  String get elapsed => 'Время';

  @override
  String get connectionStats => 'Статистика подключений';

  @override
  String get connectionStatsDesc => 'Подключения, запросы и DNS-запросы';

  @override
  String get memoryInfoDesc => 'Память приложения и ядра';

  @override
  String get editDashboard => 'Изменить панель';

  @override
  String get done => 'Готово';

  @override
  String get dashboardAddableSection => 'Можно добавить';

  @override
  String customImportDroppedSubRules(num count, Object label) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Пользовательские профили не поддерживают подправила, поэтому отброшено $label правила SUB-RULE',
      many:
          'Пользовательские профили не поддерживают подправила, поэтому отброшено $label правил SUB-RULE',
      few:
          'Пользовательские профили не поддерживают подправила, поэтому отброшено $label правила SUB-RULE',
      one:
          'Пользовательские профили не поддерживают подправила, поэтому отброшено $label правило SUB-RULE',
    );
    return '$_temp0';
  }

  @override
  String get autoInclude => 'Автоматическое включение';

  @override
  String get allReferencedProxies => 'Все используемые прокси';

  @override
  String get allReferencedProxyProviders =>
      'Все используемые провайдеры прокси';

  @override
  String get clearDnsCache => 'Очистить кэш DNS';

  @override
  String get dnsCacheCleared => 'Кэш DNS очищен';

  @override
  String get clearDnsCacheFailed => 'Не удалось очистить кэш DNS';

  @override
  String get select => 'Выбрать';

  @override
  String get preferred => 'Предпочтительный';

  @override
  String get addToLocalProxies => 'Добавить в локальные прокси';

  @override
  String addedToLocalProxies(Object name) {
    return '«$name» добавлен в локальные прокси';
  }

  @override
  String alreadyInLocalProxies(Object name) {
    return '«$name» уже есть в локальных прокси';
  }

  @override
  String get mitm => 'MITM';

  @override
  String get httpsDecryption => 'Расшифровка HTTPS';

  @override
  String get httpCapture => 'Захват HTTP';

  @override
  String get httpCaptureDesc =>
      'Записывает запросы к хостам из списка имён хостов; их можно посмотреть в сведениях о соединении. Записи хранятся только в памяти.';

  @override
  String get httpCaptureNoHosts =>
      'Хосты не указаны, поэтому ничего не записывается. Добавьте их в поле «Имя хоста» на странице MITM или из сведений о соединении.';

  @override
  String get httpCaptureLimit => 'Максимум записей';

  @override
  String httpCaptureLimitDesc(Object memory, Object body) {
    return 'Когда записей станет столько или они займут $memory памяти, самые старые удаляются первыми. От каждого тела сохраняются первые $body.';
  }

  @override
  String get httpRequests => 'HTTP-запросы';

  @override
  String get httpRequestsMissing =>
      'Запросы, отправленные до включения захвата или уже удалённые, не показаны.';

  @override
  String get httpRequestCleared => 'Запись этого запроса удалена';

  @override
  String get httpCaptureOff => 'Захват выключен';

  @override
  String get inProgress => 'Выполняется';

  @override
  String get method => 'Метод';

  @override
  String get originalUrl => 'Исходный URL';

  @override
  String get timeToFirstByte => 'Время до первого байта';

  @override
  String get requestBody => 'Тело запроса';

  @override
  String get response => 'Ответ';

  @override
  String get responseBody => 'Тело ответа';

  @override
  String get responseHeaders => 'Заголовки ответа';

  @override
  String get matchedRules => 'Сработавшие правила';

  @override
  String get overview => 'Обзор';

  @override
  String get viewAll => 'Показать всё';

  @override
  String get copyAsBase64 => 'Копировать как Base64';

  @override
  String get copyAsCurl => 'Копировать как cURL';

  @override
  String get closeConnection => 'Закрыть соединение';

  @override
  String get copyHost => 'Копировать хост';

  @override
  String get copyDestination => 'Копировать адрес назначения';

  @override
  String get copyRequest => 'Копировать запрос';

  @override
  String get copyResponse => 'Копировать ответ';

  @override
  String get copyResponseBody => 'Копировать тело ответа';

  @override
  String get httpBodyProtobufGuess =>
      'Прочитано как Protobuf без схемы: только номера полей, типы предполагаемые.';

  @override
  String get exportHar => 'Экспорт HAR';

  @override
  String get mitmAddRejectRule => 'Добавить правило блокировки';

  @override
  String get mitmAddMapLocalRule => 'Добавить правило локальной подмены';

  @override
  String get httpExportPrivateTitle => 'Содержит личные данные';

  @override
  String get httpExportPrivate =>
      'Запрос может содержать cookie, токены, пароли и данные форм. Проверьте, что и кому вы передаёте.';

  @override
  String get mitmRuleCopiedForStash =>
      'Этот модуль — переопределение Stash, поэтому правило скопировано, добавьте его вручную.';

  @override
  String get binaryData => 'Двоичные данные';

  @override
  String get httpBodyNotKept => 'Не записано: не хватало памяти.';

  @override
  String get httpBodyTruncated => 'Записано только начало тела.';

  @override
  String httpBodyUndecoded(Object encoding) {
    return 'Не удалось декодировать $encoding, показаны данные в том виде, в каком они были переданы.';
  }

  @override
  String get mitmEnableTip =>
      'FlClash сможет читать всё, что отправляется на расшифровываемые узлы, включая cookie и пароли. Включайте только для узлов, которые нужно перезаписывать.';

  @override
  String get generateCertificate => 'Создать сертификат';

  @override
  String get regenerateCertificate => 'Пересоздать сертификат';

  @override
  String get regenerateCertificateTip =>
      'Новый сертификат заменит текущий; FlClash по возможности удалит текущий из доверенных корневых сертификатов этого устройства. На каждое другое устройство, доверяющее текущему, нужно установить новый.';

  @override
  String get exportCertificate => 'Экспортировать сертификат';

  @override
  String get installCertificate => 'Установить в систему';

  @override
  String get installCertificateSuccess => 'Сертификат установлен';

  @override
  String validUntil(Object date) {
    return 'Действителен до $date';
  }

  @override
  String get mitmCertificateExportTip =>
      'Экспортируйте его и добавьте в доверенные на устройствах, трафик которых нужно расшифровывать.';

  @override
  String get mitmTrustReady => 'Доверенный';

  @override
  String get mitmTrustUntrusted => 'Доверие неполное';

  @override
  String get mitmTrustNotInstalled => 'Не установлен';

  @override
  String get mitmTrustChecking => 'Проверка…';

  @override
  String get mitmCertificateAndroidReadyTip =>
      'Расшифровываются только приложения, доверяющие пользовательским сертификатам, в основном браузеры.';

  @override
  String get mitmAndroidRootDesc =>
      'Без root можно расшифровать только приложения, доверяющие пользовательским сертификатам, в основном браузеры. С root — любые приложения.';

  @override
  String get mitmCertificateLinuxTip =>
      'В браузеры из Flatpak экспортированный сертификат нужно импортировать вручную.';

  @override
  String mitmCertutilMissing(Object command) {
    return 'Chrome и Firefox используют собственные хранилища сертификатов, для которых нужен certutil: $command';
  }

  @override
  String mitmMissingStores(Object stores) {
    return 'Ещё не добавлен в: $stores';
  }

  @override
  String get httpRequestsReadFailed => 'Не удалось прочитать запросы';

  @override
  String get requestBodyReadFailed => 'Не удалось прочитать тело запроса';

  @override
  String get responseBodyReadFailed => 'Не удалось прочитать тело ответа';

  @override
  String mitmGrpcOverLimit(Object size) {
    return 'После распаковки больше $size МБ; показаны сжатые данные';
  }

  @override
  String mitmUntrustedStores(Object stores) {
    return 'Установлен, но не доверен в: $stores';
  }

  @override
  String get mitmSystemStoreFailed =>
      'Не удалось добавить сертификат в доверенные корневые сертификаты системы';

  @override
  String get mitmRootUntilReboot =>
      'Не найден Magisk, KernelSU или APatch, чтобы сохранить сертификат. После перезагрузки устройства установите его снова.';

  @override
  String get mitmRootPendingReboot =>
      'Сертификат начнёт действовать после перезагрузки устройства.';

  @override
  String get mitmInstallSystemCaTip =>
      'Обнаружен root: сертификат будет добавлен в доверенные сертификаты системы как модуль Magisk, KernelSU или APatch «FlClash MITM CA». После этого ему будут доверять все приложения устройства, а любой, у кого есть его закрытый ключ, сможет расшифровать HTTPS-трафик устройства. Чтобы отменить это, создайте сертификат заново или удалите модуль в root-менеджере и перезагрузите устройство. Если в root отказано, сертификат будет установлен как пользовательский.';

  @override
  String get mitmInstallUserCaTip =>
      'Root не обнаружен: сертификат можно установить только как пользовательский. Расшифровываются только приложения, доверяющие пользовательским сертификатам, в основном браузеры; остальные не смогут подключиться к указанным узлам, поэтому не указывайте их узлы. Начиная с Android 11 установку нужно завершить вручную в настройках системы.';

  @override
  String mitmCertificateSavedTip(Object fileName) {
    return 'Файл $fileName сохранён в «Загрузки». Установите его в настройках: Безопасность › Шифрование и учётные данные › Установка сертификата › Сертификат ЦС.';
  }

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String mitmRemoveOldCertificateTip(Object name) {
    return 'Удалите старый сертификат $name в настройках: Безопасность › Шифрование и учётные данные › Надёжные учётные данные › Пользователь, затем установите новый.';
  }

  @override
  String mitmOldCertificateLeftTip(Object name) {
    return 'Не удалось удалить старый сертификат $name. Удалите его из доверенных корневых сертификатов вручную.';
  }

  @override
  String mitmOldSystemCertificateLeftTip(Object name) {
    return 'Старый сертификат $name всё ещё среди доверенных системных сертификатов. Разрешите FlClash доступ root в менеджере root и создайте сертификат заново или удалите там модуль «FlClash MITM CA» и перезагрузите устройство.';
  }

  @override
  String get removeCertificate => 'Удалить сертификат';

  @override
  String get removeCertificateSuccess => 'Сертификат удалён';

  @override
  String get mitmSystemStoreRemoveFailed =>
      'Не удалось удалить сертификат из доверенных корневых сертификатов системы';

  @override
  String get mitmRemoveInSettings => 'Удалите в настройках';

  @override
  String mitmRemoveUserCertificateTip(Object name) {
    return 'Android не позволяет приложениям удалять пользовательские сертификаты. Удалите $name в настройках: Безопасность › Шифрование и учётные данные › Надёжные учётные данные › Пользователь.';
  }

  @override
  String get mitmCannotRemove => 'Не удалось удалить';

  @override
  String get mitmRemoveSystemCertificateTip =>
      'Сертификат добавлен в систему root-модулем «FlClash MITM CA». Разрешите FlClash доступ root в менеджере root и повторите попытку или удалите там модуль и перезагрузите устройство.';

  @override
  String get mitmDecryptHost => 'Расшифровывать этот хост';

  @override
  String mitmDecryptHostTip(Object host) {
    return 'Добавить $host в список имён хостов? FlClash сможет читать всё, что на него отправляется, включая cookie и пароли.';
  }

  @override
  String get mitmClientRefusedCertificate =>
      'Клиент отклонил сертификат. Установите сертификат или исключите этот хост, если приложение закрепляет свой сертификат.';

  @override
  String get mitmExcludeHost => 'Исключить из расшифровки';

  @override
  String mitmExcludeHostTip(Object host) {
    return 'Добавить -$host в начало списка имён хостов? После этого узел никогда не будет расшифровываться.';
  }

  @override
  String get urlRewrite => 'Перезапись URL';

  @override
  String get headerRewrite => 'Перезапись заголовков';

  @override
  String get bodyRewrite => 'Перезапись тела';

  @override
  String get mapLocal => 'Локальная подмена';

  @override
  String get requestBodyMock => 'Подмена тела запроса';

  @override
  String get clientSourceAddress => 'Адреса клиентов';

  @override
  String get skipVerifyHostname => 'Хосты без проверки сертификата';

  @override
  String get mitmModules => 'Модули';

  @override
  String get mitmModule => 'Модуль';

  @override
  String get mitmModuleInvalid =>
      'Это не модуль Surge, не плагин Loon, не фрагмент Quantumult X и не переопределение Stash';

  @override
  String get arguments => 'Аргументы';

  @override
  String get mitmRoutingRules => 'Правила маршрутизации';

  @override
  String get mitmIgnoredLines => 'Пропущенные строки';

  @override
  String get mitmModuleRulesDesc =>
      'Правила маршрутизации идут перед правилами профиля.';

  @override
  String get mitmRequestRulesDesc =>
      'Правила URL-REGEX и USER-AGENT модуля превращаются в перезаписи URL и проверяются для каждого запроса: для всех запросов по открытому HTTP, а для HTTPS — только для хостов из списка MITM.';

  @override
  String mitmModuleSystemTip(Object system) {
    return 'Написан для $system; некоторые строки могут не подходить к приложениям на этом устройстве.';
  }

  @override
  String mitmModuleRequirementTip(Object requirement) {
    return 'Модуль требует $requirement, а это устройство не удовлетворяет условию; он может работать не так, как задумано.';
  }

  @override
  String mitmExitModules(Object modules) {
    return 'Из модулей: $modules';
  }

  @override
  String get mitmModuleRiskTitle => 'Включить этот модуль?';

  @override
  String get mitmNetworkRisk =>
      'При создании конфигурации он меняет сетевые настройки ниже и имеет приоритет над тем, что вы задали для них в FlClash. Если выключить или удалить модуль, всё вернётся.';

  @override
  String mitmSkipVerifyRisk(Object hosts) {
    return 'После включения сертификаты серверов этих хостов больше не проверяются, и сервер, выдающий себя за них, останется незамеченным: $hosts';
  }

  @override
  String mitmClientSourceRisk(Object addresses) {
    return 'Расшифровывается трафик только этих клиентов: $addresses. При включённом TUN приложения этого устройства подключаются с адреса TUN и могут не попасть в список.';
  }

  @override
  String get mitmClientSourceTunTip =>
      'При включённом TUN приложения этого устройства подключаются с адреса TUN; если его нет в списке, их трафик не расшифровывается.';

  @override
  String get mitmNetworkChanges => 'Сетевые настройки';

  @override
  String mitmChangeReplace(Object values) {
    return 'Заменяется на $values';
  }

  @override
  String mitmChangeInsert(Object values) {
    return 'Добавляет $values в начало';
  }

  @override
  String mitmChangeAppend(Object values) {
    return 'Добавляет $values';
  }

  @override
  String get mitmChangeOverridesYours => 'Перекрывает вашу настройку';

  @override
  String mitmChangeReplacedBy(Object module) {
    return 'Перекрыто модулем $module';
  }

  @override
  String mitmSkipSection(Object section) {
    return 'Раздел [$section] не поддерживается';
  }

  @override
  String get mitmSkipSetting => 'Этот параметр не поддерживается';

  @override
  String get mitmSkipScriptType => 'Этот тип скриптов не поддерживается';

  @override
  String get mitmSkipRule => 'Этот тип правила не поддерживается';

  @override
  String get mitmSkipHttpRulePolicy =>
      'Правила URL-REGEX и USER-AGENT допускают только политику REJECT';

  @override
  String get mitmSkipFinalRule =>
      'Правила модуля идут первыми, поэтому финальное правило скрыло бы все последующие';

  @override
  String get mitmSkipDeviceRule =>
      'Этому правилу нужны сведения об устройстве или сети, которые FlClash не может получить';

  @override
  String get mitmSkipRequirement =>
      'Устройство не удовлетворяет условию этой строки';

  @override
  String get mitmSkipManagedCa =>
      'Сертификатом ЦС управляет FlClash; модуль не может его изменить';

  @override
  String get mitmSkipProxies =>
      'Модуль не может изменять прокси и группы прокси';

  @override
  String get mitmSkipAppOnly =>
      'Это функция исходного приложения, которой нет в FlClash';

  @override
  String get mitmSkipReflect =>
      'FlClash не может отправить пакеты обратно отправителю';

  @override
  String get mitmSkipConditional => 'Условные перезаписи не поддерживаются';

  @override
  String get mitmSkipSkipVerifyAll =>
      'Проверку сертификатов нельзя отключить для всех хостов';

  @override
  String get mitmSkipRelativeData =>
      'Файл из этой строки не прикреплён; укажите URL или прикрепите его';

  @override
  String get mitmSkipNotDownloaded => 'Его файл ещё не загружен';

  @override
  String get mitmSkipUnreadable => 'Эту строку не удалось прочитать';

  @override
  String get mitmAddLocalFile => 'Добавить локальный файл';

  @override
  String get mitmNewModule => 'Новый модуль';

  @override
  String get mitmAttachments => 'Вложения';

  @override
  String get mitmAttachmentsDesc =>
      'Строки ссылаются на вложения по имени файла, например script-path=a.js.';

  @override
  String mitmFileTooLarge(Object size) {
    return 'Файл больше $size МБ';
  }

  @override
  String get mitmSkipDisabled => 'Отключено аргументом';

  @override
  String get mitmSkipEvent => 'Это событие не поддерживается';

  @override
  String get mitmRunScript => 'Запустить сейчас';

  @override
  String get mitmScriptCron => 'По расписанию';

  @override
  String get mitmScriptEvent => 'Событие';

  @override
  String get mitmScriptGeneric => 'Общий';

  @override
  String get mitmExcluded => 'Исключено';

  @override
  String get mitmScriptNoOutput => 'Скрипт завершился без вывода';

  @override
  String get mitmScriptRiskTitle => 'Запускать скрипты этого модуля?';

  @override
  String get mitmModulesTurnedOff => 'Модули отключены';

  @override
  String mitmModuleTurnedOffDesc(Object name) {
    return 'Обновление $name принесло скрипты или сетевые изменения, на которые вы не соглашались';
  }

  @override
  String mitmModulesTurnedOffDesc(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Обновления $count модулей принесли скрипты или сетевые изменения, на которые вы не соглашались',
    );
    return '$_temp0';
  }

  @override
  String get mitmScriptRisk =>
      'Его скрипты читают и меняют трафик подходящих хостов, включая файлы cookie и токены, и могут сами отправлять запросы. Включайте, только если доверяете источнику. После включения его обновления применяются без повторного запроса.';

  @override
  String get mitmModuleUnreadableRisk =>
      'Не удалось прочитать файл модуля, поэтому неизвестно, что он меняет. Включайте, только если доверяете источнику.';

  @override
  String get skipServerCertVerify => 'Пропускать проверку сертификата сервера';

  @override
  String get blockQuic => 'Блокировать QUIC';

  @override
  String get http2 => 'HTTP/2';

  @override
  String get decryptUntrusted => 'Расшифровывать без локального доверия';

  @override
  String invalidOfCount(Object invalid, Object total) {
    return 'Недействительно: $invalid из $total';
  }

  @override
  String get batchLineInputTip => 'По одному элементу в строке';

  @override
  String get downloadingUpdate => 'Загрузка обновления';

  @override
  String get updateFailed => 'Не удалось обновить';

  @override
  String get updateDownloadTest => 'Тест загрузки обновления';

  @override
  String get liveStatusTest => 'Тест карточек текущего состояния';

  @override
  String get updateDownloadStarted =>
      'Загрузка обновления началась. Следите за ходом на главной странице.';

  @override
  String get updateReady => 'Обновление готово';

  @override
  String get updateReadyTip =>
      'Обновление загружено. Нажмите, чтобы установить.';

  @override
  String get stopUpdateDownloadTip => 'Остановить загрузку обновления?';

  @override
  String get forceRestartCoreAsk => 'Принудительно перезапустить ядро?';

  @override
  String get forceRestartCoreAskDesc => 'Текущие соединения будут разорваны';

  @override
  String get stopUpdateDownloadDesc => 'Уже загруженная часть будет удалена';

  @override
  String get stopDownload => 'Стоп';

  @override
  String get updateInstallFailed =>
      'Не удалось установить обновление. Его можно скачать на странице релиза.';

  @override
  String get updateNotVerified =>
      'Не удалось проверить загруженное обновление.';

  @override
  String get updateRestartTip =>
      'FlClash закроется для установки обновления и снова откроется после завершения.';

  @override
  String get updateDownloadFailed => 'Не удалось загрузить обновление.';

  @override
  String get updateFileMissing =>
      'В релизе нет файла обновления. Скачайте его вручную со страницы релиза.';

  @override
  String get defaultNameserverDesc =>
      'Разрешает имена других DNS-серверов. Только IP-адреса.';

  @override
  String get nameserverDesc =>
      'DNS-серверы по умолчанию, например 223.5.5.5, tls://1.1.1.1 или https://dns.google/dns-query.';

  @override
  String get fallbackDesc =>
      'Используются вместо Nameserver, когда фильтр fallback считает его ответ подменённым.';

  @override
  String get proxyServerNameserverDesc =>
      'Используется только для разрешения имён прокси-серверов.';

  @override
  String get proxyServerNameserverPolicyDesc =>
      'Совпавшие имена прокси-серверов используют указанный здесь DNS-сервер вместо Proxy Server Nameserver.';

  @override
  String get directNameserverDesc => 'Разрешает домены прямых соединений.';

  @override
  String get nameserverPolicyDesc =>
      'Совпавшие домены используют указанный здесь DNS-сервер вместо Nameserver и Fallback.';

  @override
  String get fakeipFilterDesc =>
      'Эти домены получают реальные IP вместо Fake-IP. В режиме whitelist Fake-IP получают только они.';

  @override
  String get fallbackFilterGeositeDesc =>
      'Домены из этих категорий GeoSite сразу разрешаются через Fallback.';

  @override
  String get fallbackFilterIpcidrDesc =>
      'Если Nameserver возвращает IP из этих диапазонов, используется ответ Fallback.';

  @override
  String get fallbackFilterDomainDesc =>
      'Эти домены сразу разрешаются через Fallback.';

  @override
  String get liveStatus => 'Текущее состояние';

  @override
  String get coreStopped => 'Ядро остановлено';

  @override
  String get coreStoppedDesc => 'Приложение потеряло связь с ядром';

  @override
  String coreStoppedWithReason(Object reason) {
    return 'Приложение потеряло связь с ядром: $reason';
  }

  @override
  String mixedPortReset(Object value, Object port) {
    return 'Смешанный порт не может быть $value, он возвращён к $port';
  }

  @override
  String get restartCore => 'Перезапустить ядро';

  @override
  String get installUpdate => 'Установить обновление';

  @override
  String liveStatusPosition(Object index, Object count) {
    return '$index из $count';
  }

  @override
  String get coreStarting => 'Запуск ядра';

  @override
  String get coreStartingDesc => 'Подключение к ядру';

  @override
  String get coreRunning => 'Ядро работает';

  @override
  String get coreRunningDesc => 'Приложение подключено к ядру';

  @override
  String get forceRestartCore => 'Принудительный перезапуск';

  @override
  String get vpnPermissionNotGranted =>
      'Разрешение на VPN не выдано, поэтому VPN не запущен. Постоянная VPN, заданная для другого приложения, тоже мешает запуску.';

  @override
  String get vpnServiceStartFailed => 'Не удалось запустить службу VPN.';
}
