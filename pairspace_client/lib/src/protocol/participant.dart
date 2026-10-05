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
import 'participant_status.dart' as _idcdy19m;

abstract class Participant
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Participant._({
    this.id,
    required this.roomId,
    required this.authUserId,
    required this.role,
    required this.status,
    required this.displayName,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
  }) : joinedAt = joinedAt ?? DateTime.now(),
       lastSeenAt = lastSeenAt ?? DateTime.now();

  factory Participant({
    int? id,
    required int roomId,
    required _isc.UuidValue authUserId,
    required _i5kza8cj.ParticipantRole role,
    required _idcdy19m.ParticipantStatus status,
    required String displayName,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
  }) = _ParticipantImpl;

  factory Participant.fromJson(Map<String, dynamic> jsonSerialization) {
    return Participant(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      role: _i5kza8cj.ParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      status: _idcdy19m.ParticipantStatus.fromJson(
        (jsonSerialization['status'] as String),
      ),
      displayName: jsonSerialization['displayName'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSeenAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  _isc.UuidValue authUserId;

  _i5kza8cj.ParticipantRole role;

  _idcdy19m.ParticipantStatus status;

  String displayName;

  DateTime joinedAt;

  DateTime lastSeenAt;

  /// Returns a shallow copy of this [Participant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Participant copyWith({
    int? id,
    int? roomId,
    _isc.UuidValue? authUserId,
    _i5kza8cj.ParticipantRole? role,
    _idcdy19m.ParticipantStatus? status,
    String? displayName,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Participant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'status': status.toJson(),
      'displayName': displayName,
      'joinedAt': joinedAt.toJson(),
      'lastSeenAt': lastSeenAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Participant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'authUserId': authUserId.toJson(),
      'role': role.toJson(),
      'status': status.toJson(),
      'displayName': displayName,
      'joinedAt': joinedAt.toJson(),
      'lastSeenAt': lastSeenAt.toJson(),
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
    required _isc.UuidValue authUserId,
    required _i5kza8cj.ParticipantRole role,
    required _idcdy19m.ParticipantStatus status,
    required String displayName,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
  }) : super._(
         id: id,
         roomId: roomId,
         authUserId: authUserId,
         role: role,
         status: status,
         displayName: displayName,
         joinedAt: joinedAt,
         lastSeenAt: lastSeenAt,
       );

  /// Returns a shallow copy of this [Participant]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Participant copyWith({
    Object? id = _Undefined,
    int? roomId,
    _isc.UuidValue? authUserId,
    _i5kza8cj.ParticipantRole? role,
    _idcdy19m.ParticipantStatus? status,
    String? displayName,
    DateTime? joinedAt,
    DateTime? lastSeenAt,
  }) {
    return Participant(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      authUserId: authUserId ?? this.authUserId,
      role: role ?? this.role,
      status: status ?? this.status,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }
}
