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

abstract class CodeEdit
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
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
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  static final t = CodeEditTable();

  static const db = CodeEditRepository._();

  @override
  int? id;

  int roomId;

  int offset;

  int removed;

  String inserted;

  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [CodeEdit]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
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

  static CodeEditInclude include() {
    return CodeEditInclude._();
  }

  static CodeEditIncludeList includeList({
    _is.WhereExpressionBuilder<CodeEditTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CodeEditTable>? orderBy,
    _is.OrderByListBuilder<CodeEditTable>? orderByList,
    CodeEditInclude? include,
  }) {
    return CodeEditIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CodeEdit.t),
      orderByList: orderByList?.call(CodeEdit.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
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
  @_is.useResult
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

class CodeEditUpdateTable extends _is.UpdateTable<CodeEditTable> {
  CodeEditUpdateTable(super.table);

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<int, int> offset(int value) => _is.ColumnValue(
    table.offset,
    value,
  );

  _is.ColumnValue<int, int> removed(int value) => _is.ColumnValue(
    table.removed,
    value,
  );

  _is.ColumnValue<String, String> inserted(String value) => _is.ColumnValue(
    table.inserted,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class CodeEditTable extends _is.Table<int?> {
  CodeEditTable({super.tableRelation}) : super(tableName: 'code_edit') {
    updateTable = CodeEditUpdateTable(this);
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    offset = _is.ColumnInt(
      'offset',
      this,
    );
    removed = _is.ColumnInt(
      'removed',
      this,
    );
    inserted = _is.ColumnString(
      'inserted',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final CodeEditUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnInt offset;

  late final _is.ColumnInt removed;

  late final _is.ColumnString inserted;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    offset,
    removed,
    inserted,
    createdAt,
  ];
}

class CodeEditInclude extends _is.IncludeObject {
  CodeEditInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => CodeEdit.t;
}

class CodeEditIncludeList extends _is.IncludeList {
  CodeEditIncludeList._({
    _is.WhereExpressionBuilder<CodeEditTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(CodeEdit.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => CodeEdit.t;
}

class CodeEditRepository {
  const CodeEditRepository._();

  /// Returns a list of [CodeEdit]s matching the given query parameters.
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
  Future<List<CodeEdit>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CodeEditTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CodeEditTable>? orderBy,
    _is.OrderByListBuilder<CodeEditTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<CodeEdit>(
      where: where?.call(CodeEdit.t),
      orderBy: orderBy?.call(CodeEdit.t),
      orderByList: orderByList?.call(CodeEdit.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [CodeEdit] matching the given query parameters.
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
  Future<CodeEdit?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CodeEditTable>? where,
    int? offset,
    _is.OrderByBuilder<CodeEditTable>? orderBy,
    _is.OrderByListBuilder<CodeEditTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<CodeEdit>(
      where: where?.call(CodeEdit.t),
      orderBy: orderBy?.call(CodeEdit.t),
      orderByList: orderByList?.call(CodeEdit.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [CodeEdit] by its [id] or null if no such row exists.
  Future<CodeEdit?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<CodeEdit>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [CodeEdit]s in the list and returns the inserted rows.
  ///
  /// The returned [CodeEdit]s will have their `id` fields set.
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
  Future<List<CodeEdit>> insert(
    _is.DatabaseSession session,
    List<CodeEdit> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<CodeEdit>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [CodeEdit] and returns the inserted row.
  ///
  /// The returned [CodeEdit] will have its `id` field set.
  Future<CodeEdit> insertRow(
    _is.DatabaseSession session,
    CodeEdit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<CodeEdit>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [CodeEdit]s in the list and returns the resulting rows.
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
  /// The returned [CodeEdit]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CodeEdit>> upsert(
    _is.DatabaseSession session,
    List<CodeEdit> rows, {
    required _is.ColumnSelections<CodeEditTable> conflictColumns,
    _is.ColumnSelections<CodeEditTable>? updateColumns,
    _is.WhereExpressionBuilder<CodeEditTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<CodeEdit>(
      rows,
      conflictColumns: conflictColumns(CodeEdit.t),
      updateColumns: updateColumns?.call(CodeEdit.t),
      updateWhere: updateWhere?.call(CodeEdit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [CodeEdit] and returns the resulting row.
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
  /// The returned [CodeEdit] will have its `id` field set.
  Future<CodeEdit?> upsertRow(
    _is.DatabaseSession session,
    CodeEdit row, {
    required _is.ColumnSelections<CodeEditTable> conflictColumns,
    _is.ColumnSelections<CodeEditTable>? updateColumns,
    _is.WhereExpressionBuilder<CodeEditTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<CodeEdit>(
      row,
      conflictColumns: conflictColumns(CodeEdit.t),
      updateColumns: updateColumns?.call(CodeEdit.t),
      updateWhere: updateWhere?.call(CodeEdit.t),
      transaction: transaction,
    );
  }

  /// Updates all [CodeEdit]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CodeEdit>> update(
    _is.DatabaseSession session,
    List<CodeEdit> rows, {
    _is.ColumnSelections<CodeEditTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<CodeEdit>(
      rows,
      columns: columns?.call(CodeEdit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [CodeEdit]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<CodeEdit> updateRow(
    _is.DatabaseSession session,
    CodeEdit row, {
    _is.ColumnSelections<CodeEditTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<CodeEdit>(
      row,
      columns: columns?.call(CodeEdit.t),
      transaction: transaction,
    );
  }

  /// Updates a single [CodeEdit] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<CodeEdit?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<CodeEditUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<CodeEdit>(
      id,
      columnValues: columnValues(CodeEdit.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [CodeEdit]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<CodeEdit>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<CodeEditUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<CodeEditTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<CodeEditTable>? orderBy,
    _is.OrderByListBuilder<CodeEditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<CodeEdit>(
      columnValues: columnValues(CodeEdit.t.updateTable),
      where: where(CodeEdit.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(CodeEdit.t),
      orderByList: orderByList?.call(CodeEdit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [CodeEdit]s in the list and returns the deleted rows.
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
  Future<List<CodeEdit>> delete(
    _is.DatabaseSession session,
    List<CodeEdit> rows, {
    _is.OrderByBuilder<CodeEditTable>? orderBy,
    _is.OrderByListBuilder<CodeEditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<CodeEdit>(
      rows,
      orderBy: orderBy?.call(CodeEdit.t),
      orderByList: orderByList?.call(CodeEdit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [CodeEdit].
  Future<CodeEdit> deleteRow(
    _is.DatabaseSession session,
    CodeEdit row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<CodeEdit>(
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
  Future<List<CodeEdit>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CodeEditTable> where,
    _is.OrderByBuilder<CodeEditTable>? orderBy,
    _is.OrderByListBuilder<CodeEditTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<CodeEdit>(
      where: where(CodeEdit.t),
      orderBy: orderBy?.call(CodeEdit.t),
      orderByList: orderByList?.call(CodeEdit.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<CodeEditTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<CodeEdit>(
      where: where?.call(CodeEdit.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [CodeEdit] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<CodeEditTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<CodeEdit>(
      where: where(CodeEdit.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
