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

abstract class IntegrityEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IntegrityEvent._({
    this.id,
    required this.roomId,
    required this.participantId,
    required this.type,
    this.detail,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory IntegrityEvent({
    int? id,
    required int roomId,
    required int participantId,
    required String type,
    String? detail,
    DateTime? createdAt,
  }) = _IntegrityEventImpl;

  factory IntegrityEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntegrityEvent(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      participantId: jsonSerialization['participantId'] as int,
      type: jsonSerialization['type'] as String,
      detail: jsonSerialization['detail'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  int participantId;

  String type;

  String? detail;

  DateTime createdAt;

  /// Returns a shallow copy of this [IntegrityEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IntegrityEvent copyWith({
    int? id,
    int? roomId,
    int? participantId,
    String? type,
    String? detail,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntegrityEvent',
      if (id != null) 'id': id,
      'roomId': roomId,
      'participantId': participantId,
      'type': type,
      if (detail != null) 'detail': detail,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IntegrityEvent',
      if (id != null) 'id': id,
      'roomId': roomId,
      'participantId': participantId,
      'type': type,
      if (detail != null) 'detail': detail,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IntegrityEventImpl extends IntegrityEvent {
  _IntegrityEventImpl({
    int? id,
    required int roomId,
    required int participantId,
    required String type,
    String? detail,
    DateTime? createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         participantId: participantId,
         type: type,
         detail: detail,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [IntegrityEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IntegrityEvent copyWith({
    Object? id = _Undefined,
    int? roomId,
    int? participantId,
    String? type,
    Object? detail = _Undefined,
    DateTime? createdAt,
  }) {
    return IntegrityEvent(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      participantId: participantId ?? this.participantId,
      type: type ?? this.type,
      detail: detail is String? ? detail : this.detail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
