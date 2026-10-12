import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

class RunEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  static const _baseUrl = 'https://ce.judge0.com';
  static const _languageIds = {'python': 100, 'cpp': 105, 'java': 91};

  static const _maxCodeChars = 20000;
  static const _maxOutputChars = 10000;
  static const _maxRunsPerWindow = 5;
  static const _window = Duration(seconds: 30);
  static final Map<String, List<DateTime>> _recentRuns = {};

  bool _rateLimited(String key) {
    final now = DateTime.now();
    final runs = _recentRuns.putIfAbsent(key, () => []);
    runs.removeWhere((t) => now.difference(t) > _window);
    if (runs.length >= _maxRunsPerWindow) return true;
    runs.add(now);
    return false;
  }

  String _clip(String s) => s.length <= _maxOutputChars
      ? s
      : '${s.substring(0, _maxOutputChars)}\n...[output truncated]';

  String _normalize(String language) {
    final l = language.trim().toLowerCase();
    if (l == 'py' || l == 'python3') return 'python';
    if (l == 'c++') return 'cpp';
    return l;
  }

  RunResult _error(String message) =>
      RunResult(stdout: '', stderr: message, status: 'Error');

  Future<RunResult> runCode(
    Session session,
    int roomId,
    String language,
    String code, {
    String? stdin,
  }) async {
    await _requireAdmitted(session, roomId);

    if (!_languageIds.containsKey(_normalize(language))) {
      return _error('Unsupported language: $language');
    }
    if (code.length > _maxCodeChars) {
      return _error('Code is too long to run (max $_maxCodeChars characters).');
    }
    if (_rateLimited(session.authenticated!.userIdentifier)) {
      return _error(
        'You are running code too fast. Wait a few seconds and try again.',
      );
    }

    final channel = 'room-run-$roomId';
    await session.messages.postMessage(
      channel,
      RunResult(stdout: '', stderr: '', status: 'Running', language: language),
    );

    RunResult result;
    try {
      result = await _execute(session, language, code, stdin: stdin);
    } catch (e) {
      result = _error('Run failed unexpectedly. Please try again.');
    }
    result.language = language;
    await session.messages.postMessage(channel, result);
    return result;
  }

  /// Everyone admitted to the room receives every run (and "Running" signal).
  Stream<RunResult> runStream(Session session, int roomId) async* {
    await _requireAdmitted(session, roomId);
    yield* session.messages.createStream<RunResult>('room-run-$roomId');
  }

  Future<void> sendStdin(
    Session session,
    int roomId,
    String senderId,
    String text,
  ) async {
    await _requireAdmitted(session, roomId);
    if (text.length > 5000 || senderId.length > 64) return;
    await session.messages.postMessage(
      'room-stdin-$roomId',
      StdinUpdate(roomId: roomId, senderId: senderId, text: text),
    );
  }

  Stream<StdinUpdate> stdinStream(Session session, int roomId) async* {
    await _requireAdmitted(session, roomId);
    yield* session.messages.createStream<StdinUpdate>('room-stdin-$roomId');
  }

  Future<void> _requireAdmitted(Session session, int roomId) async {
    final userId = session.authenticated!.authUserId;
    final participant = await Participant.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(roomId) & t.authUserId.equals(userId),
    );
    if (participant == null ||
        participant.status != ParticipantStatus.admitted) {
      throw AccessDeniedException(message: 'Not admitted to this room');
    }
  }

  Future<RunResult> _execute(
    Session session,
    String language,
    String code, {
    String? stdin,
  }) async {
    final languageId = _languageIds[_normalize(language)];
    if (languageId == null) {
      return _error('Unsupported language: $language');
    }

    try {
      final create = await http
          .post(
            Uri.parse('$_baseUrl/submissions?base64_encoded=false'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'source_code': code,
              'language_id': languageId,
              'cpu_time_limit': 3,
              'memory_limit': 128000,
              if (stdin != null) 'stdin': stdin,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (create.statusCode == 429) {
        return _error(
          'The execution service is busy. Try again in a few seconds.',
        );
      }
      if (create.statusCode != 200 && create.statusCode != 201) {
        return _error('Execution service error (${create.statusCode}).');
      }
      final token = jsonDecode(create.body)['token'] as String;

      for (var i = 0; i < 15; i++) {
        await Future.delayed(const Duration(milliseconds: 800));
        final res = await http
            .get(Uri.parse('$_baseUrl/submissions/$token?base64_encoded=false'))
            .timeout(const Duration(seconds: 15));
        if (res.statusCode != 200) continue;

        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final statusId = (data['status']?['id'] as int?) ?? 0;
        if (statusId <= 2) continue; // 1 = in queue, 2 = processing

        final stderr =
            '${data['stderr'] ?? ''}${data['compile_output'] ?? ''}${data['message'] ?? ''}';
        final seconds = double.tryParse('${data['time'] ?? ''}');
        return RunResult(
          stdout: _clip((data['stdout'] ?? '') as String),
          stderr: _clip(stderr),
          status: (data['status']?['description'] ?? 'Unknown') as String,
          timeMs: seconds == null ? null : (seconds * 1000).round(),
        );
      }
      return _error('Execution timed out. Please try again.');
    } catch (e, st) {
      session.log(
        'runCode failed',
        level: LogLevel.warning,
        exception: e,
        stackTrace: st,
      );
      return _error('Could not reach the execution service.');
    }
  }
}
