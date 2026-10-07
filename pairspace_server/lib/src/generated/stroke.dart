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

abstract class Stroke implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Stroke._({
    this.id,
    required this.roomId,
    required this.points,
    required this.color,
    required this.width,
    String? kind,
    this.text,
    String? clientId,
    bool? isDeleted,
    DateTime? createdAt,
  }) : kind = kind ?? 'pen',
       clientId = clientId ?? '',
       isDeleted = isDeleted ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory Stroke({
    int? id,
    required int roomId,
    required List<double> points,
    required int color,
    required double width,
    String? kind,
    String? text,
    String? clientId,
    bool? isDeleted,
    DateTime? createdAt,
  }) = _StrokeImpl;

  factory Stroke.fromJson(Map<String, dynamic> jsonSerialization) {
    return Stroke(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      points: _icaos0x9.Protocol().deserialize<List<double>>(
        jsonSerialization['points'],
      ),
      color: jsonSerialization['color'] as int,
      width: (jsonSerialization['width'] as num).toDouble(),
      kind: jsonSerialization['kind'] as String?,
      text: jsonSerialization['text'] as String?,
      clientId: jsonSerialization['clientId'] as String?,
      isDeleted: jsonSerialization['isDeleted'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isDeleted']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = StrokeTable();

  static const db = StrokeRepository._();

  @override
  int? id;

  int roomId;

  List<double> points;

  int color;

  double width;

  String kind;

  String? text;

  String clientId;

  bool isDeleted;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Stroke]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Stroke copyWith({
    int? id,
    int? roomId,
    List<double>? points,
    int? color,
    double? width,
    String? kind,
    String? text,
    String? clientId,
    bool? isDeleted,
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
      'kind': kind,
      if (text != null) 'text': text,
      'clientId': clientId,
      'isDeleted': isDeleted,
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
      'kind': kind,
      if (text != null) 'text': text,
      'clientId': clientId,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toJson(),
    };
  }

  static StrokeInclude include() {
    return StrokeInclude._();
  }

  static StrokeIncludeList includeList({
    _is.WhereExpressionBuilder<StrokeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StrokeTable>? orderBy,
    _is.OrderByListBuilder<StrokeTable>? orderByList,
    StrokeInclude? include,
  }) {
    return StrokeIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Stroke.t),
      orderByList: orderByList?.call(Stroke.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
    String? kind,
    String? text,
    String? clientId,
    bool? isDeleted,
    DateTime? createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         points: points,
         color: color,
         width: width,
         kind: kind,
         text: text,
         clientId: clientId,
         isDeleted: isDeleted,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Stroke]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Stroke copyWith({
    Object? id = _Undefined,
    int? roomId,
    List<double>? points,
    int? color,
    double? width,
    String? kind,
    Object? text = _Undefined,
    String? clientId,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return Stroke(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      points: points ?? this.points.map((e0) => e0).toList(),
      color: color ?? this.color,
      width: width ?? this.width,
      kind: kind ?? this.kind,
      text: text is String? ? text : this.text,
      clientId: clientId ?? this.clientId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StrokeUpdateTable extends _is.UpdateTable<StrokeTable> {
  StrokeUpdateTable(super.table);

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<List<double>, List<double>> points(List<double> value) =>
      _is.ColumnValue(
        table.points,
        value,
      );

  _is.ColumnValue<int, int> color(int value) => _is.ColumnValue(
    table.color,
    value,
  );

  _is.ColumnValue<double, double> width(double value) => _is.ColumnValue(
    table.width,
    value,
  );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> text(String? value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<String, String> clientId(String value) => _is.ColumnValue(
    table.clientId,
    value,
  );

  _is.ColumnValue<bool, bool> isDeleted(bool value) => _is.ColumnValue(
    table.isDeleted,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class StrokeTable extends _is.Table<int?> {
  StrokeTable({super.tableRelation}) : super(tableName: 'stroke') {
    updateTable = StrokeUpdateTable(this);
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    points = _is.ColumnSerializable<List<double>>(
      'points',
      this,
    );
    color = _is.ColumnInt(
      'color',
      this,
    );
    width = _is.ColumnDouble(
      'width',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
      hasDefault: true,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    clientId = _is.ColumnString(
      'clientId',
      this,
      hasDefault: true,
    );
    isDeleted = _is.ColumnBool(
      'isDeleted',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final StrokeUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnSerializable<List<double>> points;

  late final _is.ColumnInt color;

  late final _is.ColumnDouble width;

  late final _is.ColumnString kind;

  late final _is.ColumnString text;

  late final _is.ColumnString clientId;

  late final _is.ColumnBool isDeleted;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    points,
    color,
    width,
    kind,
    text,
    clientId,
    isDeleted,
    createdAt,
  ];
}

class StrokeInclude extends _is.IncludeObject {
  StrokeInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Stroke.t;
}

class StrokeIncludeList extends _is.IncludeList {
  StrokeIncludeList._({
    _is.WhereExpressionBuilder<StrokeTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Stroke.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Stroke.t;
}

class StrokeRepository {
  const StrokeRepository._();

  /// Returns a list of [Stroke]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Stroke>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StrokeTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StrokeTable>? orderBy,
    _is.OrderByListBuilder<StrokeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Stroke>(
      where: where?.call(Stroke.t),
      orderBy: orderBy?.call(Stroke.t),
      orderByList: orderByList?.call(Stroke.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Stroke] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Stroke?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StrokeTable>? where,
    int? offset,
    _is.OrderByBuilder<StrokeTable>? orderBy,
    _is.OrderByListBuilder<StrokeTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Stroke>(
      where: where?.call(Stroke.t),
      orderBy: orderBy?.call(Stroke.t),
      orderByList: orderByList?.call(Stroke.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Stroke] by its [id] or null if no such row exists.
  Future<Stroke?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Stroke>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Stroke]s in the list and returns the inserted rows.
  ///
  /// The returned [Stroke]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Stroke>> insert(
    _is.DatabaseSession session,
    List<Stroke> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Stroke>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Stroke] and returns the inserted row.
  ///
  /// The returned [Stroke] will have its `id` field set.
  Future<Stroke> insertRow(
    _is.DatabaseSession session,
    Stroke row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Stroke>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Stroke]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Stroke]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Stroke>> upsert(
    _is.DatabaseSession session,
    List<Stroke> rows, {
    required _is.ColumnSelections<StrokeTable> conflictColumns,
    _is.ColumnSelections<StrokeTable>? updateColumns,
    _is.WhereExpressionBuilder<StrokeTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Stroke>(
      rows,
      conflictColumns: conflictColumns(Stroke.t),
      updateColumns: updateColumns?.call(Stroke.t),
      updateWhere: updateWhere?.call(Stroke.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Stroke] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Stroke] will have its `id` field set.
  Future<Stroke?> upsertRow(
    _is.DatabaseSession session,
    Stroke row, {
    required _is.ColumnSelections<StrokeTable> conflictColumns,
    _is.ColumnSelections<StrokeTable>? updateColumns,
    _is.WhereExpressionBuilder<StrokeTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Stroke>(
      row,
      conflictColumns: conflictColumns(Stroke.t),
      updateColumns: updateColumns?.call(Stroke.t),
      updateWhere: updateWhere?.call(Stroke.t),
      transaction: transaction,
    );
  }

  /// Updates all [Stroke]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Stroke>> update(
    _is.DatabaseSession session,
    List<Stroke> rows, {
    _is.ColumnSelections<StrokeTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Stroke>(
      rows,
      columns: columns?.call(Stroke.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Stroke]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Stroke> updateRow(
    _is.DatabaseSession session,
    Stroke row, {
    _is.ColumnSelections<StrokeTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Stroke>(
      row,
      columns: columns?.call(Stroke.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Stroke] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Stroke?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<StrokeUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Stroke>(
      id,
      columnValues: columnValues(Stroke.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Stroke]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Stroke>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<StrokeUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<StrokeTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<StrokeTable>? orderBy,
    _is.OrderByListBuilder<StrokeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Stroke>(
      columnValues: columnValues(Stroke.t.updateTable),
      where: where(Stroke.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Stroke.t),
      orderByList: orderByList?.call(Stroke.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Stroke]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Stroke>> delete(
    _is.DatabaseSession session,
    List<Stroke> rows, {
    _is.OrderByBuilder<StrokeTable>? orderBy,
    _is.OrderByListBuilder<StrokeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Stroke>(
      rows,
      orderBy: orderBy?.call(Stroke.t),
      orderByList: orderByList?.call(Stroke.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Stroke].
  Future<Stroke> deleteRow(
    _is.DatabaseSession session,
    Stroke row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Stroke>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Stroke>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StrokeTable> where,
    _is.OrderByBuilder<StrokeTable>? orderBy,
    _is.OrderByListBuilder<StrokeTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Stroke>(
      where: where(Stroke.t),
      orderBy: orderBy?.call(Stroke.t),
      orderByList: orderByList?.call(Stroke.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<StrokeTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Stroke>(
      where: where?.call(Stroke.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Stroke] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<StrokeTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Stroke>(
      where: where(Stroke.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
