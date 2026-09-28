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
import 'participant_role.dart' as _i5kza8cj;

abstract class Participant
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Participant._({
    this.id,
    required this.roomId,
    required this.role,
    required this.displayName,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory Participant({
    int? id,
    required int roomId,
    required _i5kza8cj.ParticipantRole role,
    required String displayName,
    DateTime? joinedAt,
  }) = _ParticipantImpl;

  factory Participant.fromJson(Map<String, dynamic> jsonSerialization) {
    return Participant(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      role: _i5kza8cj.ParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      displayName: jsonSerialization['displayName'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  _i5kza8cj.ParticipantRole role;

  String displayName;

  DateTime joinedAt;

  /// Returns a shallow copy of this [Participant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Participant copyWith({
    int? id,
    int? roomId,
    _i5kza8cj.ParticipantRole? role,
    String? displayName,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Participant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'role': role.toJson(),
      'displayName': displayName,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Participant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'role': role.toJson(),
      'displayName': displayName,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ParticipantImpl extends Participant {
  _ParticipantImpl({
    int? id,
    required int roomId,
    required _i5kza8cj.ParticipantRole role,
    required String displayName,
    DateTime? joinedAt,
  }) : super._(
         id: id,
         roomId: roomId,
         role: role,
         displayName: displayName,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [Participant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Participant copyWith({
    Object? id = _Undefined,
    int? roomId,
    _i5kza8cj.ParticipantRole? role,
    String? displayName,
    DateTime? joinedAt,
  }) {
    return Participant(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
