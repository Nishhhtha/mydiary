// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTaskLogCollection on Isar {
  IsarCollection<TaskLog> get taskLogs => this.collection();
}

const TaskLogSchema = CollectionSchema(
  name: r'TaskLog',
  id: 3852084319912361112,
  properties: {
    r'currentProgress': PropertySchema(
      id: 0,
      name: r'currentProgress',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 2,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'taskUuid': PropertySchema(
      id: 3,
      name: r'taskUuid',
      type: IsarType.string,
    )
  },
  estimateSize: _taskLogEstimateSize,
  serialize: _taskLogSerialize,
  deserialize: _taskLogDeserialize,
  deserializeProp: _taskLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _taskLogGetId,
  getLinks: _taskLogGetLinks,
  attach: _taskLogAttach,
  version: '3.1.0+1',
);

int _taskLogEstimateSize(
  TaskLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.date.length * 3;
  bytesCount += 3 + object.taskUuid.length * 3;
  return bytesCount;
}

void _taskLogSerialize(
  TaskLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.currentProgress);
  writer.writeString(offsets[1], object.date);
  writer.writeBool(offsets[2], object.isCompleted);
  writer.writeString(offsets[3], object.taskUuid);
}

TaskLog _taskLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TaskLog();
  object.currentProgress = reader.readDouble(offsets[0]);
  object.date = reader.readString(offsets[1]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[2]);
  object.taskUuid = reader.readString(offsets[3]);
  return object;
}

P _taskLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _taskLogGetId(TaskLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _taskLogGetLinks(TaskLog object) {
  return [];
}

void _taskLogAttach(IsarCollection<dynamic> col, Id id, TaskLog object) {
  object.id = id;
}

extension TaskLogQueryWhereSort on QueryBuilder<TaskLog, TaskLog, QWhere> {
  QueryBuilder<TaskLog, TaskLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TaskLogQueryWhere on QueryBuilder<TaskLog, TaskLog, QWhereClause> {
  QueryBuilder<TaskLog, TaskLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TaskLogQueryFilter
    on QueryBuilder<TaskLog, TaskLog, QFilterCondition> {
  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> currentProgressEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition>
      currentProgressGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> currentProgressLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentProgress',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> currentProgressBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentProgress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'date',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'date',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> dateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'date',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> isCompletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'taskUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'taskUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'taskUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'taskUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'taskUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'taskUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'taskUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'taskUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterFilterCondition> taskUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'taskUuid',
        value: '',
      ));
    });
  }
}

extension TaskLogQueryObject
    on QueryBuilder<TaskLog, TaskLog, QFilterCondition> {}

extension TaskLogQueryLinks
    on QueryBuilder<TaskLog, TaskLog, QFilterCondition> {}

extension TaskLogQuerySortBy on QueryBuilder<TaskLog, TaskLog, QSortBy> {
  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByCurrentProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByCurrentProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.desc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByTaskUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> sortByTaskUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.desc);
    });
  }
}

extension TaskLogQuerySortThenBy
    on QueryBuilder<TaskLog, TaskLog, QSortThenBy> {
  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByCurrentProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByCurrentProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentProgress', Sort.desc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByTaskUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.asc);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QAfterSortBy> thenByTaskUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'taskUuid', Sort.desc);
    });
  }
}

extension TaskLogQueryWhereDistinct
    on QueryBuilder<TaskLog, TaskLog, QDistinct> {
  QueryBuilder<TaskLog, TaskLog, QDistinct> distinctByCurrentProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentProgress');
    });
  }

  QueryBuilder<TaskLog, TaskLog, QDistinct> distinctByDate(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TaskLog, TaskLog, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<TaskLog, TaskLog, QDistinct> distinctByTaskUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'taskUuid', caseSensitive: caseSensitive);
    });
  }
}

extension TaskLogQueryProperty
    on QueryBuilder<TaskLog, TaskLog, QQueryProperty> {
  QueryBuilder<TaskLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TaskLog, double, QQueryOperations> currentProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentProgress');
    });
  }

  QueryBuilder<TaskLog, String, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<TaskLog, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<TaskLog, String, QQueryOperations> taskUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'taskUuid');
    });
  }
}
