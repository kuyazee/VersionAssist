import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// {@template commit_command}
/// A command which creates a version commit and tag
/// {@endtemplate}
class CommitCommand extends Command<int> {
  /// {@macro commit_command}
  CommitCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'path',
        abbr: 'p',
        help: 'Path to pubspec.yaml',
        defaultsTo: path.join('pubspec.yaml'),
      )
      ..addFlag(
        'dry-run',
        abbr: 'd',
        help: 'Show what would happen without making changes',
        negatable: false,
      );
  }

  final Logger _logger;

  @override
  String get description => 'Creates a version commit and tag';

  @override
  String get name => 'commit';

  /// Extracts version from pubspec.yaml content
  String? _extractVersion(String content) {
    final versionPattern = RegExp(r'version:\s+(\d+\.\d+\.\d+(?:\+\d+)?)');
    final match = versionPattern.firstMatch(content);
    return match?.group(1);
  }

  @override
  Future<int> run() async {
    try {
      final pubspecPath = argResults?['path'] as String;
      final isDryRun = argResults?['dry-run'] as bool;

      // Read pubspec.yaml
      final pubspecFile = File(pubspecPath);
      if (!await pubspecFile.exists()) {
        _logger.err('pubspec.yaml not found at $pubspecPath');
        return ExitCode.usage.code;
      }

      final pubspecContent = await pubspecFile.readAsString();
      final version = _extractVersion(pubspecContent);

      if (version == null) {
        _logger.err('Could not find valid version in pubspec.yaml');
        return ExitCode.usage.code;
      }

      if (isDryRun) {
        _logger
          ..info('Would create commit with message:')
          ..info('build(version): Bump version to $version')
          ..info('Would create tag: $version');
        return ExitCode.success.code;
      }

      // Run git commands
      final gitAdd = await Process.run(
        'git',
        ['add', pubspecPath],
      );
      if (gitAdd.exitCode != 0) {
        _logger.err('Error during git add: ${gitAdd.stderr}');
        return ExitCode.software.code;
      }

      final commitMessage = 'build(version): Bump version to $version';
      final gitCommit = await Process.run(
        'git',
        ['commit', '-m', commitMessage, pubspecPath],
      );

      if (gitCommit.exitCode != 0) {
        _logger.err('Error during git commit: ${gitCommit.stderr}');
        return ExitCode.software.code;
      }

      final gitTag = await Process.run(
        'git',
        ['tag', version],
      );

      if (gitTag.exitCode != 0) {
        _logger.err('Error during git tag: ${gitTag.stderr}');
        return ExitCode.software.code;
      }

      _logger.success('Successfully created version commit and tag for $version');
      return ExitCode.success.code;
    } catch (error) {
      _logger.err('$error');
      return ExitCode.software.code;
    }
  }
}
