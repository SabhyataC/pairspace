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
import 'package:pairspace_client/src/protocol/protocol.dart' as _ipbiefcp;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class Stroke
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Stroke._({
    this.id,
    required this.roomId,
    required this.points,
    required this.color,
    required this.width,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Stroke({
    int? id,
    required int roomId,
    required List<double> points,
    required int color,
    required double width,
    DateTime? createdAt,
  }) = _StrokeImpl;

  factory Stroke.fromJson(Map<String, dynamic> jsonSerialization) {
    return Stroke(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      points: _ipbiefcp.Protocol().deserialize<List<double>>(
        jsonSerialization['points'],
      ),
      color: jsonSerialization['color'] as int,
      width: (jsonSerialization['width'] as num).toDouble(),
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

  List<double> points;

  int color;

  double width;

  DateTime createdAt;

  /// Returns a shallow copy of this [Stroke]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Stroke copyWith({
    int? id,
    int? roomId,
    List<double>? points,
    int? color,
    double? width,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Stroke',
      if (id != null) 'id': id,
      'roomId': roomId,
      'points': points.toJson(),
      'color': color,
      'width': width,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Stroke',
      if (id != null) 'id': id,
      'roomId': roomId,
      'points': points.toJson(),
      'color': color,
      'width': width,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _StrokeImpl extends Stroke {
  _StrokeImpl({
    int? id,
    required int roomId,
    required List<double> points,
    required int color,
    required double width,
    DateTime? createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         points: points,
         color: color,
         width: width,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Stroke]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Stroke copyWith({
    Object? id = _Undefined,
    int? roomId,
    List<double>? points,
    int? color,
    double? width,
    DateTime? createdAt,
  }) {
    return Stroke(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      points: points ?? this.points.map((e0) => e0).toList(),
      color: color ?? this.color,
      width: width ?? this.width,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
