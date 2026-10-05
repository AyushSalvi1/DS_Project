import 'package:equatable/equatable.dart';

/// أنواع النشاط اللي بنسجلها في "ذاكرة التسوق".
enum ActivityType { search, view, compare, purchase, wishlist, ask, redirect }

/// حدث نشاط مستخدم واحد — ذاكرة التسوق اللي
/// بتستخدمها التوصية الشخصية والمساعد الذكي.
class UserActivityEntity extends Equatable {
  final String id;
  final String uid;
  final ActivityType type;
  final String? productId;
  final String? query;

  /// بيانات إضافية حسب النوع (مثال: productIds للمقارنة،
  /// merchantId للتحويل، amount للشراء).
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const UserActivityEntity({
    required this.id,
    required this.uid,
    required this.type,
    this.productId,
    this.query,
    this.data = const {},
    required this.timestamp,
  });

  factory UserActivityEntity.fromJson(String id, Map<String, dynamic> json) {
    return UserActivityEntity(
      id: id,
      uid: json['uid'] as String? ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.view,
      ),
      productId: json['productId'] as String?,
      query: json['query'] as String?,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'type': type.name,
        'productId': productId,
        'query': query,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, uid, type, productId, query, data, timestamp];
}
