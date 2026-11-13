import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_paths.dart';

class _RecordedRun {
  const _RecordedRun(this.executable, this.arguments);

  final String executable;
  final List<String> arguments;

  String get key =>
      arguments.isEmpty ? executable : '$executable ${arguments.first}';

  String get commandLine => [executable, ...arguments].join(' ');
}

/// Stands in for `Process.run`, keyed by executable plus its first argument so
/// the several `networksetup` subcommands can answer differently.
class _FakeProcesses {
  final List<_RecordedRun> runs = [];
  final Map<String, String> _stdout = {};
  final Map<String, int> _exitCodes = {};
  final Set<String> _failures = {};

  void stub(String key, String stdout, {int exitCode = 0}) {
    _stdout[key] = stdout;
    _exitCodes[key] = exitCode;
  }

  void stubThrow(String key) {
    _failures.add(key);
  }

  final List<String> inputs = [];

  Future<ProcessResult> runWithInput(
    String executable,
    List<String> arguments,
    String input,
  ) {
    inputs.add(input);
    return run(executable, arguments);
  }

  Future<ProcessResult> run(String executable, List<String> arguments) async {
    final recorded = _RecordedRun(executable, arguments);
    runs.add(recorded);
    if (_failures.contains(recorded.key) || _failures.contains(executable)) {
      throw ProcessException(executable, arguments);
    }
    return ProcessResult(
      0,
      _exitCodes[recorded.commandLine] ??
          _exitCodes[recorded.key] ??
          _exitCodes[executable] ??
          0,
      _stdout[recorded.commandLine] ??
          _stdout[recorded.key] ??
          _stdout[executable] ??
          '',
      '',
    );
  }

  List<String> argumentsFor(String key) => runs
      .firstWhere((run) => run.key == key || run.executable == key)
      .arguments;

  bool ran(String key) =>
      runs.any((run) => run.key == key || run.executable == key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late _FakeProcesses processes;
  String? password;

  setUpAll(() async {
    root = Directory.systemTemp.createTempSync('system_test');
    await useAppPaths(root);
  });

  tearDownAll(() {
    // The shared system temp dir is not exclusively ours; another suite running
    // alongside this one can take the tree out from under the teardown.
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  setUp(() {
    processes = _FakeProcesses();
    system.runProcess = processes.run;
    MacOS().runProcess = processes.run;
    linuxElevation.run = processes.run;
    linuxElevation.runWithInput = processes.runWithInput;
    linuxElevation.askPassword = () async => password;
    password = null;
  });

  tearDown(() {
    system.runProcess = Process.run;
    MacOS().runProcess = Process.run;
    linuxElevation.run = Process.run;
  });

  group('statArguments', () {
    test('selects the BSD format on macOS and the GNU one elsewhere', () {
      expect(System.statArguments('/a/core', isMacOS: true), [
        '-f',
        '%Su:%Sg %Sp',
        '/a/core',
      ]);
      expect(System.statArguments('/a/core', isMacOS: false), [
        '-c',
        '%U:%G %A',
        '/a/core',
      ]);
    });

    test('passes a path containing spaces through untouched', () {
      const path = '/Users/a b/FlClash.app/Contents/MacOS/FlClashCore';
      for (final isMacOS in [true, false]) {
        final arguments = System.statArguments(path, isMacOS: isMacOS);
        expect(arguments.last, path);
        expect(arguments.last, isNot(contains(r'\')));
      }
    });
  });

  group('aclArguments', () {
    test('grants the inheriting user access to the whole tree', () {
      final arguments = System.aclArguments('/Users/a/Support', 'alice');

      expect(arguments.first, '-R');
      expect(arguments[1], '+a');
      expect(arguments[2], startsWith('user:alice allow '));
      expect(arguments.last, '/Users/a/Support');
      expect(
        arguments[2].split(' allow ').last.split(','),
        unorderedEquals(const [
          'list',
          'search',
          'add_file',
          'add_subdirectory',
          'delete',
          'delete_child',
          'file_inherit',
          'directory_inherit',
        ]),
      );
    });

    test('never hands out ownership or the ACL itself', () {
      final arguments = System.aclArguments('/Users/a/Support', 'alice');

      expect(arguments[2], isNot(contains('writesecurity')));
      expect(arguments[2], isNot(contains('chown')));
    });

    test('passes a path containing spaces through untouched', () {
      const path = '/Users/a b/Library/Application Support/com.follow.clash';

      final arguments = System.aclArguments(path, 'alice');

      expect(arguments.last, path);
      expect(arguments.last, isNot(contains(r'\')));
    });
  });

  group('grantHomeDirAccess', () {
    test('only touches the filesystem on macOS', () async {
      await system.grantHomeDirAccess('/Users/a/Support');

      final userName = Platform.environment['USER'];
      expect(
        processes.ran('chmod'),
        system.isMacOS && userName != null && userName.isNotEmpty,
      );
    });

    test('survives a chmod that cannot apply an ACL', () async {
      processes.stub('chmod', '', exitCode: 1);

      await expectLater(
        system.grantHomeDirAccess('/Users/a/Support'),
        completes,
      );

      processes.stubThrow('chmod');

      await expectLater(
        system.grantHomeDirAccess('/Users/a/Support'),
        completes,
      );
    });
  });

  group('isPrivilegedStatOutput', () {
    test('accepts a root-owned setuid binary closed to others', () {
      expect(
        System.isPrivilegedStatOutput(
          'root:admin -rwsr-x---\n',
          ownerPrefix: 'root:admin',
        ),
        isTrue,
      );
      expect(
        System.isPrivilegedStatOutput(
          'root:alice -rws------+',
          ownerPrefix: 'root:',
        ),
        isTrue,
      );
    });

    test('rejects a setuid binary that others can execute', () {
      for (final mode in [
        '-rwsr-sr-x',
        '-rwsr-xr-x',
        '-rwsr-x--x',
        '-rwsr-x--t',
      ]) {
        expect(
          System.isPrivilegedStatOutput(
            'root:admin $mode',
            ownerPrefix: 'root:admin',
          ),
          isFalse,
          reason: mode,
        );
      }
    });

    test('rejects a root-owned binary without the setuid bit', () {
      expect(
        System.isPrivilegedStatOutput(
          'root:admin -rwxr-xr-x',
          ownerPrefix: 'root:admin',
        ),
        isFalse,
      );
    });

    test('rejects a setuid binary owned by somebody else', () {
      expect(
        System.isPrivilegedStatOutput(
          'alice:staff -rwsr-sr-x',
          ownerPrefix: 'root:admin',
        ),
        isFalse,
      );
    });

    test('rejects the empty output stat leaves for a missing file', () {
      expect(
        System.isPrivilegedStatOutput('', ownerPrefix: 'root:admin'),
        isFalse,
      );
    });
  });

  group(
    'checkIsAdmin',
    () {
      test('stats the core path verbatim', () async {
        processes.stub('stat', 'root:admin -rwsr-x---');

        expect(await system.checkIsAdmin(), isTrue);
        expect(processes.argumentsFor('stat').last, appPath.corePath);
      });

      test(
        'does not trust a core earlier versions left executable by all',
        () async {
          processes.stub('stat', 'root:admin -rwsr-sr-x');

          expect(await system.checkIsAdmin(), isFalse);
        },
      );

      test('reports a core that is not setuid root', () async {
        processes.stub('stat', 'alice:staff -rwxr-xr-x');

        expect(await system.checkIsAdmin(), isFalse);
      });

      test('reports a core stat could not find', () async {
        processes.stub('stat', '');

        expect(await system.checkIsAdmin(), isFalse);
      });
    },
    skip: system.hasHelperService
        ? 'the Helper probe replaces stat here'
        : false,
  );

  group('elevation shells', () {
    test('macOS hands the Core to the admin group and nobody else', () {
      expect(
        System.macOSElevationShell('/Apps/Fl Clash/core'),
        "chown root:admin '/Apps/Fl Clash/core' && "
        "chmod 4750 '/Apps/Fl Clash/core'",
      );
    });

    test('Linux hands the Core to the requesting user\'s group', () {
      final shell = System.linuxElevationShell('/opt/FlClash/FlClashCore');

      expect(
        shell,
        startsWith(r'group=$(id -g "${PKEXEC_UID:-$SUDO_UID}") && '),
      );
      expect(shell, contains(r'chown "root:$group" '));
      expect(shell, endsWith("chmod 4750 '/opt/FlClash/FlClashCore'"));
    });

    test('neither leaves execute to others', () {
      for (final shell in [
        System.macOSElevationShell('/core'),
        System.linuxElevationShell('/core'),
      ]) {
        expect(shell, isNot(contains('+sx')));
        expect(shell, contains('chmod 4750'));
      }
    });
  });

  group('authorizeCore on macOS', () {
    test('refuses an account outside the admin group', () async {
      processes.stub('id', 'alice staff everyone');

      expect(await system.authorizeCore(), AuthorizeCode.error);
      expect(processes.ran('osascript'), isFalse);
    });

    test('elevates the Core for an admin account', () async {
      processes.stub('id', 'alice staff admin');

      expect(await system.authorizeCore(), AuthorizeCode.success);
      expect(processes.argumentsFor('osascript').last, contains('chmod 4750'));
    });
  }, skip: system.isMacOS ? false : 'macOS only');

  group('Windows installArguments', () {
    test('names this process as the account the Helper serves', () {
      expect(Windows.installArguments(4242), 'install --owner-pid 4242');
    });
  });

  group('Linux installService', () {
    test('asks pkexec to install the bundled Helper', () async {
      expect(await Linux().installService(), isTrue);
      expect(processes.argumentsFor('pkexec'), [appPath.helperPath, 'install']);
    });

    test('reports an installation the user dismissed', () async {
      processes.stub('pkexec', '', exitCode: 126);

      expect(await Linux().installService(), isFalse);
    });

    test('installs through cached sudo credentials without pkexec', () async {
      processes.stubThrow('pkexec');

      expect(await Linux().installService(), isTrue);
      expect(processes.argumentsFor('sudo'), [
        '-n',
        '--',
        appPath.helperPath,
        'install',
      ]);
      expect(processes.inputs, isEmpty);
    });

    test('asks for the sudo password when no polkit agent answers', () async {
      processes.stub('pkexec', '', exitCode: 127);
      processes.stub('sudo -n', '', exitCode: 1);
      password = 'secret';

      expect(await Linux().installService(), isTrue);
      expect(processes.runs.last.arguments, [
        '-S',
        '-p',
        '',
        '--',
        appPath.helperPath,
        'install',
      ]);
      expect(processes.inputs, ['secret\n']);
    });

    test('reports a command that failed under cached sudo', () async {
      processes.stubThrow('pkexec');
      processes.stub('sudo -n', '', exitCode: 1);
      processes.stub('sudo -n true', '');
      password = 'secret';

      expect(await Linux().installService(), isFalse);
      expect(processes.ran('sudo -S'), isFalse);
      expect(processes.inputs, isEmpty);
    });

    test('gives up when the sudo prompt is cancelled', () async {
      processes.stubThrow('pkexec');
      processes.stub('sudo -n', '', exitCode: 1);

      expect(await Linux().installService(), isFalse);
      expect(processes.ran('sudo -S'), isFalse);
    });

    test('does not ask sudo after the polkit dialog is dismissed', () async {
      processes.stub('pkexec', '', exitCode: 126);

      expect(await Linux().installService(), isFalse);
      expect(processes.ran('sudo'), isFalse);
    });
  });

  group('writeDnsServers', () {
    test('writes the requested servers', () async {
      expect(await MacOS().writeDnsServers('Wi-Fi', ['1.1.1.1']), isTrue);
      expect(processes.argumentsFor('networksetup -setdnsservers'), [
        '-setdnsservers',
        'Wi-Fi',
        '1.1.1.1',
      ]);
    });

    test('clears the servers with the literal networksetup keyword', () async {
      expect(await MacOS().writeDnsServers('Wi-Fi', []), isTrue);
      expect(processes.argumentsFor('networksetup -setdnsservers'), [
        '-setdnsservers',
        'Wi-Fi',
        'Empty',
      ]);
    });

    test('reports a rejected write instead of assuming success', () async {
      processes.stub('networksetup -setdnsservers', '', exitCode: 1);

      expect(await MacOS().writeDnsServers('Wi-Fi', ['1.1.1.1']), isFalse);
    });
  });
}
