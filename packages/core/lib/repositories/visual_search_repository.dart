import 'dart:typed_data';

import '../entities/product_entity.dart';

/// نتيجة البحث البصري — وصف الصورة + كلمات
/// البحث + IDs المنتجات الأقرب (مرتبة).
class VisualSearchResult {
  final String description;
  final List<String> keywords;
  final List<String> rankedProductIds;

  const VisualSearchResult({
    required this.description,
    this.keywords = const [],
    this.rankedProductIds = const [],
  });
}

/// عقد البحث بالصورة (AI visual search) —
/// صورة المنتج بترفع للذكاء الاصطناعي فيصفها
/// ونطابقها على الكتالوج والمواقع الخارجية.
abstract class VisualSearchRepository {
  Future<VisualSearchResult> searchByImage(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
    List<ProductEntity>? candidates,
  });
}
