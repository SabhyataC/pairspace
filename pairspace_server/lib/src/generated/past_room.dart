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
import 'package:pairspace_server/src/generated/protocol.dart' as _icaos0x9;
import 'package:serverpod/serverpod.dart' as _is;
import 'room.dart' as _ieflxecy;

abstract class PastRoom
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PastRoom._({
    required this.room,
    this.candidateName,
  });

  factory PastRoom({
    required _ieflxecy.Room room,
    String? candidateName,
  }) = _PastRoomImpl;

  factory PastRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return PastRoom(
      room: _icaos0x9.Protocol().deserialize<_ieflxecy.Room>(
        jsonSerialization['room'],
      ),
      candidateName: jsonSerialization['candidateName'] as String?,
    );
  }

  _ieflxecy.Room room;

  String? candidateName;

  /// Returns a shallow copy of this [PastRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PastRoom copyWith({
    _ieflxecy.Room? room,
    String? candidateName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PastRoom',
      'room': room.toJson(),
      if (candidateName != null) 'candidateName': candidateName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PastRoom',
      'room': room.toJsonForProtocol(),
      if (candidateName != null) 'candidateName': candidateName,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PastRoomImpl extends PastRoom {
  _PastRoomImpl({
    required _ieflxecy.Room room,
    String? candidateName,
  }) : super._(
         room: room,
         candidateName: candidateName,
       );

  /// Returns a shallow copy of this [PastRoom]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PastRoom copyWith({
    _ieflxecy.Room? room,
    Object? candidateName = _Undefined,
  }) {
    return PastRoom(
      room: room ?? this.room.copyWith(),
      candidateName: candidateName is String?
          ? candidateName
          : this.candidateName,
    );
  }
}
