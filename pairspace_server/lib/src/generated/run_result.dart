/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;

abstract class RunResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RunResult._({
    required this.stdout,
    required this.stderr,
    required this.status,
    this.timeMs,
    this.language,
  });

  factory RunResult({
    required String stdout,
    required String stderr,
    required String status,
    int? timeMs,
    String? language,
  }) = _RunResultImpl;

  factory RunResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return RunResult(
      stdout: jsonSerialization['stdout'] as String,
      stderr: jsonSerialization['stderr'] as String,
      status: jsonSerialization['status'] as String,
      timeMs: jsonSerialization['timeMs'] as int?,
      language: jsonSerialization['language'] as String?,
    );
  }

  String stdout;

  String stderr;

  String status;

  int? timeMs;

  String? language;

  /// Returns a shallow copy of this [RunResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RunResult copyWith({
    String? stdout,
    String? stderr,
    String? status,
    int? timeMs,
    String? language,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RunResult',
      'stdout': stdout,
      'stderr': stderr,
      'status': status,
      if (timeMs != null) 'timeMs': timeMs,
      if (language != null) 'language': language,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RunResult',
      'stdout': stdout,
      'stderr': stderr,
      'status': status,
      if (timeMs != null) 'timeMs': timeMs,
      if (language != null) 'language': language,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RunResultImpl extends RunResult {
  _RunResultImpl({
    required String stdout,
    required String stderr,
    required String status,
    int? timeMs,
    String? language,
  }) : super._(
         stdout: stdout,
         stderr: stderr,
         status: status,
         timeMs: timeMs,
         language: language,
       );

  /// Returns a shallow copy of this [RunResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RunResult copyWith({
    String? stdout,
    String? stderr,
    String? status,
    Object? timeMs = _Undefined,
    Object? language = _Undefined,
  }) {
    return RunResult(
      stdout: stdout ?? this.stdout,
      stderr: stderr ?? this.stderr,
      status: status ?? this.status,
      timeMs: timeMs is int? ? timeMs : this.timeMs,
      language: language is String? ? language : this.language,
    );
  }
}
