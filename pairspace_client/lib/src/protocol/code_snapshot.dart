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

abstract class CodeSnapshot
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CodeSnapshot._({
    this.id,
    required this.roomId,
    required this.content,
    required this.language,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory CodeSnapshot({
    int? id,
    required int roomId,
    required String content,
    required String language,
    DateTime? updatedAt,
  }) = _CodeSnapshotImpl;

  factory CodeSnapshot.fromJson(Map<String, dynamic> jsonSerialization) {
    return CodeSnapshot(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      content: jsonSerialization['content'] as String,
      language: jsonSerialization['language'] as String,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  String content;

  String language;

  DateTime updatedAt;

  /// Returns a shallow copy of this [CodeSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CodeSnapshot copyWith({
    int? id,
    int? roomId,
    String? content,
    String? language,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CodeSnapshot',
      if (id != null) 'id': id,
      'roomId': roomId,
      'content': content,
      'language': language,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CodeSnapshot',
      if (id != null) 'id': id,
      'roomId': roomId,
      'content': content,
      'language': language,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CodeSnapshotImpl extends CodeSnapshot {
  _CodeSnapshotImpl({
    int? id,
    required int roomId,
    required String content,
    required String language,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         roomId: roomId,
         content: content,
         language: language,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [CodeSnapshot]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CodeSnapshot copyWith({
    Object? id = _Undefined,
    int? roomId,
    String? content,
    String? language,
    DateTime? updatedAt,
  }) {
    return CodeSnapshot(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      content: content ?? this.content,
      language: language ?? this.language,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
