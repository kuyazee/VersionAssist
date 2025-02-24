import 'dart:io';

import 'package:mason_logger/mason_logger.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:version_assist/src/command_runner.dart';

class _MockLogger extends Mock implements Logger {}

class _MockFile extends Mock implements File {}

class _MockProgress extends Mock implements Progress {}

void main() {
  group('version set', () {
    late Logger logger;
    late Progress progress;
    late VersionAssistCommandRunner commandRunner;

    setUpAll(() {
      registerFallbackValue('');
      registerFallbackValue(<String>[]);
    });

    setUp(() {
      logger = _MockLogger();
      progress = _MockProgress();
      commandRunner = VersionAssistCommandRunner(logger: logger);

      // Set up default mock behavior for logger
      when(() => logger.progress(any())).thenReturn(progress);
      when(() => logger.detail(any())).thenReturn(null);
      when(() => logger.err(any())).thenReturn(null);
      when(() => logger.info(any())).thenReturn(null);
      when(() => logger.success(any())).thenReturn(null);
      when(() => progress.complete(any())).thenReturn(null);
      when(() => progress.fail(any())).thenReturn(null);
    });

    test('sets version without build number', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner.run(['set', '--version', '2.0.0']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully set version to 2.0.0')).called(1);
    });

    test('sets version with build number', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner.run(['set', '--version', '2.0.0+1']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully set version to 2.0.0+1'))
          .called(1);
    });

    test('validates version format', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode =
          await commandRunner.run(['set', '--version', 'invalid.version']);

      expect(exitCode, ExitCode.usage.code);
      verify(
        () => logger.err('Invalid version format. Must be x.y.z or x.y.z+build'),
      ).called(1);
    });

    test('shows changes in dry run mode', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);

      final exitCode =
          await commandRunner.run(['set', '--version', '2.0.0', '-d']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.info('Would change version from 1.0.0 to 2.0.0'))
          .called(1);
    });

    test('handles file not found', () async {
      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => false);

      final exitCode = await commandRunner.run(['set', '--version', '2.0.0']);

      expect(exitCode, ExitCode.usage.code);
      verify(() => logger.err('pubspec.yaml not found at pubspec.yaml'))
          .called(1);
    });

    test('handles missing version argument', () async {
      final exitCode = await commandRunner.run(['set']);

      expect(exitCode, ExitCode.usage.code);
    });

    test('auto-commits version change', () async {
      const testPubspec = '''
name: test_app
description: A test application
version: 1.0.0
''';

      final file = _MockFile();
      when(file.exists).thenAnswer((_) async => true);
      when(file.readAsString).thenAnswer((_) async => testPubspec);
      when(() => file.writeAsString(any())).thenAnswer((_) async => file);

      final exitCode = await commandRunner
          .run(['set', '--version', '2.0.0', '--auto-commit']);

      expect(exitCode, ExitCode.success.code);
      verify(() => logger.success('Successfully set version to 2.0.0')).called(1);
      verify(
        () => logger.success('Successfully created version commit and tag for 2.0.0'),
      ).called(1);
    });
  });
}
