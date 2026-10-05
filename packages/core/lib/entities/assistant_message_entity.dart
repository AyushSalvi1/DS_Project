import 'package:equatable/equatable.dart';

enum AssistantRole { user, assistant }

/// رسالة واحدة في محادثة المساعد الذكي — مع
/// المنتجات المرتبطة والاقتراحات السريعة اللي
/// بيعرضها بعد الرد.
class AssistantMessageEntity extends Equatable {
  final String id;
  final String uid;
  final AssistantRole role;
  final String text;

  /// IDs المنتجات المرتبطة بالرد (عشان نعرضها
  /// ككروت داخل المحادثة).
  final List<String> productIds;

  /// أزرار اقتراح سريع تحت الرد (خطوة التالية
  /// في رحلة: قارن / تتبع سعر / بدائل...).
  final List<String> suggestions;
  final DateTime timestamp;

  const AssistantMessageEntity({
    required this.id,
    required this.uid,
    required this.role,
    required this.text,
    this.productIds = const [],
    this.suggestions = const [],
    required this.timestamp,
  });

  factory AssistantMessageEntity.fromJson(
    String id,
    Map<String, dynamic> json,
  ) {
    return AssistantMessageEntity(
      id: id,
      uid: json['uid'] as String? ?? '',
      role: AssistantRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => AssistantRole.assistant,
      ),
      text: json['text'] as String? ?? '',
      productIds: (json['productIds'] as List? ?? const []).cast<String>(),
      suggestions:
          (json['suggestions'] as List? ?? const []).cast<String>(),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'role': role.name,
        'text': text,
        'productIds': productIds,
        'suggestions': suggestions,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, uid, role, text, productIds, suggestions, timestamp];
}

/// رد المساعد المنظم — النص + المنتجات + الاقتراحات
/// + الإجراء المقترح (بحث/مقارنة/تتبع/تحويل).
class AssistantResponse {
  final String text;
  final List<String> productIds;
  final List<String> suggestions;

  /// الإجراء التالي المقترح في الرحلة:
  /// 'search' | 'compare' | 'track' | 'redirect' | 'none'
  final String action;

  const AssistantResponse({
    required this.text,
    this.productIds = const [],
    this.suggestions = const [],
    this.action = 'none',
  });
}
