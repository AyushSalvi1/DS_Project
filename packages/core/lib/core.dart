
// Theme
export 'theme/brand_config.dart';
export 'theme/app_theme.dart';

// Entities
export 'entities/product_entity.dart';
export 'entities/category_entity.dart';
export 'entities/user_entity.dart';
export 'entities/address_entity.dart';
export 'entities/order_entity.dart';
export 'entities/cart_item_entity.dart';
export 'entities/review_entity.dart';
export 'entities/notification_entity.dart';

// Repository contracts
export 'repositories/product_repository.dart';
export 'repositories/category_repository.dart';
export 'repositories/auth_repository.dart';
export 'repositories/cart_repository.dart';
export 'repositories/order_repository.dart';
export 'repositories/favourite_repository.dart';
export 'repositories/address_repository.dart';
export 'repositories/notification_repository.dart';
export 'repositories/recently_viewed_repository.dart';
// Data sources (للاستخدام في الاختبارات بشكل أساس)
export 'datasources/auth_remote_datasource.dart';
export 'datasources/category_remote_datasource.dart';
export 'datasources/product_remote_datasource.dart';
export 'datasources/cart_remote_datasource.dart';
export 'datasources/order_remote_datasource.dart';
export 'datasources/favourite_remote_datasource.dart';
export 'datasources/address_remote_datasource.dart';
export 'datasources/notification_remote_datasource.dart';
export 'datasources/recently_viewed_remote_datasource.dart';

// Repository implementations — التنفيذ الفعلي المشترك بين customer_app وadmin_app
export 'repositories_impl/auth_repository_impl.dart';
export 'repositories_impl/category_repository_impl.dart';
export 'repositories_impl/product_repository_impl.dart';
export 'repositories_impl/cart_repository_impl.dart';
export 'repositories_impl/order_repository_impl.dart';
export 'repositories_impl/favourite_repository_impl.dart';
export 'repositories_impl/address_repository_impl.dart';
export 'repositories_impl/notification_repository_impl.dart';
export 'repositories_impl/recently_viewed_repository_impl.dart';

export 'entities/banner_entity.dart';
export 'repositories/banner_repository.dart';
export 'datasources/banner_remote_datasource.dart';
export 'repositories_impl/banner_repository_impl.dart';
export 'repositories/storage_repository.dart';
export 'repositories_impl/storage_repository_impl.dart';

export 'entities/onboarding_slide_entity.dart';
export 'repositories/onboarding_slide_repository.dart';
export 'datasources/onboarding_slide_remote_datasource.dart';
export 'repositories_impl/onboarding_slide_repository_impl.dart';

export 'utils/discount_calculator.dart';
export 'utils/category_icon_library.dart';
export 'utils/product_color_palette.dart';
export 'utils/recommendation_engine.dart';
export 'utils/responsive.dart';
export 'widgets/responsive_content.dart';

export 'repositories/search_repository.dart';
export 'repositories_impl/search_repository_impl.dart';
export 'repositories_impl/product_translation_service.dart';

// Localization
export 'localization/app_strings.dart';
export 'localization/app_strings_delegate.dart';

// =========================================================================
// AI Shopping Features — multi-website search, explainable recommendations,
// price tracking, conversational assistant, and more.
// =========================================================================

// Entities
export 'entities/merchant_entity.dart';
export 'entities/external_listing_entity.dart';
export 'entities/price_history_entity.dart';
export 'entities/price_alert_entity.dart';
export 'entities/wishlist_item_entity.dart';
export 'entities/shopping_preferences_entity.dart';
export 'entities/user_activity_entity.dart';
export 'entities/assistant_message_entity.dart';
export 'entities/scored_product_entity.dart';
export 'entities/comparison_result_entity.dart';
export 'entities/alternative_entity.dart';
export 'entities/sentiment_entity.dart';
export 'entities/collection_entity.dart';
export 'entities/compatibility_entity.dart';
export 'entities/duplicate_group_entity.dart';
export 'entities/analytics_entity.dart';

// Repository contracts
export 'repositories/merchant_repository.dart';
export 'repositories/price_tracking_repository.dart';
export 'repositories/wishlist_repository.dart';
export 'repositories/preferences_repository.dart';
export 'repositories/activity_repository.dart';
export 'repositories/assistant_repository.dart';
export 'repositories/visual_search_repository.dart';
export 'repositories/comparison_repository.dart';
export 'repositories/alternatives_repository.dart';
export 'repositories/sentiment_repository.dart';
export 'repositories/collection_repository.dart';
export 'repositories/compatibility_repository.dart';
export 'repositories/duplicate_detection_repository.dart';
export 'repositories/analytics_repository.dart';
export 'repositories/recommendation_repository.dart';

// Data sources
export 'datasources/merchant_remote_datasource.dart';
export 'datasources/simulated_web_search_datasource.dart';
export 'datasources/price_alert_remote_datasource.dart';
export 'datasources/wishlist_remote_datasource.dart';
export 'datasources/preferences_remote_datasource.dart';
export 'datasources/activity_remote_datasource.dart';
export 'datasources/collection_remote_datasource.dart';
export 'datasources/analytics_remote_datasource.dart';

// Repository implementations
export 'repositories_impl/merchant_repository_impl.dart';
export 'repositories_impl/price_tracking_repository_impl.dart';
export 'repositories_impl/wishlist_repository_impl.dart';
export 'repositories_impl/preferences_repository_impl.dart';
export 'repositories_impl/assistant_repository_impl.dart';
export 'repositories_impl/visual_search_repository_impl.dart';
export 'repositories_impl/comparison_repository_impl.dart';
export 'repositories_impl/alternatives_repository_impl.dart';
export 'repositories_impl/sentiment_repository_impl.dart';
export 'repositories_impl/compatibility_repository_impl.dart';
export 'repositories_impl/duplicate_detection_repository_impl.dart';
export 'repositories_impl/analytics_repository_impl.dart';
export 'repositories_impl/recommendation_repository_impl.dart';

// Offline engines + utilities
export 'utils/explainable_scoring_engine.dart';
export 'utils/alternatives_engine.dart';
export 'utils/duplicate_detector.dart';
export 'utils/compatibility_engine.dart';
export 'utils/price_alert_checker.dart';
export 'utils/offline_cache.dart';
