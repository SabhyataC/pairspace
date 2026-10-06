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

abstract class IntegrityEvent
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  IntegrityEvent._({
    this.id,
    required this.roomId,
    required this.participantId,
    required this.type,
    this.detail,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory IntegrityEvent({
    int? id,
    required int roomId,
    required int participantId,
    required String type,
    String? detail,
    DateTime? createdAt,
  }) = _IntegrityEventImpl;

  factory IntegrityEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return IntegrityEvent(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      participantId: jsonSerialization['participantId'] as int,
      type: jsonSerialization['type'] as String,
      detail: jsonSerialization['detail'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = IntegrityEventTable();

  static const db = IntegrityEventRepository._();

  @override
  int? id;

  int roomId;

  int participantId;

  String type;

  String? detail;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [IntegrityEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  IntegrityEvent copyWith({
    int? id,
    int? roomId,
    int? participantId,
    String? type,
    String? detail,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IntegrityEvent',
      if (id != null) 'id': id,
      'roomId': roomId,
      'participantId': participantId,
      'type': type,
      if (detail != null) 'detail': detail,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IntegrityEvent',
      if (id != null) 'id': id,
      'roomId': roomId,
      'participantId': participantId,
      'type': type,
      if (detail != null) 'detail': detail,
      'createdAt': createdAt.toJson(),
    };
  }

  static IntegrityEventInclude include() {
    return IntegrityEventInclude._();
  }

  static IntegrityEventIncludeList includeList({
    _is.WhereExpressionBuilder<IntegrityEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IntegrityEventTable>? orderBy,
    _is.OrderByListBuilder<IntegrityEventTable>? orderByList,
    IntegrityEventInclude? include,
  }) {
    return IntegrityEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IntegrityEvent.t),
      orderByList: orderByList?.call(IntegrityEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IntegrityEventImpl extends IntegrityEvent {
  _IntegrityEventImpl({
    int? id,
    required int roomId,
    required int participantId,
    required String type,
    String? detail,
    DateTime? createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         participantId: participantId,
         type: type,
         detail: detail,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [IntegrityEvent]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  IntegrityEvent copyWith({
    Object? id = _Undefined,
    int? roomId,
    int? participantId,
    String? type,
    Object? detail = _Undefined,
    DateTime? createdAt,
  }) {
    return IntegrityEvent(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      participantId: participantId ?? this.participantId,
      type: type ?? this.type,
      detail: detail is String? ? detail : this.detail,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class IntegrityEventUpdateTable extends _is.UpdateTable<IntegrityEventTable> {
  IntegrityEventUpdateTable(super.table);

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<int, int> participantId(int value) => _is.ColumnValue(
    table.participantId,
    value,
  );

  _is.ColumnValue<String, String> type(String value) => _is.ColumnValue(
    table.type,
    value,
  );

  _is.ColumnValue<String, String> detail(String? value) => _is.ColumnValue(
    table.detail,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class IntegrityEventTable extends _is.Table<int?> {
  IntegrityEventTable({super.tableRelation})
    : super(tableName: 'integrity_event') {
    updateTable = IntegrityEventUpdateTable(this);
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    participantId = _is.ColumnInt(
      'participantId',
      this,
    );
    type = _is.ColumnString(
      'type',
      this,
    );
    detail = _is.ColumnString(
      'detail',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
  }

  late final IntegrityEventUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnInt participantId;

  late final _is.ColumnString type;

  late final _is.ColumnString detail;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    participantId,
    type,
    detail,
    createdAt,
  ];
}

class IntegrityEventInclude extends _is.IncludeObject {
  IntegrityEventInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => IntegrityEvent.t;
}

class IntegrityEventIncludeList extends _is.IncludeList {
  IntegrityEventIncludeList._({
    _is.WhereExpressionBuilder<IntegrityEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IntegrityEvent.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => IntegrityEvent.t;
}

class IntegrityEventRepository {
  const IntegrityEventRepository._();

  /// Returns a list of [IntegrityEvent]s matching the given query parameters.
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
  Future<List<IntegrityEvent>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IntegrityEventTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IntegrityEventTable>? orderBy,
    _is.OrderByListBuilder<IntegrityEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IntegrityEvent>(
      where: where?.call(IntegrityEvent.t),
      orderBy: orderBy?.call(IntegrityEvent.t),
      orderByList: orderByList?.call(IntegrityEvent.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [IntegrityEvent] matching the given query parameters.
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
  Future<IntegrityEvent?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IntegrityEventTable>? where,
    int? offset,
    _is.OrderByBuilder<IntegrityEventTable>? orderBy,
    _is.OrderByListBuilder<IntegrityEventTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IntegrityEvent>(
      where: where?.call(IntegrityEvent.t),
      orderBy: orderBy?.call(IntegrityEvent.t),
      orderByList: orderByList?.call(IntegrityEvent.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IntegrityEvent] by its [id] or null if no such row exists.
  Future<IntegrityEvent?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IntegrityEvent>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IntegrityEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [IntegrityEvent]s will have their `id` fields set.
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
  Future<List<IntegrityEvent>> insert(
    _is.DatabaseSession session,
    List<IntegrityEvent> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<IntegrityEvent>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [IntegrityEvent] and returns the inserted row.
  ///
  /// The returned [IntegrityEvent] will have its `id` field set.
  Future<IntegrityEvent> insertRow(
    _is.DatabaseSession session,
    IntegrityEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<IntegrityEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [IntegrityEvent]s in the list and returns the resulting rows.
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
  /// The returned [IntegrityEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IntegrityEvent>> upsert(
    _is.DatabaseSession session,
    List<IntegrityEvent> rows, {
    required _is.ColumnSelections<IntegrityEventTable> conflictColumns,
    _is.ColumnSelections<IntegrityEventTable>? updateColumns,
    _is.WhereExpressionBuilder<IntegrityEventTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<IntegrityEvent>(
      rows,
      conflictColumns: conflictColumns(IntegrityEvent.t),
      updateColumns: updateColumns?.call(IntegrityEvent.t),
      updateWhere: updateWhere?.call(IntegrityEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [IntegrityEvent] and returns the resulting row.
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
  /// The returned [IntegrityEvent] will have its `id` field set.
  Future<IntegrityEvent?> upsertRow(
    _is.DatabaseSession session,
    IntegrityEvent row, {
    required _is.ColumnSelections<IntegrityEventTable> conflictColumns,
    _is.ColumnSelections<IntegrityEventTable>? updateColumns,
    _is.WhereExpressionBuilder<IntegrityEventTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<IntegrityEvent>(
      row,
      conflictColumns: conflictColumns(IntegrityEvent.t),
      updateColumns: updateColumns?.call(IntegrityEvent.t),
      updateWhere: updateWhere?.call(IntegrityEvent.t),
      transaction: transaction,
    );
  }

  /// Updates all [IntegrityEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IntegrityEvent>> update(
    _is.DatabaseSession session,
    List<IntegrityEvent> rows, {
    _is.ColumnSelections<IntegrityEventTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<IntegrityEvent>(
      rows,
      columns: columns?.call(IntegrityEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [IntegrityEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IntegrityEvent> updateRow(
    _is.DatabaseSession session,
    IntegrityEvent row, {
    _is.ColumnSelections<IntegrityEventTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<IntegrityEvent>(
      row,
      columns: columns?.call(IntegrityEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IntegrityEvent] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IntegrityEvent?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<IntegrityEventUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<IntegrityEvent>(
      id,
      columnValues: columnValues(IntegrityEvent.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IntegrityEvent]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<IntegrityEvent>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<IntegrityEventUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<IntegrityEventTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<IntegrityEventTable>? orderBy,
    _is.OrderByListBuilder<IntegrityEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<IntegrityEvent>(
      columnValues: columnValues(IntegrityEvent.t.updateTable),
      where: where(IntegrityEvent.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IntegrityEvent.t),
      orderByList: orderByList?.call(IntegrityEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [IntegrityEvent]s in the list and returns the deleted rows.
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
  Future<List<IntegrityEvent>> delete(
    _is.DatabaseSession session,
    List<IntegrityEvent> rows, {
    _is.OrderByBuilder<IntegrityEventTable>? orderBy,
    _is.OrderByListBuilder<IntegrityEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<IntegrityEvent>(
      rows,
      orderBy: orderBy?.call(IntegrityEvent.t),
      orderByList: orderByList?.call(IntegrityEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [IntegrityEvent].
  Future<IntegrityEvent> deleteRow(
    _is.DatabaseSession session,
    IntegrityEvent row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IntegrityEvent>(
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
  Future<List<IntegrityEvent>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IntegrityEventTable> where,
    _is.OrderByBuilder<IntegrityEventTable>? orderBy,
    _is.OrderByListBuilder<IntegrityEventTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<IntegrityEvent>(
      where: where(IntegrityEvent.t),
      orderBy: orderBy?.call(IntegrityEvent.t),
      orderByList: orderByList?.call(IntegrityEvent.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<IntegrityEventTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<IntegrityEvent>(
      where: where?.call(IntegrityEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IntegrityEvent] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<IntegrityEventTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IntegrityEvent>(
      where: where(IntegrityEvent.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
