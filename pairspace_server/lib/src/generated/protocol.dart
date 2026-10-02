/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:pairspace_server/src/generated/participant.dart' as _ibvon4z2;
import 'package:pairspace_server/src/generated/stroke.dart' as _iziyni4f;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'access_denied.dart' as _icyx6leh;
import 'code_snapshot.dart' as _ixhe19s2;
import 'future_calls_generated_models/end_empty_room_future_call_end_model.dart'
    as _iotrfso8;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'participant.dart' as _ih83ei55;
import 'participant_role.dart' as _i5kza8cj;
import 'participant_status.dart' as _idcdy19m;
import 'room.dart' as _ieflxecy;
import 'signal_message.dart' as _i6c8vmrx;
import 'stroke.dart' as _ikjj7mbr;
export 'access_denied.dart';
export 'code_snapshot.dart';
export 'greetings/greeting.dart';
export 'participant.dart';
export 'participant_role.dart';
export 'participant_status.dart';
export 'room.dart';
export 'signal_message.dart';
export 'stroke.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'code_snapshot',
      dartName: 'CodeSnapshot',
      schema: 'public',
      module: 'pairspace',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'content',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'language',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'updatedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'code_snapshot_fk_0',
          columns: ['roomId'],
          referenceTable: 'room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'code_snapshot_room_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'participant',
      dartName: 'Participant',
      schema: 'public',
      module: 'pairspace',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ParticipantRole',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:ParticipantStatus',
        ),
        _isp.ColumnDefinition(
          name: 'displayName',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'joinedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'participant_fk_0',
          columns: ['roomId'],
          referenceTable: 'room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'participant_room_user_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'room',
      dartName: 'Room',
      schema: 'public',
      module: 'pairspace',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'code',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'createdBy',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
        _isp.ColumnDefinition(
          name: 'endedAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'room_code_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'code',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'stroke',
      dartName: 'Stroke',
      schema: 'public',
      module: 'pairspace',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'roomId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'points',
          columnType: _isp.ColumnType.json,
          isNullable: false,
          dartType: 'List<double>',
        ),
        _isp.ColumnDefinition(
          name: 'color',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'width',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'now',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'stroke_fk_0',
          columns: ['roomId'],
          referenceTable: 'room',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'stroke_room_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'roomId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _icyx6leh.AccessDeniedException) {
      return _icyx6leh.AccessDeniedException.fromJson(data) as T;
    }
    if (t == _ixhe19s2.CodeSnapshot) {
      return _ixhe19s2.CodeSnapshot.fromJson(data) as T;
    }
    if (t == _iotrfso8.EndEmptyRoomFutureCallEndModel) {
      return _iotrfso8.EndEmptyRoomFutureCallEndModel.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _ih83ei55.Participant) {
      return _ih83ei55.Participant.fromJson(data) as T;
    }
    if (t == _i5kza8cj.ParticipantRole) {
      return _i5kza8cj.ParticipantRole.fromJson(data) as T;
    }
    if (t == _idcdy19m.ParticipantStatus) {
      return _idcdy19m.ParticipantStatus.fromJson(data) as T;
    }
    if (t == _ieflxecy.Room) {
      return _ieflxecy.Room.fromJson(data) as T;
    }
    if (t == _i6c8vmrx.SignalMessage) {
      return _i6c8vmrx.SignalMessage.fromJson(data) as T;
    }
    if (t == _ikjj7mbr.Stroke) {
      return _ikjj7mbr.Stroke.fromJson(data) as T;
    }
    if (t == _is.getType<_icyx6leh.AccessDeniedException?>()) {
      return (data != null
              ? _icyx6leh.AccessDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_ixhe19s2.CodeSnapshot?>()) {
      return (data != null ? _ixhe19s2.CodeSnapshot.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iotrfso8.EndEmptyRoomFutureCallEndModel?>()) {
      return (data != null
              ? _iotrfso8.EndEmptyRoomFutureCallEndModel.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ih83ei55.Participant?>()) {
      return (data != null ? _ih83ei55.Participant.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i5kza8cj.ParticipantRole?>()) {
      return (data != null ? _i5kza8cj.ParticipantRole.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idcdy19m.ParticipantStatus?>()) {
      return (data != null ? _idcdy19m.ParticipantStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ieflxecy.Room?>()) {
      return (data != null ? _ieflxecy.Room.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i6c8vmrx.SignalMessage?>()) {
      return (data != null ? _i6c8vmrx.SignalMessage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ikjj7mbr.Stroke?>()) {
      return (data != null ? _ikjj7mbr.Stroke.fromJson(data) : null) as T;
    }
    if (t == List<double>) {
      return (data as List).map((e) => deserialize<double>(e)).toList() as T;
    }
    if (t == List<_iziyni4f.Stroke>) {
      return (data as List)
              .map((e) => deserialize<_iziyni4f.Stroke>(e))
              .toList()
          as T;
    }
    if (t == List<_ibvon4z2.Participant>) {
      return (data as List)
              .map((e) => deserialize<_ibvon4z2.Participant>(e))
              .toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _icyx6leh.AccessDeniedException => 'AccessDeniedException',
      _ixhe19s2.CodeSnapshot => 'CodeSnapshot',
      _iotrfso8.EndEmptyRoomFutureCallEndModel =>
        'EndEmptyRoomFutureCallEndModel',
      _izw8z7ou.Greeting => 'Greeting',
      _ih83ei55.Participant => 'Participant',
      _i5kza8cj.ParticipantRole => 'ParticipantRole',
      _idcdy19m.ParticipantStatus => 'ParticipantStatus',
      _ieflxecy.Room => 'Room',
      _i6c8vmrx.SignalMessage => 'SignalMessage',
      _ikjj7mbr.Stroke => 'Stroke',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('pairspace.', '');
    }

    switch (data) {
      case _icyx6leh.AccessDeniedException():
        return 'AccessDeniedException';
      case _ixhe19s2.CodeSnapshot():
        return 'CodeSnapshot';
      case _iotrfso8.EndEmptyRoomFutureCallEndModel():
        return 'EndEmptyRoomFutureCallEndModel';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _ih83ei55.Participant():
        return 'Participant';
      case _i5kza8cj.ParticipantRole():
        return 'ParticipantRole';
      case _idcdy19m.ParticipantStatus():
        return 'ParticipantStatus';
      case _ieflxecy.Room():
        return 'Room';
      case _i6c8vmrx.SignalMessage():
        return 'SignalMessage';
      case _ikjj7mbr.Stroke():
        return 'Stroke';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AccessDeniedException') {
      return deserialize<_icyx6leh.AccessDeniedException>(data['data']);
    }
    if (dataClassName == 'CodeSnapshot') {
      return deserialize<_ixhe19s2.CodeSnapshot>(data['data']);
    }
    if (dataClassName == 'EndEmptyRoomFutureCallEndModel') {
      return deserialize<_iotrfso8.EndEmptyRoomFutureCallEndModel>(
        data['data'],
      );
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'Participant') {
      return deserialize<_ih83ei55.Participant>(data['data']);
    }
    if (dataClassName == 'ParticipantRole') {
      return deserialize<_i5kza8cj.ParticipantRole>(data['data']);
    }
    if (dataClassName == 'ParticipantStatus') {
      return deserialize<_idcdy19m.ParticipantStatus>(data['data']);
    }
    if (dataClassName == 'Room') {
      return deserialize<_ieflxecy.Room>(data['data']);
    }
    if (dataClassName == 'SignalMessage') {
      return deserialize<_i6c8vmrx.SignalMessage>(data['data']);
    }
    if (dataClassName == 'Stroke') {
      return deserialize<_ikjj7mbr.Stroke>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('pairspace', this);
    _iacs.Protocol().registerHostProtocol('pairspace', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _ixhe19s2.CodeSnapshot:
        return _ixhe19s2.CodeSnapshot.t;
      case _ih83ei55.Participant:
        return _ih83ei55.Participant.t;
      case _ieflxecy.Room:
        return _ieflxecy.Room.t;
      case _ikjj7mbr.Stroke:
        return _ikjj7mbr.Stroke.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'pairspace';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
