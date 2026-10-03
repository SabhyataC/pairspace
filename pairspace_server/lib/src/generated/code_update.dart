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

abstract class CodeUpdate
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CodeUpdate._({
    required this.roomId,
    required this.senderId,
    required this.version,
    required this.text,
    required this.language,
  });

  factory CodeUpdate({
    required int roomId,
    required String senderId,
    required int version,
    required String text,
    required String language,
  }) = _CodeUpdateImpl;

  factory CodeUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return CodeUpdate(
      roomId: jsonSerialization['roomId'] as int,
      senderId: jsonSerialization['senderId'] as String,
      version: jsonSerialization['version'] as int,
      text: jsonSerialization['text'] as String,
      language: jsonSerialization['language'] as String,
    );
  }

  int roomId;

  String senderId;

  int version;

  String text;

  String language;

  /// Returns a shallow copy of this [CodeUpdate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CodeUpdate copyWith({
    int? roomId,
    String? senderId,
    int? version,
    String? text,
    String? language,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CodeUpdate',
      'roomId': roomId,
      'senderId': senderId,
      'version': version,
      'text': text,
      'language': language,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CodeUpdate',
      'roomId': roomId,
      'senderId': senderId,
      'version': version,
      'text': text,
      'language': language,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _CodeUpdateImpl extends CodeUpdate {
  _CodeUpdateImpl({
    required int roomId,
    required String senderId,
    required int version,
    required String text,
    required String language,
  }) : super._(
         roomId: roomId,
         senderId: senderId,
         version: version,
         text: text,
         language: language,
       );

  /// Returns a shallow copy of this [CodeUpdate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CodeUpdate copyWith({
    int? roomId,
    String? senderId,
    int? version,
    String? text,
    String? language,
  }) {
    return CodeUpdate(
      roomId: roomId ?? this.roomId,
      senderId: senderId ?? this.senderId,
      version: version ?? this.version,
      text: text ?? this.text,
      language: language ?? this.language,
    );
  }
}
