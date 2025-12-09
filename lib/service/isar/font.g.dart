// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'font.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFontCollection on Isar {
  IsarCollection<Font> get fonts => this.collection();
}

const FontSchema = CollectionSchema(
  name: r'Font',
  id: -7442748732413312422,
  properties: {
    r'copyRight': PropertySchema(
      id: 0,
      name: r'copyRight',
      type: IsarType.string,
    ),
    r'downloadURL': PropertySchema(
      id: 1,
      name: r'downloadURL',
      type: IsarType.string,
    ),
    r'fileName': PropertySchema(
      id: 2,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'fullName': PropertySchema(
      id: 3,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'license': PropertySchema(
      id: 4,
      name: r'license',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    ),
    r'sha256': PropertySchema(
      id: 6,
      name: r'sha256',
      type: IsarType.string,
    ),
    r'subName': PropertySchema(
      id: 7,
      name: r'subName',
      type: IsarType.string,
    ),
    r'version': PropertySchema(
      id: 8,
      name: r'version',
      type: IsarType.string,
    )
  },
  estimateSize: _fontEstimateSize,
  serialize: _fontSerialize,
  deserialize: _fontDeserialize,
  deserializeProp: _fontDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _fontGetId,
  getLinks: _fontGetLinks,
  attach: _fontAttach,
  version: '3.1.0+1',
);

int _fontEstimateSize(
  Font object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.copyRight;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.downloadURL;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fileName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fullName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.license;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sha256;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.subName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.version;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _fontSerialize(
  Font object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.copyRight);
  writer.writeString(offsets[1], object.downloadURL);
  writer.writeString(offsets[2], object.fileName);
  writer.writeString(offsets[3], object.fullName);
  writer.writeString(offsets[4], object.license);
  writer.writeString(offsets[5], object.name);
  writer.writeString(offsets[6], object.sha256);
  writer.writeString(offsets[7], object.subName);
  writer.writeString(offsets[8], object.version);
}

Font _fontDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Font(
    copyRight: reader.readStringOrNull(offsets[0]),
    downloadURL: reader.readStringOrNull(offsets[1]),
    fileName: reader.readStringOrNull(offsets[2]),
    fullName: reader.readStringOrNull(offsets[3]),
    license: reader.readStringOrNull(offsets[4]),
    name: reader.readStringOrNull(offsets[5]),
    sha256: reader.readStringOrNull(offsets[6]),
    subName: reader.readStringOrNull(offsets[7]),
    version: reader.readStringOrNull(offsets[8]),
  );
  object.id = id;
  return object;
}

P _fontDeserializeProp<P>(
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
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _fontGetId(Font object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _fontGetLinks(Font object) {
  return [];
}

void _fontAttach(IsarCollection<dynamic> col, Id id, Font object) {
  object.id = id;
}

extension FontQueryWhereSort on QueryBuilder<Font, Font, QWhere> {
  QueryBuilder<Font, Font, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FontQueryWhere on QueryBuilder<Font, Font, QWhereClause> {
  QueryBuilder<Font, Font, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Font, Font, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Font, Font, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Font, Font, QAfterWhereClause> idBetween(
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

extension FontQueryFilter on QueryBuilder<Font, Font, QFilterCondition> {
  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'copyRight',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'copyRight',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'copyRight',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'copyRight',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'copyRight',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'copyRight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'copyRight',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'copyRight',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'copyRight',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'copyRight',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'copyRight',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> copyRightIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'copyRight',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'downloadURL',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'downloadURL',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'downloadURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'downloadURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'downloadURL',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'downloadURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'downloadURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'downloadURL',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'downloadURL',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'downloadURL',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> downloadURLIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'downloadURL',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fileName',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fileName',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fullName',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fullName',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Font, Font, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Font, Font, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'license',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'license',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'license',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'license',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'license',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'license',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'license',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'license',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'license',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'license',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'license',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> licenseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'license',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256IsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sha256',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256IsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sha256',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256EqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256GreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256LessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256Between(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sha256',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256StartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256EndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256Contains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sha256',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256Matches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sha256',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sha256',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> sha256IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sha256',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'subName',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'subName',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'subName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'subName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'subName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'subName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subName',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> subNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'subName',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'version',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'version',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'version',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: '',
      ));
    });
  }

  QueryBuilder<Font, Font, QAfterFilterCondition> versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'version',
        value: '',
      ));
    });
  }
}

extension FontQueryObject on QueryBuilder<Font, Font, QFilterCondition> {}

extension FontQueryLinks on QueryBuilder<Font, Font, QFilterCondition> {}

extension FontQuerySortBy on QueryBuilder<Font, Font, QSortBy> {
  QueryBuilder<Font, Font, QAfterSortBy> sortByCopyRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyRight', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByCopyRightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyRight', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByDownloadURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadURL', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByDownloadURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadURL', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByLicense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'license', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByLicenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'license', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortBySha256() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortBySha256Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortBySubName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subName', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortBySubNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subName', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension FontQuerySortThenBy on QueryBuilder<Font, Font, QSortThenBy> {
  QueryBuilder<Font, Font, QAfterSortBy> thenByCopyRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyRight', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByCopyRightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'copyRight', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByDownloadURL() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadURL', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByDownloadURLDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'downloadURL', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByLicense() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'license', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByLicenseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'license', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenBySha256() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenBySha256Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sha256', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenBySubName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subName', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenBySubNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subName', Sort.desc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<Font, Font, QAfterSortBy> thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension FontQueryWhereDistinct on QueryBuilder<Font, Font, QDistinct> {
  QueryBuilder<Font, Font, QDistinct> distinctByCopyRight(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'copyRight', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctByDownloadURL(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'downloadURL', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctByFileName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctByFullName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctByLicense(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'license', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctBySha256(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sha256', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctBySubName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Font, Font, QDistinct> distinctByVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version', caseSensitive: caseSensitive);
    });
  }
}

extension FontQueryProperty on QueryBuilder<Font, Font, QQueryProperty> {
  QueryBuilder<Font, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> copyRightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'copyRight');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> downloadURLProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'downloadURL');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> licenseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'license');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> sha256Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sha256');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> subNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subName');
    });
  }

  QueryBuilder<Font, String?, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}
