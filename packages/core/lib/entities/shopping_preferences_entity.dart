import 'package:equatable/equatable.dart';

/// ملف التسوق الشخصي — التفضيلات اللي بتستخدمها محركات
/// التوصية والتخصيص (الفئات المفضلة، الميزانية، الألوان،
/// الكلمات المفتاحية للأسلوب، ومستوى الجودة).
class ShoppingPreferencesEntity extends Equatable {
  final String uid;
  final List<String> preferredCategoryIds;
  final List<String> preferredColors;
  final double? budgetMin;
  final double? budgetMax;

  /// كلمات بتوصف أسلوب المستخدم (مثال: "modern", "minimalist", "bohemian").
  final List<String> styleKeywords;

  /// 'value' | 'balanced' | 'premium' — بتأثر في ترجيح السعر مقابل الجودة.
  final String qualityPreference;
  final DateTime updatedAt;

  const ShoppingPreferencesEntity({
    required this.uid,
    this.preferredCategoryIds = const [],
    this.preferredColors = const [],
    this.budgetMin,
    this.budgetMax,
    this.styleKeywords = const [],
    this.qualityPreference = 'balanced',
    required this.updatedAt,
  });

  bool get hasPreferences =>
      preferredCategoryIds.isNotEmpty ||
      preferredColors.isNotEmpty ||
      styleKeywords.isNotEmpty ||
      budgetMin != null ||
      budgetMax != null;

  /// جودة السعر اللي يفضلها المستخدم كوزن رقمي:
  /// value = بيهتم بالسعر أكتر، premium = بيهتم بالجودة أكتر.
  double get priceWeight =>
      qualityPreference == 'value' ? 0.35 : (qualityPreference == 'premium' ? 0.15 : 0.25);

  double get qualityWeight => 1 - priceWeight;

  factory ShoppingPreferencesEntity.fromJson(
    String uid,
    Map<String, dynamic> json,
  ) {
    return ShoppingPreferencesEntity(
      uid: uid,
      preferredCategoryIds:
          (json['preferredCategoryIds'] as List? ?? const []).cast<String>(),
      preferredColors:
          (json['preferredColors'] as List? ?? const []).cast<String>(),
      budgetMin: (json['budgetMin'] as num?)?.toDouble(),
      budgetMax: (json['budgetMax'] as num?)?.toDouble(),
      styleKeywords: (json['styleKeywords'] as List? ?? const []).cast<String>(),
      qualityPreference: json['qualityPreference'] as String? ?? 'balanced',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'preferredCategoryIds': preferredCategoryIds,
        'preferredColors': preferredColors,
        'budgetMin': budgetMin,
        'budgetMax': budgetMax,
        'styleKeywords': styleKeywords,
        'qualityPreference': qualityPreference,
        'updatedAt': updatedAt.toIso8601String(),
      };

  ShoppingPreferencesEntity copyWith({
    List<String>? preferredCategoryIds,
    List<String>? preferredColors,
    double? budgetMin,
    double? budgetMax,
    bool clearBudget = false,
    List<String>? styleKeywords,
    String? qualityPreference,
    DateTime? updatedAt,
  }) {
    return ShoppingPreferencesEntity(
      uid: uid,
      preferredCategoryIds: preferredCategoryIds ?? this.preferredCategoryIds,
      preferredColors: preferredColors ?? this.preferredColors,
      budgetMin: clearBudget ? null : (budgetMin ?? this.budgetMin),
      budgetMax: clearBudget ? null : (budgetMax ?? this.budgetMax),
      styleKeywords: styleKeywords ?? this.styleKeywords,
      qualityPreference: qualityPreference ?? this.qualityPreference,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        preferredCategoryIds,
        preferredColors,
        budgetMin,
        budgetMax,
        styleKeywords,
        qualityPreference,
        updatedAt,
      ];
}

/// إعدادات الخصوصية والتخصيص — بيقرر المستخدم إيه اللي
/// يتجمّع عنه وإيه اللي يتستخدم في التوصية الشخصية.
class PrivacySettingsEntity extends Equatable {
  final String uid;

  /// لو false: التوصيات بتتحول للنظام العام (الأعلى تقييمًا)
  /// ومفيش استخدام للإشارات الشخصية خالص.
  final bool personalizationEnabled;

  /// لو false: مش بنسجّل نشاط المستخدم (بحث/مشاهدة/مقارنة) خالص.
  final bool activityTrackingEnabled;

  /// لو false: إحصائيات الاستخدام التجميعية مش بتتبعت.
  final bool analyticsSharingEnabled;
  final DateTime updatedAt;

  const PrivacySettingsEntity({
    required this.uid,
    this.personalizationEnabled = true,
    this.activityTrackingEnabled = true,
    this.analyticsSharingEnabled = true,
    required this.updatedAt,
  });

  factory PrivacySettingsEntity.fromJson(
    String uid,
    Map<String, dynamic> json,
  ) {
    return PrivacySettingsEntity(
      uid: uid,
      personalizationEnabled: json['personalizationEnabled'] as bool? ?? true,
      activityTrackingEnabled: json['activityTrackingEnabled'] as bool? ?? true,
      analyticsSharingEnabled: json['analyticsSharingEnabled'] as bool? ?? true,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'personalizationEnabled': personalizationEnabled,
        'activityTrackingEnabled': activityTrackingEnabled,
        'analyticsSharingEnabled': analyticsSharingEnabled,
        'updatedAt': updatedAt.toIso8601String(),
      };

  PrivacySettingsEntity copyWith({
    bool? personalizationEnabled,
    bool? activityTrackingEnabled,
    bool? analyticsSharingEnabled,
    DateTime? updatedAt,
  }) {
    return PrivacySettingsEntity(
      uid: uid,
      personalizationEnabled: personalizationEnabled ?? this.personalizationEnabled,
      activityTrackingEnabled:
          activityTrackingEnabled ?? this.activityTrackingEnabled,
      analyticsSharingEnabled:
          analyticsSharingEnabled ?? this.analyticsSharingEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        personalizationEnabled,
        activityTrackingEnabled,
        analyticsSharingEnabled,
        updatedAt,
      ];
}
