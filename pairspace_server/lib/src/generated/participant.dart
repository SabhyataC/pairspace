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
import 'participant_role.dart' as _i5kza8cj;

abstract class Participant
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Participant._({
    this.id,
    required this.roomId,
    required this.role,
    required this.displayName,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  factory Participant({
    int? id,
    required int roomId,
    required _i5kza8cj.ParticipantRole role,
    required String displayName,
    DateTime? joinedAt,
  }) = _ParticipantImpl;

  factory Participant.fromJson(Map<String, dynamic> jsonSerialization) {
    return Participant(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      role: _i5kza8cj.ParticipantRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      displayName: jsonSerialization['displayName'] as String,
      joinedAt: jsonSerialization['joinedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['joinedAt']),
    );
  }

  static final t = ParticipantTable();

  static const db = ParticipantRepository._();

  @override
  int? id;

  int roomId;

  _i5kza8cj.ParticipantRole role;

  String displayName;

  DateTime joinedAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Participant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Participant copyWith({
    int? id,
    int? roomId,
    _i5kza8cj.ParticipantRole? role,
    String? displayName,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Participant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'role': role.toJson(),
      'displayName': displayName,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Participant',
      if (id != null) 'id': id,
      'roomId': roomId,
      'role': role.toJson(),
      'displayName': displayName,
      'joinedAt': joinedAt.toJson(),
    };
  }

  static ParticipantInclude include() {
    return ParticipantInclude._();
  }

  static ParticipantIncludeList includeList({
    _is.WhereExpressionBuilder<ParticipantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ParticipantTable>? orderBy,
    _is.OrderByListBuilder<ParticipantTable>? orderByList,
    ParticipantInclude? include,
  }) {
    return ParticipantIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Participant.t),
      orderByList: orderByList?.call(Participant.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ParticipantImpl extends Participant {
  _ParticipantImpl({
    int? id,
    required int roomId,
    required _i5kza8cj.ParticipantRole role,
    required String displayName,
    DateTime? joinedAt,
  }) : super._(
         id: id,
         roomId: roomId,
         role: role,
         displayName: displayName,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [Participant]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Participant copyWith({
    Object? id = _Undefined,
    int? roomId,
    _i5kza8cj.ParticipantRole? role,
    String? displayName,
    DateTime? joinedAt,
  }) {
    return Participant(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

class ParticipantUpdateTable extends _is.UpdateTable<ParticipantTable> {
  ParticipantUpdateTable(super.table);

  _is.ColumnValue<int, int> roomId(int value) => _is.ColumnValue(
    table.roomId,
    value,
  );

  _is.ColumnValue<_i5kza8cj.ParticipantRole, _i5kza8cj.ParticipantRole> role(
    _i5kza8cj.ParticipantRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<String, String> displayName(String value) => _is.ColumnValue(
    table.displayName,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> joinedAt(DateTime value) =>
      _is.ColumnValue(
        table.joinedAt,
        value,
      );
}

class ParticipantTable extends _is.Table<int?> {
  ParticipantTable({super.tableRelation}) : super(tableName: 'participant') {
    updateTable = ParticipantUpdateTable(this);
    roomId = _is.ColumnInt(
      'roomId',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
    );
    displayName = _is.ColumnString(
      'displayName',
      this,
    );
    joinedAt = _is.ColumnDateTime(
      'joinedAt',
      this,
      hasDefault: true,
    );
  }

  late final ParticipantUpdateTable updateTable;

  late final _is.ColumnInt roomId;

  late final _is.ColumnEnum<_i5kza8cj.ParticipantRole> role;

  late final _is.ColumnString displayName;

  late final _is.ColumnDateTime joinedAt;

  @override
  List<_is.Column> get columns => [
    id,
    roomId,
    role,
    displayName,
    joinedAt,
  ];
}

class ParticipantInclude extends _is.IncludeObject {
  ParticipantInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => Participant.t;
}

class ParticipantIncludeList extends _is.IncludeList {
  ParticipantIncludeList._({
    _is.WhereExpressionBuilder<ParticipantTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Participant.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Participant.t;
}

class ParticipantRepository {
  const ParticipantRepository._();

  /// Returns a list of [Participant]s matching the given query parameters.
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
  Future<List<Participant>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ParticipantTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ParticipantTable>? orderBy,
    _is.OrderByListBuilder<ParticipantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Participant>(
      where: where?.call(Participant.t),
      orderBy: orderBy?.call(Participant.t),
      orderByList: orderByList?.call(Participant.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Participant] matching the given query parameters.
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
  Future<Participant?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ParticipantTable>? where,
    int? offset,
    _is.OrderByBuilder<ParticipantTable>? orderBy,
    _is.OrderByListBuilder<ParticipantTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Participant>(
      where: where?.call(Participant.t),
      orderBy: orderBy?.call(Participant.t),
      orderByList: orderByList?.call(Participant.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Participant] by its [id] or null if no such row exists.
  Future<Participant?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Participant>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Participant]s in the list and returns the inserted rows.
  ///
  /// The returned [Participant]s will have their `id` fields set.
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
  Future<List<Participant>> insert(
    _is.DatabaseSession session,
    List<Participant> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Participant>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Participant] and returns the inserted row.
  ///
  /// The returned [Participant] will have its `id` field set.
  Future<Participant> insertRow(
    _is.DatabaseSession session,
    Participant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Participant>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Participant]s in the list and returns the resulting rows.
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
  /// The returned [Participant]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Participant>> upsert(
    _is.DatabaseSession session,
    List<Participant> rows, {
    required _is.ColumnSelections<ParticipantTable> conflictColumns,
    _is.ColumnSelections<ParticipantTable>? updateColumns,
    _is.WhereExpressionBuilder<ParticipantTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Participant>(
      rows,
      conflictColumns: conflictColumns(Participant.t),
      updateColumns: updateColumns?.call(Participant.t),
      updateWhere: updateWhere?.call(Participant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Participant] and returns the resulting row.
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
  /// The returned [Participant] will have its `id` field set.
  Future<Participant?> upsertRow(
    _is.DatabaseSession session,
    Participant row, {
    required _is.ColumnSelections<ParticipantTable> conflictColumns,
    _is.ColumnSelections<ParticipantTable>? updateColumns,
    _is.WhereExpressionBuilder<ParticipantTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Participant>(
      row,
      conflictColumns: conflictColumns(Participant.t),
      updateColumns: updateColumns?.call(Participant.t),
      updateWhere: updateWhere?.call(Participant.t),
      transaction: transaction,
    );
  }

  /// Updates all [Participant]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Participant>> update(
    _is.DatabaseSession session,
    List<Participant> rows, {
    _is.ColumnSelections<ParticipantTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Participant>(
      rows,
      columns: columns?.call(Participant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Participant]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Participant> updateRow(
    _is.DatabaseSession session,
    Participant row, {
    _is.ColumnSelections<ParticipantTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Participant>(
      row,
      columns: columns?.call(Participant.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Participant] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Participant?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ParticipantUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Participant>(
      id,
      columnValues: columnValues(Participant.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Participant]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Participant>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ParticipantUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ParticipantTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ParticipantTable>? orderBy,
    _is.OrderByListBuilder<ParticipantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Participant>(
      columnValues: columnValues(Participant.t.updateTable),
      where: where(Participant.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Participant.t),
      orderByList: orderByList?.call(Participant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Participant]s in the list and returns the deleted rows.
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
  Future<List<Participant>> delete(
    _is.DatabaseSession session,
    List<Participant> rows, {
    _is.OrderByBuilder<ParticipantTable>? orderBy,
    _is.OrderByListBuilder<ParticipantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Participant>(
      rows,
      orderBy: orderBy?.call(Participant.t),
      orderByList: orderByList?.call(Participant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Participant].
  Future<Participant> deleteRow(
    _is.DatabaseSession session,
    Participant row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Participant>(
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
  Future<List<Participant>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ParticipantTable> where,
    _is.OrderByBuilder<ParticipantTable>? orderBy,
    _is.OrderByListBuilder<ParticipantTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Participant>(
      where: where(Participant.t),
      orderBy: orderBy?.call(Participant.t),
      orderByList: orderByList?.call(Participant.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ParticipantTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Participant>(
      where: where?.call(Participant.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Participant] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ParticipantTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Participant>(
      where: where(Participant.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
