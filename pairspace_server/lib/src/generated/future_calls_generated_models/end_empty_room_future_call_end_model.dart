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

abstract class EndEmptyRoomFutureCallEndModel
    implements _is.SerializableModel, _is.ProtocolSerialization {
  EndEmptyRoomFutureCallEndModel._({required this.roomId});

  factory EndEmptyRoomFutureCallEndModel({required int roomId}) =
      _EndEmptyRoomFutureCallEndModelImpl;

  factory EndEmptyRoomFutureCallEndModel.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return EndEmptyRoomFutureCallEndModel(
      roomId: jsonSerialization['roomId'] as int,
    );
  }

  int roomId;

  /// Returns a shallow copy of this [EndEmptyRoomFutureCallEndModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  EndEmptyRoomFutureCallEndModel copyWith({int? roomId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EndEmptyRoomFutureCallEndModel',
      'roomId': roomId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _EndEmptyRoomFutureCallEndModelImpl
    extends EndEmptyRoomFutureCallEndModel {
  _EndEmptyRoomFutureCallEndModelImpl({required int roomId})
    : super._(roomId: roomId);

  /// Returns a shallow copy of this [EndEmptyRoomFutureCallEndModel]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  EndEmptyRoomFutureCallEndModel copyWith({int? roomId}) {
    return EndEmptyRoomFutureCallEndModel(roomId: roomId ?? this.roomId);
  }
}
