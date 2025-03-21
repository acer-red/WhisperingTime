// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConfigCollection on Isar {
  IsarCollection<Config> get configs => this.collection();
}

const ConfigSchema = CollectionSchema(
  name: r'Config',
  id: -3644000870443854999,
  properties: {
    r'apis': PropertySchema(
      id: 0,
      name: r'apis',
      type: IsarType.objectList,
      target: r'APIsar',
    ),
    r'defaultShowTool': PropertySchema(
      id: 1,
      name: r'defaultShowTool',
      type: IsarType.bool,
    ),
    r'devlopMode': PropertySchema(
      id: 2,
      name: r'devlopMode',
      type: IsarType.bool,
    ),
    r'serverAddress': PropertySchema(
      id: 3,
      name: r'serverAddress',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 4,
      name: r'uid',
      type: IsarType.string,
    ),
    r'visualNoneTitle': PropertySchema(
      id: 5,
      name: r'visualNoneTitle',
      type: IsarType.bool,
    )
  },
  estimateSize: _configEstimateSize,
  serialize: _configSerialize,
  deserialize: _configDeserialize,
  deserializeProp: _configDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'APIsar': APIsarSchema},
  getId: _configGetId,
  getLinks: _configGetLinks,
  attach: _configAttach,
  version: '3.1.0+1',
);

int _configEstimateSize(
  Config object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.apis.length * 3;
  {
    final offsets = allOffsets[APIsar]!;
    for (var i = 0; i < object.apis.length; i++) {
      final value = object.apis[i];
      bytesCount += APIsarSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.serverAddress.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _configSerialize(
  Config object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<APIsar>(
    offsets[0],
    allOffsets,
    APIsarSchema.serialize,
    object.apis,
  );
  writer.writeBool(offsets[1], object.defaultShowTool);
  writer.writeBool(offsets[2], object.devlopMode);
  writer.writeString(offsets[3], object.serverAddress);
  writer.writeString(offsets[4], object.uid);
  writer.writeBool(offsets[5], object.visualNoneTitle);
}

Config _configDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Config();
  object.apis = reader.readObjectList<APIsar>(
        offsets[0],
        APIsarSchema.deserialize,
        allOffsets,
        APIsar(),
      ) ??
      [];
  object.defaultShowTool = reader.readBool(offsets[1]);
  object.devlopMode = reader.readBool(offsets[2]);
  object.id = id;
  object.serverAddress = reader.readString(offsets[3]);
  object.uid = reader.readString(offsets[4]);
  object.visualNoneTitle = reader.readBool(offsets[5]);
  return object;
}

P _configDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<APIsar>(
            offset,
            APIsarSchema.deserialize,
            allOffsets,
            APIsar(),
          ) ??
          []) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _configGetId(Config object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _configGetLinks(Config object) {
  return [];
}

void _configAttach(IsarCollection<dynamic> col, Id id, Config object) {
  object.id = id;
}

extension ConfigQueryWhereSort on QueryBuilder<Config, Config, QWhere> {
  QueryBuilder<Config, Config, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ConfigQueryWhere on QueryBuilder<Config, Config, QWhereClause> {
  QueryBuilder<Config, Config, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Config, Config, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Config, Config, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Config, Config, QAfterWhereClause> idBetween(
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

extension ConfigQueryFilter on QueryBuilder<Config, Config, QFilterCondition> {
  QueryBuilder<Config, Config, QAfterFilterCondition> apisLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'apis',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> apisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'apis',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> apisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'apis',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> apisLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'apis',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> apisLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'apis',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> apisLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'apis',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> defaultShowToolEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultShowTool',
        value: value,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> devlopModeEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'devlopMode',
        value: value,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Config, Config, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Config, Config, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'serverAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'serverAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'serverAddress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'serverAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'serverAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'serverAddress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'serverAddress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> serverAddressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'serverAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition>
      serverAddressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'serverAddress',
        value: '',
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Config, Config, QAfterFilterCondition> visualNoneTitleEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'visualNoneTitle',
        value: value,
      ));
    });
  }
}

extension ConfigQueryObject on QueryBuilder<Config, Config, QFilterCondition> {
  QueryBuilder<Config, Config, QAfterFilterCondition> apisElement(
      FilterQuery<APIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'apis');
    });
  }
}

extension ConfigQueryLinks on QueryBuilder<Config, Config, QFilterCondition> {}

extension ConfigQuerySortBy on QueryBuilder<Config, Config, QSortBy> {
  QueryBuilder<Config, Config, QAfterSortBy> sortByDefaultShowTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultShowTool', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByDefaultShowToolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultShowTool', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByDevlopMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devlopMode', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByDevlopModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devlopMode', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByServerAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverAddress', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByServerAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverAddress', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByVisualNoneTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualNoneTitle', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> sortByVisualNoneTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualNoneTitle', Sort.desc);
    });
  }
}

extension ConfigQuerySortThenBy on QueryBuilder<Config, Config, QSortThenBy> {
  QueryBuilder<Config, Config, QAfterSortBy> thenByDefaultShowTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultShowTool', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByDefaultShowToolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultShowTool', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByDevlopMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devlopMode', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByDevlopModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'devlopMode', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByServerAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverAddress', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByServerAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'serverAddress', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByVisualNoneTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualNoneTitle', Sort.asc);
    });
  }

  QueryBuilder<Config, Config, QAfterSortBy> thenByVisualNoneTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'visualNoneTitle', Sort.desc);
    });
  }
}

extension ConfigQueryWhereDistinct on QueryBuilder<Config, Config, QDistinct> {
  QueryBuilder<Config, Config, QDistinct> distinctByDefaultShowTool() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultShowTool');
    });
  }

  QueryBuilder<Config, Config, QDistinct> distinctByDevlopMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'devlopMode');
    });
  }

  QueryBuilder<Config, Config, QDistinct> distinctByServerAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'serverAddress',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Config, Config, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Config, Config, QDistinct> distinctByVisualNoneTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visualNoneTitle');
    });
  }
}

extension ConfigQueryProperty on QueryBuilder<Config, Config, QQueryProperty> {
  QueryBuilder<Config, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Config, List<APIsar>, QQueryOperations> apisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apis');
    });
  }

  QueryBuilder<Config, bool, QQueryOperations> defaultShowToolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultShowTool');
    });
  }

  QueryBuilder<Config, bool, QQueryOperations> devlopModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'devlopMode');
    });
  }

  QueryBuilder<Config, String, QQueryOperations> serverAddressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'serverAddress');
    });
  }

  QueryBuilder<Config, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<Config, bool, QQueryOperations> visualNoneTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visualNoneTitle');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const APIsarSchema = Schema(
  name: r'APIsar',
  id: -6201739561409360728,
  properties: {
    r'extime': PropertySchema(
      id: 0,
      name: r'extime',
      type: IsarType.string,
    ),
    r'key': PropertySchema(
      id: 1,
      name: r'key',
      type: IsarType.string,
    )
  },
  estimateSize: _aPIsarEstimateSize,
  serialize: _aPIsarSerialize,
  deserialize: _aPIsarDeserialize,
  deserializeProp: _aPIsarDeserializeProp,
);

int _aPIsarEstimateSize(
  APIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.extime;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.key;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _aPIsarSerialize(
  APIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.extime);
  writer.writeString(offsets[1], object.key);
}

APIsar _aPIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = APIsar(
    extime: reader.readStringOrNull(offsets[0]),
    key: reader.readStringOrNull(offsets[1]),
  );
  return object;
}

P _aPIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension APIsarQueryFilter on QueryBuilder<APIsar, APIsar, QFilterCondition> {
  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extime',
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extime',
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'extime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'extime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'extime',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'extime',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extime',
        value: '',
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> extimeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'extime',
        value: '',
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'key',
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'key',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'key',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'key',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'key',
        value: '',
      ));
    });
  }

  QueryBuilder<APIsar, APIsar, QAfterFilterCondition> keyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'key',
        value: '',
      ));
    });
  }
}

extension APIsarQueryObject on QueryBuilder<APIsar, APIsar, QFilterCondition> {}
