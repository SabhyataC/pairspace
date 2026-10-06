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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class Room
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Room._({
    this.id,
    required this.code,
    required this.createdBy,
    DateTime? createdAt,
    this.endedAt,
    int? durationMinutes,
  }) : createdAt = createdAt ?? DateTime.now(),
       durationMinutes = durationMinutes ?? 60;

  factory Room({
    int? id,
    required String code,
    required _isc.UuidValue createdBy,
    DateTime? createdAt,
    DateTime? endedAt,
    int? durationMinutes,
  }) = _RoomImpl;

  factory Room.fromJson(Map<String, dynamic> jsonSerialization) {
    return Room(
      id: jsonSerialization['id'] as int?,
      code: jsonSerialization['code'] as String,
      createdBy: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['createdBy'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      endedAt: jsonSerialization['endedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['endedAt']),
      durationMinutes: jsonSerialization['durationMinutes'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String code;

  _isc.UuidValue createdBy;

  DateTime createdAt;

  DateTime? endedAt;

  int durationMinutes;

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Room copyWith({
    int? id,
    String? code,
    _isc.UuidValue? createdBy,
    DateTime? createdAt,
    DateTime? endedAt,
    int? durationMinutes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'code': code,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'durationMinutes': durationMinutes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Room',
      if (id != null) 'id': id,
      'code': code,
      'createdBy': createdBy.toJson(),
      'createdAt': createdAt.toJson(),
      if (endedAt != null) 'endedAt': endedAt?.toJson(),
      'durationMinutes': durationMinutes,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomImpl extends Room {
  _RoomImpl({
    int? id,
    required String code,
    required _isc.UuidValue createdBy,
    DateTime? createdAt,
    DateTime? endedAt,
    int? durationMinutes,
  }) : super._(
         id: id,
         code: code,
         createdBy: createdBy,
         createdAt: createdAt,
         endedAt: endedAt,
         durationMinutes: durationMinutes,
       );

  /// Returns a shallow copy of this [Room]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Room copyWith({
    Object? id = _Undefined,
    String? code,
    _isc.UuidValue? createdBy,
    DateTime? createdAt,
    Object? endedAt = _Undefined,
    int? durationMinutes,
  }) {
    return Room(
      id: id is int? ? id : this.id,
      code: code ?? this.code,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt is DateTime? ? endedAt : this.endedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
