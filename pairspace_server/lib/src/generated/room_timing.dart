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

abstract class RoomTiming
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RoomTiming._({
    required this.startedAt,
    required this.durationMinutes,
    required this.serverNow,
  });

  factory RoomTiming({
    required DateTime startedAt,
    required int durationMinutes,
    required DateTime serverNow,
  }) = _RoomTimingImpl;

  factory RoomTiming.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomTiming(
      startedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['startedAt'],
      ),
      durationMinutes: jsonSerialization['durationMinutes'] as int,
      serverNow: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['serverNow'],
      ),
    );
  }

  DateTime startedAt;

  int durationMinutes;

  DateTime serverNow;

  /// Returns a shallow copy of this [RoomTiming]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RoomTiming copyWith({
    DateTime? startedAt,
    int? durationMinutes,
    DateTime? serverNow,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomTiming',
      'startedAt': startedAt.toJson(),
      'durationMinutes': durationMinutes,
      'serverNow': serverNow.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomTiming',
      'startedAt': startedAt.toJson(),
      'durationMinutes': durationMinutes,
      'serverNow': serverNow.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RoomTimingImpl extends RoomTiming {
  _RoomTimingImpl({
    required DateTime startedAt,
    required int durationMinutes,
    required DateTime serverNow,
  }) : super._(
         startedAt: startedAt,
         durationMinutes: durationMinutes,
         serverNow: serverNow,
       );

  /// Returns a shallow copy of this [RoomTiming]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RoomTiming copyWith({
    DateTime? startedAt,
    int? durationMinutes,
    DateTime? serverNow,
  }) {
    return RoomTiming(
      startedAt: startedAt ?? this.startedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      serverNow: serverNow ?? this.serverNow,
    );
  }
}
