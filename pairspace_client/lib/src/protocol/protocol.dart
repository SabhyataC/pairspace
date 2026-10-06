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
import 'package:pairspace_client/src/protocol/integrity_event.dart'
    as _ivbyloxl;
import 'package:pairspace_client/src/protocol/participant.dart' as _i9rgdsem;
import 'package:pairspace_client/src/protocol/room.dart' as _iiu20v5l;
import 'package:pairspace_client/src/protocol/stroke.dart' as _is7tpwzz;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'access_denied.dart' as _icyx6leh;
import 'code_snapshot.dart' as _ixhe19s2;
import 'code_update.dart' as _i4nm3yea;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'integrity_event.dart' as _inmjytxd;
import 'participant.dart' as _ih83ei55;
import 'participant_role.dart' as _i5kza8cj;
import 'participant_status.dart' as _idcdy19m;
import 'room.dart' as _ieflxecy;
import 'signal_message.dart' as _i6c8vmrx;
import 'stroke.dart' as _ikjj7mbr;
export 'access_denied.dart';
export 'code_snapshot.dart';
export 'code_update.dart';
export 'greetings/greeting.dart';
export 'integrity_event.dart';
export 'participant.dart';
export 'participant_role.dart';
export 'participant_status.dart';
export 'room.dart';
export 'signal_message.dart';
export 'stroke.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

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
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
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
    if (t == _i4nm3yea.CodeUpdate) {
      return _i4nm3yea.CodeUpdate.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _inmjytxd.IntegrityEvent) {
      return _inmjytxd.IntegrityEvent.fromJson(data) as T;
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
    if (t == _isc.getType<_icyx6leh.AccessDeniedException?>()) {
      return (data != null
              ? _icyx6leh.AccessDeniedException.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_ixhe19s2.CodeSnapshot?>()) {
      return (data != null ? _ixhe19s2.CodeSnapshot.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i4nm3yea.CodeUpdate?>()) {
      return (data != null ? _i4nm3yea.CodeUpdate.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_inmjytxd.IntegrityEvent?>()) {
      return (data != null ? _inmjytxd.IntegrityEvent.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ih83ei55.Participant?>()) {
      return (data != null ? _ih83ei55.Participant.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i5kza8cj.ParticipantRole?>()) {
      return (data != null ? _i5kza8cj.ParticipantRole.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_idcdy19m.ParticipantStatus?>()) {
      return (data != null ? _idcdy19m.ParticipantStatus.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ieflxecy.Room?>()) {
      return (data != null ? _ieflxecy.Room.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_i6c8vmrx.SignalMessage?>()) {
      return (data != null ? _i6c8vmrx.SignalMessage.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ikjj7mbr.Stroke?>()) {
      return (data != null ? _ikjj7mbr.Stroke.fromJson(data) : null) as T;
    }
    if (t == List<double>) {
      return (data as List).map((e) => deserialize<double>(e)).toList() as T;
    }
    if (t == List<_is7tpwzz.Stroke>) {
      return (data as List)
              .map((e) => deserialize<_is7tpwzz.Stroke>(e))
              .toList()
          as T;
    }
    if (t == List<_ivbyloxl.IntegrityEvent>) {
      return (data as List)
              .map((e) => deserialize<_ivbyloxl.IntegrityEvent>(e))
              .toList()
          as T;
    }
    if (t == List<_iiu20v5l.Room>) {
      return (data as List).map((e) => deserialize<_iiu20v5l.Room>(e)).toList()
          as T;
    }
    if (t == List<_i9rgdsem.Participant>) {
      return (data as List)
              .map((e) => deserialize<_i9rgdsem.Participant>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _icyx6leh.AccessDeniedException => 'AccessDeniedException',
      _ixhe19s2.CodeSnapshot => 'CodeSnapshot',
      _i4nm3yea.CodeUpdate => 'CodeUpdate',
      _izw8z7ou.Greeting => 'Greeting',
      _inmjytxd.IntegrityEvent => 'IntegrityEvent',
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
      case _i4nm3yea.CodeUpdate():
        return 'CodeUpdate';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _inmjytxd.IntegrityEvent():
        return 'IntegrityEvent';
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
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
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
    if (dataClassName == 'CodeUpdate') {
      return deserialize<_i4nm3yea.CodeUpdate>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'IntegrityEvent') {
      return deserialize<_inmjytxd.IntegrityEvent>(data['data']);
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
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('pairspace', this);
    _iacc.Protocol().registerHostProtocol('pairspace', this);
  }

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
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
