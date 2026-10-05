import '../entities/user_activity_entity.dart';

/// عقد ذاكرة التسوق — كل حاجة المستخدم عملها
/// (بحث، مشاهدة، مقارنة، شراء، تحويل) بتتسجل
/// وتستخدم في التوصية الشخصية والمساعد الذكي.
abstract class ActivityRepository {
  Future<void> recordActivity(UserActivityEntity activity);

  /// آخر نشاط (الأحدث أولاً).
  Stream<List<UserActivityEntity>> watchRecentActivity(
    String uid, {
    int limit = 50,
  });

  Future<List<UserActivityEntity>> getActivity(
    String uid, {
    int limit = 200,
  });

  /// آخر عمليات بحث فريدة (لذاكرة "ابحثت عن").
  Stream<List<String>> watchRecentSearches(String uid, {int limit = 10});

  Future<void> clearActivity(String uid);
}
