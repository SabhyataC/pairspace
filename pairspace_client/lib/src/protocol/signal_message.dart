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

abstract class SignalMessage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SignalMessage._({
    required this.senderParticipantId,
    required this.type,
    this.sdp,
    this.candidate,
    this.sdpMid,
    this.sdpMLineIndex,
  });

  factory SignalMessage({
    required int senderParticipantId,
    required String type,
    String? sdp,
    String? candidate,
    String? sdpMid,
    int? sdpMLineIndex,
  }) = _SignalMessageImpl;

  factory SignalMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return SignalMessage(
      senderParticipantId: jsonSerialization['senderParticipantId'] as int,
      type: jsonSerialization['type'] as String,
      sdp: jsonSerialization['sdp'] as String?,
      candidate: jsonSerialization['candidate'] as String?,
      sdpMid: jsonSerialization['sdpMid'] as String?,
      sdpMLineIndex: jsonSerialization['sdpMLineIndex'] as int?,
    );
  }

  int senderParticipantId;

  String type;

  String? sdp;

  String? candidate;

  String? sdpMid;

  int? sdpMLineIndex;

  /// Returns a shallow copy of this [SignalMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SignalMessage copyWith({
    int? senderParticipantId,
    String? type,
    String? sdp,
    String? candidate,
    String? sdpMid,
    int? sdpMLineIndex,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SignalMessage',
      'senderParticipantId': senderParticipantId,
      'type': type,
      if (sdp != null) 'sdp': sdp,
      if (candidate != null) 'candidate': candidate,
      if (sdpMid != null) 'sdpMid': sdpMid,
      if (sdpMLineIndex != null) 'sdpMLineIndex': sdpMLineIndex,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SignalMessage',
      'senderParticipantId': senderParticipantId,
      'type': type,
      if (sdp != null) 'sdp': sdp,
      if (candidate != null) 'candidate': candidate,
      if (sdpMid != null) 'sdpMid': sdpMid,
      if (sdpMLineIndex != null) 'sdpMLineIndex': sdpMLineIndex,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SignalMessageImpl extends SignalMessage {
  _SignalMessageImpl({
    required int senderParticipantId,
    required String type,
    String? sdp,
    String? candidate,
    String? sdpMid,
    int? sdpMLineIndex,
  }) : super._(
         senderParticipantId: senderParticipantId,
         type: type,
         sdp: sdp,
         candidate: candidate,
         sdpMid: sdpMid,
         sdpMLineIndex: sdpMLineIndex,
       );

  /// Returns a shallow copy of this [SignalMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SignalMessage copyWith({
    int? senderParticipantId,
    String? type,
    Object? sdp = _Undefined,
    Object? candidate = _Undefined,
    Object? sdpMid = _Undefined,
    Object? sdpMLineIndex = _Undefined,
  }) {
    return SignalMessage(
      senderParticipantId: senderParticipantId ?? this.senderParticipantId,
      type: type ?? this.type,
      sdp: sdp is String? ? sdp : this.sdp,
      candidate: candidate is String? ? candidate : this.candidate,
      sdpMid: sdpMid is String? ? sdpMid : this.sdpMid,
      sdpMLineIndex: sdpMLineIndex is int? ? sdpMLineIndex : this.sdpMLineIndex,
    );
  }
}
