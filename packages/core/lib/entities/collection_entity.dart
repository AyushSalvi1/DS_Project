import 'package:equatable/equatable.dart';

/// مجموعة منتجات (Collection) — بتتبنى بـ"AI setup
/// builder": المستخدم يوصف الإعداد بكلماته
/// ("صالون مودرن بأقل من 500 دولار") والذكاء
/// الاصطناعي بيختار المنتجات المناسبة.
class CollectionEntity extends Equatable {
  final String id;
  final String uid;
  final String name;
  final String description;
  final List<String> productIds;

  /// الأسلوب/الغرفة اللي اتبنت للمجموعة.
  final String? style;
  final double? budget;
  final DateTime createdAt;
  final bool aiGenerated;

  const CollectionEntity({
    required this.id,
    required this.uid,
    required this.name,
    this.description = '',
    this.productIds = const [],
    this.style,
    this.budget,
    required this.createdAt,
    this.aiGenerated = false,
  });

  factory CollectionEntity.fromJson(String id, Map<String, dynamic> json) {
    return CollectionEntity(
      id: id,
      uid: json['uid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      productIds: (json['productIds'] as List? ?? const []).cast<String>(),
      style: json['style'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      aiGenerated: json['aiGenerated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'description': description,
        'productIds': productIds,
        'style': style,
        'budget': budget,
        'createdAt': createdAt.toIso8601String(),
        'aiGenerated': aiGenerated,
      };

  CollectionEntity copyWith({
    String? name,
    String? description,
    List<String>? productIds,
    String? style,
    double? budget,
    bool clearBudget = false,
  }) {
    return CollectionEntity(
      id: id,
      uid: uid,
      name: name ?? this.name,
      description: description ?? this.description,
      productIds: productIds ?? this.productIds,
      style: style ?? this.style,
      budget: clearBudget ? null : (budget ?? this.budget),
      createdAt: createdAt,
      aiGenerated: aiGenerated,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        name,
        description,
        productIds,
        style,
        budget,
        createdAt,
        aiGenerated,
      ];
}
