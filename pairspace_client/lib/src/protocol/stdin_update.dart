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

abstract class StdinUpdate
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  StdinUpdate._({
    required this.roomId,
    required this.senderId,
    required this.text,
  });

  factory StdinUpdate({
    required int roomId,
    required String senderId,
    required String text,
  }) = _StdinUpdateImpl;

  factory StdinUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return StdinUpdate(
      roomId: jsonSerialization['roomId'] as int,
      senderId: jsonSerialization['senderId'] as String,
      text: jsonSerialization['text'] as String,
    );
  }

  int roomId;

  String senderId;

  String text;

  /// Returns a shallow copy of this [StdinUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  StdinUpdate copyWith({
    int? roomId,
    String? senderId,
    String? text,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'StdinUpdate',
      'roomId': roomId,
      'senderId': senderId,
      'text': text,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'StdinUpdate',
      'roomId': roomId,
      'senderId': senderId,
      'text': text,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _StdinUpdateImpl extends StdinUpdate {
  _StdinUpdateImpl({
    required int roomId,
    required String senderId,
    required String text,
  }) : super._(
         roomId: roomId,
         senderId: senderId,
         text: text,
       );

  /// Returns a shallow copy of this [StdinUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  StdinUpdate copyWith({
    int? roomId,
    String? senderId,
    String? text,
  }) {
    return StdinUpdate(
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
    );
  }
}
