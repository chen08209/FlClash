// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ko locale. All the
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
  String get localeName => 'ko';

  static String m0(count) => "${count}개 선택됨";

  static String m1(name) => "${name}을(를) 로컬 프록시에 추가했습니다";

  static String m2(name) => "${name}은(는) 이미 로컬 프록시에 있습니다";

  static String m3(count, skipped) => "추가 ${count}개, 이미 있어서 건너뜀 ${skipped}개";

  static String m4(detail) => "데이터를 지우지 못했습니다: ${detail}";

  static String m5(code) =>
      "Windows에서 FlClashCore.exe 실행을 거부했습니다(오류 ${code}). Smart App Control이나 AppLocker와 같은 앱 제어 정책이 서명되지 않은 프로그램을 차단합니다. 해당 정책에서 FlClash를 허용하거나 정책을 끈 후 다시 시도하세요.";

  static String m6(name) =>
      "앱이 두 번 연속 시작을 완료하지 못했습니다. 반복을 끊기 위해 프로필 ${name}의 선택을 해제하고 자동 설정을 건너뛰었습니다. 언제든지 다시 선택할 수 있습니다.";

  static String m7(url) => "${url}에서 프로필을 만드시겠습니까?";

  static String m8(count, label) =>
      "${Intl.plural(count, other: '사용자 지정 프로필은 하위 규칙을 지원하지 않아 SUB-RULE 규칙 ${label}개를 제외했습니다')}";

  static String m9(message) => "코어가 이 프록시를 해석할 수 없습니다: ${message}";

  static String m10(proxy, target) =>
      "${proxy}이(가) ${target}을(를) 거쳐 다시 ${proxy}(으)로 돌아오므로 다이얼이 순환합니다";

  static String m11(name) => "다른 프록시 또는 프록시 그룹이 이미 사용 중인 이름입니다: ${name}";

  static String m12(path) => "프록시 그룹이 서로를 순환 참조합니다: ${path}";

  static String m13(name) => "빈 폴백은 프록시여야 하지만 존재하지 않거나 프록시 그룹입니다: ${name}";

  static String m14(name, message) => "올바른 정규식이 아닙니다(${name}): ${message}";

  static String m15(name) => "존재하지 않는 다이얼러 프록시: ${name}";

  static String m16(names) => "존재하지 않는 프록시 공급자: ${names}";

  static String m17(names) => "존재하지 않는 프록시 또는 정책: ${names}";

  static String m18(name) => "내장 정책 이름이라 여기에서 사용할 수 없습니다: ${name}";

  static String m19(count) => "문제가 있는 항목 ${count}개, 이 프로필을 적용하면 실패할 수 있습니다";

  static String m20(count) => "${Intl.plural(count, other: '${count}일 전')}";

  static String m21(count) => "${Intl.plural(count, other: '${count}일 전')}";

  static String m22(label) => "선택한 ${label}을(를) 삭제하시겠습니까?";

  static String m23(label) => "이 ${label}을(를) 삭제하시겠습니까?";

  static String m24(label) => "${label} 상세 정보";

  static String m25(name) =>
      "${name}을(를) 거치는 다이얼이 이를 사용하는 프록시로 되돌아와 연결을 중단했습니다";

  static String m26(label) => "${label}을(를) 입력하세요";

  static String m27(label) => "${label}이(가) 이미 있습니다";

  static String m28(count) => "${count}개 항목 실패";

  static String m29(label, message) => "${label}: ${message}";

  static String m30(name) => "${name}: 이미 최신 상태입니다";

  static String m31(name) => "${name}: 업데이트됨";

  static String m32(count) => "${Intl.plural(count, other: '그룹 ${count}개')}";

  static String m33(count) => "${count}개 시간 초과";

  static String m34(action) => "이미 “${action}”에서 사용 중입니다. 저장하면 이쪽으로 옮겨집니다.";

  static String m35(modifiers) => "${modifiers} 중 하나 이상을 포함하세요";

  static String m36(count) => "${Intl.plural(count, other: '${count}시간 전')}";

  static String m37(count) => "${Intl.plural(count, other: '${count}시간 전')}";

  static String m38(target) => "올바르지 않은 정책: ${target}";

  static String m39(proxyName) => "올바르지 않은 프록시: ${proxyName}";

  static String m40(providerName) => "올바르지 않은 프록시 공급자: ${providerName}";

  static String m41(ruleSet) => "올바르지 않은 규칙 세트: ${ruleSet}";

  static String m42(subRule) => "올바르지 않은 SUB_RULE: ${subRule}";

  static String m43(count) => "${Intl.plural(count, other: '항목 ${count}개')}";

  static String m44(line, message) => "${line}행: ${message}";

  static String m45(appName) =>
      "1. 시스템 설정 > 개인정보 보호 및 보안을 엽니다\n2. 위치 서비스를 선택합니다\n3. 목록에서 ${appName}을(를) 찾아 체크합니다\n\n완료되면 앱으로 돌아와 계속하세요. 협조해 주셔서 감사합니다.";

  static String m46(label, max) => "${label}은(는) 최대 ${max}자까지 입력할 수 있습니다";

  static String m47(size) => "${size} 해제됨";

  static String m48(count) => "${Intl.plural(count, other: '${count}분 전')}";

  static String m49(count) => "${Intl.plural(count, other: '${count}분 전')}";

  static String m50(count) => "${Intl.plural(count, other: '${count}개월 전')}";

  static String m51(count) => "${Intl.plural(count, other: '${count}개월 전')}";

  static String m52(code) =>
      "서버가 접근을 거부했습니다(HTTP ${code}). 링크가 만료되었거나 자격 증명이 잘못되었을 수 있습니다";

  static String m53(code) => "서버가 요청을 거부했습니다(HTTP ${code})";

  static String m54(code) =>
      "이 주소에서 아무것도 찾지 못했습니다(HTTP ${code}). URL이 올바른지 확인하세요";

  static String m55(detail) => "네트워크 요청 실패: ${detail}";

  static String m56(code) => "서버에 문제가 발생했습니다(HTTP ${code}). 나중에 다시 시도하세요";

  static String m57(label) => "${label}이(가) 아직 없습니다";

  static String m58(label, min, max) => "${label}은(는) ${min}에서 ${max} 사이여야 합니다";

  static String m59(label) => "${label}은(는) 숫자여야 합니다";

  static String m60(label) => "${label}은(는) 1024에서 49151 사이여야 합니다";

  static String m61(port) => "포트 ${port}";

  static String m62(days) => "${Intl.plural(days, other: '${days}일 남음')}";

  static String m63(date, days) =>
      "${date} 만료, ${Intl.plural(days, other: '${days}일')} 남음";

  static String m64(time) => "${time} 업데이트";

  static String m65(label, profiles) =>
      "${label}은(는) 아직 ${profiles}에서 사용 중이며, 삭제하면 해당 프로필이 제대로 작동하지 않습니다. 삭제하시겠습니까?";

  static String m66(count, label) =>
      "${Intl.plural(count, other: '프록시 ${label}개')}";

  static String m67(name, count) => "${name} 외 (프록시 ${count}개)";

  static String m68(removed) =>
      "다음 프록시가 삭제됩니다: ${removed}. 이름이 바뀐 줄은 새 프록시로 간주되며, 삭제된 프록시를 지정한 사용자 지정 프로필에는 누락으로 표시됩니다. 그래도 적용하시겠습니까?";

  static String m69(removed, added) =>
      "다음 프록시가 삭제됩니다: ${removed}. 다음 프록시가 추가됩니다: ${added}. 이름이 바뀐 줄은 새 프록시로 간주되며, 삭제된 프록시를 지정한 사용자 지정 프로필에는 누락으로 표시됩니다. 그래도 적용하시겠습니까?";

  static String m70(label) =>
      "${label}은(는) 이 프로필의 규칙, 프록시 그룹, 다이얼러 프록시, DNS 또는 NTP에서 아직 참조 중이며, 삭제하면 작동하지 않게 됩니다. 삭제하시겠습니까?";

  static String m71(count, label) =>
      "${Intl.plural(count, other: '프록시 그룹 ${label}개')}";

  static String m72(count, label) =>
      "${Intl.plural(count, other: '규칙 ${label}개')}";

  static String m73(appName) => "${appName} (안전 모드)";

  static String m74(count) => "${Intl.plural(count, other: '${count}초')}";

  static String m75(count) => "${count}개 적용 중";

  static String m76(count) => "${Intl.plural(count, other: '문제 ${count}건')}";

  static String m77(time) => "확인 시각: ${time}";

  static String m78(count) => "${Intl.plural(count, other: '설정 ${count}개')}";

  static String m79(link) => "읽을 수 있는 프록시가 없습니다: ${link}";

  static String m80(label) => "${label}은(는) 하나만 입력해야 합니다";

  static String m81(value) => "최고 ${value}";

  static String m82(value) => "합계 ${value}";

  static String m83(transport) => "${transport} 요청 헤더";

  static String m84(label) => "${label}은(는) URL이어야 합니다";

  static String m85(count) => "${Intl.plural(count, other: '${count}년 전')}";

  static String m86(count) => "${Intl.plural(count, other: '${count}년 전')}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("정보"),
    "accessControl": MessageLookupByLibrary.simpleMessage("접근 제어"),
    "accessControlAllowDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 앱만 VPN을 거칩니다",
    ),
    "accessControlDesc": MessageLookupByLibrary.simpleMessage(
      "접근 제어는 프록시를 사용할 앱을 선택합니다.",
    ),
    "accessControlDisabledDesc": MessageLookupByLibrary.simpleMessage(
      "앱 접근 제어가 꺼져 있습니다",
    ),
    "accessControlNotAllowDesc": MessageLookupByLibrary.simpleMessage(
      "선택한 앱은 VPN에서 제외됩니다",
    ),
    "accessControlSelectedCount": m0,
    "account": MessageLookupByLibrary.simpleMessage("계정"),
    "action": MessageLookupByLibrary.simpleMessage("동작"),
    "actionDelayTest": MessageLookupByLibrary.simpleMessage("모든 지연 테스트"),
    "actionDirectMode": MessageLookupByLibrary.simpleMessage("직접 모드"),
    "actionGlobalMode": MessageLookupByLibrary.simpleMessage("전역 모드"),
    "actionMode": MessageLookupByLibrary.simpleMessage("모드 전환"),
    "actionProxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "actionRuleMode": MessageLookupByLibrary.simpleMessage("규칙 모드"),
    "actionStart": MessageLookupByLibrary.simpleMessage("시작/중지"),
    "actionTun": MessageLookupByLibrary.simpleMessage("TUN"),
    "actionUpdateProfiles": MessageLookupByLibrary.simpleMessage("프로필 업데이트"),
    "actionView": MessageLookupByLibrary.simpleMessage("표시/숨기기"),
    "add": MessageLookupByLibrary.simpleMessage("추가"),
    "addCustomProxy": MessageLookupByLibrary.simpleMessage("프록시 추가"),
    "addFilters": MessageLookupByLibrary.simpleMessage("필터 추가"),
    "addNodes": MessageLookupByLibrary.simpleMessage("노드 추가"),
    "addOverrideEntry": MessageLookupByLibrary.simpleMessage("덮어쓰기 항목 추가"),
    "addProfile": MessageLookupByLibrary.simpleMessage("프로필 추가"),
    "addProxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹 추가"),
    "addRule": MessageLookupByLibrary.simpleMessage("규칙 추가"),
    "addSettingEntry": MessageLookupByLibrary.simpleMessage("설정 추가"),
    "addSsid": MessageLookupByLibrary.simpleMessage("SSID 추가"),
    "addToLocalProxies": MessageLookupByLibrary.simpleMessage("로컬 프록시에 추가"),
    "addedRules": MessageLookupByLibrary.simpleMessage("추가한 규칙"),
    "addedToLocalProxies": m1,
    "additionalParameters": MessageLookupByLibrary.simpleMessage("추가 매개변수"),
    "additionalPrefix": MessageLookupByLibrary.simpleMessage("이름 접두사"),
    "additionalSuffix": MessageLookupByLibrary.simpleMessage("이름 접미사"),
    "address": MessageLookupByLibrary.simpleMessage("주소"),
    "addressHelp": MessageLookupByLibrary.simpleMessage("WebDAV 서버 주소"),
    "addressTip": MessageLookupByLibrary.simpleMessage("올바른 WebDAV 주소를 입력하세요"),
    "advancedConfig": MessageLookupByLibrary.simpleMessage("고급 구성"),
    "advancedConfigDesc": MessageLookupByLibrary.simpleMessage(
      "고급 구성에는 네트워크, DNS, 추가한 규칙, 스크립트가 포함됩니다.",
    ),
    "ageEncryptedProfile": MessageLookupByLibrary.simpleMessage("암호화된 프로필"),
    "ageSecretKey": MessageLookupByLibrary.simpleMessage("age 비밀 키"),
    "ageSecretKeyRequiredTip": MessageLookupByLibrary.simpleMessage(
      "이 프로필은 age로 암호화되어 있어 복호화하려면 age 비밀 키가 필요합니다",
    ),
    "agree": MessageLookupByLibrary.simpleMessage("동의"),
    "allReferencedProxies": MessageLookupByLibrary.simpleMessage("참조된 모든 프록시"),
    "allReferencedProxyProviders": MessageLookupByLibrary.simpleMessage(
      "참조된 모든 프록시 공급자",
    ),
    "allowBypass": MessageLookupByLibrary.simpleMessage("앱의 VPN 우회 허용"),
    "allowLan": MessageLookupByLibrary.simpleMessage("LAN 허용"),
    "allowedIps": MessageLookupByLibrary.simpleMessage("허용 IP"),
    "alreadyInLocalProxies": m2,
    "answers": MessageLookupByLibrary.simpleMessage("응답"),
    "app": MessageLookupByLibrary.simpleMessage("앱"),
    "appAccessControl": MessageLookupByLibrary.simpleMessage("앱 접근 제어"),
    "appIconDesign": MessageLookupByLibrary.simpleMessage("앱 아이콘 디자인"),
    "appProxiesEmpty": MessageLookupByLibrary.simpleMessage("로컬 프록시 없음"),
    "appendSystemDns": MessageLookupByLibrary.simpleMessage("시스템 DNS 추가"),
    "authentication": MessageLookupByLibrary.simpleMessage("인증"),
    "authenticationDesc": MessageLookupByLibrary.simpleMessage(
      "인증을 켜면 로컬 프록시 포트에서 사용자 이름과 비밀번호를 요구합니다.",
    ),
    "authenticationSystemProxyDesc": MessageLookupByLibrary.simpleMessage(
      "인증이 켜져 있는 동안에는 시스템 프록시가 적용되지 않습니다.",
    ),
    "authorize": MessageLookupByLibrary.simpleMessage("허용"),
    "authorized": MessageLookupByLibrary.simpleMessage("허용됨"),
    "auto": MessageLookupByLibrary.simpleMessage("자동"),
    "autoCheckUpdate": MessageLookupByLibrary.simpleMessage("업데이트 자동 확인"),
    "autoCloseConnections": MessageLookupByLibrary.simpleMessage("연결 자동 종료"),
    "autoCloseConnectionsDesc": MessageLookupByLibrary.simpleMessage(
      "연결 자동 종료는 프록시를 전환할 때 열려 있는 연결을 끊습니다.",
    ),
    "autoInclude": MessageLookupByLibrary.simpleMessage("자동 포함"),
    "autoLaunch": MessageLookupByLibrary.simpleMessage("자동 실행"),
    "autoRun": MessageLookupByLibrary.simpleMessage("자동 시작"),
    "autoRunDesc": MessageLookupByLibrary.simpleMessage(
      "자동 시작은 앱을 열 때 프록시를 시작합니다.",
    ),
    "autoSetSystemDns": MessageLookupByLibrary.simpleMessage("시스템 DNS 자동 설정"),
    "autoUpdate": MessageLookupByLibrary.simpleMessage("자동 업데이트"),
    "autoUpdateInterval": MessageLookupByLibrary.simpleMessage("자동 업데이트 간격"),
    "back": MessageLookupByLibrary.simpleMessage("뒤로"),
    "backgroundBlur": MessageLookupByLibrary.simpleMessage("배경 흐림"),
    "backup": MessageLookupByLibrary.simpleMessage("백업"),
    "backupAndRestore": MessageLookupByLibrary.simpleMessage("백업 및 복원"),
    "backupFromNewerVersion": MessageLookupByLibrary.simpleMessage(
      "이 백업은 더 최신 버전의 앱에서 만들어졌습니다. 복원하기 전에 앱을 업데이트하세요",
    ),
    "backupSuccess": MessageLookupByLibrary.simpleMessage("백업 완료"),
    "basicInfo": MessageLookupByLibrary.simpleMessage("기본 정보"),
    "basicStrategy": MessageLookupByLibrary.simpleMessage("기본 전략"),
    "batchAdd": MessageLookupByLibrary.simpleMessage("일괄 추가"),
    "batchImport": MessageLookupByLibrary.simpleMessage("일괄 가져오기"),
    "batchLinkInputTip": MessageLookupByLibrary.simpleMessage("한 줄에 링크 하나씩"),
    "batchListInputTip": MessageLookupByLibrary.simpleMessage(
      "한 줄에 하나씩 또는 쉼표로 구분하여 입력하세요",
    ),
    "batchMapInputTip": MessageLookupByLibrary.simpleMessage(
      "한 줄에 하나씩, 키, 공백, 값 순서로 입력하세요",
    ),
    "batchPreviewTip": m3,
    "batchUrlInputTip": MessageLookupByLibrary.simpleMessage("한 줄에 URL 하나씩"),
    "batteryOptimizationDesc": MessageLookupByLibrary.simpleMessage(
      "배터리 최적화를 무시하면 앱이 백그라운드에서 계속 실행됩니다.",
    ),
    "bind": MessageLookupByLibrary.simpleMessage("연결"),
    "blacklistMode": MessageLookupByLibrary.simpleMessage("블랙리스트 모드"),
    "blockConnection": MessageLookupByLibrary.simpleMessage("연결 차단"),
    "brightness": MessageLookupByLibrary.simpleMessage("밝기"),
    "bypassDomain": MessageLookupByLibrary.simpleMessage("우회 도메인"),
    "bypassDomainDesc": MessageLookupByLibrary.simpleMessage(
      "우회 도메인은 시스템 프록시가 켜져 있을 때만 적용됩니다.",
    ),
    "bypassPrivateRoute": MessageLookupByLibrary.simpleMessage("사설 주소 우회"),
    "bypassPrivateRouteDesc": MessageLookupByLibrary.simpleMessage(
      "사설 주소 우회를 켜면 LAN, 루프백, 멀티캐스트 주소는 TUN을 거치지 않습니다.",
    ),
    "cache": MessageLookupByLibrary.simpleMessage("캐시"),
    "cacheAlgorithm": MessageLookupByLibrary.simpleMessage("캐시 알고리즘"),
    "cacheCorrupt": MessageLookupByLibrary.simpleMessage(
      "캐시가 손상되었습니다. 지우시겠습니까?",
    ),
    "cacheMaxSize": MessageLookupByLibrary.simpleMessage("캐시 크기"),
    "cameraPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "QR 코드를 스캔하려면 시스템 설정에서 카메라 접근을 허용하거나, 앨범에서 QR 코드 이미지를 선택하세요.",
    ),
    "cameraPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "카메라 권한 필요",
    ),
    "cameraUnavailable": MessageLookupByLibrary.simpleMessage("카메라를 사용할 수 없음"),
    "cancel": MessageLookupByLibrary.simpleMessage("취소"),
    "cancelSelectAll": MessageLookupByLibrary.simpleMessage("모두 선택 해제"),
    "cannotSave": MessageLookupByLibrary.simpleMessage("저장할 수 없음"),
    "changeProxyFailedTip": MessageLookupByLibrary.simpleMessage(
      "프록시를 전환하지 못해 이전 선택을 복원했습니다",
    ),
    "changelogBreaking": MessageLookupByLibrary.simpleMessage("호환성 변경"),
    "changelogFeatures": MessageLookupByLibrary.simpleMessage("새로운 기능"),
    "changelogFixes": MessageLookupByLibrary.simpleMessage("버그 수정"),
    "changelogPerformance": MessageLookupByLibrary.simpleMessage("성능"),
    "changelogReverts": MessageLookupByLibrary.simpleMessage("되돌림"),
    "checkCertificate": MessageLookupByLibrary.simpleMessage("TLS 인증서 검증"),
    "checkCertificateDesc": MessageLookupByLibrary.simpleMessage(
      "TLS 검증을 끄면 구독과 백업이 중간자 공격에 노출됩니다.",
    ),
    "checkUpdate": MessageLookupByLibrary.simpleMessage("업데이트 확인"),
    "checkUpdateError": MessageLookupByLibrary.simpleMessage("이미 최신 버전입니다"),
    "cipher": MessageLookupByLibrary.simpleMessage("암호화 방식"),
    "clearData": MessageLookupByLibrary.simpleMessage("데이터 지우기"),
    "clearDataAndExitTip": MessageLookupByLibrary.simpleMessage(
      "모든 프로필, 설정, 로컬 데이터를 삭제한 후 앱을 종료합니다. 앱을 다시 열면 처음부터 시작합니다.",
    ),
    "clearDataFailed": m4,
    "clearDnsCache": MessageLookupByLibrary.simpleMessage("DNS 캐시 지우기"),
    "clearDnsCacheFailed": MessageLookupByLibrary.simpleMessage(
      "DNS 캐시를 지우지 못했습니다",
    ),
    "clearSearch": MessageLookupByLibrary.simpleMessage("검색 지우기"),
    "clientFingerprint": MessageLookupByLibrary.simpleMessage("클라이언트 핑거프린트"),
    "clipboardExport": MessageLookupByLibrary.simpleMessage("클립보드로 내보내기"),
    "clipboardImport": MessageLookupByLibrary.simpleMessage("클립보드에서 가져오기"),
    "clipboardWriteFailed": MessageLookupByLibrary.simpleMessage(
      "클립보드에 복사하지 못했습니다. 선택 영역이 너무 클 수 있습니다",
    ),
    "close": MessageLookupByLibrary.simpleMessage("닫기"),
    "closeConnections": MessageLookupByLibrary.simpleMessage("연결 종료"),
    "color": MessageLookupByLibrary.simpleMessage("색상"),
    "colorStyle": MessageLookupByLibrary.simpleMessage("색상 스타일"),
    "columns": MessageLookupByLibrary.simpleMessage("열"),
    "compact": MessageLookupByLibrary.simpleMessage("간결하게"),
    "compatible": MessageLookupByLibrary.simpleMessage("호환 모드"),
    "confirm": MessageLookupByLibrary.simpleMessage("확인"),
    "confirmClearAllData": MessageLookupByLibrary.simpleMessage(
      "모든 데이터를 지우시겠습니까?",
    ),
    "confirmDeleteProxyGroup": MessageLookupByLibrary.simpleMessage(
      "이 프록시 그룹을 삭제하시겠습니까?",
    ),
    "confirmExitWindow": MessageLookupByLibrary.simpleMessage("현재 창을 닫으시겠습니까?"),
    "confirmForceCrashCore": MessageLookupByLibrary.simpleMessage(
      "코어를 강제로 비정상 종료시키시겠습니까?",
    ),
    "congestionControl": MessageLookupByLibrary.simpleMessage("혼잡 제어"),
    "congestionController": MessageLookupByLibrary.simpleMessage("TCP 혼잡 제어"),
    "congestionControllerDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 혼잡 제어는 mips 스택에서만 작동합니다.",
    ),
    "connected": MessageLookupByLibrary.simpleMessage("연결됨"),
    "connecting": MessageLookupByLibrary.simpleMessage("연결 중…"),
    "connection": MessageLookupByLibrary.simpleMessage("연결"),
    "connectionStats": MessageLookupByLibrary.simpleMessage("연결 통계"),
    "connectionStatsDesc": MessageLookupByLibrary.simpleMessage(
      "실시간 연결, 최근 요청, DNS 쿼리",
    ),
    "connections": MessageLookupByLibrary.simpleMessage("연결"),
    "connectivity": MessageLookupByLibrary.simpleMessage("연결 상태: "),
    "content": MessageLookupByLibrary.simpleMessage("내용"),
    "contentNotEmpty": MessageLookupByLibrary.simpleMessage("내용을 입력하세요"),
    "controlGlobalAddedRules": MessageLookupByLibrary.simpleMessage(
      "전역 추가 규칙 관리",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("복사"),
    "copyEnvVar": MessageLookupByLibrary.simpleMessage("환경 변수 복사"),
    "copyLink": MessageLookupByLibrary.simpleMessage("링크 복사"),
    "copySuccess": MessageLookupByLibrary.simpleMessage("복사했습니다"),
    "core": MessageLookupByLibrary.simpleMessage("코어"),
    "coreBlockedByPolicyTip": m5,
    "coreBlockedBySmartAppControlTip": MessageLookupByLibrary.simpleMessage(
      "서명되지 않아 Windows Smart App Control이 FlClashCore.exe를 차단했습니다. Windows 보안 → 앱 및 브라우저 컨트롤 → Smart App Control 설정에서 끔을 선택한 후 FlClash를 다시 시작하세요. Smart App Control은 Windows를 다시 설치하지 않으면 다시 켤 수 없습니다.",
    ),
    "coreStatus": MessageLookupByLibrary.simpleMessage("코어 상태"),
    "country": MessageLookupByLibrary.simpleMessage("지역"),
    "crashDetected": MessageLookupByLibrary.simpleMessage("비정상 종료 감지됨"),
    "crashDetectedTip": m6,
    "crashTest": MessageLookupByLibrary.simpleMessage("비정상 종료 테스트"),
    "create": MessageLookupByLibrary.simpleMessage("만들기"),
    "createProfileFromUrlTip": m7,
    "creationTime": MessageLookupByLibrary.simpleMessage("생성 시간"),
    "currentOutboundDesc": MessageLookupByLibrary.simpleMessage(
      "시작 버튼이 있어 제거할 수 없습니다",
    ),
    "custom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "customColor": MessageLookupByLibrary.simpleMessage("사용자 지정 색상"),
    "customImportDroppedSubRules": m8,
    "customIssueCoreRejected": m9,
    "customIssueDialerLoop": m10,
    "customIssueDuplicateName": m11,
    "customIssueEmptyName": MessageLookupByLibrary.simpleMessage("이름이 비어 있습니다"),
    "customIssueGroupLoop": m12,
    "customIssueInvalidEmptyFallback": m13,
    "customIssueInvalidFilter": m14,
    "customIssueMissingDialer": m15,
    "customIssueMissingProviders": m16,
    "customIssueMissingProxies": m17,
    "customIssueNoProxySource": MessageLookupByLibrary.simpleMessage(
      "선택한 프록시나 프록시 공급자가 없어 코어가 이 그룹을 거부합니다",
    ),
    "customIssueReservedName": m18,
    "customIssuesSummary": m19,
    "customProfile": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "customProfileDesc": MessageLookupByLibrary.simpleMessage(
      "앱 프록시와 다른 프로필로 프록시 그룹과 규칙을 조합합니다",
    ),
    "customProfileResources": MessageLookupByLibrary.simpleMessage(
      "사용자 지정 프로필 리소스",
    ),
    "customProfileResourcesDesc": MessageLookupByLibrary.simpleMessage(
      "사용자 지정 프로필 리소스는 직접 추가해 사용자 지정 프로필에서 쓰는 프록시, 규칙 공급자, 필터, 아이콘 세트입니다.",
    ),
    "cut": MessageLookupByLibrary.simpleMessage("잘라내기"),
    "dark": MessageLookupByLibrary.simpleMessage("다크"),
    "dashboard": MessageLookupByLibrary.simpleMessage("대시보드"),
    "dashboardAddableSection": MessageLookupByLibrary.simpleMessage("추가 가능"),
    "databaseWriteFailedTip": MessageLookupByLibrary.simpleMessage(
      "변경 사항을 저장하지 못해 되돌렸습니다",
    ),
    "daysAgo": m20,
    "daysAgoShort": m21,
    "defaultSelected": MessageLookupByLibrary.simpleMessage("기본 선택"),
    "defaultText": MessageLookupByLibrary.simpleMessage("기본값"),
    "definitionNotMap": MessageLookupByLibrary.simpleMessage(
      "구성은 이름과 유형이 있는 YAML 매핑이어야 합니다",
    ),
    "delay": MessageLookupByLibrary.simpleMessage("지연"),
    "delayFailed": MessageLookupByLibrary.simpleMessage("실패"),
    "delayTest": MessageLookupByLibrary.simpleMessage("지연 테스트"),
    "delayTestTimeout": MessageLookupByLibrary.simpleMessage("지연 테스트 시간 제한"),
    "delete": MessageLookupByLibrary.simpleMessage("삭제"),
    "deleteMultipTip": m22,
    "deleteTip": m23,
    "desc": MessageLookupByLibrary.simpleMessage(
      "ClashMeta 기반의 멀티 플랫폼 프록시 클라이언트로, 간편하게 사용할 수 있으며 오픈 소스이고 광고가 없습니다.",
    ),
    "destination": MessageLookupByLibrary.simpleMessage("목적지"),
    "destinationGeoIP": MessageLookupByLibrary.simpleMessage("목적지 GeoIP"),
    "destinationIPASN": MessageLookupByLibrary.simpleMessage("목적지 IP ASN"),
    "details": m24,
    "detectionTip": MessageLookupByLibrary.simpleMessage(
      "서드파티 API에 의존하므로 참고용으로만 사용하세요",
    ),
    "developerMode": MessageLookupByLibrary.simpleMessage("개발자 모드"),
    "developerModeEnableTip": MessageLookupByLibrary.simpleMessage(
      "개발자 모드가 켜졌습니다.",
    ),
    "dialerProxy": MessageLookupByLibrary.simpleMessage("다이얼러 프록시"),
    "dialerProxyDesc": MessageLookupByLibrary.simpleMessage(
      "다이얼러 프록시는 NTP 서버에 연결할 때 사용하는 아웃바운드입니다.",
    ),
    "dialerProxyLoopStopped": m25,
    "direct": MessageLookupByLibrary.simpleMessage("직접"),
    "disableIcmpForwarding": MessageLookupByLibrary.simpleMessage(
      "ICMP 전달 사용 안 함",
    ),
    "disableIcmpForwardingDesc": MessageLookupByLibrary.simpleMessage(
      "ICMP 전달을 끄면 TUN이 ping에 직접 응답하므로 ping에 실제 지연 시간이 표시되지 않습니다.",
    ),
    "disableKeepAlive": MessageLookupByLibrary.simpleMessage(
      "TCP 킵얼라이브 사용 안 함",
    ),
    "disableUDP": MessageLookupByLibrary.simpleMessage("UDP 사용 안 함"),
    "disabled": MessageLookupByLibrary.simpleMessage("사용 안 함"),
    "discardChanges": MessageLookupByLibrary.simpleMessage("변경 사항을 취소하시겠습니까?"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("면책 조항"),
    "disclaimerAcceptContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어를 설치, 복사 또는 사용하면 이 문서 전체를 읽고 동의한 것으로 간주합니다. 어느 조항이라도 동의하지 않는 경우 즉시 본 소프트웨어의 사용을 중단하고 삭제하세요.",
    ),
    "disclaimerAcceptTitle": MessageLookupByLibrary.simpleMessage("동의"),
    "disclaimerAcknowledgeLabel": MessageLookupByLibrary.simpleMessage(
      "이 문구를 읽고 이해했습니다",
    ),
    "disclaimerAcknowledgeTip": MessageLookupByLibrary.simpleMessage(
      "내용을 이해했는지 확인하기 위해 다음 문구를 읽고 아래 항목에 체크하세요.",
    ),
    "disclaimerAcknowledgeTitle": MessageLookupByLibrary.simpleMessage("문구 확인"),
    "disclaimerChangesContent": MessageLookupByLibrary.simpleMessage(
      "개발자는 릴리스와 함께 본 문서를 개정할 수 있으며, 개정 내용은 해당 릴리스가 공개되는 시점에 효력이 발생합니다. 업데이트 후에도 본 소프트웨어를 계속 사용하면 개정된 문서를 수락한 것으로 간주합니다.",
    ),
    "disclaimerChangesTitle": MessageLookupByLibrary.simpleMessage("본 문서의 변경"),
    "disclaimerDesc": MessageLookupByLibrary.simpleMessage(
      "FlClash(이하 “본 소프트웨어”)를 사용하기 전에 이 문서를 주의 깊게 읽고 모든 내용을 이해했는지 확인하세요. “동의”를 누르면 아래 모든 조항을 읽고 이해했으며 수락한 것으로 간주합니다. 동의하지 않으면 “종료”를 누르고 본 소프트웨어의 사용을 중단하세요.",
    ),
    "disclaimerLiabilityContent": MessageLookupByLibrary.simpleMessage(
      "관련 법률이 허용하는 최대 범위에서, 개발자와 기여자는 본 소프트웨어의 사용 또는 사용 불능으로 발생하는 직접, 간접, 부수적, 특별, 징벌적 또는 결과적 손해에 대해 책임을 지지 않습니다. 여기에는 데이터 손실, 기기 손상, 네트워크 장애, 사업 중단, 이익 손실 및 그로 인한 법적 분쟁이 포함되며 이에 국한되지 않고, 그러한 손해의 가능성을 사전에 통지받은 경우에도 마찬가지입니다.",
    ),
    "disclaimerLiabilityTitle": MessageLookupByLibrary.simpleMessage("책임의 제한"),
    "disclaimerLicenseContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 GPL-3.0 라이선스로 공개된 오픈 소스입니다. 파생 저작물도 GPL-3.0으로 배포하고 원저작권 고지를 유지해야 하는 라이선스 조건을 준수하는 한 자유롭게 사용, 수정, 배포할 수 있습니다.\n\nClash.Meta 코어를 포함한 본 소프트웨어의 제3자 구성 요소는 각자의 라이선스를 따릅니다. 원저작자는 수정 또는 재배포된 버전에서 발생하는 어떠한 문제에도 책임을 지지 않습니다.",
    ),
    "disclaimerLicenseTitle": MessageLookupByLibrary.simpleMessage(
      "오픈 소스 라이선스",
    ),
    "disclaimerNoServiceStatement": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어 자체는 프록시 서버, 노드, 구독, 네트워크 접속 서비스를 일절 제공하지 않으며, 이러한 서비스의 어떤 제공자와도 제휴, 대리 또는 보증 관계가 없습니다.",
    ),
    "disclaimerPrivacyContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 구독 URL, 노드 정보, 구성 내용, 방문한 웹사이트, 연결 기록, 트래픽 내용, 로그를 수집하거나 업로드하지 않습니다. 이 데이터는 사용자의 기기에만 저장되며 개발자는 접근할 수 없습니다.\n\n본 소프트웨어는 프로필을 업데이트할 때 사용자가 입력한 구독 URL을 가져오거나 업데이트를 확인할 때 GitHub에 접속하는 등 기능이 필요할 때만 네트워크에 접속합니다.\n\n본 소프트웨어에는 어떤 플랫폼에서도 분석 또는 비정상 종료 보고 서비스가 포함되어 있지 않습니다.",
    ),
    "disclaimerPrivacyTitle": MessageLookupByLibrary.simpleMessage(
      "데이터 수집 및 개인정보 보호",
    ),
    "disclaimerResponsibilityContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어의 사용이 거주지에서 적법한지 확인할 책임은 사용자에게 있으며, 본 소프트웨어로 한 모든 행위와 그 결과에 대한 법적 책임은 사용자 본인이 부담합니다.\n\n가져오는 구독, 노드, 구성은 사용자 본인의 선택입니다. 출처의 적법성, 콘텐츠의 안전성, 서비스의 신뢰성은 사용자와 해당 제공자 사이의 문제입니다.",
    ),
    "disclaimerResponsibilityTitle": MessageLookupByLibrary.simpleMessage(
      "사용자의 책임",
    ),
    "disclaimerRestateHint": MessageLookupByLibrary.simpleMessage(
      "위 문구를 입력하세요",
    ),
    "disclaimerRestateMismatch": MessageLookupByLibrary.simpleMessage(
      "문구와 일치하지 않습니다",
    ),
    "disclaimerRestateTip": MessageLookupByLibrary.simpleMessage(
      "내용을 이해했는지 확인하기 위해 아래 입력란에 다음 문구를 그대로 입력하세요.",
    ),
    "disclaimerRestateTitle": MessageLookupByLibrary.simpleMessage("문구 다시 입력"),
    "disclaimerSoftwareContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 Clash.Meta(mihomo) 코어를 기반으로 한 오픈 소스 네트워크 프록시 클라이언트입니다. 구성 관리, 규칙 기반 라우팅, 트래픽 전달과 같은 로컬 도구만 제공합니다.",
    ),
    "disclaimerSoftwareTitle": MessageLookupByLibrary.simpleMessage(
      "소프트웨어의 성격",
    ),
    "disclaimerThirdPartyContent": MessageLookupByLibrary.simpleMessage(
      "구독 링크, 구성 파일, 규칙 세트, 스크립트, 외부 리소스, 외부 링크는 모두 제3자가 제공합니다. 개발자는 이들의 적법성, 정확성, 안전성, 가용성을 심사하거나 보증할 수 없으며 보증하지 않습니다.\n\n제3자 콘텐츠로 인한 데이터 유출, 금전적 손실, 계정 정지 및 기타 손해는 사용자와 해당 제3자 사이에서 해결해야 하며, 개발자는 이에 대해 책임을 지지 않습니다.",
    ),
    "disclaimerThirdPartyTitle": MessageLookupByLibrary.simpleMessage(
      "제3자 콘텐츠",
    ),
    "disclaimerUsageContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 학습, 교류, 기술 연구와 같은 비상업적 용도로만 제공됩니다. 유료 배포, 끼워 팔기, 상업 서비스의 일부로 사용, 본 소프트웨어의 이름을 내세운 영업 등 어떠한 상업적 목적의 사용도 엄격히 금지되며, 이에 국한되지 않습니다. 모든 상업 활동은 본 소프트웨어 및 개발자와 무관합니다.\n\n거주 국가 또는 지역의 법령을 위반하는 용도로 본 소프트웨어를 사용하는 것은 엄격히 금지됩니다. 여기에는 합법적으로 부과된 네트워크 접속 제한 우회, 불법 콘텐츠 유포, 네트워크 공격, 타인의 합법적 권리 침해가 포함되며 이에 국한되지 않습니다.",
    ),
    "disclaimerUsageTitle": MessageLookupByLibrary.simpleMessage("사용 제한"),
    "disclaimerWarrantyContent": MessageLookupByLibrary.simpleMessage(
      "본 소프트웨어는 “있는 그대로”, “이용 가능한 상태로” 제공되며, 상품성, 특정 목적에의 적합성, 비침해성, 중단 없는 이용 가능성, 오류 없음, 보안 취약점 없음에 대한 보증을 포함하되 이에 국한되지 않고 명시적이든 묵시적이든 어떠한 종류의 보증도 하지 않습니다.\n\n개발자는 본 소프트웨어가 사용자의 요구를 충족하거나 중단 및 오류 없이 실행될 것임을 보증하지 않습니다.",
    ),
    "disclaimerWarrantyTitle": MessageLookupByLibrary.simpleMessage("보증 부인"),
    "disconnected": MessageLookupByLibrary.simpleMessage("연결 끊김"),
    "discoverNewVersion": MessageLookupByLibrary.simpleMessage("새 버전 발견"),
    "dnsCacheCleared": MessageLookupByLibrary.simpleMessage("DNS 캐시를 지웠습니다"),
    "dnsHijackDesc": MessageLookupByLibrary.simpleMessage(
      "추가하지 않으면 53번 포트로 가는 모든 DNS 쿼리를 하이재킹합니다(any:53).",
    ),
    "dnsHijacking": MessageLookupByLibrary.simpleMessage("DNS 하이재킹"),
    "dnsMode": MessageLookupByLibrary.simpleMessage("DNS 모드"),
    "dnsOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "여기에 추가한 항목은 모든 URL 및 파일 프로필의 DNS를 대체합니다. 추가하지 않은 항목은 프로필 자체 설정을 유지합니다. 사용자 지정 프로필은 내용에서 DNS를 설정합니다.",
    ),
    "dnsQueries": MessageLookupByLibrary.simpleMessage("DNS 쿼리"),
    "docked": MessageLookupByLibrary.simpleMessage("고정"),
    "domain": MessageLookupByLibrary.simpleMessage("도메인"),
    "done": MessageLookupByLibrary.simpleMessage("완료"),
    "download": MessageLookupByLibrary.simpleMessage("다운로드"),
    "downloadBandwidth": MessageLookupByLibrary.simpleMessage("다운로드 대역폭"),
    "duration": MessageLookupByLibrary.simpleMessage("소요 시간"),
    "edit": MessageLookupByLibrary.simpleMessage("편집"),
    "editDashboard": MessageLookupByLibrary.simpleMessage("대시보드 편집"),
    "editGlobalRules": MessageLookupByLibrary.simpleMessage("전역 규칙 편집"),
    "editProxy": MessageLookupByLibrary.simpleMessage("프록시 편집"),
    "editProxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹 편집"),
    "editRule": MessageLookupByLibrary.simpleMessage("규칙 편집"),
    "editSsid": MessageLookupByLibrary.simpleMessage("SSID 편집"),
    "editorUnavailable": MessageLookupByLibrary.simpleMessage("편집기를 사용할 수 없음"),
    "elapsed": MessageLookupByLibrary.simpleMessage("소요"),
    "emptyFallback": MessageLookupByLibrary.simpleMessage("빈 폴백"),
    "emptyTip": m26,
    "en": MessageLookupByLibrary.simpleMessage("영어"),
    "enabled": MessageLookupByLibrary.simpleMessage("사용"),
    "entries": MessageLookupByLibrary.simpleMessage("개 항목"),
    "error": MessageLookupByLibrary.simpleMessage("오류"),
    "errorDetails": MessageLookupByLibrary.simpleMessage("오류 세부 정보"),
    "es": MessageLookupByLibrary.simpleMessage("스페인어"),
    "exclude": MessageLookupByLibrary.simpleMessage("최근 작업에서 숨기기"),
    "excludeDstPort": MessageLookupByLibrary.simpleMessage("제외할 대상 포트"),
    "excludeDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "제외할 대상 포트로 가는 트래픽은 TUN을 거치지 않습니다.",
    ),
    "excludeFilter": MessageLookupByLibrary.simpleMessage("제외 필터"),
    "excludeInterface": MessageLookupByLibrary.simpleMessage("제외할 인터페이스"),
    "excludeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "docker0와 같이 제외할 인터페이스로 들어오는 트래픽은 TUN을 거치지 않습니다.",
    ),
    "excludeSrcPort": MessageLookupByLibrary.simpleMessage("제외할 소스 포트"),
    "excludeSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "제외할 소스 포트에서 나가는 트래픽은 TUN을 거치지 않습니다.",
    ),
    "excludeSsids": MessageLookupByLibrary.simpleMessage("제외할 SSID"),
    "excludeSsidsDesc": MessageLookupByLibrary.simpleMessage(
      "제외 SSID의 Wi-Fi에 연결되면 앱의 실행 상태가 자동으로 전환됩니다.",
    ),
    "excludeUid": MessageLookupByLibrary.simpleMessage("제외할 사용자 ID"),
    "excludeUidDesc": MessageLookupByLibrary.simpleMessage(
      "제외할 사용자 ID의 프로세스 트래픽은 TUN을 거치지 않습니다.",
    ),
    "existsTip": m27,
    "exit": MessageLookupByLibrary.simpleMessage("종료"),
    "exitFullScreen": MessageLookupByLibrary.simpleMessage("전체 화면 종료"),
    "exitNodes": MessageLookupByLibrary.simpleMessage("출구 노드"),
    "expectedStatus": MessageLookupByLibrary.simpleMessage("예상 상태"),
    "expireTime": MessageLookupByLibrary.simpleMessage("만료 시간"),
    "exportFile": MessageLookupByLibrary.simpleMessage("파일 내보내기"),
    "exportLogs": MessageLookupByLibrary.simpleMessage("로그 내보내기"),
    "exportSuccess": MessageLookupByLibrary.simpleMessage("내보내기 완료"),
    "extend": MessageLookupByLibrary.simpleMessage("확장"),
    "extendMode": MessageLookupByLibrary.simpleMessage("확장 모드"),
    "extendScript": MessageLookupByLibrary.simpleMessage("확장 스크립트"),
    "externalController": MessageLookupByLibrary.simpleMessage("외부 컨트롤러"),
    "externalControllerDesc": MessageLookupByLibrary.simpleMessage(
      "외부 컨트롤러를 사용하면 9090 포트로 코어를 제어할 수 있습니다.",
    ),
    "externalControllerSecret": MessageLookupByLibrary.simpleMessage(
      "외부 컨트롤러 시크릿",
    ),
    "externalLink": MessageLookupByLibrary.simpleMessage("외부 링크"),
    "extraLarge": MessageLookupByLibrary.simpleMessage("매우 크게"),
    "fade": MessageLookupByLibrary.simpleMessage("페이드"),
    "failedCount": m28,
    "failedItem": m29,
    "fakeipFilter": MessageLookupByLibrary.simpleMessage("Fake-IP 필터"),
    "fakeipFilterMode": MessageLookupByLibrary.simpleMessage("Fake-IP 필터 모드"),
    "fakeipFilterModeDesc": MessageLookupByLibrary.simpleMessage(
      "Fake-IP 필터 모드에서 블랙리스트는 일치 항목을 제외하고, 화이트리스트는 일치 항목에만 가짜 IP를 사용하며, 규칙은 규칙에 따라 일치시킵니다.",
    ),
    "fakeipRange": MessageLookupByLibrary.simpleMessage("Fake-IP 범위"),
    "fakeipRange6": MessageLookupByLibrary.simpleMessage("Fake-IP 범위(IPv6)"),
    "fakeipTtl": MessageLookupByLibrary.simpleMessage("Fake-IP TTL"),
    "fallbackFilter": MessageLookupByLibrary.simpleMessage("폴백 필터"),
    "file": MessageLookupByLibrary.simpleMessage("파일"),
    "fileDesc": MessageLookupByLibrary.simpleMessage("프로필 파일을 직접 업로드"),
    "fileIsUpdate": MessageLookupByLibrary.simpleMessage(
      "파일이 수정되었습니다. 변경 사항을 저장하시겠습니까?",
    ),
    "filter": MessageLookupByLibrary.simpleMessage("필터"),
    "filters": MessageLookupByLibrary.simpleMessage("필터"),
    "findProcessMode": MessageLookupByLibrary.simpleMessage("프로세스 찾기"),
    "floating": MessageLookupByLibrary.simpleMessage("플로팅"),
    "followProfile": MessageLookupByLibrary.simpleMessage("프로필 따르기"),
    "followSystem": MessageLookupByLibrary.simpleMessage("시스템 설정 따르기"),
    "fontFamily": MessageLookupByLibrary.simpleMessage("글꼴"),
    "fontSize": MessageLookupByLibrary.simpleMessage("크기"),
    "forceDnsMapping": MessageLookupByLibrary.simpleMessage("DNS 매핑 강제"),
    "forceDnsMappingDesc": MessageLookupByLibrary.simpleMessage(
      "DNS 매핑 강제는 DNS 매핑에서 도메인을 얻은 연결도 스니핑합니다.",
    ),
    "forceDomain": MessageLookupByLibrary.simpleMessage("강제 도메인"),
    "forceDomainDesc": MessageLookupByLibrary.simpleMessage(
      "강제 도메인은 항상 스니핑합니다. 이미 도메인이 있는 다른 연결은 그대로 둡니다.",
    ),
    "forceRestartCoreTip": MessageLookupByLibrary.simpleMessage(
      "코어를 강제로 다시 시작하시겠습니까?",
    ),
    "fr": MessageLookupByLibrary.simpleMessage("프랑스어"),
    "general": MessageLookupByLibrary.simpleMessage("일반"),
    "geoResources": MessageLookupByLibrary.simpleMessage("Geo"),
    "geoSkipped": m30,
    "geoUpdated": m31,
    "geodataLoader": MessageLookupByLibrary.simpleMessage("Geo 저메모리 모드"),
    "global": MessageLookupByLibrary.simpleMessage("전역"),
    "go": MessageLookupByLibrary.simpleMessage("이동"),
    "goDownload": MessageLookupByLibrary.simpleMessage("다운로드"),
    "goToConfigureAddedRules": MessageLookupByLibrary.simpleMessage(
      "추가한 규칙 구성으로 이동",
    ),
    "goToConfigureScript": MessageLookupByLibrary.simpleMessage("스크립트 구성으로 이동"),
    "grid": MessageLookupByLibrary.simpleMessage("격자"),
    "groupCount": m32,
    "groupCountUnit": MessageLookupByLibrary.simpleMessage("개"),
    "groupTimeoutCount": m33,
    "hasCacheChange": MessageLookupByLibrary.simpleMessage("변경 사항을 캐시하시겠습니까?"),
    "hashByInUser": MessageLookupByLibrary.simpleMessage("인바운드 사용자별 해시"),
    "healthCheck": MessageLookupByLibrary.simpleMessage("상태 확인"),
    "helperCorruptTip": MessageLookupByLibrary.simpleMessage(
      "헬퍼 서비스를 사용할 수 없어 TUN 모드를 켤 수 없습니다. FlClash를 다시 설치하여 복구하세요.",
    ),
    "hex": MessageLookupByLibrary.simpleMessage("16진수"),
    "hideFromList": MessageLookupByLibrary.simpleMessage("목록에서 숨기기"),
    "hideIp": MessageLookupByLibrary.simpleMessage("IP 숨기기"),
    "hidePassword": MessageLookupByLibrary.simpleMessage("비밀번호 숨기기"),
    "hideTimeoutProxies": MessageLookupByLibrary.simpleMessage(
      "시간 초과된 프록시 숨기기",
    ),
    "hopInterval": MessageLookupByLibrary.simpleMessage("호핑 간격"),
    "host": MessageLookupByLibrary.simpleMessage("호스트"),
    "hostname": MessageLookupByLibrary.simpleMessage("호스트 이름"),
    "hotkeyConflictWith": m34,
    "hotkeyDesc": MessageLookupByLibrary.simpleMessage(
      "전역 단축키는 창이 숨겨져 있어도 작동합니다. 동작을 눌러 키 조합을 기록하세요.",
    ),
    "hotkeyManagement": MessageLookupByLibrary.simpleMessage("단축키 관리"),
    "hotkeyNeedsModifier": m35,
    "hotkeyNotSet": MessageLookupByLibrary.simpleMessage("설정 안 됨"),
    "hotkeyUnavailable": MessageLookupByLibrary.simpleMessage(
      "등록되지 않음: 다른 앱이 사용 중일 수 있습니다",
    ),
    "hours": MessageLookupByLibrary.simpleMessage("시간"),
    "hoursAgo": m36,
    "hoursAgoShort": m37,
    "hue": MessageLookupByLibrary.simpleMessage("색조"),
    "icon": MessageLookupByLibrary.simpleMessage("아이콘"),
    "iconRecords": MessageLookupByLibrary.simpleMessage("아이콘 기록"),
    "iconSets": MessageLookupByLibrary.simpleMessage("아이콘 세트"),
    "iconSetsEmptyTip": MessageLookupByLibrary.simpleMessage(
      "아이콘 세트가 아직 없습니다. 사용자 지정 프로필 리소스 → 아이콘 세트에서 추가하세요",
    ),
    "iconStyle": MessageLookupByLibrary.simpleMessage("아이콘 스타일"),
    "iconStyleFilled": MessageLookupByLibrary.simpleMessage("채움"),
    "iconStyleHidden": MessageLookupByLibrary.simpleMessage("숨김"),
    "iconStylePlain": MessageLookupByLibrary.simpleMessage("기본"),
    "iconUrl": MessageLookupByLibrary.simpleMessage("아이콘 URL"),
    "ignoreBatteryOptimization": MessageLookupByLibrary.simpleMessage(
      "배터리 최적화 무시",
    ),
    "import": MessageLookupByLibrary.simpleMessage("가져오기"),
    "importConfigInvalid": MessageLookupByLibrary.simpleMessage(
      "가져올 수 있는 구성 파일이 아닙니다",
    ),
    "importConfigReplaceTip": MessageLookupByLibrary.simpleMessage(
      "가져오면 이 프로필의 현재 프록시 그룹, 규칙, 설정이 대체됩니다",
    ),
    "importFile": MessageLookupByLibrary.simpleMessage("파일에서 가져오기"),
    "importFromLink": MessageLookupByLibrary.simpleMessage("링크에서 가져오기"),
    "importUrl": MessageLookupByLibrary.simpleMessage("URL에서 가져오기"),
    "inbound": MessageLookupByLibrary.simpleMessage("인바운드"),
    "includeInterface": MessageLookupByLibrary.simpleMessage("포함할 인터페이스"),
    "includeInterfaceDesc": MessageLookupByLibrary.simpleMessage(
      "포함할 인터페이스로 들어오는 트래픽만 TUN을 거치며, 제외할 인터페이스는 더 이상 적용되지 않습니다.",
    ),
    "includeUid": MessageLookupByLibrary.simpleMessage("포함할 사용자 ID"),
    "includeUidDesc": MessageLookupByLibrary.simpleMessage(
      "포함할 사용자 ID의 프로세스 트래픽만 TUN을 거칩니다.",
    ),
    "infiniteTime": MessageLookupByLibrary.simpleMessage("만료되지 않음"),
    "init": MessageLookupByLibrary.simpleMessage("초기화"),
    "initFailed": MessageLookupByLibrary.simpleMessage("시작 실패"),
    "initFailedTip": MessageLookupByLibrary.simpleMessage(
      "FlClash를 시작하는 중 오류가 발생하여 계속할 수 없습니다. 세부 정보를 복사하여 문제를 보고하세요. 문제가 계속되면 데이터를 지우면 대개 앱이 다시 시작됩니다.",
    ),
    "initiator": MessageLookupByLibrary.simpleMessage("요청자"),
    "initiatorShort": MessageLookupByLibrary.simpleMessage("출처"),
    "inputProxyGroupName": MessageLookupByLibrary.simpleMessage(
      "프록시 그룹 이름을 입력하세요",
    ),
    "inputRuleContent": MessageLookupByLibrary.simpleMessage("규칙 내용을 입력하세요"),
    "installedAppsPermissionDeniedMessage":
        MessageLookupByLibrary.simpleMessage(
          "앱 목록 권한이 거부되어 설치된 앱을 표시할 수 없습니다. 시스템 설정에서 직접 허용해 주세요.",
        ),
    "installedAppsPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "이 시스템은 권한을 허용하기 전까지 설치된 앱 목록을 숨깁니다. 앱별 프록시를 구성하려면 권한을 허용하세요.",
    ),
    "installedAppsPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "앱 목록 권한 필요",
    ),
    "installedFonts": MessageLookupByLibrary.simpleMessage("설치된 글꼴"),
    "intelligentSelected": MessageLookupByLibrary.simpleMessage("스마트 선택"),
    "interfaceName": MessageLookupByLibrary.simpleMessage("인터페이스 이름"),
    "interfaceNameDesc": MessageLookupByLibrary.simpleMessage(
      "인터페이스 이름은 아웃바운드 연결이 사용하는 네트워크 인터페이스입니다.",
    ),
    "interfaceNameMode": MessageLookupByLibrary.simpleMessage("아웃바운드 인터페이스"),
    "interfaceNameModeClear": MessageLookupByLibrary.simpleMessage("지정 안 함"),
    "interfaceNameModeCustom": MessageLookupByLibrary.simpleMessage("사용자 지정"),
    "interfaceNameModeFollow": MessageLookupByLibrary.simpleMessage("구성 따르기"),
    "internet": MessageLookupByLibrary.simpleMessage("인터넷"),
    "interval": MessageLookupByLibrary.simpleMessage("간격"),
    "intranetIP": MessageLookupByLibrary.simpleMessage("내부망 IP"),
    "invalidBackupFile": MessageLookupByLibrary.simpleMessage("올바르지 않은 백업 파일"),
    "invalidCidrContent": MessageLookupByLibrary.simpleMessage(
      "192.168.0.0/16과 같은 CIDR 형식의 IP 범위를 입력하세요",
    ),
    "invalidDscpContent": MessageLookupByLibrary.simpleMessage(
      "DSCP 마크는 63을 넘을 수 없습니다",
    ),
    "invalidHostContent": MessageLookupByLibrary.simpleMessage(
      "도메인 또는 IP 주소를 입력하세요",
    ),
    "invalidIconSet": MessageLookupByLibrary.simpleMessage("올바른 아이콘 세트가 아닙니다"),
    "invalidLinkTip": MessageLookupByLibrary.simpleMessage(
      "구독 링크 또는 프록시 공유 링크가 아닙니다",
    ),
    "invalidListenContent": MessageLookupByLibrary.simpleMessage(
      "0.0.0.0:1053과 같은 주소와 포트를 입력하세요",
    ),
    "invalidNetworkContent": MessageLookupByLibrary.simpleMessage(
      "tcp 또는 udp만 지원합니다",
    ),
    "invalidPolicy": m38,
    "invalidPortRangeContent": MessageLookupByLibrary.simpleMessage(
      "443 또는 8000-9000과 같은 포트나 범위를 입력하세요",
    ),
    "invalidProfileQrcode": MessageLookupByLibrary.simpleMessage(
      "이 QR 코드에는 프로필 링크가 없습니다",
    ),
    "invalidProxy": m39,
    "invalidProxyProvider": m40,
    "invalidRangeContent": MessageLookupByLibrary.simpleMessage(
      "80 또는 8000-9000과 같은 숫자나 범위를 /로 구분하여 입력하세요",
    ),
    "invalidRuleSet": m41,
    "invalidSubRule": m42,
    "ipAddress": MessageLookupByLibrary.simpleMessage("IP 주소"),
    "ipAsn": MessageLookupByLibrary.simpleMessage("ASN"),
    "ipFlagAbuser": MessageLookupByLibrary.simpleMessage("악용 이력"),
    "ipFlagProxy": MessageLookupByLibrary.simpleMessage("프록시"),
    "ipFlagTor": MessageLookupByLibrary.simpleMessage("Tor"),
    "ipFlagVpn": MessageLookupByLibrary.simpleMessage("VPN"),
    "ipFlags": MessageLookupByLibrary.simpleMessage("플래그"),
    "ipOrganization": MessageLookupByLibrary.simpleMessage("조직"),
    "ipQualityFailed": MessageLookupByLibrary.simpleMessage(
      "IP 유형을 확인할 수 없습니다",
    ),
    "ipQualityGood": MessageLookupByLibrary.simpleMessage("양호"),
    "ipQualityLevel": MessageLookupByLibrary.simpleMessage("등급"),
    "ipQualityNormal": MessageLookupByLibrary.simpleMessage("보통"),
    "ipQualityRetry": MessageLookupByLibrary.simpleMessage("다시 확인"),
    "ipQualityRisky": MessageLookupByLibrary.simpleMessage("위험"),
    "ipQualityShort": MessageLookupByLibrary.simpleMessage("품질"),
    "ipQualitySource": MessageLookupByLibrary.simpleMessage("응답 출처"),
    "ipQualitySources": MessageLookupByLibrary.simpleMessage("출처"),
    "ipSourceIpMismatch": MessageLookupByLibrary.simpleMessage("아웃바운드 IP가 다름"),
    "ipSourceNoType": MessageLookupByLibrary.simpleMessage("유형 없음"),
    "ipSourceRateLimited": MessageLookupByLibrary.simpleMessage("요청 제한됨"),
    "ipType": MessageLookupByLibrary.simpleMessage("유형"),
    "ipTypeBusiness": MessageLookupByLibrary.simpleMessage("기업용"),
    "ipTypeHosting": MessageLookupByLibrary.simpleMessage("데이터 센터"),
    "ipTypeMobile": MessageLookupByLibrary.simpleMessage("모바일 네트워크"),
    "ipTypeResidential": MessageLookupByLibrary.simpleMessage("가정용"),
    "ipTypeUnknown": MessageLookupByLibrary.simpleMessage("알 수 없는 유형"),
    "ipVersion": MessageLookupByLibrary.simpleMessage("IP 버전"),
    "ipv6Desc": MessageLookupByLibrary.simpleMessage(
      "IPv6 트래픽은 IPv6가 켜져 있을 때만 수신됩니다.",
    ),
    "ipv6InboundDesc": MessageLookupByLibrary.simpleMessage(
      "IPv6를 켜면 VPN이 IPv6 인바운드를 허용합니다.",
    ),
    "ipv6Timeout": MessageLookupByLibrary.simpleMessage("IPv6 타임아웃(ms)"),
    "itemsCount": m43,
    "ja": MessageLookupByLibrary.simpleMessage("일본어"),
    "justNow": MessageLookupByLibrary.simpleMessage("방금"),
    "keepAliveIdle": MessageLookupByLibrary.simpleMessage("TCP 킵얼라이브 유휴 시간"),
    "keepAliveIntervalDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 킵얼라이브 간격",
    ),
    "key": MessageLookupByLibrary.simpleMessage("키"),
    "ko": MessageLookupByLibrary.simpleMessage("한국어"),
    "label": MessageLookupByLibrary.simpleMessage("레이블"),
    "language": MessageLookupByLibrary.simpleMessage("언어"),
    "large": MessageLookupByLibrary.simpleMessage("크게"),
    "lastUpdated": MessageLookupByLibrary.simpleMessage("마지막 업데이트"),
    "launchInterrupted": MessageLookupByLibrary.simpleMessage("시작이 완료되지 않음"),
    "launchInterruptedTip": MessageLookupByLibrary.simpleMessage(
      "지난번 시작하는 중에 앱이 예기치 않게 종료되었습니다. 이번 실행에서는 자동 설정을 건너뛰었으니 직접 시작하여 다시 시도하세요.",
    ),
    "layout": MessageLookupByLibrary.simpleMessage("레이아웃"),
    "light": MessageLookupByLibrary.simpleMessage("라이트"),
    "lineIssueTip": m44,
    "lineWrap": MessageLookupByLibrary.simpleMessage("자동 줄 바꿈"),
    "link": MessageLookupByLibrary.simpleMessage("링크"),
    "linkDesc": MessageLookupByLibrary.simpleMessage(
      "구독 링크 또는 프록시 공유 링크로 프로필 가져오기",
    ),
    "liquidGlass": MessageLookupByLibrary.simpleMessage("Liquid Glass"),
    "list": MessageLookupByLibrary.simpleMessage("목록"),
    "listen": MessageLookupByLibrary.simpleMessage("수신"),
    "listenRoutingMark": MessageLookupByLibrary.simpleMessage("수신 라우팅 마크"),
    "listenRoutingMarkDesc": MessageLookupByLibrary.simpleMessage(
      "수신 라우팅 마크는 Linux에서만 작동합니다.",
    ),
    "liveConnections": MessageLookupByLibrary.simpleMessage("실시간 연결"),
    "loading": MessageLookupByLibrary.simpleMessage("로드 중…"),
    "local": MessageLookupByLibrary.simpleMessage("로컬"),
    "localImage": MessageLookupByLibrary.simpleMessage("로컬 이미지"),
    "localNetworkDeniedTip": MessageLookupByLibrary.simpleMessage(
      "로컬 네트워크 권한이 거부되었습니다. gvisor 스택을 사용하므로 LAN에 연결할 수 없습니다.",
    ),
    "localProxies": MessageLookupByLibrary.simpleMessage("로컬 프록시"),
    "locationPermission": MessageLookupByLibrary.simpleMessage("위치 권한"),
    "locationPermissionDeniedMessage": MessageLookupByLibrary.simpleMessage(
      "위치 권한이 거부되어 현재 Wi-Fi 이름을 읽을 수 없습니다. 시스템 설정에서 위치 권한을 직접 켜 주세요.",
    ),
    "locationPermissionDesc": MessageLookupByLibrary.simpleMessage(
      "시스템에서 Wi-Fi 이름을 읽으려면 위치 권한이 필요합니다. Android에서는 “항상 허용”을 선택해야 하며, 그렇지 않으면 앱이 백그라운드에 있을 때 Wi-Fi 이름을 읽을 수 없습니다.",
    ),
    "locationPermissionGuide": m45,
    "locationPermissionRequired": MessageLookupByLibrary.simpleMessage(
      "위치 권한 필요",
    ),
    "log": MessageLookupByLibrary.simpleMessage("로그"),
    "logLevel": MessageLookupByLibrary.simpleMessage("로그 수준"),
    "logcat": MessageLookupByLibrary.simpleMessage("Logcat"),
    "logcatDesc": MessageLookupByLibrary.simpleMessage(
      "Logcat을 끄면 로그 항목이 숨겨집니다.",
    ),
    "logs": MessageLookupByLibrary.simpleMessage("로그"),
    "logsAndDiagnostics": MessageLookupByLibrary.simpleMessage("로그 및 진단"),
    "logsTest": MessageLookupByLibrary.simpleMessage("로그 테스트"),
    "loopback": MessageLookupByLibrary.simpleMessage("UWP 루프백 예외"),
    "loose": MessageLookupByLibrary.simpleMessage("넓게"),
    "matchCase": MessageLookupByLibrary.simpleMessage("대/소문자 구분"),
    "matchSourceIp": MessageLookupByLibrary.simpleMessage("출발지 IP 일치"),
    "matchTarget": MessageLookupByLibrary.simpleMessage("MATCH-TARGET"),
    "maxFailedTimes": MessageLookupByLibrary.simpleMessage("최대 실패 횟수"),
    "maxLengthTip": m46,
    "maximize": MessageLookupByLibrary.simpleMessage("최대화"),
    "memoryAppResident": MessageLookupByLibrary.simpleMessage("상주 메모리"),
    "memoryAppShared": MessageLookupByLibrary.simpleMessage("앱 및 공유"),
    "memoryCoreHeapIdle": MessageLookupByLibrary.simpleMessage("유휴 힙"),
    "memoryCoreHeapInuse": MessageLookupByLibrary.simpleMessage("사용 중인 힙"),
    "memoryCoreNotRunning": MessageLookupByLibrary.simpleMessage(
      "코어가 실행 중이 아닙니다",
    ),
    "memoryCoreRuntime": MessageLookupByLibrary.simpleMessage("런타임 오버헤드"),
    "memoryCoreStack": MessageLookupByLibrary.simpleMessage("고루틴 스택"),
    "memoryEstimateDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 상주 메모리로 추정한 값이며 시스템에 표시되는 값과 다를 수 있습니다.",
    ),
    "memoryEstimateSharedDesc": MessageLookupByLibrary.simpleMessage(
      "코어는 앱 프로세스 안에서 실행됩니다. 코어의 점유량은 런타임 통계로 추정하며, 나머지는 앱 및 공유 메모리로 집계합니다.",
    ),
    "memoryInfo": MessageLookupByLibrary.simpleMessage("메모리 정보"),
    "memoryInfoDesc": MessageLookupByLibrary.simpleMessage("앱과 코어가 사용하는 메모리"),
    "memoryReleased": MessageLookupByLibrary.simpleMessage("메모리를 해제했습니다"),
    "memoryReleasedSize": m47,
    "messageTest": MessageLookupByLibrary.simpleMessage("메시지 테스트"),
    "messageTestTip": MessageLookupByLibrary.simpleMessage("이것은 메시지입니다."),
    "minimize": MessageLookupByLibrary.simpleMessage("최소화"),
    "minimizeOnExit": MessageLookupByLibrary.simpleMessage("종료 시 최소화"),
    "minutes": MessageLookupByLibrary.simpleMessage("분"),
    "minutesAgo": m48,
    "minutesAgoShort": m49,
    "mixedPort": MessageLookupByLibrary.simpleMessage("혼합 포트"),
    "mode": MessageLookupByLibrary.simpleMessage("모드"),
    "monochromeIcon": MessageLookupByLibrary.simpleMessage("모노크롬 아이콘"),
    "monochromeScheme": MessageLookupByLibrary.simpleMessage("모노크롬"),
    "monthsAgo": m50,
    "monthsAgoShort": m51,
    "more": MessageLookupByLibrary.simpleMessage("더 보기"),
    "name": MessageLookupByLibrary.simpleMessage("이름"),
    "navigationBarStyle": MessageLookupByLibrary.simpleMessage("하단 바"),
    "network": MessageLookupByLibrary.simpleMessage("네트워크"),
    "networkAccessDeniedError": m52,
    "networkBadResponseError": m53,
    "networkCancelledError": MessageLookupByLibrary.simpleMessage(
      "요청이 취소되었습니다",
    ),
    "networkConnectionError": MessageLookupByLibrary.simpleMessage(
      "서버에 연결할 수 없습니다. 네트워크 연결이나 프록시 설정을 확인하세요",
    ),
    "networkHostLookupError": MessageLookupByLibrary.simpleMessage(
      "서버 주소를 확인할 수 없습니다. URL이 올바른지, DNS가 정상인지 확인하세요",
    ),
    "networkName": MessageLookupByLibrary.simpleMessage("네트워크 이름"),
    "networkNotFoundError": m54,
    "networkRateLimitedError": MessageLookupByLibrary.simpleMessage(
      "요청이 너무 많습니다(HTTP 429). 잠시 후 다시 시도하세요",
    ),
    "networkRequestFailed": m55,
    "networkSecret": MessageLookupByLibrary.simpleMessage("네트워크 시크릿"),
    "networkServerError": m56,
    "networkSpeed": MessageLookupByLibrary.simpleMessage("네트워크 속도"),
    "networkTakeover": MessageLookupByLibrary.simpleMessage("트래픽 가로채기"),
    "networkTimeoutError": MessageLookupByLibrary.simpleMessage(
      "요청 시간이 초과되었습니다. 네트워크나 프록시를 확인한 후 다시 시도하세요",
    ),
    "networkTlsError": MessageLookupByLibrary.simpleMessage(
      "보안 연결에 실패했습니다. 서버 인증서가 올바르지 않거나 연결이 가로채이고 있을 수 있습니다",
    ),
    "networkType": MessageLookupByLibrary.simpleMessage("네트워크 유형"),
    "nextMatch": MessageLookupByLibrary.simpleMessage("다음 결과"),
    "no": MessageLookupByLibrary.simpleMessage("아니요"),
    "noData": MessageLookupByLibrary.simpleMessage("데이터 없음"),
    "noInfo": MessageLookupByLibrary.simpleMessage("정보 없음"),
    "noLongerRemind": MessageLookupByLibrary.simpleMessage("다시 알리지 않음"),
    "noNetwork": MessageLookupByLibrary.simpleMessage("네트워크 없음"),
    "noNetworkApp": MessageLookupByLibrary.simpleMessage("네트워크 미사용 앱"),
    "noResolve": MessageLookupByLibrary.simpleMessage("IP 확인 안 함"),
    "noResolveHostname": MessageLookupByLibrary.simpleMessage("호스트 이름 확인 안 함"),
    "noSearchResults": MessageLookupByLibrary.simpleMessage("일치하는 결과 없음"),
    "nodes": MessageLookupByLibrary.simpleMessage("노드"),
    "nonTextProviderFile": MessageLookupByLibrary.simpleMessage(
      "이 외부 리소스는 텍스트 파일이 아닙니다",
    ),
    "none": MessageLookupByLibrary.simpleMessage("없음"),
    "notRunning": MessageLookupByLibrary.simpleMessage("실행 중 아님"),
    "notSelectedTip": MessageLookupByLibrary.simpleMessage(
      "현재 프록시 그룹은 선택할 수 없습니다",
    ),
    "ntpInterval": MessageLookupByLibrary.simpleMessage("동기화 간격(분)"),
    "ntpStatusDesc": MessageLookupByLibrary.simpleMessage(
      "NTP는 시스템 시계 대신 NTP 서버에서 시간을 가져옵니다.",
    ),
    "nullProfileDesc": MessageLookupByLibrary.simpleMessage("프로필을 추가하여 시작하세요"),
    "nullTip": m57,
    "numberRangeTip": m58,
    "numberTip": m59,
    "obfs": MessageLookupByLibrary.simpleMessage("난독화"),
    "obfsHost": MessageLookupByLibrary.simpleMessage("난독화 호스트"),
    "obfsMode": MessageLookupByLibrary.simpleMessage("난독화 모드"),
    "obfsParam": MessageLookupByLibrary.simpleMessage("난독화 매개변수"),
    "obfsPassword": MessageLookupByLibrary.simpleMessage("난독화 비밀번호"),
    "onDemand": MessageLookupByLibrary.simpleMessage("필요 시 실행"),
    "onDemandDesc": MessageLookupByLibrary.simpleMessage(
      "필요 시 실행은 제외된 Wi-Fi에서 프록시를 일시 중지합니다.",
    ),
    "onlyStatisticsProxy": MessageLookupByLibrary.simpleMessage("프록시 트래픽만 집계"),
    "optional": MessageLookupByLibrary.simpleMessage("선택 사항"),
    "options": MessageLookupByLibrary.simpleMessage("옵션"),
    "other": MessageLookupByLibrary.simpleMessage("기타"),
    "otherContributors": MessageLookupByLibrary.simpleMessage("기타 기여자"),
    "outbound": MessageLookupByLibrary.simpleMessage("아웃바운드"),
    "outboundExit": MessageLookupByLibrary.simpleMessage("출구"),
    "outboundIp": MessageLookupByLibrary.simpleMessage("아웃바운드 IP"),
    "outboundMode": MessageLookupByLibrary.simpleMessage("아웃바운드 모드"),
    "overrideDestination": MessageLookupByLibrary.simpleMessage("대상 덮어쓰기"),
    "overrideDestinationDesc": MessageLookupByLibrary.simpleMessage(
      "대상 덮어쓰기는 원래 주소 대신 스니핑한 도메인으로 연결합니다.",
    ),
    "overrideEntries": MessageLookupByLibrary.simpleMessage("덮어쓰기 항목"),
    "parsePureIp": MessageLookupByLibrary.simpleMessage("순수 IP 분석"),
    "parsePureIpDesc": MessageLookupByLibrary.simpleMessage(
      "순수 IP 분석은 IP 주소만 있는 연결을 스니핑합니다.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("비밀번호"),
    "paste": MessageLookupByLibrary.simpleMessage("붙여넣기"),
    "peers": MessageLookupByLibrary.simpleMessage("피어"),
    "pickFromAlbum": MessageLookupByLibrary.simpleMessage("앨범에서 선택"),
    "pinWindow": MessageLookupByLibrary.simpleMessage("창 고정"),
    "pleaseBindWebDAV": MessageLookupByLibrary.simpleMessage("WebDAV를 연결하세요"),
    "pleaseEnterScriptName": MessageLookupByLibrary.simpleMessage(
      "스크립트 이름을 입력하세요",
    ),
    "pleaseUploadValidQrcode": MessageLookupByLibrary.simpleMessage(
      "올바른 QR 코드를 업로드하세요",
    ),
    "plugin": MessageLookupByLibrary.simpleMessage("플러그인"),
    "pluginCipher": MessageLookupByLibrary.simpleMessage("플러그인 암호화 방식"),
    "pluginHost": MessageLookupByLibrary.simpleMessage("플러그인 호스트"),
    "pluginMode": MessageLookupByLibrary.simpleMessage("플러그인 모드"),
    "pluginPassword": MessageLookupByLibrary.simpleMessage("플러그인 비밀번호"),
    "pluginPath": MessageLookupByLibrary.simpleMessage("플러그인 경로"),
    "pluginUsername": MessageLookupByLibrary.simpleMessage("플러그인 사용자 이름"),
    "port": MessageLookupByLibrary.simpleMessage("포트"),
    "portConflictTip": MessageLookupByLibrary.simpleMessage("다른 포트를 입력하세요"),
    "portHopping": MessageLookupByLibrary.simpleMessage("포트 호핑"),
    "portTip": m60,
    "portValue": m61,
    "ports": MessageLookupByLibrary.simpleMessage("포트"),
    "preSharedKey": MessageLookupByLibrary.simpleMessage("사전 공유 키"),
    "preferred": MessageLookupByLibrary.simpleMessage("우선"),
    "prerequisites": MessageLookupByLibrary.simpleMessage("사전 요건"),
    "pressKeyboard": MessageLookupByLibrary.simpleMessage("키 조합을 누르세요"),
    "preview": MessageLookupByLibrary.simpleMessage("미리보기"),
    "previousMatch": MessageLookupByLibrary.simpleMessage("이전 결과"),
    "privateKey": MessageLookupByLibrary.simpleMessage("개인 키"),
    "privateKeyPassphrase": MessageLookupByLibrary.simpleMessage("개인 키 암호"),
    "process": MessageLookupByLibrary.simpleMessage("프로세스"),
    "profile": MessageLookupByLibrary.simpleMessage("프로필"),
    "profileAutoUpdateIntervalInvalidValidationDesc":
        MessageLookupByLibrary.simpleMessage("올바른 간격을 입력하세요"),
    "profileAutoUpdateIntervalNullValidationDesc":
        MessageLookupByLibrary.simpleMessage("자동 업데이트 간격을 입력하세요"),
    "profileDaysLeft": m62,
    "profileExpiresIn": m63,
    "profileHasUpdate": MessageLookupByLibrary.simpleMessage(
      "프로필이 수정되었습니다. 자동 업데이트를 끄시겠습니까?",
    ),
    "profileNameNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 이름을 입력하세요",
    ),
    "profileSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "이 프로필에만 적용되며, 추가하지 않은 항목은 기본값을 사용합니다.",
    ),
    "profileTunSettingsDesc": MessageLookupByLibrary.simpleMessage(
      "이 프로필에만 적용되며 네트워크 설정의 TUN 덮어쓰기 항목보다 우선합니다.",
    ),
    "profileUpdatedAt": m64,
    "profileUrlInvalidValidationDesc": MessageLookupByLibrary.simpleMessage(
      "올바른 프로필 URL을 입력하세요",
    ),
    "profileUrlNullValidationDesc": MessageLookupByLibrary.simpleMessage(
      "프로필 URL을 입력하세요",
    ),
    "profiles": MessageLookupByLibrary.simpleMessage("프로필"),
    "profilesSort": MessageLookupByLibrary.simpleMessage("프로필 정렬"),
    "project": MessageLookupByLibrary.simpleMessage("프로젝트"),
    "protocol": MessageLookupByLibrary.simpleMessage("프로토콜"),
    "protocolParam": MessageLookupByLibrary.simpleMessage("프로토콜 매개변수"),
    "protocolVersion": MessageLookupByLibrary.simpleMessage("프로토콜 버전"),
    "providerInUse": m65,
    "providerUrlTip": MessageLookupByLibrary.simpleMessage("원격 공급자만 지원합니다"),
    "providers": MessageLookupByLibrary.simpleMessage("외부 리소스"),
    "proxies": MessageLookupByLibrary.simpleMessage("프록시"),
    "proxiesCount": m66,
    "proxiesProfileLabel": m67,
    "proxiesRemovedTip": m68,
    "proxiesReplacedTip": m69,
    "proxyChains": MessageLookupByLibrary.simpleMessage("프록시 체인"),
    "proxyGroup": MessageLookupByLibrary.simpleMessage("프록시 그룹"),
    "proxyGroupEmpty": MessageLookupByLibrary.simpleMessage("프록시 그룹이 비어 있습니다"),
    "proxyGroupInUse": m70,
    "proxyGroupsAfterStart": MessageLookupByLibrary.simpleMessage(
      "코어가 시작되면 그룹이 여기에 표시됩니다",
    ),
    "proxyGroupsCount": m71,
    "proxyProviders": MessageLookupByLibrary.simpleMessage("프록시 공급자"),
    "proxyType": MessageLookupByLibrary.simpleMessage("프록시 유형"),
    "pruneCache": MessageLookupByLibrary.simpleMessage("캐시 정리"),
    "publicKey": MessageLookupByLibrary.simpleMessage("공개 키"),
    "pureBlack": MessageLookupByLibrary.simpleMessage("퓨어 블랙"),
    "pureBlackMode": MessageLookupByLibrary.simpleMessage("퓨어 블랙 모드"),
    "qrcode": MessageLookupByLibrary.simpleMessage("QR 코드"),
    "qrcodeDesc": MessageLookupByLibrary.simpleMessage("QR 코드를 스캔하여 프로필 가져오기"),
    "qrcodeTooLongTip": MessageLookupByLibrary.simpleMessage(
      "이 링크는 너무 길어 QR 코드로 만들 수 없습니다. 링크 복사를 사용하세요.",
    ),
    "quickActions": MessageLookupByLibrary.simpleMessage("빠른 작업"),
    "quickEdit": MessageLookupByLibrary.simpleMessage("빠른 편집"),
    "recentRequests": MessageLookupByLibrary.simpleMessage("최근 요청"),
    "recommendedIcons": MessageLookupByLibrary.simpleMessage("추천"),
    "recordType": MessageLookupByLibrary.simpleMessage("레코드 유형"),
    "redirPort": MessageLookupByLibrary.simpleMessage("Redir 포트"),
    "redo": MessageLookupByLibrary.simpleMessage("다시 실행"),
    "regex": MessageLookupByLibrary.simpleMessage("정규식"),
    "releaseMemory": MessageLookupByLibrary.simpleMessage("메모리 해제"),
    "releaseMemoryFailed": MessageLookupByLibrary.simpleMessage(
      "메모리를 해제하지 못했습니다",
    ),
    "remote": MessageLookupByLibrary.simpleMessage("원격"),
    "remoteDestination": MessageLookupByLibrary.simpleMessage("원격 목적지"),
    "remoteDnsResolve": MessageLookupByLibrary.simpleMessage("원격 DNS 확인"),
    "remove": MessageLookupByLibrary.simpleMessage("제거"),
    "rename": MessageLookupByLibrary.simpleMessage("이름 변경"),
    "replace": MessageLookupByLibrary.simpleMessage("바꾸기"),
    "replaceAll": MessageLookupByLibrary.simpleMessage("모두 바꾸기"),
    "request": MessageLookupByLibrary.simpleMessage("요청"),
    "requestHeaders": MessageLookupByLibrary.simpleMessage("요청 헤더"),
    "requests": MessageLookupByLibrary.simpleMessage("요청"),
    "requestsAndUpdates": MessageLookupByLibrary.simpleMessage("요청 및 업데이트"),
    "required": MessageLookupByLibrary.simpleMessage("필수"),
    "reset": MessageLookupByLibrary.simpleMessage("초기화"),
    "resetPageChangesTip": MessageLookupByLibrary.simpleMessage(
      "이 페이지에 변경 사항이 있습니다. 초기화하시겠습니까?",
    ),
    "resetTip": MessageLookupByLibrary.simpleMessage("초기화하시겠습니까?"),
    "resourceUpdateInterval": MessageLookupByLibrary.simpleMessage(
      "자동 업데이트 간격",
    ),
    "resourceUpdateIntervalTip": MessageLookupByLibrary.simpleMessage(
      "자동 업데이트 간격은 0보다 커야 합니다",
    ),
    "resources": MessageLookupByLibrary.simpleMessage("리소스"),
    "respectRules": MessageLookupByLibrary.simpleMessage("규칙 준수"),
    "respectRulesDesc": MessageLookupByLibrary.simpleMessage(
      "규칙 준수는 DNS 연결을 규칙에 따라 라우팅하며 Proxy Server Nameserver가 필요합니다.",
    ),
    "responseCode": MessageLookupByLibrary.simpleMessage("응답 코드"),
    "restart": MessageLookupByLibrary.simpleMessage("다시 시작"),
    "restartCoreTip": MessageLookupByLibrary.simpleMessage("코어를 다시 시작하시겠습니까?"),
    "restore": MessageLookupByLibrary.simpleMessage("복원"),
    "restoreAllData": MessageLookupByLibrary.simpleMessage("모든 데이터 복원"),
    "restoreOnlyConfig": MessageLookupByLibrary.simpleMessage("프로필만 복원"),
    "restoreStrategy": MessageLookupByLibrary.simpleMessage("복원 방식"),
    "restoreStrategyCompatible": MessageLookupByLibrary.simpleMessage("호환"),
    "restoreStrategyOverride": MessageLookupByLibrary.simpleMessage("덮어쓰기"),
    "restoreSuccess": MessageLookupByLibrary.simpleMessage("복원 완료"),
    "result": MessageLookupByLibrary.simpleMessage("결과"),
    "retry": MessageLookupByLibrary.simpleMessage("다시 시도"),
    "routeAddress": MessageLookupByLibrary.simpleMessage("라우팅 주소"),
    "routeExcludeAddress": MessageLookupByLibrary.simpleMessage("라우팅 제외 주소"),
    "routingMark": MessageLookupByLibrary.simpleMessage("라우팅 마크"),
    "ru": MessageLookupByLibrary.simpleMessage("러시아어"),
    "rule": MessageLookupByLibrary.simpleMessage("규칙"),
    "ruleActionAndDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 AND"),
    "ruleActionDomainDesc": MessageLookupByLibrary.simpleMessage("전체 도메인 일치"),
    "ruleActionDomainKeywordDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 키워드 일치",
    ),
    "ruleActionDomainRegexDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 정규식 일치",
    ),
    "ruleActionDomainSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "도메인 접미사 일치",
    ),
    "ruleActionDomainWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "와일드카드 일치, *와 ?만 지원",
    ),
    "ruleActionDscpDesc": MessageLookupByLibrary.simpleMessage(
      "DSCP 마크 일치(tproxy UDP 인바운드 전용)",
    ),
    "ruleActionDstPortDesc": MessageLookupByLibrary.simpleMessage(
      "목적지 포트 범위 일치",
    ),
    "ruleActionGeoipDesc": MessageLookupByLibrary.simpleMessage("IP의 국가 코드 일치"),
    "ruleActionGeositeDesc": MessageLookupByLibrary.simpleMessage(
      "Geosite의 도메인 일치",
    ),
    "ruleActionInNameDesc": MessageLookupByLibrary.simpleMessage("인바운드 이름 일치"),
    "ruleActionInPortDesc": MessageLookupByLibrary.simpleMessage("인바운드 포트 일치"),
    "ruleActionInTypeDesc": MessageLookupByLibrary.simpleMessage("인바운드 유형 일치"),
    "ruleActionInUserDesc": MessageLookupByLibrary.simpleMessage(
      "인바운드 사용자 이름 일치, 여러 사용자 이름은 /로 구분",
    ),
    "ruleActionIpAsnDesc": MessageLookupByLibrary.simpleMessage("IP의 ASN 일치"),
    "ruleActionIpCidr6Desc": MessageLookupByLibrary.simpleMessage(
      "IP 주소 범위 일치, IP-CIDR6는 별칭일 뿐입니다",
    ),
    "ruleActionIpCidrDesc": MessageLookupByLibrary.simpleMessage("IP 주소 범위 일치"),
    "ruleActionIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "IP 접미사 범위 일치",
    ),
    "ruleActionMatchDesc": MessageLookupByLibrary.simpleMessage(
      "모든 요청과 일치, 조건 불필요",
    ),
    "ruleActionNetworkDesc": MessageLookupByLibrary.simpleMessage(
      "TCP 또는 UDP 일치",
    ),
    "ruleActionNotDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 NOT"),
    "ruleActionOrDesc": MessageLookupByLibrary.simpleMessage("논리 규칙 OR"),
    "ruleActionProcessNameDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름으로 일치, Android에서는 패키지 이름과 일치",
    ),
    "ruleActionProcessNameRegexDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름 정규식으로 일치, Android에서는 패키지 이름과 일치",
    ),
    "ruleActionProcessNameWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 이름 와일드카드로 일치, *와 ?만 지원",
    ),
    "ruleActionProcessPathDesc": MessageLookupByLibrary.simpleMessage(
      "전체 프로세스 경로로 일치",
    ),
    "ruleActionProcessPathRegexDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 경로 정규식으로 일치",
    ),
    "ruleActionProcessPathWildcardDesc": MessageLookupByLibrary.simpleMessage(
      "프로세스 경로 와일드카드로 일치, *와 ?만 지원",
    ),
    "ruleActionRematchNameDesc": MessageLookupByLibrary.simpleMessage(
      "리매치 이름 일치, 여러 이름은 /로 구분",
    ),
    "ruleActionRuleSetDesc": MessageLookupByLibrary.simpleMessage(
      "규칙 세트 참조, rule-providers 필요",
    ),
    "ruleActionSrcGeoipDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP의 국가 코드 일치",
    ),
    "ruleActionSrcIpAsnDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP의 ASN 일치",
    ),
    "ruleActionSrcIpCidrDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP 주소 범위 일치",
    ),
    "ruleActionSrcIpSuffixDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 IP 접미사 범위 일치",
    ),
    "ruleActionSrcPortDesc": MessageLookupByLibrary.simpleMessage(
      "출발지 포트 범위 일치",
    ),
    "ruleActionSubRuleDesc": MessageLookupByLibrary.simpleMessage(
      "하위 규칙으로 일치, 괄호에 유의",
    ),
    "ruleActionUidDesc": MessageLookupByLibrary.simpleMessage(
      "Linux 사용자 ID 일치",
    ),
    "ruleEmpty": MessageLookupByLibrary.simpleMessage("규칙이 비어 있습니다"),
    "ruleListInvalid": MessageLookupByLibrary.simpleMessage(
      "규칙은 항목마다 규칙 하나인 YAML 목록이어야 합니다. 예: - DOMAIN,example.com,DIRECT",
    ),
    "rulePresetBittorrentDirect": MessageLookupByLibrary.simpleMessage(
      "BitTorrent 직접 연결",
    ),
    "rulePresetBlockDot": MessageLookupByLibrary.simpleMessage(
      "DNS over TLS 차단",
    ),
    "rulePresetBlockLoopback": MessageLookupByLibrary.simpleMessage(
      "프록시 루프백 차단",
    ),
    "rulePresetBlockQuic": MessageLookupByLibrary.simpleMessage("QUIC 차단"),
    "rulePresetBlockStun": MessageLookupByLibrary.simpleMessage("STUN 차단"),
    "rulePresetLanDirect": MessageLookupByLibrary.simpleMessage("LAN 직접 연결"),
    "rulePresetSystemServicesDirect": MessageLookupByLibrary.simpleMessage(
      "Apple 및 Microsoft 직접 연결",
    ),
    "ruleProviders": MessageLookupByLibrary.simpleMessage("규칙 공급자"),
    "ruleSet": MessageLookupByLibrary.simpleMessage("규칙 세트"),
    "ruleSetEmptyTip": MessageLookupByLibrary.simpleMessage(
      "규칙 세트에 사용할 수 있는 항목이 없습니다",
    ),
    "ruleSetInvalidTip": MessageLookupByLibrary.simpleMessage(
      "이 mrs 파일을 읽을 수 없습니다",
    ),
    "ruleSetMixedTip": MessageLookupByLibrary.simpleMessage(
      "규칙 세트에 도메인과 IP 범위가 섞여 있어 유형을 판별할 수 없습니다",
    ),
    "ruleTarget": MessageLookupByLibrary.simpleMessage("규칙 대상"),
    "ruleTextInvalid": MessageLookupByLibrary.simpleMessage(
      "규칙은 DOMAIN,example.com,DIRECT처럼 지원하는 유형으로 시작해야 합니다",
    ),
    "rules": MessageLookupByLibrary.simpleMessage("규칙"),
    "rulesCount": m72,
    "runTime": MessageLookupByLibrary.simpleMessage("실행 시간"),
    "running": MessageLookupByLibrary.simpleMessage("실행 중"),
    "runtimeConfig": MessageLookupByLibrary.simpleMessage("런타임 구성"),
    "safeMode": MessageLookupByLibrary.simpleMessage("안전 모드"),
    "safeModeAppTitle": m73,
    "saturation": MessageLookupByLibrary.simpleMessage("채도"),
    "save": MessageLookupByLibrary.simpleMessage("저장"),
    "saveChanges": MessageLookupByLibrary.simpleMessage("변경 사항을 저장하시겠습니까?"),
    "script": MessageLookupByLibrary.simpleMessage("스크립트"),
    "scriptModeDesc": MessageLookupByLibrary.simpleMessage(
      "스크립트 모드: 확장 스크립트로 프로필 전체를 다시 작성합니다",
    ),
    "scrollToSelected": MessageLookupByLibrary.simpleMessage("선택 항목으로 스크롤"),
    "search": MessageLookupByLibrary.simpleMessage("검색"),
    "seconds": MessageLookupByLibrary.simpleMessage("초"),
    "secondsCount": m74,
    "secretKey": MessageLookupByLibrary.simpleMessage("키"),
    "sectionsInEffect": m75,
    "select": MessageLookupByLibrary.simpleMessage("선택"),
    "selectAll": MessageLookupByLibrary.simpleMessage("모두 선택"),
    "selectRuleSet": MessageLookupByLibrary.simpleMessage("규칙 세트를 선택하세요"),
    "selectSplitStrategy": MessageLookupByLibrary.simpleMessage("분할 전략을 선택하세요"),
    "send": MessageLookupByLibrary.simpleMessage("보내기"),
    "sendFromPhone": MessageLookupByLibrary.simpleMessage("휴대폰에서 보내기"),
    "sendFromPhoneConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "휴대폰에서 받은 링크를 가져올까요?",
    ),
    "sendFromPhoneDesc": MessageLookupByLibrary.simpleMessage(
      "휴대폰으로 스캔해 이 기기로 링크를 보냅니다",
    ),
    "sendFromPhoneNoNetwork": MessageLookupByLibrary.simpleMessage(
      "이 기기는 로컬 네트워크에 연결되어 있지 않습니다",
    ),
    "sendFromPhonePageHint": MessageLookupByLibrary.simpleMessage(
      "구독 링크 또는 프록시 공유 링크",
    ),
    "sendFromPhonePageSent": MessageLookupByLibrary.simpleMessage(
      "보냈습니다. 다른 기기에서 가져오기를 확인하세요.",
    ),
    "sendFromPhonePageTitle": MessageLookupByLibrary.simpleMessage(
      "FlClash로 링크 보내기",
    ),
    "sendFromPhonePermissionDenied": MessageLookupByLibrary.simpleMessage(
      "휴대폰에서 링크를 받으려면 FlClash가 로컬 네트워크에 접근할 수 있도록 \'근처 기기\' 권한이 필요합니다. 앱 설정에서 켜 주세요.",
    ),
    "sendFromPhoneTip": MessageLookupByLibrary.simpleMessage(
      "휴대폰 카메라로 코드를 스캔한 뒤 열린 페이지에 링크를 붙여 넣으세요. 두 기기가 같은 네트워크에 연결되어 있어야 합니다.",
    ),
    "server": MessageLookupByLibrary.simpleMessage("서버"),
    "serviceAbnormalCount": m76,
    "serviceAllAvailable": MessageLookupByLibrary.simpleMessage("모두 사용 가능"),
    "serviceAvailable": MessageLookupByLibrary.simpleMessage("사용 가능"),
    "serviceBlocked": MessageLookupByLibrary.simpleMessage("차단됨"),
    "serviceCheck": MessageLookupByLibrary.simpleMessage("확인"),
    "serviceCheckAll": MessageLookupByLibrary.simpleMessage("모두 확인"),
    "serviceCheckedAt": m77,
    "serviceComingSoon": MessageLookupByLibrary.simpleMessage("출시 예정"),
    "serviceDisallowedIsp": MessageLookupByLibrary.simpleMessage("허용되지 않는 ISP"),
    "serviceFailed": MessageLookupByLibrary.simpleMessage("확인 실패"),
    "serviceManage": MessageLookupByLibrary.simpleMessage("서비스 관리"),
    "serviceOriginalsOnly": MessageLookupByLibrary.simpleMessage("오리지널 콘텐츠만"),
    "servicePending": MessageLookupByLibrary.simpleMessage("확인 전"),
    "serviceRestricted": MessageLookupByLibrary.simpleMessage("접근 제한됨"),
    "serviceShownOnDashboard": MessageLookupByLibrary.simpleMessage(
      "대시보드에 표시됨",
    ),
    "serviceStatus": MessageLookupByLibrary.simpleMessage("서비스 상태"),
    "serviceUnavailable": MessageLookupByLibrary.simpleMessage("사용 불가"),
    "serviceUnsupportedRegion": MessageLookupByLibrary.simpleMessage(
      "지원하지 않는 지역",
    ),
    "settingEntries": MessageLookupByLibrary.simpleMessage("설정"),
    "settings": MessageLookupByLibrary.simpleMessage("설정"),
    "settingsCount": m78,
    "shareLinkUnreadable": m79,
    "shareLinksInvalid": MessageLookupByLibrary.simpleMessage(
      "링크에서 읽을 수 있는 프록시가 없습니다",
    ),
    "shareQrcodeTip": MessageLookupByLibrary.simpleMessage(
      "다른 기기의 FlClash로 스캔하면 이 프로필을 가져올 수 있습니다.",
    ),
    "show": MessageLookupByLibrary.simpleMessage("표시"),
    "showLess": MessageLookupByLibrary.simpleMessage("접기"),
    "showMore": MessageLookupByLibrary.simpleMessage("펼치기"),
    "showNotificationStopAction": MessageLookupByLibrary.simpleMessage(
      "알림에 중지 버튼 표시",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("비밀번호 표시"),
    "sidebar": MessageLookupByLibrary.simpleMessage("사이드바"),
    "sidebarBlurDesc": MessageLookupByLibrary.simpleMessage(
      "배경 흐림은 창 뒤의 바탕화면을 사이드바에 비쳐 보이게 합니다.",
    ),
    "silentLaunch": MessageLookupByLibrary.simpleMessage("백그라운드 실행"),
    "silentLaunchDesc": MessageLookupByLibrary.simpleMessage(
      "백그라운드 실행은 창을 표시하지 않고 시작합니다.",
    ),
    "singleAdd": MessageLookupByLibrary.simpleMessage("개별 추가"),
    "singleImport": MessageLookupByLibrary.simpleMessage("개별 가져오기"),
    "singleShareLinkOnly": MessageLookupByLibrary.simpleMessage(
      "여기에는 링크를 하나만 입력하세요. 여러 개는 목록의 빠른 편집에서 편집하세요",
    ),
    "singleValueTip": m80,
    "size": MessageLookupByLibrary.simpleMessage("크기"),
    "skipCertVerify": MessageLookupByLibrary.simpleMessage("인증서 검증 건너뛰기"),
    "skipDomain": MessageLookupByLibrary.simpleMessage("건너뛸 도메인"),
    "skipDomainDesc": MessageLookupByLibrary.simpleMessage(
      "건너뛸 도메인 목록에 있는 스니핑된 도메인은 사용하지 않습니다.",
    ),
    "skipDstAddress": MessageLookupByLibrary.simpleMessage("건너뛸 목적지 주소"),
    "skipSrcAddress": MessageLookupByLibrary.simpleMessage("건너뛸 출발지 주소"),
    "slide": MessageLookupByLibrary.simpleMessage("슬라이드"),
    "sliders": MessageLookupByLibrary.simpleMessage("슬라이더"),
    "sniffProtocols": MessageLookupByLibrary.simpleMessage("프로토콜"),
    "sniffer": MessageLookupByLibrary.simpleMessage("스니퍼"),
    "snifferStatusDesc": MessageLookupByLibrary.simpleMessage(
      "스니퍼는 TLS, HTTP, QUIC 트래픽에서 도메인을 읽어 규칙이 일치할 수 있게 합니다.",
    ),
    "socksPort": MessageLookupByLibrary.simpleMessage("SOCKS 포트"),
    "softStyle": MessageLookupByLibrary.simpleMessage("부드러움"),
    "sort": MessageLookupByLibrary.simpleMessage("정렬"),
    "source": MessageLookupByLibrary.simpleMessage("소스"),
    "sourceIp": MessageLookupByLibrary.simpleMessage("출발지 IP"),
    "specialProxy": MessageLookupByLibrary.simpleMessage("특수 프록시"),
    "specialRules": MessageLookupByLibrary.simpleMessage("특수 규칙"),
    "spectrum": MessageLookupByLibrary.simpleMessage("스펙트럼"),
    "speedStatistics": MessageLookupByLibrary.simpleMessage("속도 통계"),
    "splitStrategy": MessageLookupByLibrary.simpleMessage("분할 전략"),
    "splitStrategyNotEmpty": MessageLookupByLibrary.simpleMessage(
      "분할 전략을 입력하세요",
    ),
    "ssidsEmpty": MessageLookupByLibrary.simpleMessage("SSID가 비어 있습니다"),
    "stackMode": MessageLookupByLibrary.simpleMessage("스택 모드"),
    "stackTrace": MessageLookupByLibrary.simpleMessage("스택 트레이스"),
    "standard": MessageLookupByLibrary.simpleMessage("표준"),
    "standardModeDesc": MessageLookupByLibrary.simpleMessage(
      "표준 모드: 프로필 위에 규칙을 추가합니다",
    ),
    "start": MessageLookupByLibrary.simpleMessage("시작"),
    "startFromScratch": MessageLookupByLibrary.simpleMessage("처음부터 시작"),
    "startVpn": MessageLookupByLibrary.simpleMessage("VPN 시작 중…"),
    "startupAndBackground": MessageLookupByLibrary.simpleMessage("시작 및 백그라운드"),
    "status": MessageLookupByLibrary.simpleMessage("상태"),
    "statusDesc": MessageLookupByLibrary.simpleMessage(
      "DNS를 끄면 시스템 DNS를 사용합니다.",
    ),
    "stop": MessageLookupByLibrary.simpleMessage("중지"),
    "stopVpn": MessageLookupByLibrary.simpleMessage("VPN 중지 중…"),
    "strategy": MessageLookupByLibrary.simpleMessage("전략"),
    "strictRoute": MessageLookupByLibrary.simpleMessage("엄격한 라우팅"),
    "strictRouteDesc": MessageLookupByLibrary.simpleMessage(
      "엄격한 라우팅은 DNS 등의 트래픽이 TUN을 우회하지 못하게 하며, IPv6가 꺼져 있으면 이 기기의 IPv6 연결을 차단합니다.",
    ),
    "style": MessageLookupByLibrary.simpleMessage("스타일"),
    "submit": MessageLookupByLibrary.simpleMessage("제출"),
    "subscriptionInfo": MessageLookupByLibrary.simpleMessage("구독 정보"),
    "sudoPasswordTitle": MessageLookupByLibrary.simpleMessage(
      "sudo 비밀번호를 입력하세요",
    ),
    "suspended": MessageLookupByLibrary.simpleMessage("일시 중지됨…"),
    "switchProfile": MessageLookupByLibrary.simpleMessage("프로필 전환"),
    "sync": MessageLookupByLibrary.simpleMessage("동기화"),
    "system": MessageLookupByLibrary.simpleMessage("시스템"),
    "systemApp": MessageLookupByLibrary.simpleMessage("시스템 앱"),
    "systemProxy": MessageLookupByLibrary.simpleMessage("시스템 프록시"),
    "tab": MessageLookupByLibrary.simpleMessage("탭"),
    "tabAnimation": MessageLookupByLibrary.simpleMessage("탭 애니메이션"),
    "tapIconToRetry": MessageLookupByLibrary.simpleMessage("아이콘을 눌러 다시 시도"),
    "tapToAuthorize": MessageLookupByLibrary.simpleMessage("눌러서 허용"),
    "target": MessageLookupByLibrary.simpleMessage("대상"),
    "tcpConcurrent": MessageLookupByLibrary.simpleMessage("TCP 동시 연결"),
    "testInterval": MessageLookupByLibrary.simpleMessage("테스트 간격"),
    "testUrl": MessageLookupByLibrary.simpleMessage("테스트 URL"),
    "testWhenUsed": MessageLookupByLibrary.simpleMessage("사용할 때 테스트"),
    "textScale": MessageLookupByLibrary.simpleMessage("글자 크기 조절"),
    "textScalePreview": MessageLookupByLibrary.simpleMessage(
      "앱의 글자가 이렇게 표시됩니다",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("테마"),
    "themeColor": MessageLookupByLibrary.simpleMessage("테마 색상"),
    "themeMode": MessageLookupByLibrary.simpleMessage("테마 모드"),
    "tight": MessageLookupByLibrary.simpleMessage("좁게"),
    "time": MessageLookupByLibrary.simpleMessage("시간"),
    "timeout": MessageLookupByLibrary.simpleMessage("시간 초과"),
    "tintedStyle": MessageLookupByLibrary.simpleMessage("틴트"),
    "tip": MessageLookupByLibrary.simpleMessage("안내"),
    "toggle": MessageLookupByLibrary.simpleMessage("전환"),
    "tolerance": MessageLookupByLibrary.simpleMessage("허용 오차"),
    "tools": MessageLookupByLibrary.simpleMessage("도구"),
    "torch": MessageLookupByLibrary.simpleMessage("손전등"),
    "total": MessageLookupByLibrary.simpleMessage("합계"),
    "totalDownload": MessageLookupByLibrary.simpleMessage("다운로드량"),
    "totalTraffic": MessageLookupByLibrary.simpleMessage("전체 트래픽"),
    "totalUpload": MessageLookupByLibrary.simpleMessage("업로드량"),
    "tproxyPort": MessageLookupByLibrary.simpleMessage("TProxy 포트"),
    "traffic": MessageLookupByLibrary.simpleMessage("트래픽"),
    "trafficPeak": m81,
    "trafficTotal": m82,
    "trafficUsage": MessageLookupByLibrary.simpleMessage("트래픽 사용량"),
    "transport": MessageLookupByLibrary.simpleMessage("전송"),
    "transportHeaders": m83,
    "tun": MessageLookupByLibrary.simpleMessage("TUN"),
    "tunAuthorizationFailed": MessageLookupByLibrary.simpleMessage(
      "TUN 권한을 얻지 못해 끄기로 되돌렸습니다.",
    ),
    "tunDesc": MessageLookupByLibrary.simpleMessage("TUN은 관리자 모드에서만 작동합니다."),
    "tunOverrideDesc": MessageLookupByLibrary.simpleMessage(
      "여기에 추가한 항목은 모든 프로필의 TUN 설정을 대체합니다. 추가하지 않은 항목은 프로필 자체 설정을 유지합니다. 사용자 지정 프로필이 직접 추가한 항목이 우선합니다.",
    ),
    "turnOff": MessageLookupByLibrary.simpleMessage("끄기"),
    "turnOn": MessageLookupByLibrary.simpleMessage("켜기"),
    "udpRelayMode": MessageLookupByLibrary.simpleMessage("UDP 릴레이 모드"),
    "udpTimeout": MessageLookupByLibrary.simpleMessage("UDP 시간 제한"),
    "udpTimeoutDesc": MessageLookupByLibrary.simpleMessage(
      "UDP 시간 제한은 초 단위이며 gvisor, system, mixed 스택에서만 작동합니다.",
    ),
    "ultra": MessageLookupByLibrary.simpleMessage("최고"),
    "undo": MessageLookupByLibrary.simpleMessage("실행 취소"),
    "unifiedDelay": MessageLookupByLibrary.simpleMessage("통합 지연"),
    "unknown": MessageLookupByLibrary.simpleMessage("알 수 없음"),
    "unknownNetworkError": MessageLookupByLibrary.simpleMessage(
      "알 수 없는 네트워크 오류",
    ),
    "unmaximize": MessageLookupByLibrary.simpleMessage("이전 크기로 복원"),
    "unnamed": MessageLookupByLibrary.simpleMessage("이름 없음"),
    "unpinWindow": MessageLookupByLibrary.simpleMessage("창 고정 해제"),
    "update": MessageLookupByLibrary.simpleMessage("업데이트"),
    "upload": MessageLookupByLibrary.simpleMessage("업로드"),
    "uploadBandwidth": MessageLookupByLibrary.simpleMessage("업로드 대역폭"),
    "url": MessageLookupByLibrary.simpleMessage("URL"),
    "urlTip": m84,
    "useHosts": MessageLookupByLibrary.simpleMessage("hosts 사용"),
    "useSystemHosts": MessageLookupByLibrary.simpleMessage("시스템 hosts 사용"),
    "usedShort": MessageLookupByLibrary.simpleMessage("사용"),
    "usedTraffic": MessageLookupByLibrary.simpleMessage("사용한 트래픽"),
    "userAgent": MessageLookupByLibrary.simpleMessage("User-Agent"),
    "username": MessageLookupByLibrary.simpleMessage("사용자 이름"),
    "value": MessageLookupByLibrary.simpleMessage("값"),
    "view": MessageLookupByLibrary.simpleMessage("보기"),
    "virtualIpv4": MessageLookupByLibrary.simpleMessage("가상 IPv4"),
    "vividStyle": MessageLookupByLibrary.simpleMessage("선명"),
    "vpnConfigChangeDetected": MessageLookupByLibrary.simpleMessage(
      "VPN 관련 구성 변경이 감지되었습니다",
    ),
    "vpnEnableDesc": MessageLookupByLibrary.simpleMessage(
      "VPN은 VpnService를 통해 모든 시스템 트래픽을 자동으로 라우팅합니다.",
    ),
    "webDAVConfiguration": MessageLookupByLibrary.simpleMessage("WebDAV 구성"),
    "whitelistMode": MessageLookupByLibrary.simpleMessage("화이트리스트 모드"),
    "writeToSystem": MessageLookupByLibrary.simpleMessage("시스템에 기록"),
    "writeToSystemDesc": MessageLookupByLibrary.simpleMessage(
      "시스템에 기록하면 시스템 시계도 설정합니다. Android에서는 무시됩니다.",
    ),
    "yearsAgo": m85,
    "yearsAgoShort": m86,
    "yes": MessageLookupByLibrary.simpleMessage("예"),
    "zhCN": MessageLookupByLibrary.simpleMessage("중국어 간체"),
  };
}
