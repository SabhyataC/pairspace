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

abstract class CodeEdit
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CodeEdit._({
    this.id,
    required this.roomId,
    required this.offset,
    required this.removed,
    required this.inserted,
    required this.createdAt,
  });

  factory CodeEdit({
    int? id,
    required int roomId,
    required int offset,
    required int removed,
    required String inserted,
    required DateTime createdAt,
  }) = _CodeEditImpl;

  factory CodeEdit.fromJson(Map<String, dynamic> jsonSerialization) {
    return CodeEdit(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      offset: jsonSerialization['offset'] as int,
      removed: jsonSerialization['removed'] as int,
      inserted: jsonSerialization['inserted'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  int offset;

  int removed;

  String inserted;

  DateTime createdAt;

  /// Returns a shallow copy of this [CodeEdit]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CodeEdit copyWith({
    int? id,
    int? roomId,
    int? offset,
    int? removed,
    String? inserted,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CodeEdit',
      if (id != null) 'id': id,
      'roomId': roomId,
      'offset': offset,
      'removed': removed,
      'inserted': inserted,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CodeEdit',
      if (id != null) 'id': id,
      'roomId': roomId,
      'offset': offset,
      'removed': removed,
      'inserted': inserted,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CodeEditImpl extends CodeEdit {
  _CodeEditImpl({
    int? id,
    required int roomId,
    required int offset,
    required int removed,
    required String inserted,
    required DateTime createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         offset: offset,
         removed: removed,
         inserted: inserted,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [CodeEdit]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CodeEdit copyWith({
    Object? id = _Undefined,
    int? roomId,
    int? offset,
    int? removed,
    String? inserted,
    DateTime? createdAt,
  }) {
    return CodeEdit(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      offset: offset ?? this.offset,
      removed: removed ?? this.removed,
      inserted: inserted ?? this.inserted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
