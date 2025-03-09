// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// 이 파일은 en 로케일에 대한 메시지를 제공하는 라이브러리입니다. 메인 프로그램의 모든 메시지는 여기에서 동일한 함수 이름으로 반복 정의되어야 합니다.

// 이 파일에서 흔히 발생하는 lint 문제를 무시합니다.
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
  String get localeName => 'ko';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("소개"),
    "accessControl": MessageLookupByLibrary.simpleMessage("접근 제어"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "지정된 애플리케이션만 VPN을 사용할 수 있습니다",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "애플리케이션의 프록시 접근 권한을 설정합니다",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 애플리케이션은 VPN을 사용할 수 없습니다",
    ),
    "account": MessageLookupByLibrary.simpleMessage("계정"),
    "accountTip": MessageLookupByLibrary.simpleMessage(
      "계정 필드는 비워둘 수 없습니다",
    ),
    "action": MessageLookupByLibrary.simpleMessage("작업"),
    "action_mode": MessageLookupByLibrary.simpleMessage("모드 전환"),
    "action_proxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "action_start": MessageLookupByLibrary.simpleMessage("시작/중지"),
    "action_tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "action_view": MessageLookupByLibrary.simpleMessage("표시/숨김"),
    "add": MessageLookupByLibrary.simpleMessage("추가"),
    "address": MessageLookupByLibrary.simpleMessage("주소"),
    "addressHelp": MessageLookupByLibrary.simpleMessage(
      "WebDAV 서버 주소",
    ),
    "addressTip": MessageLookupByLibrary.simpleMessage(
      "유효한 WebDAV 주소를 입력해 주세요",
    ),
    "adminAutoLaunch": MessageLookupByLibrary.simpleMessage(
      "관리자 자동 시작",
    ),
    "adminAutoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "관리자 권한으로 자동 시작합니다",
    ),
    "ago": MessageLookupByLibrary.simpleMessage("전"),
    "agree": MessageLookupByLibrary.simpleMessage("동의"),
    "allApps": MessageLookupByLibrary.simpleMessage("모든 애플리케이션"),
    "allowBypass": MessageLookupByLibrary.simpleMessage(
      "애플리케이션이 VPN을 우회하도록 허용",
    ),
    "allowBypassDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 일부 애플리케이션이 VPN을 우회할 수 있습니다",
    ),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN 허용"),
    "allowLanDesc": MessageLookupByLibrary.simpleMessage(
      "LAN을 통해 프록시에 접근할 수 있도록 허용합니다",
    ),
    "app": MessageLookupByLibrary.simpleMessage("애플리케이션"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage(
      "애플리케이션 접근 제어",
    ),
    "appDesc": MessageLookupByLibrary.simpleMessage(
      "애플리케이션 관련 설정을 관리합니다",
    ),
    "application": MessageLookupByLibrary.simpleMessage("애플리케이션"),
    "applicationDesc": MessageLookupByLibrary.simpleMessage(
      "애플리케이션 관련 설정을 조정합니다",
    ),
    "auto": MessageLookupByLibrary.simpleMessage("자동"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage(
      "업데이트 자동 확인",
    ),
    "autoCheckUpdateDesc": MessageLookupByLibrary.simpleMessage(
      "프로그램 시작 시 업데이트를 자동으로 확인합니다",
    ),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage(
      "연결 자동 종료",
    ),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "노드를 변경한 후 기존 연결을 자동으로 종료합니다",
    ),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("자동 시작"),
    "autoLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "시스템 부팅 시 자동으로 시작합니다",
    ),
    "autoRun": MessageLookupByLibrary.simpleMessage("자동 실행"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "애플리케이션 시작 시 자동으로 실행합니다",
    ),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("자동 업데이트"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "자동 업데이트 간격(분)",
    ),
    "backup": MessageLookupByLibrary.simpleMessage("백업"),
    "backupAndRecovery": MessageLookupByLibrary.simpleMessage(
      "백업 및 복구",
    ),
    "backupAndRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAV 또는 파일을 통해 데이터를 동기화합니다",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("백업 성공"),
    "bind": MessageLookupByLibrary.simpleMessage("바인딩"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("블랙리스트 모드"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("도메인 우회"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "시스템 프록시가 활성화된 경우에만 적용됩니다",
    ),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "캐시가 손상되었습니다. 지우시겠습니까?",
    ),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "cancelFilterSystemApp": MessageLookupByLibrary.simpleMessage(
      "시스템 앱 필터링 해제",
    ),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage(
      "전체 선택 해제",
    ),
    "checkError": MessageLookupByLibrary.simpleMessage("오류 확인"),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("업데이트 확인"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage(
      "현재 애플리케이션은 최신 버전입니다",
    ),
    "checking": MessageLookupByLibrary.simpleMessage("확인 중…"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("클립보드로 내보내기"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("클립보드에서 가져오기"),
    "columns": MessageLookupByLibrary.simpleMessage("열"),
    "compatible": MessageLookupByLibrary.simpleMessage("호환 모드"),
    "compatibleDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 일부 애플리케이션 기능을 희생하여 Clash에 대한 완전한 지원을 받을 수 있습니다",
    ),
    "confirm": MessageLookupByLibrary.simpleMessage("확인"),
    "connections": MessageLookupByLibrary.simpleMessage("연결"),
    "connectionsDesc": MessageLookupByLibrary.simpleMessage(
      "현재 연결 정보를 확인합니다",
    ),
    "connectivity": MessageLookupByLibrary.simpleMessage("연결 상태:"),
    "copy": MessageLookupByLibrary.simpleMessage("복사"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage(
      "환경 변수 복사",
    ),
    "copyLink": MessageLookupByLibrary.simpleMessage("링크 복사"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("복사 성공"),
    "core": MessageLookupByLibrary.simpleMessage("코어"),
    "coreInfo": MessageLookupByLibrary.simpleMessage("코어 정보"),
    "country": MessageLookupByLibrary.simpleMessage("국가/지역"),
    "create": MessageLookupByLibrary.simpleMessage("생성"),
    "cut": MessageLookupByLibrary.simpleMessage("잘라내기"),
    "dark": MessageLookupByLibrary.simpleMessage("다크"),
    "dashboard": MessageLookupByLibrary.simpleMessage("대시보드"),
    "days": MessageLookupByLibrary.simpleMessage("일"),
    "defaultNameserver": MessageLookupByLibrary.simpleMessage(
      "기본 네임서버",
    ),
    "defaultNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "DNS를 해석하는 데 사용되는 서버",
    ),
    "defaultSort": MessageLookupByLibrary.simpleMessage("기본 정렬"),
    "defaultText": MessageLookupByLibrary.simpleMessage("기본"),
    "delay": MessageLookupByLibrary.simpleMessage("지연"),
    "delaySort": MessageLookupByLibrary.simpleMessage("지연 기준 정렬"),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "deleteProfileTip": MessageLookupByLibrary.simpleMessage(
      "현재 프로필을 삭제하시겠습니까?",
    ),
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMeta 기반의 다중 플랫폼 프록시 클라이언트로, 사용이 간편하고 오픈소스이며 광고가 없습니다",
    ),
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "타사 API에 의존하며, 결과는 참고용입니다",
    ),
    "direct": MessageLookupByLibrary.simpleMessage("직접 연결"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("면책 조항"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "이 소프트웨어는 학습 교류 및 과학 연구 등 비상업적 용도로만 사용 가능하며, 상업적 목적으로 사용하는 것은 엄격히 금지됩니다. 상업적 행위(있는 경우)는 이 소프트웨어와 무관합니다",
    ),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage(
      "새 버전 발견",
    ),
    "discovery": MessageLookupByLibrary.simpleMessage(
      "새 버전 발견",
    ),
    "dnsDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 관련 설정을 업데이트합니다",
    ),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS 모드"),
    "doYouWantToPass": MessageLookupByLibrary.simpleMessage(
      "통과하시겠습니까?",
    ),
    "domain": MessageLookupByLibrary.simpleMessage("도메인"),
    "download": MessageLookupByLibrary.simpleMessage("다운로드"),
    "edit": MessageLookupByLibrary.simpleMessage("편집"),
    "en": MessageLookupByLibrary.simpleMessage("영어"),
    "entries": MessageLookupByLibrary.simpleMessage("항목"),
    "exclude": MessageLookupByLibrary.simpleMessage("최근 작업에서 숨김"),
    "excludeDesc": MessageLookupByLibrary.simpleMessage(
      "애플리케이션이 백그라운드에서 실행 중일 때 최근 작업 목록에서 숨깁니다",
    ),
    "exit": MessageLookupByLibrary.simpleMessage("종료"),
    "expand": MessageLookupByLibrary.simpleMessage("표준"),
    "expirationTime": MessageLookupByLibrary.simpleMessage("만료 시간"),
    "exportFile": MessageLookupByLibrary.simpleMessage("파일 내보내기"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("로그 내보내기"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("내보내기 성공"),
    "externalController": MessageLookupByLibrary.simpleMessage(
      "외부 컨트롤러",
    ),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 9090 포트를 통해 Clash 코어를 제어할 수 있습니다",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("외부 링크"),
    "externalResources": MessageLookupByLibrary.simpleMessage(
      "외부 리소스",
    ),
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("가상 IP 필터"),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("가상 IP 범위"),
    "fallback": MessageLookupByLibrary.simpleMessage("폴백"),
    "fallbackDesc": MessageLookupByLibrary.simpleMessage(
      "일반적으로 해외 DNS 서버를 사용합니다",
    ),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("폴백 필터"),
    "file": MessageLookupByLibrary.simpleMessage("파일"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("설정 파일 직접 업로드"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "파일이 변경되었습니다. 수정 사항을 저장하시겠습니까?",
    ),
    "filterSystemApp": MessageLookupByLibrary.simpleMessage(
      "시스템 앱 필터링",
    ),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("프로세스 검색 모드"),
    "findProcessModeDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 프로그램 충돌 위험이 있을 수 있습니다",
    ),
    "fontFamily": MessageLookupByLibrary.simpleMessage("글꼴 패밀리"),
    "fourColumns": MessageLookupByLibrary.simpleMessage("4열"),
    "general": MessageLookupByLibrary.simpleMessage("일반"),
    "generalDesc": MessageLookupByLibrary.simpleMessage(
      "일반 설정을 관리합니다",
    ),
    "geoData": MessageLookupByLibrary.simpleMessage("지리 데이터"),
    "geodataLoader": MessageLookupByLibrary.simpleMessage(
      "지리 데이터 저메모리 모드",
    ),
    "geodataLoaderDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 저메모리 지리 데이터 로더를 사용합니다",
    ),
    "geoipCode": MessageLookupByLibrary.simpleMessage("지리 IP 코드"),
    "global": MessageLookupByLibrary.simpleMessage("글로벌"),
    "go": MessageLookupByLibrary.simpleMessage("이동"),
    "goDownload": MessageLookupByLibrary.simpleMessage("다운로드로 이동"),
    "hasCacheChange": MessageLookupByLibrary.simpleMessage(
      "캐시 변경 사항을 저장하시겠습니까?",
    ),
    "hostsDesc": MessageLookupByLibrary.simpleMessage("호스트 설정 추가"),
    "hotkeyConflict": MessageLookupByLibrary.simpleMessage("단축키 충돌"),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage(
      "단축키 관리",
    ),
    "hotkeyManagementDesc": MessageLookupByLibrary.simpleMessage(
      "키보드 단축키로 애플리케이션을 제어합니다",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("시간"),
    "icon": MessageLookupByLibrary.simpleMessage("아이콘"),
    "iconConfiguration": MessageLookupByLibrary.simpleMessage(
      "아이콘 설정",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("아이콘 스타일"),
    "importFromURL": MessageLookupByLibrary.simpleMessage("URL에서 가져오기"),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("무기한 유효"),
    "init": MessageLookupByLibrary.simpleMessage("초기화"),
    "inputCorrectHotkey": MessageLookupByLibrary.simpleMessage(
      "유효한 단축키를 입력해 주세요",
    ),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage(
      "스마트 선택",
    ),
    "intranetIP": MessageLookupByLibrary.simpleMessage("인트라넷 IP"),
    "ipcidr": MessageLookupByLibrary.simpleMessage("IPCIDR"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 IPv6 트래픽을 수신할 수 있습니다",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "IPv6 인바운드 허용",
    ),
    "ja": MessageLookupByLibrary.simpleMessage("일본어"),
    "just": MessageLookupByLibrary.simpleMessage("방금"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 연결 유지 간격",
    ),
    "key": MessageLookupByLibrary.simpleMessage("키"),
    "ko": MessageLookupByLibrary.simpleMessage("한국어"),
    "fr": MessageLookupByLibrary.simpleMessage("프랑스어"),
    "de": MessageLookupByLibrary.simpleMessage("독일어"),
    "ar": MessageLookupByLibrary.simpleMessage("아랍어"),
    "fa": MessageLookupByLibrary.simpleMessage("페르시아어"),
    "language": MessageLookupByLibrary.simpleMessage("언어"),
    "layout": MessageLookupByLibrary.simpleMessage("레이아웃"),
    "light": MessageLookupByLibrary.simpleMessage("라이트"),
    "list": MessageLookupByLibrary.simpleMessage("목록"),
    "listen": MessageLookupByLibrary.simpleMessage("수신"),
    "local": MessageLookupByLibrary.simpleMessage("로컬"),
    "localBackupDesc": MessageLookupByLibrary.simpleMessage(
      "데이터를 로컬에 백업합니다",
    ),
    "localRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "로컬 파일에서 데이터를 복구합니다",
    ),
    "logLevel": MessageLookupByLibrary.simpleMessage("로그 레벨"),
    "logcat": MessageLookupByLibrary.simpleMessage("로그 캡처"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "비활성화하면 로그 내용이 숨겨집니다",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("로그"),
    "logsDesc": MessageLookupByLibrary.simpleMessage("로그 기록을 확인합니다"),
    "loopback": MessageLookupByLibrary.simpleMessage("루프백 잠금 해제 도구"),
    "loopbackDesc": MessageLookupByLibrary.simpleMessage(
      "UWP 루프백 제한을 해제하는 데 사용됩니다",
    ),
    "loose": MessageLookupByLibrary.simpleMessage("느슨함"),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("메모리 정보"),
    "min": MessageLookupByLibrary.simpleMessage("분"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("종료 시 최소화"),
    "minimizeOnExitDesc": MessageLookupByLibrary.simpleMessage(
      "기본 종료 동작을 최소화로 변경합니다",
    ),
    "minutes": MessageLookupByLibrary.simpleMessage("분"),
    "mode": MessageLookupByLibrary.simpleMessage("모드"),
    "months": MessageLookupByLibrary.simpleMessage("개월"),
    "more": MessageLookupByLibrary.simpleMessage("더 보기"),
    "name": MessageLookupByLibrary.simpleMessage("이름"),
    "nameSort": MessageLookupByLibrary.simpleMessage("이름 기준 정렬"),
    "nameserver": MessageLookupByLibrary.simpleMessage("네임서버"),
    "nameserverDesc": MessageLookupByLibrary.simpleMessage(
      "도메인을 해석하는 데 사용되는 서버",
    ),
    "nameserverPolicy": MessageLookupByLibrary.simpleMessage(
      "네임서버 정책",
    ),
    "nameserverPolicyDesc": MessageLookupByLibrary.simpleMessage(
      "해당 네임서버 정책을 지정합니다",
    ),
    "network": MessageLookupByLibrary.simpleMessage("네트워크"),
    "networkDesc": MessageLookupByLibrary.simpleMessage(
      "네트워크 관련 설정을 조정합니다",
    ),
    "networkDetection": MessageLookupByLibrary.simpleMessage(
      "네트워크 감지",
    ),
    "networkSpeed": MessageLookupByLibrary.simpleMessage("네트워크 속도"),
    "noData": MessageLookupByLibrary.simpleMessage("데이터 없음"),
    "noHotKey": MessageLookupByLibrary.simpleMessage("단축키 없음"),
    "noIcon": MessageLookupByLibrary.simpleMessage("아이콘 없음"),
    "noInfo": MessageLookupByLibrary.simpleMessage("정보 없음"),
    "noMoreInfoDesc": MessageLookupByLibrary.simpleMessage("추가 정보 없음"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("네트워크 연결 없음"),
    "noProxy": MessageLookupByLibrary.simpleMessage("프록시 없음"),
    "noProxyDesc": MessageLookupByLibrary.simpleMessage(
      "프로필을 생성하거나 유효한 프로필을 추가해 주세요",
    ),
    "notEmpty": MessageLookupByLibrary.simpleMessage("비워둘 수 없음"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "현재 프록시 그룹은 선택할 수 없습니다",
    ),
    "nullConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "연결 없음",
    ),
    "nullCoreInfoDesc": MessageLookupByLibrary.simpleMessage(
      "코어 정보를 가져올 수 없습니다",
    ),
    "nullLogsDesc": MessageLookupByLibrary.simpleMessage("로그 기록 없음"),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage(
      "프로필이 없습니다. 프로필을 추가해 주세요",
    ),
    "nullProxies": MessageLookupByLibrary.simpleMessage("프록시 없음"),
    "nullRequestsDesc": MessageLookupByLibrary.simpleMessage("요청 기록 없음"),
    "oneColumn": MessageLookupByLibrary.simpleMessage("1열"),
    "onlyIcon": MessageLookupByLibrary.simpleMessage("아이콘만"),
    "onlyOtherApps": MessageLookupByLibrary.simpleMessage(
      "타사 앱만",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage(
      "프록시 트래픽만 통계",
    ),
    "onlyStatisticsProxyDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 프록시 관련 트래픽만 기록합니다",
    ),
    "options": MessageLookupByLibrary.simpleMessage("옵션"),
    "other": MessageLookupByLibrary.simpleMessage("기타"),
    "otherContributors": MessageLookupByLibrary.simpleMessage(
      "기타 기여자",
    ),
    "outboundMode": MessageLookupByLibrary.simpleMessage("아웃바운드 모드"),
    "override": MessageLookupByLibrary.simpleMessage("덮어쓰기"),
    "overrideDesc": MessageLookupByLibrary.simpleMessage(
      "프록시 관련 설정을 덮어씁니다",
    ),
    "overrideDns": MessageLookupByLibrary.simpleMessage("DNS 덮어쓰기"),
    "overrideDnsDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 프로필 내 DNS 설정을 덮어씁니다",
    ),
    "password": MessageLookupByLibrary.simpleMessage("비밀번호"),
    "passwordTip": MessageLookupByLibrary.simpleMessage(
      "비밀번호 필드는 비워둘 수 없습니다",
    ),
    "paste": MessageLookupByLibrary.simpleMessage("붙여넣기"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage(
      "WebDAV를 바인딩해 주세요",
    ),
    "pleaseInputAdminPassword": MessageLookupByLibrary.simpleMessage(
      "관리자 비밀번호를 입력해 주세요",
    ),
    "pleaseUploadFile": MessageLookupByLibrary.simpleMessage(
      "파일을 업로드해 주세요",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "유효한 QR 코드를 업로드해 주세요",
    ),
    "port": MessageLookupByLibrary.simpleMessage("포트"),
    "preferH3Desc": MessageLookupByLibrary.simpleMessage(
      "HTTP/3의 DOH를 우선 사용",
    ),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage(
      "키보드를 눌러 주세요",
    ),
    "preview": MessageLookupByLibrary.simpleMessage("미리보기"),
    "profile": MessageLookupByLibrary.simpleMessage("프로필"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "유효한 간격 시간 형식을 입력해 주세요",
        ),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage(
          "자동 업데이트 간격 시간을 입력해 주세요",
        ),
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "프로필이 변경되었습니다. 자동 업데이트를 비활성화하시겠습니까?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 이름을 입력해 주세요",
    ),
    "profileParseErrorDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 파싱에 실패했습니다",
    ),
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "유효한 프로필 URL을 입력해 주세요",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 URL을 입력해 주세요",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("프로필"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("프로필 정렬"),
    "project": MessageLookupByLibrary.simpleMessage("프로젝트"),
    "providers": MessageLookupByLibrary.simpleMessage("제공자"),
    "proxies": MessageLookupByLibrary.simpleMessage("프록시"),
    "proxiesSetting": MessageLookupByLibrary.simpleMessage("프록시 설정"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹"),
    "proxyNameserver": MessageLookupByLibrary.simpleMessage("프록시 네임서버"),
    "proxyNameserverDesc": MessageLookupByLibrary.simpleMessage(
      "프록시 노드 도메인을 해석하는 데 사용되는 서버",
    ),
    "proxyPort": MessageLookupByLibrary.simpleMessage("프록시 포트"),
    "proxyPortDesc": MessageLookupByLibrary.simpleMessage(
      "Clash의 수신 포트를 설정합니다",
    ),
    "proxyProviders": MessageLookupByLibrary.simpleMessage("프록시 제공자"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("순수 블랙 모드"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR 코드"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage(
      "QR 코드를 스캔하여 프로필을 가져옵니다",
    ),
    "recovery": MessageLookupByLibrary.simpleMessage("복구"),
    "recoveryAll": MessageLookupByLibrary.simpleMessage("모든 데이터 복구"),
    "recoveryProfiles": MessageLookupByLibrary.simpleMessage(
      "프로필만 복구",
    ),
    "recoverySuccess": MessageLookupByLibrary.simpleMessage("복구 성공"),
    "regExp": MessageLookupByLibrary.simpleMessage("정규 표현식"),
    "remote": MessageLookupByLibrary.simpleMessage("원격"),
    "remoteBackupDesc": MessageLookupByLibrary.simpleMessage(
      "데이터를 WebDAV에 백업합니다",
    ),
    "remoteRecoveryDesc": MessageLookupByLibrary.simpleMessage(
      "WebDAV에서 데이터를 복구합니다",
    ),
    "remove": MessageLookupByLibrary.simpleMessage("제거"),
    "requests": MessageLookupByLibrary.simpleMessage("요청"),
    "requestsDesc": MessageLookupByLibrary.simpleMessage(
      "최근 요청 기록을 확인합니다",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("초기화"),
    "resetTip": MessageLookupByLibrary.simpleMessage("초기화하시겠습니까?"),
    "resources": MessageLookupByLibrary.simpleMessage("리소스"),
    "resourcesDesc": MessageLookupByLibrary.simpleMessage(
      "외부 리소스 관련 정보",
    ),
    "respectRules": MessageLookupByLibrary.simpleMessage("규칙 준수"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 연결이 규칙을 따르며, 프록시와 네임서버 설정이 필요합니다",
    ),
    "routeAddress": MessageLookupByLibrary.simpleMessage("라우팅 주소"),
    "routeAddressDesc": MessageLookupByLibrary.simpleMessage(
      "수신할 라우팅 주소를 설정합니다",
    ),
    "routeMode": MessageLookupByLibrary.simpleMessage("라우팅 모드"),
    "routeMode_bypassPrivate": MessageLookupByLibrary.simpleMessage(
      "사설 라우팅 주소 우회",
    ),
    "routeMode_config": MessageLookupByLibrary.simpleMessage("프로필 사용"),
    "ru": MessageLookupByLibrary.simpleMessage("러시아어"),
    "rule": MessageLookupByLibrary.simpleMessage("규칙"),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("규칙 제공자"),
    "save": MessageLookupByLibrary.simpleMessage("저장"),
    "search": MessageLookupByLibrary.simpleMessage("검색"),
    "seconds": MessageLookupByLibrary.simpleMessage("초"),
    "selectAll": MessageLookupByLibrary.simpleMessage("전체 선택"),
    "selected": MessageLookupByLibrary.simpleMessage("선택됨"),
    "settings": MessageLookupByLibrary.simpleMessage("설정"),
    "show": MessageLookupByLibrary.simpleMessage("표시"),
    "shrink": MessageLookupByLibrary.simpleMessage("축소"),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("조용히 시작"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "백그라운드에서 애플리케이션을 시작합니다",
    ),
    "size": MessageLookupByLibrary.simpleMessage("크기"),
    "sort": MessageLookupByLibrary.simpleMessage("정렬"),
    "source": MessageLookupByLibrary.simpleMessage("소스"),
    "stackMode": MessageLookupByLibrary.simpleMessage("스택 모드"),
    "standard": MessageLookupByLibrary.simpleMessage("표준"),
    "start": MessageLookupByLibrary.simpleMessage("시작"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN 시작 중…"),
    "status": MessageLookupByLibrary.simpleMessage("상태"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "꺼져 있을 때 시스템 DNS를 사용합니다",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("중지"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN 중지 중…"),
    "style": MessageLookupByLibrary.simpleMessage("스타일"),
    "submit": MessageLookupByLibrary.simpleMessage("제출"),
    "sync": MessageLookupByLibrary.simpleMessage("동기화"),
    "system": MessageLookupByLibrary.simpleMessage("시스템"),
    "systemFont": MessageLookupByLibrary.simpleMessage("시스템 글꼴"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "systemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP 프록시를 VpnService에 추가합니다",
    ),
    "tab": MessageLookupByLibrary.simpleMessage("탭"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("탭 애니메이션"),
    "tabAnimationDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 홈페이지 탭 전환 시 애니메이션 효과가 표시됩니다",
    ),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP 병렬"),
    "tcpConcurrentDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 TCP 병렬 전송이 허용됩니다",
    ),
    "testUrl": MessageLookupByLibrary.simpleMessage("테스트 URL"),
    "theme": MessageLookupByLibrary.simpleMessage("테마"),
    "themeColor": MessageLookupByLibrary.simpleMessage("테마 색상"),
    "themeDesc": MessageLookupByLibrary.simpleMessage(
      "다크 모드를 설정하거나 색상을 조정합니다",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("테마 모드"),
    "threeColumns": MessageLookupByLibrary.simpleMessage("3열"),
    "tight": MessageLookupByLibrary.simpleMessage("컴팩트"),
    "time": MessageLookupByLibrary.simpleMessage("시간"),
    "tip": MessageLookupByLibrary.simpleMessage("팁"),
    "toggle": MessageLookupByLibrary.simpleMessage("전환"),
    "tools": MessageLookupByLibrary.simpleMessage("도구"),
    "trafficUsage": MessageLookupByLibrary.simpleMessage("트래픽 사용 상황"),
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunDesc": MessageLookupByLibrary.simpleMessage(
      "관리자 모드에서만 유효합니다",
    ),
    "twoColumns": MessageLookupByLibrary.simpleMessage("2열"),
    "unableToUpdateCurrentProfileDesc": MessageLookupByLibrary.simpleMessage(
      "현재 프로필을 업데이트할 수 없습니다",
    ),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("통합 지연"),
    "unifiedDelayDesc": MessageLookupByLibrary.simpleMessage(
      "핸드셰이크 등 추가 지연 시간을 제거합니다",
    ),
    "unknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
    "update": MessageLookupByLibrary.simpleMessage("업데이트"),
    "upload": MessageLookupByLibrary.simpleMessage("업로드"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlDesc": MessageLookupByLibrary.simpleMessage(
      "URL을 통해 프로필을 가져옵니다",
    ),
    "useHosts": MessageLookupByLibrary.simpleMessage("호스트 설정 사용"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("시스템 호스트 사용"),
    "value": MessageLookupByLibrary.simpleMessage("값"),
    "view": MessageLookupByLibrary.simpleMessage("확인"),
    "vpnDesc": MessageLookupByLibrary.simpleMessage(
      "VPN 관련 설정을 조정합니다",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "활성화하면 모든 시스템 트래픽이 자동으로 VpnService를 통해 라우팅됩니다",
    ),
    "vpnSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "HTTP 프록시를 VpnService에 통합합니다",
    ),
    "vpnTip": MessageLookupByLibrary.simpleMessage(
      "VPN을 재시작하면 설정이 적용됩니다",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage(
      "WebDAV 설정",
    ),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("화이트리스트 모드"),
    "years": MessageLookupByLibrary.simpleMessage("년"),
    "zh_CN": MessageLookupByLibrary.simpleMessage("중국어（간체）"),
    "zh_TW": MessageLookupByLibrary.simpleMessage("중국어（번체）"),
  };
}
