// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Sex, int> sex =
      GeneratedColumn<int>(
        'sex',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Sex>($ProfilesTable.$convertersex);
  static const VerificationMeta _birthYearMeta = const VerificationMeta(
    'birthYear',
  );
  @override
  late final GeneratedColumn<int> birthYear = GeneratedColumn<int>(
    'birth_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
    'height_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActivityLevel, int> activity =
      GeneratedColumn<int>(
        'activity',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<ActivityLevel>($ProfilesTable.$converteractivity);
  @override
  late final GeneratedColumnWithTypeConverter<Goal, int> goal =
      GeneratedColumn<int>(
        'goal',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Goal>($ProfilesTable.$convertergoal);
  static const VerificationMeta _pacePercentMeta = const VerificationMeta(
    'pacePercent',
  );
  @override
  late final GeneratedColumn<double> pacePercent = GeneratedColumn<double>(
    'pace_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPerKgMeta = const VerificationMeta(
    'proteinPerKg',
  );
  @override
  late final GeneratedColumn<double> proteinPerKg = GeneratedColumn<double>(
    'protein_per_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calorieTargetOverrideMeta =
      const VerificationMeta('calorieTargetOverride');
  @override
  late final GeneratedColumn<int> calorieTargetOverride = GeneratedColumn<int>(
    'calorie_target_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sex,
    birthYear,
    heightCm,
    activity,
    goal,
    pacePercent,
    proteinPerKg,
    calorieTargetOverride,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('birth_year')) {
      context.handle(
        _birthYearMeta,
        birthYear.isAcceptableOrUnknown(data['birth_year']!, _birthYearMeta),
      );
    } else if (isInserting) {
      context.missing(_birthYearMeta);
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    } else if (isInserting) {
      context.missing(_heightCmMeta);
    }
    if (data.containsKey('pace_percent')) {
      context.handle(
        _pacePercentMeta,
        pacePercent.isAcceptableOrUnknown(
          data['pace_percent']!,
          _pacePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pacePercentMeta);
    }
    if (data.containsKey('protein_per_kg')) {
      context.handle(
        _proteinPerKgMeta,
        proteinPerKg.isAcceptableOrUnknown(
          data['protein_per_kg']!,
          _proteinPerKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPerKgMeta);
    }
    if (data.containsKey('calorie_target_override')) {
      context.handle(
        _calorieTargetOverrideMeta,
        calorieTargetOverride.isAcceptableOrUnknown(
          data['calorie_target_override']!,
          _calorieTargetOverrideMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sex: $ProfilesTable.$convertersex.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sex'],
        )!,
      ),
      birthYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_year'],
      )!,
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}height_cm'],
      )!,
      activity: $ProfilesTable.$converteractivity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}activity'],
        )!,
      ),
      goal: $ProfilesTable.$convertergoal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}goal'],
        )!,
      ),
      pacePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pace_percent'],
      )!,
      proteinPerKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per_kg'],
      )!,
      calorieTargetOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calorie_target_override'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Sex, int, int> $convertersex =
      const EnumIndexConverter<Sex>(Sex.values);
  static JsonTypeConverter2<ActivityLevel, int, int> $converteractivity =
      const EnumIndexConverter<ActivityLevel>(ActivityLevel.values);
  static JsonTypeConverter2<Goal, int, int> $convertergoal =
      const EnumIndexConverter<Goal>(Goal.values);
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final Sex sex;
  final int birthYear;
  final double heightCm;
  final ActivityLevel activity;
  final Goal goal;

  /// Tempo in Prozent des Körpergewichts pro Woche.
  final double pacePercent;
  final double proteinPerKg;

  /// Vom Nutzer bestätigtes Kalorienziel aus dem Check-in; null = Startschätzung verwenden.
  final int? calorieTargetOverride;
  const Profile({
    required this.id,
    required this.sex,
    required this.birthYear,
    required this.heightCm,
    required this.activity,
    required this.goal,
    required this.pacePercent,
    required this.proteinPerKg,
    this.calorieTargetOverride,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['sex'] = Variable<int>($ProfilesTable.$convertersex.toSql(sex));
    }
    map['birth_year'] = Variable<int>(birthYear);
    map['height_cm'] = Variable<double>(heightCm);
    {
      map['activity'] = Variable<int>(
        $ProfilesTable.$converteractivity.toSql(activity),
      );
    }
    {
      map['goal'] = Variable<int>($ProfilesTable.$convertergoal.toSql(goal));
    }
    map['pace_percent'] = Variable<double>(pacePercent);
    map['protein_per_kg'] = Variable<double>(proteinPerKg);
    if (!nullToAbsent || calorieTargetOverride != null) {
      map['calorie_target_override'] = Variable<int>(calorieTargetOverride);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      sex: Value(sex),
      birthYear: Value(birthYear),
      heightCm: Value(heightCm),
      activity: Value(activity),
      goal: Value(goal),
      pacePercent: Value(pacePercent),
      proteinPerKg: Value(proteinPerKg),
      calorieTargetOverride: calorieTargetOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(calorieTargetOverride),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      sex: $ProfilesTable.$convertersex.fromJson(
        serializer.fromJson<int>(json['sex']),
      ),
      birthYear: serializer.fromJson<int>(json['birthYear']),
      heightCm: serializer.fromJson<double>(json['heightCm']),
      activity: $ProfilesTable.$converteractivity.fromJson(
        serializer.fromJson<int>(json['activity']),
      ),
      goal: $ProfilesTable.$convertergoal.fromJson(
        serializer.fromJson<int>(json['goal']),
      ),
      pacePercent: serializer.fromJson<double>(json['pacePercent']),
      proteinPerKg: serializer.fromJson<double>(json['proteinPerKg']),
      calorieTargetOverride: serializer.fromJson<int?>(
        json['calorieTargetOverride'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sex': serializer.toJson<int>($ProfilesTable.$convertersex.toJson(sex)),
      'birthYear': serializer.toJson<int>(birthYear),
      'heightCm': serializer.toJson<double>(heightCm),
      'activity': serializer.toJson<int>(
        $ProfilesTable.$converteractivity.toJson(activity),
      ),
      'goal': serializer.toJson<int>(
        $ProfilesTable.$convertergoal.toJson(goal),
      ),
      'pacePercent': serializer.toJson<double>(pacePercent),
      'proteinPerKg': serializer.toJson<double>(proteinPerKg),
      'calorieTargetOverride': serializer.toJson<int?>(calorieTargetOverride),
    };
  }

  Profile copyWith({
    int? id,
    Sex? sex,
    int? birthYear,
    double? heightCm,
    ActivityLevel? activity,
    Goal? goal,
    double? pacePercent,
    double? proteinPerKg,
    Value<int?> calorieTargetOverride = const Value.absent(),
  }) => Profile(
    id: id ?? this.id,
    sex: sex ?? this.sex,
    birthYear: birthYear ?? this.birthYear,
    heightCm: heightCm ?? this.heightCm,
    activity: activity ?? this.activity,
    goal: goal ?? this.goal,
    pacePercent: pacePercent ?? this.pacePercent,
    proteinPerKg: proteinPerKg ?? this.proteinPerKg,
    calorieTargetOverride: calorieTargetOverride.present
        ? calorieTargetOverride.value
        : this.calorieTargetOverride,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      sex: data.sex.present ? data.sex.value : this.sex,
      birthYear: data.birthYear.present ? data.birthYear.value : this.birthYear,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      activity: data.activity.present ? data.activity.value : this.activity,
      goal: data.goal.present ? data.goal.value : this.goal,
      pacePercent: data.pacePercent.present
          ? data.pacePercent.value
          : this.pacePercent,
      proteinPerKg: data.proteinPerKg.present
          ? data.proteinPerKg.value
          : this.proteinPerKg,
      calorieTargetOverride: data.calorieTargetOverride.present
          ? data.calorieTargetOverride.value
          : this.calorieTargetOverride,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('activity: $activity, ')
          ..write('goal: $goal, ')
          ..write('pacePercent: $pacePercent, ')
          ..write('proteinPerKg: $proteinPerKg, ')
          ..write('calorieTargetOverride: $calorieTargetOverride')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sex,
    birthYear,
    heightCm,
    activity,
    goal,
    pacePercent,
    proteinPerKg,
    calorieTargetOverride,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.sex == this.sex &&
          other.birthYear == this.birthYear &&
          other.heightCm == this.heightCm &&
          other.activity == this.activity &&
          other.goal == this.goal &&
          other.pacePercent == this.pacePercent &&
          other.proteinPerKg == this.proteinPerKg &&
          other.calorieTargetOverride == this.calorieTargetOverride);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<Sex> sex;
  final Value<int> birthYear;
  final Value<double> heightCm;
  final Value<ActivityLevel> activity;
  final Value<Goal> goal;
  final Value<double> pacePercent;
  final Value<double> proteinPerKg;
  final Value<int?> calorieTargetOverride;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.sex = const Value.absent(),
    this.birthYear = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.activity = const Value.absent(),
    this.goal = const Value.absent(),
    this.pacePercent = const Value.absent(),
    this.proteinPerKg = const Value.absent(),
    this.calorieTargetOverride = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required Sex sex,
    required int birthYear,
    required double heightCm,
    required ActivityLevel activity,
    required Goal goal,
    required double pacePercent,
    required double proteinPerKg,
    this.calorieTargetOverride = const Value.absent(),
  }) : sex = Value(sex),
       birthYear = Value(birthYear),
       heightCm = Value(heightCm),
       activity = Value(activity),
       goal = Value(goal),
       pacePercent = Value(pacePercent),
       proteinPerKg = Value(proteinPerKg);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<int>? sex,
    Expression<int>? birthYear,
    Expression<double>? heightCm,
    Expression<int>? activity,
    Expression<int>? goal,
    Expression<double>? pacePercent,
    Expression<double>? proteinPerKg,
    Expression<int>? calorieTargetOverride,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sex != null) 'sex': sex,
      if (birthYear != null) 'birth_year': birthYear,
      if (heightCm != null) 'height_cm': heightCm,
      if (activity != null) 'activity': activity,
      if (goal != null) 'goal': goal,
      if (pacePercent != null) 'pace_percent': pacePercent,
      if (proteinPerKg != null) 'protein_per_kg': proteinPerKg,
      if (calorieTargetOverride != null)
        'calorie_target_override': calorieTargetOverride,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<Sex>? sex,
    Value<int>? birthYear,
    Value<double>? heightCm,
    Value<ActivityLevel>? activity,
    Value<Goal>? goal,
    Value<double>? pacePercent,
    Value<double>? proteinPerKg,
    Value<int?>? calorieTargetOverride,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      sex: sex ?? this.sex,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      activity: activity ?? this.activity,
      goal: goal ?? this.goal,
      pacePercent: pacePercent ?? this.pacePercent,
      proteinPerKg: proteinPerKg ?? this.proteinPerKg,
      calorieTargetOverride:
          calorieTargetOverride ?? this.calorieTargetOverride,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sex.present) {
      map['sex'] = Variable<int>($ProfilesTable.$convertersex.toSql(sex.value));
    }
    if (birthYear.present) {
      map['birth_year'] = Variable<int>(birthYear.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (activity.present) {
      map['activity'] = Variable<int>(
        $ProfilesTable.$converteractivity.toSql(activity.value),
      );
    }
    if (goal.present) {
      map['goal'] = Variable<int>(
        $ProfilesTable.$convertergoal.toSql(goal.value),
      );
    }
    if (pacePercent.present) {
      map['pace_percent'] = Variable<double>(pacePercent.value);
    }
    if (proteinPerKg.present) {
      map['protein_per_kg'] = Variable<double>(proteinPerKg.value);
    }
    if (calorieTargetOverride.present) {
      map['calorie_target_override'] = Variable<int>(
        calorieTargetOverride.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('sex: $sex, ')
          ..write('birthYear: $birthYear, ')
          ..write('heightCm: $heightCm, ')
          ..write('activity: $activity, ')
          ..write('goal: $goal, ')
          ..write('pacePercent: $pacePercent, ')
          ..write('proteinPerKg: $proteinPerKg, ')
          ..write('calorieTargetOverride: $calorieTargetOverride')
          ..write(')'))
        .toString();
  }
}

class $FoodsTable extends Foods with TableInfo<$FoodsTable, Food> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isLiquidMeta = const VerificationMeta(
    'isLiquid',
  );
  @override
  late final GeneratedColumn<bool> isLiquid = GeneratedColumn<bool>(
    'is_liquid',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_liquid" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _servingSizeMeta = const VerificationMeta(
    'servingSize',
  );
  @override
  late final GeneratedColumn<double> servingSize = GeneratedColumn<double>(
    'serving_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FoodSource, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<FoodSource>($FoodsTable.$convertersource);
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<double> kcal = GeneratedColumn<double>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinMeta = const VerificationMeta(
    'protein',
  );
  @override
  late final GeneratedColumn<double> protein = GeneratedColumn<double>(
    'protein',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _carbsMeta = const VerificationMeta('carbs');
  @override
  late final GeneratedColumn<double> carbs = GeneratedColumn<double>(
    'carbs',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sugarMeta = const VerificationMeta('sugar');
  @override
  late final GeneratedColumn<double> sugar = GeneratedColumn<double>(
    'sugar',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiberMeta = const VerificationMeta('fiber');
  @override
  late final GeneratedColumn<double> fiber = GeneratedColumn<double>(
    'fiber',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatMeta = const VerificationMeta('fat');
  @override
  late final GeneratedColumn<double> fat = GeneratedColumn<double>(
    'fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _saturatedFatMeta = const VerificationMeta(
    'saturatedFat',
  );
  @override
  late final GeneratedColumn<double> saturatedFat = GeneratedColumn<double>(
    'saturated_fat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monoUnsaturatedFatMeta =
      const VerificationMeta('monoUnsaturatedFat');
  @override
  late final GeneratedColumn<double> monoUnsaturatedFat =
      GeneratedColumn<double>(
        'mono_unsaturated_fat',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _polyUnsaturatedFatMeta =
      const VerificationMeta('polyUnsaturatedFat');
  @override
  late final GeneratedColumn<double> polyUnsaturatedFat =
      GeneratedColumn<double>(
        'poly_unsaturated_fat',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<double> salt = GeneratedColumn<double>(
    'salt',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    barcode,
    name,
    brand,
    isLiquid,
    servingSize,
    source,
    kcal,
    protein,
    carbs,
    sugar,
    fiber,
    fat,
    saturatedFat,
    monoUnsaturatedFat,
    polyUnsaturatedFat,
    salt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<Food> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('is_liquid')) {
      context.handle(
        _isLiquidMeta,
        isLiquid.isAcceptableOrUnknown(data['is_liquid']!, _isLiquidMeta),
      );
    }
    if (data.containsKey('serving_size')) {
      context.handle(
        _servingSizeMeta,
        servingSize.isAcceptableOrUnknown(
          data['serving_size']!,
          _servingSizeMeta,
        ),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein')) {
      context.handle(
        _proteinMeta,
        protein.isAcceptableOrUnknown(data['protein']!, _proteinMeta),
      );
    }
    if (data.containsKey('carbs')) {
      context.handle(
        _carbsMeta,
        carbs.isAcceptableOrUnknown(data['carbs']!, _carbsMeta),
      );
    }
    if (data.containsKey('sugar')) {
      context.handle(
        _sugarMeta,
        sugar.isAcceptableOrUnknown(data['sugar']!, _sugarMeta),
      );
    }
    if (data.containsKey('fiber')) {
      context.handle(
        _fiberMeta,
        fiber.isAcceptableOrUnknown(data['fiber']!, _fiberMeta),
      );
    }
    if (data.containsKey('fat')) {
      context.handle(
        _fatMeta,
        fat.isAcceptableOrUnknown(data['fat']!, _fatMeta),
      );
    }
    if (data.containsKey('saturated_fat')) {
      context.handle(
        _saturatedFatMeta,
        saturatedFat.isAcceptableOrUnknown(
          data['saturated_fat']!,
          _saturatedFatMeta,
        ),
      );
    }
    if (data.containsKey('mono_unsaturated_fat')) {
      context.handle(
        _monoUnsaturatedFatMeta,
        monoUnsaturatedFat.isAcceptableOrUnknown(
          data['mono_unsaturated_fat']!,
          _monoUnsaturatedFatMeta,
        ),
      );
    }
    if (data.containsKey('poly_unsaturated_fat')) {
      context.handle(
        _polyUnsaturatedFatMeta,
        polyUnsaturatedFat.isAcceptableOrUnknown(
          data['poly_unsaturated_fat']!,
          _polyUnsaturatedFatMeta,
        ),
      );
    }
    if (data.containsKey('salt')) {
      context.handle(
        _saltMeta,
        salt.isAcceptableOrUnknown(data['salt']!, _saltMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Food map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Food(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      isLiquid: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_liquid'],
      )!,
      servingSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}serving_size'],
      ),
      source: $FoodsTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal'],
      ),
      protein: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein'],
      ),
      carbs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs'],
      ),
      sugar: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sugar'],
      ),
      fiber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fiber'],
      ),
      fat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat'],
      ),
      saturatedFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}saturated_fat'],
      ),
      monoUnsaturatedFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mono_unsaturated_fat'],
      ),
      polyUnsaturatedFat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}poly_unsaturated_fat'],
      ),
      salt: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}salt'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FoodsTable createAlias(String alias) {
    return $FoodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FoodSource, int, int> $convertersource =
      const EnumIndexConverter<FoodSource>(FoodSource.values);
}

class Food extends DataClass implements Insertable<Food> {
  final int id;
  final String? barcode;
  final String name;
  final String? brand;
  final bool isLiquid;
  final double? servingSize;
  final FoodSource source;
  final double? kcal;
  final double? protein;
  final double? carbs;
  final double? sugar;
  final double? fiber;
  final double? fat;
  final double? saturatedFat;
  final double? monoUnsaturatedFat;
  final double? polyUnsaturatedFat;
  final double? salt;
  final DateTime updatedAt;
  const Food({
    required this.id,
    this.barcode,
    required this.name,
    this.brand,
    required this.isLiquid,
    this.servingSize,
    required this.source,
    this.kcal,
    this.protein,
    this.carbs,
    this.sugar,
    this.fiber,
    this.fat,
    this.saturatedFat,
    this.monoUnsaturatedFat,
    this.polyUnsaturatedFat,
    this.salt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['is_liquid'] = Variable<bool>(isLiquid);
    if (!nullToAbsent || servingSize != null) {
      map['serving_size'] = Variable<double>(servingSize);
    }
    {
      map['source'] = Variable<int>($FoodsTable.$convertersource.toSql(source));
    }
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<double>(kcal);
    }
    if (!nullToAbsent || protein != null) {
      map['protein'] = Variable<double>(protein);
    }
    if (!nullToAbsent || carbs != null) {
      map['carbs'] = Variable<double>(carbs);
    }
    if (!nullToAbsent || sugar != null) {
      map['sugar'] = Variable<double>(sugar);
    }
    if (!nullToAbsent || fiber != null) {
      map['fiber'] = Variable<double>(fiber);
    }
    if (!nullToAbsent || fat != null) {
      map['fat'] = Variable<double>(fat);
    }
    if (!nullToAbsent || saturatedFat != null) {
      map['saturated_fat'] = Variable<double>(saturatedFat);
    }
    if (!nullToAbsent || monoUnsaturatedFat != null) {
      map['mono_unsaturated_fat'] = Variable<double>(monoUnsaturatedFat);
    }
    if (!nullToAbsent || polyUnsaturatedFat != null) {
      map['poly_unsaturated_fat'] = Variable<double>(polyUnsaturatedFat);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<double>(salt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoodsCompanion toCompanion(bool nullToAbsent) {
    return FoodsCompanion(
      id: Value(id),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      isLiquid: Value(isLiquid),
      servingSize: servingSize == null && nullToAbsent
          ? const Value.absent()
          : Value(servingSize),
      source: Value(source),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      protein: protein == null && nullToAbsent
          ? const Value.absent()
          : Value(protein),
      carbs: carbs == null && nullToAbsent
          ? const Value.absent()
          : Value(carbs),
      sugar: sugar == null && nullToAbsent
          ? const Value.absent()
          : Value(sugar),
      fiber: fiber == null && nullToAbsent
          ? const Value.absent()
          : Value(fiber),
      fat: fat == null && nullToAbsent ? const Value.absent() : Value(fat),
      saturatedFat: saturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(saturatedFat),
      monoUnsaturatedFat: monoUnsaturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(monoUnsaturatedFat),
      polyUnsaturatedFat: polyUnsaturatedFat == null && nullToAbsent
          ? const Value.absent()
          : Value(polyUnsaturatedFat),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Food.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Food(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      isLiquid: serializer.fromJson<bool>(json['isLiquid']),
      servingSize: serializer.fromJson<double?>(json['servingSize']),
      source: $FoodsTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      kcal: serializer.fromJson<double?>(json['kcal']),
      protein: serializer.fromJson<double?>(json['protein']),
      carbs: serializer.fromJson<double?>(json['carbs']),
      sugar: serializer.fromJson<double?>(json['sugar']),
      fiber: serializer.fromJson<double?>(json['fiber']),
      fat: serializer.fromJson<double?>(json['fat']),
      saturatedFat: serializer.fromJson<double?>(json['saturatedFat']),
      monoUnsaturatedFat: serializer.fromJson<double?>(
        json['monoUnsaturatedFat'],
      ),
      polyUnsaturatedFat: serializer.fromJson<double?>(
        json['polyUnsaturatedFat'],
      ),
      salt: serializer.fromJson<double?>(json['salt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String?>(barcode),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'isLiquid': serializer.toJson<bool>(isLiquid),
      'servingSize': serializer.toJson<double?>(servingSize),
      'source': serializer.toJson<int>(
        $FoodsTable.$convertersource.toJson(source),
      ),
      'kcal': serializer.toJson<double?>(kcal),
      'protein': serializer.toJson<double?>(protein),
      'carbs': serializer.toJson<double?>(carbs),
      'sugar': serializer.toJson<double?>(sugar),
      'fiber': serializer.toJson<double?>(fiber),
      'fat': serializer.toJson<double?>(fat),
      'saturatedFat': serializer.toJson<double?>(saturatedFat),
      'monoUnsaturatedFat': serializer.toJson<double?>(monoUnsaturatedFat),
      'polyUnsaturatedFat': serializer.toJson<double?>(polyUnsaturatedFat),
      'salt': serializer.toJson<double?>(salt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Food copyWith({
    int? id,
    Value<String?> barcode = const Value.absent(),
    String? name,
    Value<String?> brand = const Value.absent(),
    bool? isLiquid,
    Value<double?> servingSize = const Value.absent(),
    FoodSource? source,
    Value<double?> kcal = const Value.absent(),
    Value<double?> protein = const Value.absent(),
    Value<double?> carbs = const Value.absent(),
    Value<double?> sugar = const Value.absent(),
    Value<double?> fiber = const Value.absent(),
    Value<double?> fat = const Value.absent(),
    Value<double?> saturatedFat = const Value.absent(),
    Value<double?> monoUnsaturatedFat = const Value.absent(),
    Value<double?> polyUnsaturatedFat = const Value.absent(),
    Value<double?> salt = const Value.absent(),
    DateTime? updatedAt,
  }) => Food(
    id: id ?? this.id,
    barcode: barcode.present ? barcode.value : this.barcode,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    isLiquid: isLiquid ?? this.isLiquid,
    servingSize: servingSize.present ? servingSize.value : this.servingSize,
    source: source ?? this.source,
    kcal: kcal.present ? kcal.value : this.kcal,
    protein: protein.present ? protein.value : this.protein,
    carbs: carbs.present ? carbs.value : this.carbs,
    sugar: sugar.present ? sugar.value : this.sugar,
    fiber: fiber.present ? fiber.value : this.fiber,
    fat: fat.present ? fat.value : this.fat,
    saturatedFat: saturatedFat.present ? saturatedFat.value : this.saturatedFat,
    monoUnsaturatedFat: monoUnsaturatedFat.present
        ? monoUnsaturatedFat.value
        : this.monoUnsaturatedFat,
    polyUnsaturatedFat: polyUnsaturatedFat.present
        ? polyUnsaturatedFat.value
        : this.polyUnsaturatedFat,
    salt: salt.present ? salt.value : this.salt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Food copyWithCompanion(FoodsCompanion data) {
    return Food(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      isLiquid: data.isLiquid.present ? data.isLiquid.value : this.isLiquid,
      servingSize: data.servingSize.present
          ? data.servingSize.value
          : this.servingSize,
      source: data.source.present ? data.source.value : this.source,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      protein: data.protein.present ? data.protein.value : this.protein,
      carbs: data.carbs.present ? data.carbs.value : this.carbs,
      sugar: data.sugar.present ? data.sugar.value : this.sugar,
      fiber: data.fiber.present ? data.fiber.value : this.fiber,
      fat: data.fat.present ? data.fat.value : this.fat,
      saturatedFat: data.saturatedFat.present
          ? data.saturatedFat.value
          : this.saturatedFat,
      monoUnsaturatedFat: data.monoUnsaturatedFat.present
          ? data.monoUnsaturatedFat.value
          : this.monoUnsaturatedFat,
      polyUnsaturatedFat: data.polyUnsaturatedFat.present
          ? data.polyUnsaturatedFat.value
          : this.polyUnsaturatedFat,
      salt: data.salt.present ? data.salt.value : this.salt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Food(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('isLiquid: $isLiquid, ')
          ..write('servingSize: $servingSize, ')
          ..write('source: $source, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('fat: $fat, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('monoUnsaturatedFat: $monoUnsaturatedFat, ')
          ..write('polyUnsaturatedFat: $polyUnsaturatedFat, ')
          ..write('salt: $salt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    barcode,
    name,
    brand,
    isLiquid,
    servingSize,
    source,
    kcal,
    protein,
    carbs,
    sugar,
    fiber,
    fat,
    saturatedFat,
    monoUnsaturatedFat,
    polyUnsaturatedFat,
    salt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Food &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.isLiquid == this.isLiquid &&
          other.servingSize == this.servingSize &&
          other.source == this.source &&
          other.kcal == this.kcal &&
          other.protein == this.protein &&
          other.carbs == this.carbs &&
          other.sugar == this.sugar &&
          other.fiber == this.fiber &&
          other.fat == this.fat &&
          other.saturatedFat == this.saturatedFat &&
          other.monoUnsaturatedFat == this.monoUnsaturatedFat &&
          other.polyUnsaturatedFat == this.polyUnsaturatedFat &&
          other.salt == this.salt &&
          other.updatedAt == this.updatedAt);
}

class FoodsCompanion extends UpdateCompanion<Food> {
  final Value<int> id;
  final Value<String?> barcode;
  final Value<String> name;
  final Value<String?> brand;
  final Value<bool> isLiquid;
  final Value<double?> servingSize;
  final Value<FoodSource> source;
  final Value<double?> kcal;
  final Value<double?> protein;
  final Value<double?> carbs;
  final Value<double?> sugar;
  final Value<double?> fiber;
  final Value<double?> fat;
  final Value<double?> saturatedFat;
  final Value<double?> monoUnsaturatedFat;
  final Value<double?> polyUnsaturatedFat;
  final Value<double?> salt;
  final Value<DateTime> updatedAt;
  const FoodsCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.isLiquid = const Value.absent(),
    this.servingSize = const Value.absent(),
    this.source = const Value.absent(),
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.fat = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.monoUnsaturatedFat = const Value.absent(),
    this.polyUnsaturatedFat = const Value.absent(),
    this.salt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  FoodsCompanion.insert({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.isLiquid = const Value.absent(),
    this.servingSize = const Value.absent(),
    required FoodSource source,
    this.kcal = const Value.absent(),
    this.protein = const Value.absent(),
    this.carbs = const Value.absent(),
    this.sugar = const Value.absent(),
    this.fiber = const Value.absent(),
    this.fat = const Value.absent(),
    this.saturatedFat = const Value.absent(),
    this.monoUnsaturatedFat = const Value.absent(),
    this.polyUnsaturatedFat = const Value.absent(),
    this.salt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name),
       source = Value(source);
  static Insertable<Food> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<bool>? isLiquid,
    Expression<double>? servingSize,
    Expression<int>? source,
    Expression<double>? kcal,
    Expression<double>? protein,
    Expression<double>? carbs,
    Expression<double>? sugar,
    Expression<double>? fiber,
    Expression<double>? fat,
    Expression<double>? saturatedFat,
    Expression<double>? monoUnsaturatedFat,
    Expression<double>? polyUnsaturatedFat,
    Expression<double>? salt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (isLiquid != null) 'is_liquid': isLiquid,
      if (servingSize != null) 'serving_size': servingSize,
      if (source != null) 'source': source,
      if (kcal != null) 'kcal': kcal,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (sugar != null) 'sugar': sugar,
      if (fiber != null) 'fiber': fiber,
      if (fat != null) 'fat': fat,
      if (saturatedFat != null) 'saturated_fat': saturatedFat,
      if (monoUnsaturatedFat != null)
        'mono_unsaturated_fat': monoUnsaturatedFat,
      if (polyUnsaturatedFat != null)
        'poly_unsaturated_fat': polyUnsaturatedFat,
      if (salt != null) 'salt': salt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  FoodsCompanion copyWith({
    Value<int>? id,
    Value<String?>? barcode,
    Value<String>? name,
    Value<String?>? brand,
    Value<bool>? isLiquid,
    Value<double?>? servingSize,
    Value<FoodSource>? source,
    Value<double?>? kcal,
    Value<double?>? protein,
    Value<double?>? carbs,
    Value<double?>? sugar,
    Value<double?>? fiber,
    Value<double?>? fat,
    Value<double?>? saturatedFat,
    Value<double?>? monoUnsaturatedFat,
    Value<double?>? polyUnsaturatedFat,
    Value<double?>? salt,
    Value<DateTime>? updatedAt,
  }) {
    return FoodsCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      isLiquid: isLiquid ?? this.isLiquid,
      servingSize: servingSize ?? this.servingSize,
      source: source ?? this.source,
      kcal: kcal ?? this.kcal,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      sugar: sugar ?? this.sugar,
      fiber: fiber ?? this.fiber,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      monoUnsaturatedFat: monoUnsaturatedFat ?? this.monoUnsaturatedFat,
      polyUnsaturatedFat: polyUnsaturatedFat ?? this.polyUnsaturatedFat,
      salt: salt ?? this.salt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (isLiquid.present) {
      map['is_liquid'] = Variable<bool>(isLiquid.value);
    }
    if (servingSize.present) {
      map['serving_size'] = Variable<double>(servingSize.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $FoodsTable.$convertersource.toSql(source.value),
      );
    }
    if (kcal.present) {
      map['kcal'] = Variable<double>(kcal.value);
    }
    if (protein.present) {
      map['protein'] = Variable<double>(protein.value);
    }
    if (carbs.present) {
      map['carbs'] = Variable<double>(carbs.value);
    }
    if (sugar.present) {
      map['sugar'] = Variable<double>(sugar.value);
    }
    if (fiber.present) {
      map['fiber'] = Variable<double>(fiber.value);
    }
    if (fat.present) {
      map['fat'] = Variable<double>(fat.value);
    }
    if (saturatedFat.present) {
      map['saturated_fat'] = Variable<double>(saturatedFat.value);
    }
    if (monoUnsaturatedFat.present) {
      map['mono_unsaturated_fat'] = Variable<double>(monoUnsaturatedFat.value);
    }
    if (polyUnsaturatedFat.present) {
      map['poly_unsaturated_fat'] = Variable<double>(polyUnsaturatedFat.value);
    }
    if (salt.present) {
      map['salt'] = Variable<double>(salt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoodsCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('isLiquid: $isLiquid, ')
          ..write('servingSize: $servingSize, ')
          ..write('source: $source, ')
          ..write('kcal: $kcal, ')
          ..write('protein: $protein, ')
          ..write('carbs: $carbs, ')
          ..write('sugar: $sugar, ')
          ..write('fiber: $fiber, ')
          ..write('fat: $fat, ')
          ..write('saturatedFat: $saturatedFat, ')
          ..write('monoUnsaturatedFat: $monoUnsaturatedFat, ')
          ..write('polyUnsaturatedFat: $polyUnsaturatedFat, ')
          ..write('salt: $salt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, DiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Meal, int> meal =
      GeneratedColumn<int>(
        'meal',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<Meal>($DiaryEntriesTable.$convertermeal);
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<int> foodId = GeneratedColumn<int>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES foods (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    meal,
    foodId,
    amount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      meal: $DiaryEntriesTable.$convertermeal.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}meal'],
        )!,
      ),
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}food_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Meal, int, int> $convertermeal =
      const EnumIndexConverter<Meal>(Meal.values);
}

class DiaryEntry extends DataClass implements Insertable<DiaryEntry> {
  final int id;

  /// Kalendertag „2026-10-14“.
  final String day;
  final Meal meal;
  final int foodId;

  /// Gramm bzw. Milliliter.
  final double amount;
  final DateTime createdAt;
  const DiaryEntry({
    required this.id,
    required this.day,
    required this.meal,
    required this.foodId,
    required this.amount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['day'] = Variable<String>(day);
    {
      map['meal'] = Variable<int>(
        $DiaryEntriesTable.$convertermeal.toSql(meal),
      );
    }
    map['food_id'] = Variable<int>(foodId);
    map['amount'] = Variable<double>(amount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      day: Value(day),
      meal: Value(meal),
      foodId: Value(foodId),
      amount: Value(amount),
      createdAt: Value(createdAt),
    );
  }

  factory DiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiaryEntry(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<String>(json['day']),
      meal: $DiaryEntriesTable.$convertermeal.fromJson(
        serializer.fromJson<int>(json['meal']),
      ),
      foodId: serializer.fromJson<int>(json['foodId']),
      amount: serializer.fromJson<double>(json['amount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<String>(day),
      'meal': serializer.toJson<int>(
        $DiaryEntriesTable.$convertermeal.toJson(meal),
      ),
      'foodId': serializer.toJson<int>(foodId),
      'amount': serializer.toJson<double>(amount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DiaryEntry copyWith({
    int? id,
    String? day,
    Meal? meal,
    int? foodId,
    double? amount,
    DateTime? createdAt,
  }) => DiaryEntry(
    id: id ?? this.id,
    day: day ?? this.day,
    meal: meal ?? this.meal,
    foodId: foodId ?? this.foodId,
    amount: amount ?? this.amount,
    createdAt: createdAt ?? this.createdAt,
  );
  DiaryEntry copyWithCompanion(DiaryEntriesCompanion data) {
    return DiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      meal: data.meal.present ? data.meal.value : this.meal,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      amount: data.amount.present ? data.amount.value : this.amount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntry(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, day, meal, foodId, amount, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiaryEntry &&
          other.id == this.id &&
          other.day == this.day &&
          other.meal == this.meal &&
          other.foodId == this.foodId &&
          other.amount == this.amount &&
          other.createdAt == this.createdAt);
}

class DiaryEntriesCompanion extends UpdateCompanion<DiaryEntry> {
  final Value<int> id;
  final Value<String> day;
  final Value<Meal> meal;
  final Value<int> foodId;
  final Value<double> amount;
  final Value<DateTime> createdAt;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.meal = const Value.absent(),
    this.foodId = const Value.absent(),
    this.amount = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String day,
    required Meal meal,
    required int foodId,
    required double amount,
    this.createdAt = const Value.absent(),
  }) : day = Value(day),
       meal = Value(meal),
       foodId = Value(foodId),
       amount = Value(amount);
  static Insertable<DiaryEntry> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<int>? meal,
    Expression<int>? foodId,
    Expression<double>? amount,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (meal != null) 'meal': meal,
      if (foodId != null) 'food_id': foodId,
      if (amount != null) 'amount': amount,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? day,
    Value<Meal>? meal,
    Value<int>? foodId,
    Value<double>? amount,
    Value<DateTime>? createdAt,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      meal: meal ?? this.meal,
      foodId: foodId ?? this.foodId,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (meal.present) {
      map['meal'] = Variable<int>(
        $DiaryEntriesTable.$convertermeal.toSql(meal.value),
      );
    }
    if (foodId.present) {
      map['food_id'] = Variable<int>(foodId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('meal: $meal, ')
          ..write('foodId: $foodId, ')
          ..write('amount: $amount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CompletedDaysTable extends CompletedDays
    with TableInfo<$CompletedDaysTable, CompletedDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletedDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completed_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletedDay> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  CompletedDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletedDay(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
    );
  }

  @override
  $CompletedDaysTable createAlias(String alias) {
    return $CompletedDaysTable(attachedDatabase, alias);
  }
}

class CompletedDay extends DataClass implements Insertable<CompletedDay> {
  final String day;
  const CompletedDay({required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    return map;
  }

  CompletedDaysCompanion toCompanion(bool nullToAbsent) {
    return CompletedDaysCompanion(day: Value(day));
  }

  factory CompletedDay.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletedDay(day: serializer.fromJson<String>(json['day']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'day': serializer.toJson<String>(day)};
  }

  CompletedDay copyWith({String? day}) => CompletedDay(day: day ?? this.day);
  CompletedDay copyWithCompanion(CompletedDaysCompanion data) {
    return CompletedDay(day: data.day.present ? data.day.value : this.day);
  }

  @override
  String toString() {
    return (StringBuffer('CompletedDay(')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => day.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletedDay && other.day == this.day);
}

class CompletedDaysCompanion extends UpdateCompanion<CompletedDay> {
  final Value<String> day;
  final Value<int> rowid;
  const CompletedDaysCompanion({
    this.day = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletedDaysCompanion.insert({
    required String day,
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<CompletedDay> custom({
    Expression<String>? day,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletedDaysCompanion copyWith({Value<String>? day, Value<int>? rowid}) {
    return CompletedDaysCompanion(
      day: day ?? this.day,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletedDaysCompanion(')
          ..write('day: $day, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, WeightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
    'kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [day, kg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeightEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  WeightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightEntry(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      kg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kg'],
      )!,
    );
  }

  @override
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class WeightEntry extends DataClass implements Insertable<WeightEntry> {
  final String day;
  final double kg;
  const WeightEntry({required this.day, required this.kg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<String>(day);
    map['kg'] = Variable<double>(kg);
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(day: Value(day), kg: Value(kg));
  }

  factory WeightEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightEntry(
      day: serializer.fromJson<String>(json['day']),
      kg: serializer.fromJson<double>(json['kg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<String>(day),
      'kg': serializer.toJson<double>(kg),
    };
  }

  WeightEntry copyWith({String? day, double? kg}) =>
      WeightEntry(day: day ?? this.day, kg: kg ?? this.kg);
  WeightEntry copyWithCompanion(WeightEntriesCompanion data) {
    return WeightEntry(
      day: data.day.present ? data.day.value : this.day,
      kg: data.kg.present ? data.kg.value : this.kg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntry(')
          ..write('day: $day, ')
          ..write('kg: $kg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, kg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightEntry && other.day == this.day && other.kg == this.kg);
}

class WeightEntriesCompanion extends UpdateCompanion<WeightEntry> {
  final Value<String> day;
  final Value<double> kg;
  final Value<int> rowid;
  const WeightEntriesCompanion({
    this.day = const Value.absent(),
    this.kg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    required String day,
    required double kg,
    this.rowid = const Value.absent(),
  }) : day = Value(day),
       kg = Value(kg);
  static Insertable<WeightEntry> custom({
    Expression<String>? day,
    Expression<double>? kg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (kg != null) 'kg': kg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEntriesCompanion copyWith({
    Value<String>? day,
    Value<double>? kg,
    Value<int>? rowid,
  }) {
    return WeightEntriesCompanion(
      day: day ?? this.day,
      kg: kg ?? this.kg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('day: $day, ')
          ..write('kg: $kg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $FoodsTable foods = $FoodsTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $CompletedDaysTable completedDays = $CompletedDaysTable(this);
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    foods,
    diaryEntries,
    completedDays,
    weightEntries,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required Sex sex,
  required int birthYear,
  required double heightCm,
  required ActivityLevel activity,
  required Goal goal,
  required double pacePercent,
  required double proteinPerKg,
  Value<int?> calorieTargetOverride,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<Sex> sex,
  Value<int> birthYear,
  Value<double> heightCm,
  Value<ActivityLevel> activity,
  Value<Goal> goal,
  Value<double> pacePercent,
  Value<double> proteinPerKg,
  Value<int?> calorieTargetOverride,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Sex, Sex, int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActivityLevel, ActivityLevel, int>
  get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Goal, Goal, int> get goal =>
      $composableBuilder(
        column: $table.goal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get pacePercent => $composableBuilder(
    column: $table.pacePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPerKg => $composableBuilder(
    column: $table.proteinPerKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calorieTargetOverride => $composableBuilder(
    column: $table.calorieTargetOverride,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sex => $composableBuilder(
    column: $table.sex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthYear => $composableBuilder(
    column: $table.birthYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activity => $composableBuilder(
    column: $table.activity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pacePercent => $composableBuilder(
    column: $table.pacePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPerKg => $composableBuilder(
    column: $table.proteinPerKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calorieTargetOverride => $composableBuilder(
    column: $table.calorieTargetOverride,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Sex, int> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<int> get birthYear =>
      $composableBuilder(column: $table.birthYear, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActivityLevel, int> get activity =>
      $composableBuilder(column: $table.activity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Goal, int> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<double> get pacePercent => $composableBuilder(
    column: $table.pacePercent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPerKg => $composableBuilder(
    column: $table.proteinPerKg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calorieTargetOverride => $composableBuilder(
    column: $table.calorieTargetOverride,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<Sex> sex = const Value.absent(),
                Value<int> birthYear = const Value.absent(),
                Value<double> heightCm = const Value.absent(),
                Value<ActivityLevel> activity = const Value.absent(),
                Value<Goal> goal = const Value.absent(),
                Value<double> pacePercent = const Value.absent(),
                Value<double> proteinPerKg = const Value.absent(),
                Value<int?> calorieTargetOverride = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                activity: activity,
                goal: goal,
                pacePercent: pacePercent,
                proteinPerKg: proteinPerKg,
                calorieTargetOverride: calorieTargetOverride,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required Sex sex,
                required int birthYear,
                required double heightCm,
                required ActivityLevel activity,
                required Goal goal,
                required double pacePercent,
                required double proteinPerKg,
                Value<int?> calorieTargetOverride = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                sex: sex,
                birthYear: birthYear,
                heightCm: heightCm,
                activity: activity,
                goal: goal,
                pacePercent: pacePercent,
                proteinPerKg: proteinPerKg,
                calorieTargetOverride: calorieTargetOverride,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, Profile>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, Profile>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$FoodsTableCreateCompanionBuilder = FoodsCompanion Function({
  Value<int> id,
  Value<String?> barcode,
  required String name,
  Value<String?> brand,
  Value<bool> isLiquid,
  Value<double?> servingSize,
  required FoodSource source,
  Value<double?> kcal,
  Value<double?> protein,
  Value<double?> carbs,
  Value<double?> sugar,
  Value<double?> fiber,
  Value<double?> fat,
  Value<double?> saturatedFat,
  Value<double?> monoUnsaturatedFat,
  Value<double?> polyUnsaturatedFat,
  Value<double?> salt,
  Value<DateTime> updatedAt,
});
typedef $$FoodsTableUpdateCompanionBuilder = FoodsCompanion Function({
  Value<int> id,
  Value<String?> barcode,
  Value<String> name,
  Value<String?> brand,
  Value<bool> isLiquid,
  Value<double?> servingSize,
  Value<FoodSource> source,
  Value<double?> kcal,
  Value<double?> protein,
  Value<double?> carbs,
  Value<double?> sugar,
  Value<double?> fiber,
  Value<double?> fat,
  Value<double?> saturatedFat,
  Value<double?> monoUnsaturatedFat,
  Value<double?> polyUnsaturatedFat,
  Value<double?> salt,
  Value<DateTime> updatedAt,
});

final class $$FoodsTableReferences
    extends BaseReferences<_$AppDatabase, $FoodsTable, Food> {
  $$FoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DiaryEntriesTable, List<DiaryEntry>>
  _diaryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.diaryEntries,
    aliasName: 'foods__id__diary_entries__food_id',
  );

  $$DiaryEntriesTableProcessedTableManager get diaryEntriesRefs {
    final manager = $$DiaryEntriesTableTableManager(
      $_db,
      $_db.diaryEntries,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_diaryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoodsTableFilterComposer extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLiquid => $composableBuilder(
    column: $table.isLiquid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FoodSource, FoodSource, int> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monoUnsaturatedFat => $composableBuilder(
    column: $table.monoUnsaturatedFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get polyUnsaturatedFat => $composableBuilder(
    column: $table.polyUnsaturatedFat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> diaryEntriesRefs(
    Expression<bool> Function($$DiaryEntriesTableFilterComposer f) f,
  ) {
    final $$DiaryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableOrderingComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLiquid => $composableBuilder(
    column: $table.isLiquid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get protein => $composableBuilder(
    column: $table.protein,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbs => $composableBuilder(
    column: $table.carbs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sugar => $composableBuilder(
    column: $table.sugar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fiber => $composableBuilder(
    column: $table.fiber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fat => $composableBuilder(
    column: $table.fat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monoUnsaturatedFat => $composableBuilder(
    column: $table.monoUnsaturatedFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get polyUnsaturatedFat => $composableBuilder(
    column: $table.polyUnsaturatedFat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salt => $composableBuilder(
    column: $table.salt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoodsTable> {
  $$FoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<bool> get isLiquid =>
      $composableBuilder(column: $table.isLiquid, builder: (column) => column);

  GeneratedColumn<double> get servingSize => $composableBuilder(
    column: $table.servingSize,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FoodSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<double> get protein =>
      $composableBuilder(column: $table.protein, builder: (column) => column);

  GeneratedColumn<double> get carbs =>
      $composableBuilder(column: $table.carbs, builder: (column) => column);

  GeneratedColumn<double> get sugar =>
      $composableBuilder(column: $table.sugar, builder: (column) => column);

  GeneratedColumn<double> get fiber =>
      $composableBuilder(column: $table.fiber, builder: (column) => column);

  GeneratedColumn<double> get fat =>
      $composableBuilder(column: $table.fat, builder: (column) => column);

  GeneratedColumn<double> get saturatedFat => $composableBuilder(
    column: $table.saturatedFat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monoUnsaturatedFat => $composableBuilder(
    column: $table.monoUnsaturatedFat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get polyUnsaturatedFat => $composableBuilder(
    column: $table.polyUnsaturatedFat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> diaryEntriesRefs<T extends Object>(
    Expression<T> Function($$DiaryEntriesTableAnnotationComposer a) f,
  ) {
    final $$DiaryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.diaryEntries,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DiaryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.diaryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoodsTable,
          Food,
          $$FoodsTableFilterComposer,
          $$FoodsTableOrderingComposer,
          $$FoodsTableAnnotationComposer,
          $$FoodsTableCreateCompanionBuilder,
          $$FoodsTableUpdateCompanionBuilder,
          (Food, $$FoodsTableReferences),
          Food,
          PrefetchHooks Function({bool diaryEntriesRefs})
        > {
  $$FoodsTableTableManager(_$AppDatabase db, $FoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<bool> isLiquid = const Value.absent(),
                Value<double?> servingSize = const Value.absent(),
                Value<FoodSource> source = const Value.absent(),
                Value<double?> kcal = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugar = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> saturatedFat = const Value.absent(),
                Value<double?> monoUnsaturatedFat = const Value.absent(),
                Value<double?> polyUnsaturatedFat = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FoodsCompanion(
                id: id,
                barcode: barcode,
                name: name,
                brand: brand,
                isLiquid: isLiquid,
                servingSize: servingSize,
                source: source,
                kcal: kcal,
                protein: protein,
                carbs: carbs,
                sugar: sugar,
                fiber: fiber,
                fat: fat,
                saturatedFat: saturatedFat,
                monoUnsaturatedFat: monoUnsaturatedFat,
                polyUnsaturatedFat: polyUnsaturatedFat,
                salt: salt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String name,
                Value<String?> brand = const Value.absent(),
                Value<bool> isLiquid = const Value.absent(),
                Value<double?> servingSize = const Value.absent(),
                required FoodSource source,
                Value<double?> kcal = const Value.absent(),
                Value<double?> protein = const Value.absent(),
                Value<double?> carbs = const Value.absent(),
                Value<double?> sugar = const Value.absent(),
                Value<double?> fiber = const Value.absent(),
                Value<double?> fat = const Value.absent(),
                Value<double?> saturatedFat = const Value.absent(),
                Value<double?> monoUnsaturatedFat = const Value.absent(),
                Value<double?> polyUnsaturatedFat = const Value.absent(),
                Value<double?> salt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => FoodsCompanion.insert(
                id: id,
                barcode: barcode,
                name: name,
                brand: brand,
                isLiquid: isLiquid,
                servingSize: servingSize,
                source: source,
                kcal: kcal,
                protein: protein,
                carbs: carbs,
                sugar: sugar,
                fiber: fiber,
                fat: fat,
                saturatedFat: saturatedFat,
                monoUnsaturatedFat: monoUnsaturatedFat,
                polyUnsaturatedFat: polyUnsaturatedFat,
                salt: salt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoodsTable, Food>(table),
                  $$FoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({diaryEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (diaryEntriesRefs) db.diaryEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (diaryEntriesRefs)
                    await $_getPrefetchedData<Food, $FoodsTable, DiaryEntry>(
                      currentTable: table,
                      referencedTable: $$FoodsTableReferences
                          ._diaryEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$FoodsTableReferences(
                        db,
                        table,
                        p0,
                      ).diaryEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.foodId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoodsTable,
      Food,
      $$FoodsTableFilterComposer,
      $$FoodsTableOrderingComposer,
      $$FoodsTableAnnotationComposer,
      $$FoodsTableCreateCompanionBuilder,
      $$FoodsTableUpdateCompanionBuilder,
      (Food, $$FoodsTableReferences),
      Food,
      PrefetchHooks Function({bool diaryEntriesRefs})
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      required String day,
      required Meal meal,
      required int foodId,
      required double amount,
      Value<DateTime> createdAt,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<int> id,
      Value<String> day,
      Value<Meal> meal,
      Value<int> foodId,
      Value<double> amount,
      Value<DateTime> createdAt,
    });

final class $$DiaryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $DiaryEntriesTable, DiaryEntry> {
  $$DiaryEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoodsTable _foodIdTable(_$AppDatabase db) =>
      db.foods.createAlias('diary_entries__food_id__foods__id');

  $$FoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<int>('food_id')!;

    final manager = $$FoodsTableTableManager(
      $_db,
      $_db.foods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Meal, Meal, int> get meal =>
      $composableBuilder(
        column: $table.meal,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoodsTableFilterComposer get foodId {
    final $$FoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableFilterComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get meal => $composableBuilder(
    column: $table.meal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoodsTableOrderingComposer get foodId {
    final $$FoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableOrderingComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Meal, int> get meal =>
      $composableBuilder(column: $table.meal, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FoodsTableAnnotationComposer get foodId {
    final $$FoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.foods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.foods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiaryEntriesTable,
          DiaryEntry,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (DiaryEntry, $$DiaryEntriesTableReferences),
          DiaryEntry,
          PrefetchHooks Function({bool foodId})
        > {
  $$DiaryEntriesTableTableManager(_$AppDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<Meal> meal = const Value.absent(),
                Value<int> foodId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                day: day,
                meal: meal,
                foodId: foodId,
                amount: amount,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String day,
                required Meal meal,
                required int foodId,
                required double amount,
                Value<DateTime> createdAt = const Value.absent(),
              }) => DiaryEntriesCompanion.insert(
                id: id,
                day: day,
                meal: meal,
                foodId: foodId,
                amount: amount,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiaryEntriesTable, DiaryEntry>(table),
                  $$DiaryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (foodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.foodId,
                        referencedTable: $$DiaryEntriesTableReferences
                            ._foodIdTable(db),
                        referencedColumn: $$DiaryEntriesTableReferences
                            ._foodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiaryEntriesTable,
      DiaryEntry,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (DiaryEntry, $$DiaryEntriesTableReferences),
      DiaryEntry,
      PrefetchHooks Function({bool foodId})
    >;
typedef $$CompletedDaysTableCreateCompanionBuilder =
    CompletedDaysCompanion Function({required String day, Value<int> rowid});
typedef $$CompletedDaysTableUpdateCompanionBuilder =
    CompletedDaysCompanion Function({Value<String> day, Value<int> rowid});

class $$CompletedDaysTableFilterComposer
    extends Composer<_$AppDatabase, $CompletedDaysTable> {
  $$CompletedDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletedDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletedDaysTable> {
  $$CompletedDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletedDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletedDaysTable> {
  $$CompletedDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);
}

class $$CompletedDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletedDaysTable,
          CompletedDay,
          $$CompletedDaysTableFilterComposer,
          $$CompletedDaysTableOrderingComposer,
          $$CompletedDaysTableAnnotationComposer,
          $$CompletedDaysTableCreateCompanionBuilder,
          $$CompletedDaysTableUpdateCompanionBuilder,
          (
            CompletedDay,
            BaseReferences<_$AppDatabase, $CompletedDaysTable, CompletedDay>,
          ),
          CompletedDay,
          PrefetchHooks Function()
        > {
  $$CompletedDaysTableTableManager(_$AppDatabase db, $CompletedDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletedDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletedDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletedDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => CompletedDaysCompanion(day: day, rowid: rowid),
          createCompanionCallback: ({
            required String day,
            Value<int> rowid = const Value.absent(),
          }) => CompletedDaysCompanion.insert(day: day, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletedDaysTable, CompletedDay>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletedDaysTable,
                    CompletedDay
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletedDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletedDaysTable,
      CompletedDay,
      $$CompletedDaysTableFilterComposer,
      $$CompletedDaysTableOrderingComposer,
      $$CompletedDaysTableAnnotationComposer,
      $$CompletedDaysTableCreateCompanionBuilder,
      $$CompletedDaysTableUpdateCompanionBuilder,
      (
        CompletedDay,
        BaseReferences<_$AppDatabase, $CompletedDaysTable, CompletedDay>,
      ),
      CompletedDay,
      PrefetchHooks Function()
    >;
typedef $$WeightEntriesTableCreateCompanionBuilder =
    WeightEntriesCompanion Function({
      required String day,
      required double kg,
      Value<int> rowid,
    });
typedef $$WeightEntriesTableUpdateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<String> day,
      Value<double> kg,
      Value<int> rowid,
    });

class $$WeightEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kg => $composableBuilder(
    column: $table.kg,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);
}

class $$WeightEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeightEntriesTable,
          WeightEntry,
          $$WeightEntriesTableFilterComposer,
          $$WeightEntriesTableOrderingComposer,
          $$WeightEntriesTableAnnotationComposer,
          $$WeightEntriesTableCreateCompanionBuilder,
          $$WeightEntriesTableUpdateCompanionBuilder,
          (
            WeightEntry,
            BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntry>,
          ),
          WeightEntry,
          PrefetchHooks Function()
        > {
  $$WeightEntriesTableTableManager(_$AppDatabase db, $WeightEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> day = const Value.absent(),
            Value<double> kg = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => WeightEntriesCompanion(day: day, kg: kg, rowid: rowid),
          createCompanionCallback: ({
            required String day,
            required double kg,
            Value<int> rowid = const Value.absent(),
          }) => WeightEntriesCompanion.insert(day: day, kg: kg, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WeightEntriesTable, WeightEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $WeightEntriesTable,
                    WeightEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeightEntriesTable,
      WeightEntry,
      $$WeightEntriesTableFilterComposer,
      $$WeightEntriesTableOrderingComposer,
      $$WeightEntriesTableAnnotationComposer,
      $$WeightEntriesTableCreateCompanionBuilder,
      $$WeightEntriesTableUpdateCompanionBuilder,
      (
        WeightEntry,
        BaseReferences<_$AppDatabase, $WeightEntriesTable, WeightEntry>,
      ),
      WeightEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db, _db.foods);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$CompletedDaysTableTableManager get completedDays =>
      $$CompletedDaysTableTableManager(_db, _db.completedDays);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
}
