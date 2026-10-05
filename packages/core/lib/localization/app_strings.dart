/// كل نصوص واجهة التطبيق (مش محتوى المنتجات — ده منفصل وليه آلية
/// ترجمة خاصة بيه، راجع ProductTranslationService). أي نص جديد يتضاف
/// هنا في الـ interface، وبعدين في النسختين العربي والإنجليزي تحت.
abstract class AppStrings {
  // شريط التنقل السفلي
  String get navHome;
  String get navCategory;
  String get navCart;
  String get navProfile;

  // الصفحة الرئيسية
  String get topSelling;
  String get topRated;
  String get discover;
  String get recommendedForYou;
  String get offLabel;
  String get endsTomorrow;
  String endsInDays(int days);

  // شاشة الترحيب
  String get welcomeTo;
  String get welcomeTagline;
  String get getStarted;

  // شاشة الـ Onboarding (السلايدات بعد الترحيب)
  String get onboardingTitle1;
  String get onboardingDescription1;
  String get onboardingTitle2;
  String get onboardingDescription2;
  String get onboardingTitle3;
  String get onboardingDescription3;
  String get next;
  String get skip;

  // البحث
  String get search;
  String get searchHint;
  String get topSearches;
  List<String> get topSearchSuggestions;
  String get noResultsForFilter;
  String noResultsFor(String query);

  // نافذة الفلترة
  String get filterTitle;
  String get priceRange;
  String get upTo;
  String get filterCategories;
  String get filterProducts;
  String get filterColors;
  String get apply;

  // اللغة
  String get languageTitle;
  String get languageArabic;
  String get languageEnglish;

  // ترجمة المحتوى (أسماء وأوصاف المنتجات)
  String get seeTranslation;
  String get showOriginal;
  String get translating;

  // السلة والدفع
  String get cartTitle;
  String get checkOut;
  String get emptyCart;
  String get subtotal;
  String get discount;
  String get taxAndFees;
  String get delivery;
  String get total;
  String get checkoutTitle;
  String get shippingAddress;
  String get chooseShippingType;
  String get orderList;
  String get payment;
  String get shippingEconomical;
  String get shippingExpress;
  String get arrivalEconomical;
  String get arrivalExpress;
  String get paymentMethodTitle;
  String get paypal;
  String get cashMoney;
  String get selectPaymentMethod;
  String get paymentMethodsTitle;
  String get addNewMethod;
  String get paymentComingSoon;
  String get paymentSuccessful;
  String get paymentSuccessDescription;

  // الأمان والإشعارات
  String get securityTitle;
  String get rememberMe;
  String get biometricId;
  String get googleAuthenticator;
  String get changePin;
  String get changePassword;
  String get notificationsTitle;
  String get notifGeneral;
  String get notifSound;
  String get notifSoundCall;
  String get notifVibrate;
  String get notifSpecialOffers;
  String get notifPayments;
  String get notifPromo;
  String get notifCashback;

  // المفضلة والطلبات والحساب
  String get favouriteTitle;
  String get emptyFavourites;
  String get profileTitle;
  String get confirmLogout;
  String get cancel;
  String get logout;
  String get ordersTitle;
  String get noOrders;
  String get trackOrder;
  String get backToHome;
  String get estimatedDelivery;
  String hoursLabel(int hours);

  // تفاصيل المنتج
  String get addToCart;
  String get addedToCart;
  String get userReviews;
  String reviewsCount(int count);
  String get noReviewsYet;
  String get seeAll;
  String get writeReview;
  String get yourRating;
  String get reviewCommentHint;
  String get submitReview;
  String get reviewSubmitted;
  String get pleaseSelectRating;
  String get signInToReview;
  String get editReview;
  String get deleteReview;
  String get confirmDeleteReview;
  String get reviewUpdated;
  String get reviewDeleted;

  // مركز الإشعارات
  String get noNotificationsYet;
  String get notifNewOrderTitle;
  String notifNewOrderBody(String customerName, String amount);
  String get notifOrderStatusTitle;
  String notifOrderStatusBody(String orderId, String status);

  // تسجيل الدخول والتسجيل
  String get signIn;
  String get signUp;
  String get orContinueWith;
  String get alreadyHaveAccount;
  String get emailHint;
  String get passwordHint;
  String get confirmPasswordHint;
  String loginTo(String appName);
  String createAccountTitle(String appName);
  String get emailRequired;
  String get emailInvalid;
  String get passwordTooShort;
  String get passwordsDontMatch;
  String get dontHaveAccount;

  // الفئات
  String get categoriesTitle;
  String get noProductsInCategory;

  // تعديل البروفايل
  String get editProfileTitle;
  String get firstNameHint;
  String get lastNameHint;
  String get dateOfBirthHint;
  String get phoneNumberHint;
  String get genderHint;
  String get male;
  String get female;
  String get continueLabel;
  String get profileUpdated;
  String get fieldRequired;

  // العناوين
  String get addressesTitle;
  String get addAddress;
  String get editAddress;
  String get deleteAddress;
  String get setAsDefault;
  String get defaultLabel;
  String get addressLabelHint;
  String get fullNameHint;
  String get countryHint;
  String get cityHint;
  String get areaHint;
  String get streetHint;
  String get buildingNumberHint;
  String get floorHint;
  String get apartmentHint;
  String get landmarkHint;
  String get noAddressesYet;
  String get addressSaved;
  String get confirmDeleteAddress;
  String get selectAddress;
  String get addAddressToContinue;

  // =========================================================================
  // AI Shopping Features
  // =========================================================================

  // المساعد الذكي (AI Assistant)
  String get aiAssistantTitle;
  String get aiAssistantHint;
  String get aiAssistantWelcome;
  String get aiAssistantSubtitle;
  String get aiThinking;
  String get aiSend;
  String get aiVoiceSearch;
  String get aiListening;
  String get aiTapToSpeak;
  String get aiSpeakNow;
  String get aiVoiceNotSupported;
  String get aiQuickActions;
  String get aiActionSearch;
  String get aiActionCompare;
  String get aiActionTrack;
  String get aiActionAlternatives;
  String get aiActionRedirect;
  String get aiRecommendedBecause;
  String get aiAskAgain;
  String get aiNewChat;
  String get aiClearHistory;
  String get aiClearHistoryConfirm;
  String get aiHistoryCleared;
  String get aiError;
  String aiActionChip(String action);

  // البحث البصري (Visual Search)
  String get visualSearchTitle;
  String get visualSearchHint;
  String get visualSearchPickImage;
  String get visualSearchTakePhoto;
  String get visualSearchAnalyzing;
  String get visualSearchResults;
  String get visualSearchDetected;
  String get visualSearchKeywords;
  String get visualSearchNoResults;
  String get visualSearchRetry;

  // المقارنة (Comparison)
  String get compareTitle;
  String get compareSubtitle;
  String get compareSelectProducts;
  String get compareProducts;
  String get compareSelectHint;
  String get compareSelected;
  String get compareAddMore;
  String get compareClear;
  String get compareWinner;
  String get compareSummary;
  String get compareWhy;
  String get compareBestPrice;
  String get compareBestRating;
  String get compareBestValue;
  String get compareAvailability;
  String get comparePopularity;
  String get compareFreshness;
  String get compareEmpty;
  String get compareMinProducts;
  String compareSelectedCount(int count);

  // تتبع الأسعار (Price Tracking)
  String get priceTrackingTitle;
  String get priceTrackingSubtitle;
  String get priceHistory;
  String get currentPrice;
  String get lowestPrice;
  String get highestPrice;
  String get priceDropSince;
  String get addPriceAlert;
  String get alertTypeTarget;
  String get alertTypeDrop;
  String get alertTypeAvailability;
  String get targetPriceHint;
  String get percentDropHint;
  String get createAlert;
  String get alertCreated;
  String get alertCreatedDesc;
  String get activeAlerts;
  String get noActiveAlerts;
  String get alertFor;
  String get alertTriggered;
  String get alertNowTriggered;
  String get alertDisable;
  String get alertEnable;
  String get alertDelete;
  String get alertDeleteConfirm;
  String get priceHistoryDays;
  String pricePerUnit(String symbol);
  String notifPriceDropTitle();
  String notifPriceDropBody(String title, String price);
  String notifBackInStockTitle();
  String notifBackInStockBody(String title);

  // البدائل (Alternatives)
  String get alternativesTitle;
  String get alternativesSubtitle;
  String get alternativesCheaper;
  String get alternativesBetter;
  String get alternativesSimilar;
  String get alternativesNewer;
  String get alternativesAll;
  String get alternativesSavings;
  String get alternativesWhy;
  String get alternativesEmpty;
  String get alternativesViewProduct;

  // قائمة الرغبات الذكية (Smart Wishlist)
  String get wishlistTitle;
  String get wishlistSubtitle;
  String get wishlistEmpty;
  String get wishlistEmptyHint;
  String get wishlistAddTarget;
  String get wishlistTargetPrice;
  String get wishlistNotifyDrop;
  String get wishlistNotifyAvailability;
  String get wishlistRemove;
  String get wishlistPriceAlertSet;
  String get wishlistCurrentPrice;
  String get wishlistTargetReached;
  String get wishlistBelowTarget;
  String get wishlistAboveTarget;
  String get wishlistAdded;
  String get wishlistRemoved;

  // المجموعات (AI Collections)
  String get collectionsTitle;
  String get collectionsSubtitle;
  String get collectionsEmpty;
  String get collectionsEmptyHint;
  String get collectionsNew;
  String get collectionBuilderTitle;
  String get collectionBuilderHint;
  String get collectionBuilderExample;
  String get collectionBuilderBudget;
  String get collectionBuilderName;
  String get collectionBuilderBuild;
  String get collectionBuilderBuilding;
  String get collectionBuilderBuilt;
  String get collectionBuilderBuiltDesc;
  String get collectionProducts;
  String get collectionTotal;
  String get collectionDelete;
  String get collectionDeleteConfirm;
  String get collectionAddMore;
  String get collectionRemove;
  String get collectionRename;
  String get collectionCreated;
  String get collectionUpdated;

  // ملف التسوق والخصوصية (Profile & Privacy)
  String get shoppingProfileTitle;
  String get shoppingProfileSubtitle;
  String get preferredCategories;
  String get preferredColors;
  String get budgetRange;
  String get budgetMin;
  String get budgetMax;
  String get styleKeywords;
  String get styleKeywordsHint;
  String get qualityPreference;
  String get qualityValue;
  String get qualityBalanced;
  String get qualityPremium;
  String get savePreferences;
  String get preferencesSaved;
  String get privacyTitle;
  String get privacySubtitle;
  String get privacyPersonalization;
  String get privacyPersonalizationDesc;
  String get privacyActivity;
  String get privacyActivityDesc;
  String get privacyAnalytics;
  String get privacyAnalyticsDesc;
  String get privacyClearData;
  String get privacyClearDataConfirm;
  String get privacyDataCleared;
  String get privacyLearnMore;

  // ذاكرة التسوق (Activity / Shopping Memory)
  String get activityTitle;
  String get activitySubtitle;
  String get activityRecentSearches;
  String get activityRecentlyViewed;
  String get activityRecentComparisons;
  String get activityPurchases;
  String get activityEmpty;
  String get activityClear;
  String get activityClearConfirm;
  String get activityCleared;
  String get activityViewedProduct;
  String get activitySearchedFor;
  String get activityCompared;
  String get activityPurchased;
  String get activityRedirected;
  String activityTimeAgo(int minutes);
  String get activityJustNow;

  // التحليلات (Analytics)
  String get analyticsTitle;
  String get analyticsSubtitle;
  String get analyticsYourActivity;
  String get analyticsRecommendations;
  String get analyticsSearches;
  String get analyticsViews;
  String get analyticsComparisons;
  String get analyticsPurchases;
  String get analyticsRedirects;
  String get analyticsAlertsTriggered;
  String get analyticsSavings;
  String get analyticsTopCategories;
  String get analyticsWeeklyActivity;
  String get analyticsRecShown;
  String get analyticsRecClicked;
  String get analyticsRecPurchased;
  String get analyticsRecPositive;
  String get analyticsRecNegative;
  String get analyticsAcceptanceRate;
  String get analyticsCtr;
  String get analyticsPositiveRate;
  String analyticsPercent(num value);
  String get analyticsNoData;

  // التجار (Merchants)
  String get merchantsTitle;
  String get merchantsSubtitle;
  String get merchantReliability;
  String get merchantReviews;
  String get merchantShipping;
  String get merchantReturns;
  String get merchantVerified;
  String get merchantNotVerified;
  String get merchantVisitStore;
  String get merchantViewSite;
  String get merchantExcellent;
  String get merchantGood;
  String get merchantAverage;
  String get merchantProducts;
  String get merchantLowestPrice;
  String get merchantFreeShipping;
  String merchantShippingCost(String symbol, String amount);

  // البحث عبر المواقع (Web Search)
  String get webSearchTitle;
  String get webSearchSubtitle;
  String get webSearchResults;
  String get webSearchNoResults;
  String get webSearchBestDeal;
  String get webSearchCheapest;
  String webSearchFrom(String merchant);
  String get webSearchInStock;
  String get webSearchOutOfStock;
  String get webSearchFreeShipping;
  String get webSearchShipping;
  String get webSearchCompareAll;
  String get webSearchTrackThis;
  String get webSearchViewDeal;
  String get webSearchLastSeen;

  // التوافق (Compatibility)
  String get compatibilityTitle;
  String get compatibilitySubtitle;
  String get compatibilityGoesWith;
  String get compatibilityEmpty;
  String get compatibilityFrequentlyBought;

  // كشف التكرار (Duplicates)
  String get duplicatesTitle;
  String get duplicatesSubtitle;
  String get duplicatesFound;
  String get duplicatesAlsoAt;
  String get duplicatesSimilar;
  String get duplicatesConfidence;
  String get duplicatesEmpty;

  // التوصيات المفسّرة (Explainable)
  String get explainableWhyRecommended;
  String get explainableScore;
  String get explainableFactors;
  String get explainableFeedbackPositive;
  String get explainableFeedbackNegative;
  String get explainableFeedbackThanks;
  String get explainableFeedbackLearned;

  // تحليل المشاعر (Sentiment Analysis)
  String get sentimentTitle;
  String get sentimentSubtitle;
  String get sentimentOverall;
  String get sentimentPositive;
  String get sentimentNeutral;
  String get sentimentNegative;
  String get sentimentPros;
  String get sentimentCons;
  String get sentimentAspects;
  String get sentimentSummary;
  String get sentimentMentions;

  // عام
  String get redirecting;
  String get openInBrowser;
  String get bestWebsite;
  String get bestDeal;
  String get save;
  String get remove;
  String get add;
  String get build;
  String get track;
  String get compare;
  String get alternatives;
  String get collections;
  String get analytics;
  String get activity;
  String get wishlist;
  String get preferences;
  String get privacy;
  String get merchants;
  String get aiAssistant;
  String get visualSearch;
  String get priceTracking;
  String get compatibility;
  String get duplicates;
  String get why;
  String get learnMore;
  String get clearAll;
  String get enabled;
  String get disabled;
  String get optional;
  String get delete;
  String get rename;
  String get back;
  String get continueLabel2;
  String get notNow;
  String get tryAgain;
  String get offlineMode;
  String get offlineHint;
  String get cachedData;
  String minutesAgo(int minutes);
  String hoursAgo(int hours);
  String daysAgo(int days);
}

class AppStringsAr implements AppStrings {
  const AppStringsAr();

  @override
  String get navHome => 'الرئيسية';
  @override
  String get navCategory => 'الفئات';
  @override
  String get navCart => 'السلة';
  @override
  String get navProfile => 'حسابي';

  @override
  String get topSelling => 'الأكثر مبيعًا';
  @override
  String get topRated => 'الأعلى تقييمًا';
  @override
  String get discover => 'اكتشف';
  @override
  String get recommendedForYou => 'مقترح لك';
  @override
  String get offLabel => 'خصم';
  @override
  String get endsTomorrow => 'ينتهي غدًا';
  @override
  String endsInDays(int days) => 'ينتهي خلال $days أيام';

  @override
  String get welcomeTo => 'مرحبًا بك في';
  @override
  String get welcomeTagline => 'صمّم مساحتك وتسوّق كل احتياجات الديكور';
  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get onboardingTitle1 => 'نظّم ديكورك وتسوّقك بكل سهولة مع decoze';
  @override
  String get onboardingDescription1 =>
      'تنقّل بثقة في رحلة تصميم منزلك، ووصولك لمساحة أحلامك بأسلوب عملي وأنيق مع decoze';
  @override
  String get onboardingTitle2 => 'ابقَ على تواصل مع فريق التصميم في أي وقت ومن أي مكان';
  @override
  String get onboardingDescription2 =>
      'في عالم الديكور المتغيّر باستمرار، التواصل مع فريق التصميم هو سر نجاحك مع decoze';
  @override
  String get onboardingTitle3 => 'اكتشف كل المزايا اللي بيقدّمها decoze';
  @override
  String get onboardingDescription3 =>
      'استكشف مجموعة مزايا decoze المتنوعة واستفد منها لأقصى درجة';
  @override
  String get next => 'التالي';
  @override
  String get skip => 'تخطي';

  @override
  String get search => 'البحث';
  @override
  String get searchHint => 'اسأل عن أي حاجة... مثلاً: أثاث غرفة نوم رخيص';
  @override
  String get topSearches => 'كلمات بحث شائعة';
  @override
  List<String> get topSearchSuggestions =>
      const ['سرير', 'لمبة', 'نباتات صناعية', 'سجاد', 'كنب', 'كراسي زرقاء'];
  @override
  String get noResultsForFilter => 'مفيش نتايج مطابقة للفلتر';
  @override
  String noResultsFor(String query) => 'مفيش نتايج لـ "$query"';

  @override
  String get filterTitle => 'الفلترة';
  @override
  String get priceRange => 'نطاق السعر';
  @override
  String get upTo => 'حتى';
  @override
  String get filterCategories => 'الفئات';
  @override
  String get filterProducts => 'المنتجات';
  @override
  String get filterColors => 'الألوان';
  @override
  String get apply => 'تطبيق';

  @override
  String get languageTitle => 'اللغة';
  @override
  String get languageArabic => 'العربية';
  @override
  String get languageEnglish => 'English';

  @override
  String get seeTranslation => 'ترجمة';
  @override
  String get showOriginal => 'عرض النص الأصلي';
  @override
  String get translating => 'جاري الترجمة...';

  @override
  String get cartTitle => 'سلة التسوق';
  @override
  String get checkOut => 'إتمام الشراء';
  @override
  String get emptyCart => 'السلة فاضية.';
  @override
  String get subtotal => 'الإجمالي الفرعي';
  @override
  String get discount => 'الخصم';
  @override
  String get taxAndFees => 'الضرائب والرسوم';
  @override
  String get delivery => 'التوصيل';
  @override
  String get total => 'الإجمالي';
  @override
  String get checkoutTitle => 'الدفع';
  @override
  String get shippingAddress => 'عنوان الشحن';
  @override
  String get chooseShippingType => 'اختر نوع الشحن';
  @override
  String get orderList => 'قائمة الطلب';
  @override
  String get payment => 'الدفع';
  @override
  String get shippingEconomical => 'اقتصادي';
  @override
  String get shippingExpress => 'سريع';
  @override
  String get arrivalEconomical => 'الوصول المتوقع: 5-7 أيام';
  @override
  String get arrivalExpress => 'الوصول المتوقع: 1-2 يوم';
  @override
  String get paymentMethodTitle => 'طريقة الدفع';
  @override
  String get paypal => 'PayPal';
  @override
  String get cashMoney => 'الدفع نقدًا';
  @override
  String get selectPaymentMethod => 'اختر طريقة الدفع اللي عايز تستخدمها.';
  @override
  String get paymentMethodsTitle => 'طرق الدفع';
  @override
  String get addNewMethod => 'إضافة طريقة جديدة';
  @override
  String get paymentComingSoon => 'هتتفعّل مع بوابة دفع حقيقية لاحقًا.';
  @override
  String get paymentSuccessful => 'تم بنجاح!';
  @override
  String get paymentSuccessDescription => 'تم الدفع بنجاح لعملية الشراء بتاعتك.';

  @override
  String get securityTitle => 'الأمان';
  @override
  String get rememberMe => 'تذكرني';
  @override
  String get biometricId => 'بصمة الدخول';
  @override
  String get googleAuthenticator => 'Google Authenticator';
  @override
  String get changePin => 'تغيير الرقم السري';
  @override
  String get changePassword => 'تغيير كلمة المرور';
  @override
  String get notificationsTitle => 'الإشعارات';
  @override
  String get notifGeneral => 'الإشعارات العامة';
  @override
  String get notifSound => 'الصوت';
  @override
  String get notifSoundCall => 'صوت المكالمات';
  @override
  String get notifVibrate => 'الاهتزاز';
  @override
  String get notifSpecialOffers => 'عروض خاصة';
  @override
  String get notifPayments => 'المدفوعات';
  @override
  String get notifPromo => 'العروض والخصومات';
  @override
  String get notifCashback => 'الكاش باك';

  @override
  String get favouriteTitle => 'المفضلة';
  @override
  String get emptyFavourites => 'قائمة المفضلة\nفاضية';
  @override
  String get profileTitle => 'حسابي';
  @override
  String get confirmLogout => 'متأكد إنك عايز تسجّل خروج؟';
  @override
  String get cancel => 'إلغاء';
  @override
  String get logout => 'تسجيل خروج';
  @override
  String get ordersTitle => 'الطلبات';
  @override
  String get noOrders => 'لا توجد طلبات سابقة.';
  @override
  String get trackOrder => 'تتبع الطلب';
  @override
  String get backToHome => 'العودة للرئيسية';
  @override
  String get estimatedDelivery => 'الوصول المتوقع';
  @override
  String hoursLabel(int hours) => '$hours ساعة';

  @override
  String get addToCart => 'أضف إلى السلة';
  @override
  String get addedToCart => 'تمت الإضافة إلى السلة.';
  @override
  String get userReviews => 'تقييمات المستخدمين';
  @override
  String reviewsCount(int count) => '+$count تقييم';
  @override
  String get noReviewsYet => 'لا توجد تقييمات بعد.';
  @override
  String get seeAll => 'عرض الكل';
  @override
  String get writeReview => 'اكتب تقييمًا';
  @override
  String get yourRating => 'تقييمك';
  @override
  String get reviewCommentHint => 'شاركنا رأيك في المنتج...';
  @override
  String get submitReview => 'إرسال التقييم';
  @override
  String get reviewSubmitted => 'تم إرسال تقييمك بنجاح.';
  @override
  String get pleaseSelectRating => 'من فضلك اختر تقييمًا أولًا.';
  @override
  String get signInToReview => 'سجّل الدخول لإضافة تقييم.';
  @override
  String get editReview => 'تعديل التقييم';
  @override
  String get deleteReview => 'حذف التقييم';
  @override
  String get confirmDeleteReview => 'متأكد إنك عايز تحذف تقييمك؟';
  @override
  String get reviewUpdated => 'تم تحديث تقييمك.';
  @override
  String get reviewDeleted => 'تم حذف تقييمك.';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات حتى الآن.';
  @override
  String get notifNewOrderTitle => 'طلب جديد';
  @override
  String notifNewOrderBody(String customerName, String amount) =>
      'طلب جديد من $customerName — $amount';
  @override
  String get notifOrderStatusTitle => 'تحديث على طلبك';
  @override
  String notifOrderStatusBody(String orderId, String status) =>
      'طلبك #${orderId.substring(0, orderId.length < 6 ? orderId.length : 6)} بقى: $status';

  @override
  String get signIn => 'تسجيل الدخول';
  @override
  String get signUp => 'إنشاء حساب';
  @override
  String get orContinueWith => 'أو تابع باستخدام';
  @override
  String get alreadyHaveAccount => 'عندك حساب بالفعل؟ سجّل دخول';
  @override
  String get emailHint => 'البريد الإلكتروني';
  @override
  String get passwordHint => 'كلمة المرور';
  @override
  String get confirmPasswordHint => 'تأكيد كلمة المرور';
  @override
  String loginTo(String appName) => 'تسجيل الدخول لـ $appName';
  @override
  String createAccountTitle(String appName) => 'أنشئ حسابك في\n$appName';
  @override
  String get emailRequired => 'من فضلك أدخل البريد الإلكتروني';
  @override
  String get emailInvalid => 'صيغة البريد الإلكتروني غير صحيحة';
  @override
  String get passwordTooShort => 'كلمة المرور لازم تكون 6 أحرف على الأقل';
  @override
  String get passwordsDontMatch => 'كلمة المرور غير متطابقة';
  @override
  String get dontHaveAccount => 'معندكش حساب؟ إنشاء حساب';

  @override
  String get categoriesTitle => 'الفئات';
  @override
  String get noProductsInCategory => 'لا توجد منتجات في هذا القسم.';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';
  @override
  String get firstNameHint => 'الاسم الأول';
  @override
  String get lastNameHint => 'اسم العائلة';
  @override
  String get dateOfBirthHint => 'تاريخ الميلاد';
  @override
  String get phoneNumberHint => 'رقم الهاتف';
  @override
  String get genderHint => 'النوع';
  @override
  String get male => 'ذكر';
  @override
  String get female => 'أنثى';
  @override
  String get continueLabel => 'متابعة';
  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي.';
  @override
  String get fieldRequired => 'الحقل ده مطلوب.';

  @override
  String get addressesTitle => 'العناوين';
  @override
  String get addAddress => 'إضافة عنوان جديد';
  @override
  String get editAddress => 'تعديل العنوان';
  @override
  String get deleteAddress => 'حذف العنوان';
  @override
  String get setAsDefault => 'تعيين كافتراضي';
  @override
  String get defaultLabel => 'افتراضي';
  @override
  String get addressLabelHint => 'اسم العنوان (المنزل، العمل...)';
  @override
  String get fullNameHint => 'الاسم الكامل لاستلام الطلب';
  @override
  String get countryHint => 'الدولة';
  @override
  String get cityHint => 'المدينة';
  @override
  String get areaHint => 'الحي / المنطقة';
  @override
  String get streetHint => 'الشارع';
  @override
  String get buildingNumberHint => 'رقم المبنى';
  @override
  String get floorHint => 'الدور (اختياري)';
  @override
  String get apartmentHint => 'رقم الشقة (اختياري)';
  @override
  String get landmarkHint => 'علامة مميزة قريبة (اختياري)';
  @override
  String get noAddressesYet => 'لسه مفيش عناوين محفوظة.';
  @override
  String get addressSaved => 'تم حفظ العنوان.';
  @override
  String get confirmDeleteAddress => 'متأكد إنك عايز تحذف العنوان ده؟';
  @override
  String get selectAddress => 'اختر عنوان الشحن';
  @override
  String get addAddressToContinue => 'أضف عنوان شحن عشان تكمل الطلب.';

  // =========================================================================
  // AI Shopping Features (عربي)
  // =========================================================================

  @override
  String get aiAssistantTitle => 'المساعد الذكي';
  @override
  String get aiAssistantHint => 'اسأل عن أي منتج... مثال: كنب رخيص لأوضة الصالون';
  @override
  String get aiAssistantWelcome => 'أهلاً! أنا مساعدك الذكي للتسوق. اسألني عن أي حاجة — هنبتدي بالبحث، نقارن، ونرشّح لك الأفضل مع الأسباب.';
  @override
  String get aiAssistantSubtitle => 'اسأل → ابحث → قارن → أوصي → وضّح → تتبّع → أحوّلك لأفضل موقع';
  @override
  String get aiThinking => 'بيفكر...';
  @override
  String get aiSend => 'إرسال';
  @override
  String get aiVoiceSearch => 'بحث صوتي';
  @override
  String get aiListening => 'بيسمعك...';
  @override
  String get aiTapToSpeak => 'دوس عشان تتكلم';
  @override
  String get aiSpeakNow => 'تكلم دلوقتي';
  @override
  String get aiVoiceNotSupported => 'البحث الصوتي مش مدعوم على الجهاز ده';
  @override
  String get aiQuickActions => 'إجراءات سريعة';
  @override
  String get aiActionSearch => 'ابحث';
  @override
  String get aiActionCompare => 'قارن';
  @override
  String get aiActionTrack => 'تتبّع السعر';
  @override
  String get aiActionAlternatives => 'بدائل';
  @override
  String get aiActionRedirect => 'أحولني للموقع';
  @override
  String get aiRecommendedBecause => 'اترشح لك لأن';
  @override
  String get aiAskAgain => 'اسأل تاني';
  @override
  String get aiNewChat => 'محادثة جديدة';
  @override
  String get aiClearHistory => 'مسح المحادثة';
  @override
  String get aiClearHistoryConfirm => 'متأكد إنك عايز تمسح المحادثة كلها؟';
  @override
  String get aiHistoryCleared => 'اتمسحت المحادثة.';
  @override
  String get aiError => 'حصل خطأ — حاول تاني.';
  @override
  String aiActionChip(String action) => action;

  @override
  String get visualSearchTitle => 'البحث بالصورة';
  @override
  String get visualSearchHint => 'ارفع صورة منتج وهنلاقيه في الكتالوج والمواقع التانية';
  @override
  String get visualSearchPickImage => 'اختر صورة';
  @override
  String get visualSearchTakePhoto => 'صور دلوقتي';
  @override
  String get visualSearchAnalyzing => 'بيحلل الصورة...';
  @override
  String get visualSearchResults => 'نتايج البحث البصري';
  @override
  String get visualSearchDetected => 'المنتج المكشوف';
  @override
  String get visualSearchKeywords => 'كلمات البحث';
  @override
  String get visualSearchNoResults => 'ملقيناش منتجات قريبة من الصورة — جرب صورة أوضح';
  @override
  String get visualSearchRetry => 'حاول تاني';

  @override
  String get compareTitle => 'مقارنة المنتجات';
  @override
  String get compareSubtitle => 'قارن بين المنتجات — السعر والتقييم والقيمة والتوفر';
  @override
  String get compareSelectProducts => 'اختر منتجات للمقارنة';
  @override
  String get compareProducts => 'المنتجات';
  @override
  String get compareSelectHint => 'اختر ٢-٤ منتجات من الكتالوج';
  @override
  String get compareSelected => 'المختار';
  @override
  String get compareAddMore => 'أضف منتج تاني';
  @override
  String get compareClear => 'مسح الكل';
  @override
  String get compareWinner => 'الأفضل إجمالًا';
  @override
  String get compareSummary => 'ملخص المقارنة';
  @override
  String get compareWhy => 'ليه ده الأفضل؟';
  @override
  String get compareBestPrice => 'أفضل سعر';
  @override
  String get compareBestRating => 'أعلى تقييم';
  @override
  String get compareBestValue => 'أفضل قيمة';
  @override
  String get compareAvailability => 'التوفر';
  @override
  String get comparePopularity => 'الشعبية';
  @override
  String get compareFreshness => 'الحداثة';
  @override
  String get compareEmpty => 'مفيش منتجات للمقارنة';
  @override
  String get compareMinProducts => 'لازم تختار منتجين على الأقل';
  @override
  String compareSelectedCount(int count) => 'تم اختيار $count';

  @override
  String get priceTrackingTitle => 'تتبع الأسعار';
  @override
  String get priceTrackingSubtitle => 'تاريخ الأسعار وتنبيهات الانخفاض';
  @override
  String get priceHistory => 'تاريخ السعر';
  @override
  String get currentPrice => 'السعر الحالي';
  @override
  String get lowestPrice => 'أدنى سعر';
  @override
  String get highestPrice => 'أعلى سعر';
  @override
  String get priceDropSince => 'انخفاض من أعلى سعر';
  @override
  String get addPriceAlert => 'تنبيه سعر جديد';
  @override
  String get alertTypeTarget => 'سعر مستهدف';
  @override
  String get alertTypeDrop => 'انخفاض بنسبة';
  @override
  String get alertTypeAvailability => 'رجوع التوفر';
  @override
  String get targetPriceHint => 'السعر اللي عايز تتنبه لو نزل تحته';
  @override
  String get percentDropHint => 'نسبة الانخفاض (مثال: 10 = ١٠٪)';
  @override
  String get createAlert => 'إنشاء التنبيه';
  @override
  String get alertCreated => 'اتعمل التنبيه';
  @override
  String get alertCreatedDesc => 'هنبقى نراقب السعر وننبّهك لو حصل التغيير.';
  @override
  String get activeAlerts => 'التنبيهات النشطة';
  @override
  String get noActiveAlerts => 'مفيش تنبيهات نشطة';
  @override
  String get alertFor => 'تنبيه لـ';
  @override
  String get alertTriggered => 'اتحقق التنبيه';
  @override
  String get alertNowTriggered => 'التنبيه اتحقق دلوقتي — بنبّهناك في الإشعارات.';
  @override
  String get alertDisable => 'تعطيل';
  @override
  String get alertEnable => 'تفعيل';
  @override
  String get alertDelete => 'حذف التنبيه';
  @override
  String get alertDeleteConfirm => 'متأكد إنك عايز تحذف التنبيه ده؟';
  @override
  String get priceHistoryDays => 'آخر ٩٠ يوم';
  @override
  String pricePerUnit(String symbol) => '$symbol للوحدة';
  @override
  String notifPriceDropTitle() => 'انخفاض سعر';
  @override
  String notifPriceDropBody(String title, String price) => 'السعر اتقلص لـ $price — $title';
  @override
  String notifBackInStockTitle() => 'رجع التوفر';
  @override
  String notifBackInStockBody(String title) => '$title بقى متوفر تاني عند التاجر.';

  @override
  String get alternativesTitle => 'البدائل';
  @override
  String get alternativesSubtitle => 'أرخص / أفضل / مشابه / أحدث';
  @override
  String get alternativesCheaper => 'أرخص';
  @override
  String get alternativesBetter => 'أفضل';
  @override
  String get alternativesSimilar => 'مشابه';
  @override
  String get alternativesNewer => 'أحدث';
  @override
  String get alternativesAll => 'الكل';
  @override
  String get alternativesSavings => 'توفير';
  @override
  String get alternativesWhy => 'ليه ده البديل؟';
  @override
  String get alternativesEmpty => 'مفيش بدائل مناسبة دلوقتي';
  @override
  String get alternativesViewProduct => 'عرض المنتج';

  @override
  String get wishlistTitle => 'قائمة الرغبات';
  @override
  String get wishlistSubtitle => 'منتجاتك المحفوظة مع تتبع السعر';
  @override
  String get wishlistEmpty => 'قائمة الرغبات فاضية';
  @override
  String get wishlistEmptyHint => 'احفظ منتجات هنا وهننبّهك لو السعر نزل أو المنتج اتوفر';
  @override
  String get wishlistAddTarget => 'حدد سعر مستهدف';
  @override
  String get wishlistTargetPrice => 'السعر المستهدف';
  @override
  String get wishlistNotifyDrop => 'نبّهني بانخفاض السعر';
  @override
  String get wishlistNotifyAvailability => 'نبّئني برجوع التوفر';
  @override
  String get wishlistRemove => 'إزالة';
  @override
  String get wishlistPriceAlertSet => 'اتعمل تنبيه السعر';
  @override
  String get wishlistCurrentPrice => 'السعر الحالي';
  @override
  String get wishlistTargetReached => 'وصل السعر للهدف';
  @override
  String get wishlistBelowTarget => 'تحت السعر المستهدف';
  @override
  String get wishlistAboveTarget => 'فوق السعر المستهدف';
  @override
  String get wishlistAdded => 'اتضاف لقائمة الرغبات';
  @override
  String get wishlistRemoved => 'اتشال من قائمة الرغبات';

  @override
  String get collectionsTitle => 'مجموعاتي';
  @override
  String get collectionsSubtitle => 'أجندة منتجات بتبنى بالذكاء الاصطناعي';
  @override
  String get collectionsEmpty => 'مفيش مجموعات بعد';
  @override
  String get collectionsEmptyHint => 'وصف الإعداد اللي عايزه (مثال: "صالون مودرن بأقل من ٥٠٠ دولار") وهنبنيهالك';
  @override
  String get collectionsNew => 'مجموعة جديدة';
  @override
  String get collectionBuilderTitle => 'مصمم المجموعات';
  @override
  String get collectionBuilderHint => 'وصف الإعداد اللي عايزه بكلماتك...';
  @override
  String get collectionBuilderExample => 'مثال: غرفة نوم هادية بأسلوب سكاندنافي والميزانية محدودة';
  @override
  String get collectionBuilderBudget => 'الميزانية (اختياري)';
  @override
  String get collectionBuilderName => 'اسم المجموعة';
  @override
  String get collectionBuilderBuild => 'ابني المجموعة';
  @override
  String get collectionBuilderBuilding => 'بيبني مجموعتك...';
  @override
  String get collectionBuilderBuilt => 'اتبنت مجموعتك';
  @override
  String get collectionBuilderBuiltDesc => 'اختارنا لك منتجات منسجمة مع وصفك';
  @override
  String get collectionProducts => 'منتجات المجموعة';
  @override
  String get collectionTotal => 'إجمالي السعر';
  @override
  String get collectionDelete => 'حذف المجموعة';
  @override
  String get collectionDeleteConfirm => 'متأكد إنك عايز تحذف المجموعة ده؟';
  @override
  String get collectionAddMore => 'أضف منتج';
  @override
  String get collectionRemove => 'إزالة من المجموعة';
  @override
  String get collectionRename => 'إعادة تسمية';
  @override
  String get collectionCreated => 'اتعملت المجموعة';
  @override
  String get collectionUpdated => 'اتحدّثت المجموعة';

  @override
  String get shoppingProfileTitle => 'ملف التسوق';
  @override
  String get shoppingProfileSubtitle => 'التفضيلات اللي بتستخدم في التوصية الشخصية';
  @override
  String get preferredCategories => 'الفئات المفضلة';
  @override
  String get preferredColors => 'الألوان المفضلة';
  @override
  String get budgetRange => 'نطاق الميزانية';
  @override
  String get budgetMin => 'الحد الأدنى';
  @override
  String get budgetMax => 'الحد الأقصى';
  @override
  String get styleKeywords => 'كلمات الأسلوب';
  @override
  String get styleKeywordsHint => 'مثال: modern, minimalist, rustic';
  @override
  String get qualityPreference => 'تفضيل الجودة';
  @override
  String get qualityValue => 'أفضل قيمة';
  @override
  String get qualityBalanced => 'متوازن';
  @override
  String get qualityPremium => 'الأعلى جودة';
  @override
  String get savePreferences => 'حفظ التفضيلات';
  @override
  String get preferencesSaved => 'اتحفظت التفضيلات';
  @override
  String get privacyTitle => 'الخصوصية';
  @override
  String get privacySubtitle => 'تحكم في بياناتك والتخصيص';
  @override
  String get privacyPersonalization => 'التوصية الشخصية';
  @override
  String get privacyPersonalizationDesc => 'استخدم نشاطي وتفضيلاتي في التوصيات';
  @override
  String get privacyActivity => 'تتبع النشاط';
  @override
  String get privacyActivityDesc => 'سجل بحثي ومشاهداتي ومقارناتي';
  @override
  String get privacyAnalytics => 'مشاركة التحليلات';
  @override
  String get privacyAnalyticsDesc => 'إرسال إحصائيات الاستخدام التجميعية';
  @override
  String get privacyClearData => 'مسح بياناتي';
  @override
  String get privacyClearDataConfirm => 'هيتمسح تفضيلاتك ونشاطك وتقييماتك — متأكد؟';
  @override
  String get privacyDataCleared => 'اتمسحت بياناتك الشخصية';
  @override
  String get privacyLearnMore => 'كيف بنستخدم بياناتك؟';

  @override
  String get activityTitle => 'ذاكرة التسوق';
  @override
  String get activitySubtitle => 'آخر حاجة عملتها في التطبيق';
  @override
  String get activityRecentSearches => 'عمليات البحث الأخيرة';
  @override
  String get activityRecentlyViewed => 'شافته مؤخرًا';
  @override
  String get activityRecentComparisons => 'المقارنات الأخيرة';
  @override
  String get activityPurchases => 'المشتريات';
  @override
  String get activityEmpty => 'مفيش نشاط بعد';
  @override
  String get activityClear => 'مسح النشاط';
  @override
  String get activityClearConfirm => 'متأكد إنك عايز تمسح سجل النشاط كله؟';
  @override
  String get activityCleared => 'اتمسح سجل النشاط';
  @override
  String get activityViewedProduct => 'شاف منتج';
  @override
  String get activitySearchedFor => 'بحث عن';
  @override
  String get activityCompared => 'قارن';
  @override
  String get activityPurchased => 'اشترى';
  @override
  String get activityRedirected => 'حوّل للموقع';
  @override
  String activityTimeAgo(int minutes) {
    if (minutes < 1) return 'دلوقتي';
    if (minutes < 60) return 'منذ $minutes دقيقة';
    final hours = (minutes / 60).round();
    if (hours < 24) return 'منذ $hours ساعة';
    final days = (hours / 24).round();
    return 'منذ $days يوم';
  }
  @override
  String get activityJustNow => 'دلوقتي';

  @override
  String get analyticsTitle => 'التحليلات';
  @override
  String get analyticsSubtitle => 'نشاطك وأداء التوصيات';
  @override
  String get analyticsYourActivity => 'نشاطك';
  @override
  String get analyticsRecommendations => 'التوصيات';
  @override
  String get analyticsSearches => 'عمليات بحث';
  @override
  String get analyticsViews => 'مشاهدات';
  @override
  String get analyticsComparisons => 'مقارنات';
  @override
  String get analyticsPurchases => 'مشتريات';
  @override
  String get analyticsRedirects => 'تحويلات للمواقع';
  @override
  String get analyticsAlertsTriggered => 'تنبيهات اتحققت';
  @override
  String get analyticsSavings => 'وفورات السعر';
  @override
  String get analyticsTopCategories => 'أعلى الفئات اهتمامًا';
  @override
  String get analyticsWeeklyActivity => 'النشاط الأسبوعي';
  @override
  String get analyticsRecShown => 'توصيات ظهرت';
  @override
  String get analyticsRecClicked => 'اتنقرت';
  @override
  String get analyticsRecPurchased => 'اتقبلت (شراء)';
  @override
  String get analyticsRecPositive => 'تقييم إيجابي';
  @override
  String get analyticsRecNegative => 'تقييم سلبي';
  @override
  String get analyticsAcceptanceRate => 'نسبة القبول';
  @override
  String get analyticsCtr => 'نسبة النقر';
  @override
  String get analyticsPositiveRate => 'نسبة الرضا';
  @override
  String analyticsPercent(num value) => '${(value * 100).round()}٪';
  @override
  String get analyticsNoData => 'مفيش بيانات كافية بعد — استخدم التطبيق وهنعرض إحصائياتك هنا';

  @override
  String get merchantsTitle => 'التجار';
  @override
  String get merchantsSubtitle => 'موثوقية وتقييمات مواقع البيع';
  @override
  String get merchantReliability => 'الموثوقية';
  @override
  String get merchantReviews => 'تقييم';
  @override
  String get merchantShipping => 'الشحن';
  @override
  String get merchantReturns => 'الإرجاع';
  @override
  String get merchantVerified => 'موثّق';
  @override
  String get merchantNotVerified => 'غير موثّق';
  @override
  String get merchantVisitStore => 'زيارة المتجر';
  @override
  String get merchantViewSite => 'عرض الموقع';
  @override
  String get merchantExcellent => 'ممتاز';
  @override
  String get merchantGood => 'جيد';
  @override
  String get merchantAverage => 'متوسط';
  @override
  String get merchantProducts => 'منتج';
  @override
  String get merchantLowestPrice => 'أدنى سعر';
  @override
  String get merchantFreeShipping => 'شحن مجاني';
  @override
  String merchantShippingCost(String symbol, String amount) => '$symbol$amount شحن';

  @override
  String get webSearchTitle => 'البحث في المواقع';
  @override
  String get webSearchSubtitle => 'نبحث في مواقع البيع المتعددة ونقارن الأسعار';
  @override
  String get webSearchResults => 'نتايج المواقع';
  @override
  String get webSearchNoResults => 'ملقيناش عروض خارجية — جرب كلمات تانية';
  @override
  String get webSearchBestDeal => 'أفضل صفقة';
  @override
  String get webSearchCheapest => 'الأرخص';
  @override
  String webSearchFrom(String merchant) => 'من $merchant';
  @override
  String get webSearchInStock => 'متوفر';
  @override
  String get webSearchOutOfStock => 'غير متوفر';
  @override
  String get webSearchFreeShipping => 'شحن مجاني';
  @override
  String get webSearchShipping => 'شحن';
  @override
  String get webSearchCompareAll => 'قارن الكل';
  @override
  String get webSearchTrackThis => 'تتبّع السعر';
  @override
  String get webSearchViewDeal => 'عرض الصفقة';
  @override
  String get webSearchLastSeen => 'آخر تحديث';

  @override
  String get compatibilityTitle => 'بتكمل بعض';
  @override
  String get compatibilitySubtitle => 'منتجات متناسقة مع المنتج ده';
  @override
  String get compatibilityGoesWith => 'بيمشي مع';
  @override
  String get compatibilityEmpty => 'مفيش منتجات متناسقة دلوقتي';
  @override
  String get compatibilityFrequentlyBought => 'بيتشترى مع بعض أكتر من مرة';

  @override
  String get duplicatesTitle => 'كشف التكرار';
  @override
  String get duplicatesSubtitle => 'نفس المنتج في أكتر من موقع';
  @override
  String get duplicatesFound => 'مجموعة تكرار مكشوفة';
  @override
  String get duplicatesAlsoAt => 'متوفر كمان عند';
  @override
  String get duplicatesSimilar => 'تشابه';
  @override
  String get duplicatesConfidence => 'ثقة الكشف';

  @override
  String get duplicatesEmpty => 'مفيش تكرار مكشوف دلوقتي';

  @override
  String get explainableWhyRecommended => 'ليه اترشح لك ده؟';
  @override
  String get explainableScore => 'درجة الملاءمة';
  @override
  String get explainableFactors => 'عوامل التقييم';
  @override
  String get explainableFeedbackPositive => 'توصية حلوة';
  @override
  String get explainableFeedbackNegative => 'مش مناسبة';
  @override
  String get explainableFeedbackThanks => 'شكرًا — هنحسن التوصيات بناءً على رأيك';
  @override
  String get explainableFeedbackLearned => 'اتعلمنا من تقييمك';

  @override
  String get sentimentTitle => 'تحليل المشاعر';
  @override
  String get sentimentSubtitle => 'ملخص ذكي لتقييمات المشترين';
  @override
  String get sentimentOverall => 'المشاعر العامة';
  @override
  String get sentimentPositive => 'إيجابي';
  @override
  String get sentimentNeutral => 'محايد';
  @override
  String get sentimentNegative => 'سلبي';
  @override
  String get sentimentPros => 'ليه عجب المشترين';
  @override
  String get sentimentCons => 'ليه مش عاجب المشترين';
  @override
  String get sentimentAspects => 'الجوانب الرئيسية';
  @override
  String get sentimentSummary => 'الملخص';
  @override
  String get sentimentMentions => 'ذكر';

  @override
  String get redirecting => 'بيحولك للموقع...';
  @override
  String get openInBrowser => 'فتح في المتصفح';
  @override
  String get bestWebsite => 'أفضل موقع';
  @override
  String get bestDeal => 'أفضل صفقة';
  @override
  String get save => 'حفظ';
  @override
  String get remove => 'إزالة';
  @override
  String get add => 'إضافة';
  @override
  String get build => 'بناء';
  @override
  String get track => 'تتبّع';
  @override
  String get compare => 'قارن';
  @override
  String get alternatives => 'بدائل';
  @override
  String get collections => 'مجموعات';
  @override
  String get analytics => 'تحليلات';
  @override
  String get activity => 'النشاط';
  @override
  String get wishlist => 'قائمة الرغبات';
  @override
  String get preferences => 'التفضيلات';
  @override
  String get privacy => 'الخصوصية';
  @override
  String get merchants => 'التجار';
  @override
  String get aiAssistant => 'المساعد الذكي';
  @override
  String get visualSearch => 'البحث بالصورة';
  @override
  String get priceTracking => 'تتبع الأسعار';
  @override
  String get compatibility => 'التوافق';
  @override
  String get duplicates => 'التكرار';
  @override
  String get why => 'ليه؟';
  @override
  String get learnMore => 'اعرف أكتر';
  @override
  String get clearAll => 'مسح الكل';
  @override
  String get enabled => 'مفعّل';
  @override
  String get disabled => 'متعطّل';
  @override
  String get optional => 'اختياري';
  @override
  String get delete => 'حذف';
  @override
  String get rename => 'إعادة تسمية';
  @override
  String get back => 'رجوع';
  @override
  String get continueLabel2 => 'متابعة';
  @override
  String get notNow => 'مش دلوقتي';
  @override
  String get tryAgain => 'حاول تاني';
  @override
  String get offlineMode => 'وضع عدم الاتصال';
  @override
  String get offlineHint => 'أنت أوفلاين — بنعرض آخر محتوى محفوظ';
  @override
  String get cachedData => 'بيانات محفوظة';
  @override
  String minutesAgo(int minutes) => 'منذ $minutes دقيقة';
  @override
  String hoursAgo(int hours) => 'منذ $hours ساعة';
  @override
  String daysAgo(int days) => 'منذ $days يوم';
}

class AppStringsEn implements AppStrings {
  const AppStringsEn();

  @override
  String get navHome => 'Home';
  @override
  String get navCategory => 'Category';
  @override
  String get navCart => 'Cart';
  @override
  String get navProfile => 'Profile';

  @override
  String get topSelling => 'Top selling';
  @override
  String get topRated => 'Top Rated';
  @override
  String get discover => 'Discover';
  @override
  String get recommendedForYou => 'Recommended for you';
  @override
  String get offLabel => 'off';
  @override
  String get endsTomorrow => 'Ends tomorrow';
  @override
  String endsInDays(int days) => 'Ends in $days days';

  @override
  String get welcomeTo => 'Welcome to';
  @override
  String get welcomeTagline => 'Style your spaces & shop for all your decor needs';
  @override
  String get getStarted => 'Get Started';

  @override
  String get onboardingTitle1 => 'Effortlessly organize your decor and shopping with decoze';
  @override
  String get onboardingDescription1 =>
      'Confidently navigate your decor journey, ensuring a stylish and productive path to your dream space with decoze';
  @override
  String get onboardingTitle2 => 'Stay connected with your design team anytime, anywhere';
  @override
  String get onboardingDescription2 =>
      "In today's dynamic decor world, staying connected with your design team is key to success with decoze.";
  @override
  String get onboardingTitle3 => 'Discover all the features decoze has to offer';
  @override
  String get onboardingDescription3 =>
      "Dive into decoze's multitude of features by exploring its diverse functionalities.";
  @override
  String get next => 'Next';
  @override
  String get skip => 'Skip';

  @override
  String get search => 'Search';
  @override
  String get searchHint => 'Ask for anything... e.g. cheap bedroom furniture';
  @override
  String get topSearches => 'Top Searches';
  @override
  List<String> get topSearchSuggestions =>
      const ['Bed', 'Lamp', 'Plastic Plants', 'Carpet', 'Sofa', 'Blue Chairs'];
  @override
  String get noResultsForFilter => 'No results match this filter';
  @override
  String noResultsFor(String query) => 'No results for "$query"';

  @override
  String get filterTitle => 'Filter';
  @override
  String get priceRange => 'Price Range';
  @override
  String get upTo => 'Up to';
  @override
  String get filterCategories => 'Categories';
  @override
  String get filterProducts => 'Products';
  @override
  String get filterColors => 'Colors';
  @override
  String get apply => 'Apply';

  @override
  String get languageTitle => 'Language';
  @override
  String get languageArabic => 'العربية';
  @override
  String get languageEnglish => 'English';

  @override
  String get seeTranslation => 'See translation';
  @override
  String get showOriginal => 'Show original';
  @override
  String get translating => 'Translating...';

  @override
  String get cartTitle => 'My Cart';
  @override
  String get checkOut => 'Check Out';
  @override
  String get emptyCart => 'Your cart is empty.';
  @override
  String get subtotal => 'Subtotal';
  @override
  String get discount => 'Discount';
  @override
  String get taxAndFees => 'Tax and Fees';
  @override
  String get delivery => 'Delivery';
  @override
  String get total => 'Total';
  @override
  String get checkoutTitle => 'Checkout';
  @override
  String get shippingAddress => 'Shipping Address';
  @override
  String get chooseShippingType => 'Choose Shipping Type';
  @override
  String get orderList => 'Order List';
  @override
  String get payment => 'Payment';
  @override
  String get shippingEconomical => 'Economical';
  @override
  String get shippingExpress => 'Express';
  @override
  String get arrivalEconomical => 'Estimated arrival: 5-7 days';
  @override
  String get arrivalExpress => 'Estimated arrival: 1-2 days';
  @override
  String get paymentMethodTitle => 'Payment Method';
  @override
  String get paypal => 'PayPal';
  @override
  String get cashMoney => 'Cash Money';
  @override
  String get selectPaymentMethod => 'Select the payment method you want to use.';
  @override
  String get paymentMethodsTitle => 'Payments Methods';
  @override
  String get addNewMethod => 'Add New Method';
  @override
  String get paymentComingSoon => 'Will be enabled with a real payment gateway later.';
  @override
  String get paymentSuccessful => 'Successful!';
  @override
  String get paymentSuccessDescription => 'Payment successful for your purchase.';

  @override
  String get securityTitle => 'Security';
  @override
  String get rememberMe => 'Remember me';
  @override
  String get biometricId => 'Biometric ID';
  @override
  String get googleAuthenticator => 'Google Authenticator';
  @override
  String get changePin => 'Change PIN';
  @override
  String get changePassword => 'Change Password';
  @override
  String get notificationsTitle => 'Notifications';
  @override
  String get notifGeneral => 'General Notification';
  @override
  String get notifSound => 'Sound';
  @override
  String get notifSoundCall => 'Sound Call';
  @override
  String get notifVibrate => 'Vibrate';
  @override
  String get notifSpecialOffers => 'Special Offers';
  @override
  String get notifPayments => 'Payments';
  @override
  String get notifPromo => 'Promo and discount';
  @override
  String get notifCashback => 'Cashback';

  @override
  String get favouriteTitle => 'Favourite';
  @override
  String get emptyFavourites => 'Your favourite list\nis empty';
  @override
  String get profileTitle => 'Profile';
  @override
  String get confirmLogout => 'Are you sure you want to log out?';
  @override
  String get cancel => 'Cancel';
  @override
  String get logout => 'Logout';
  @override
  String get ordersTitle => 'Orders';
  @override
  String get noOrders => 'No previous orders.';
  @override
  String get trackOrder => 'Track Order';
  @override
  String get backToHome => 'Back To Home';
  @override
  String get estimatedDelivery => 'Estimated Delivery';
  @override
  String hoursLabel(int hours) => '$hours Hours';

  @override
  String get addToCart => 'Add To Cart';
  @override
  String get addedToCart => 'Added to cart.';
  @override
  String get userReviews => 'User Reviews';
  @override
  String reviewsCount(int count) => '$count+ Reviews';
  @override
  String get noReviewsYet => 'No reviews yet.';
  @override
  String get seeAll => 'See all';
  @override
  String get writeReview => 'Write a Review';
  @override
  String get yourRating => 'Your Rating';
  @override
  String get reviewCommentHint => 'Share your thoughts about this product...';
  @override
  String get submitReview => 'Submit Review';
  @override
  String get reviewSubmitted => 'Your review has been submitted.';
  @override
  String get pleaseSelectRating => 'Please select a rating first.';
  @override
  String get signInToReview => 'Sign in to write a review.';
  @override
  String get editReview => 'Edit Review';
  @override
  String get deleteReview => 'Delete Review';
  @override
  String get confirmDeleteReview => 'Are you sure you want to delete your review?';
  @override
  String get reviewUpdated => 'Your review has been updated.';
  @override
  String get reviewDeleted => 'Your review has been deleted.';

  @override
  String get noNotificationsYet => 'No notifications yet.';
  @override
  String get notifNewOrderTitle => 'New order';
  @override
  String notifNewOrderBody(String customerName, String amount) =>
      'New order from $customerName — $amount';
  @override
  String get notifOrderStatusTitle => 'Update on your order';
  @override
  String notifOrderStatusBody(String orderId, String status) =>
      'Order #${orderId.substring(0, orderId.length < 6 ? orderId.length : 6)} is now: $status';

  @override
  String get signIn => 'Sign in';
  @override
  String get signUp => 'Sign up';
  @override
  String get orContinueWith => 'or continue with';
  @override
  String get alreadyHaveAccount => 'Already have an account? Sign in';
  @override
  String get emailHint => 'Email';
  @override
  String get passwordHint => 'Password';
  @override
  String get confirmPasswordHint => 'Confirm password';
  @override
  String loginTo(String appName) => 'Login to $appName';
  @override
  String createAccountTitle(String appName) => 'Create your \n$appName account';
  @override
  String get emailRequired => 'Please enter your email';
  @override
  String get emailInvalid => 'Invalid email format';
  @override
  String get passwordTooShort => 'Password must be at least 6 characters';
  @override
  String get passwordsDontMatch => "Passwords don't match";
  @override
  String get dontHaveAccount => "Don't have an account? Sign up";

  @override
  String get categoriesTitle => 'Categories';
  @override
  String get noProductsInCategory => 'No products in this category.';

  @override
  String get editProfileTitle => 'Edit Profile';
  @override
  String get firstNameHint => 'First Name';
  @override
  String get lastNameHint => 'Last Name';
  @override
  String get dateOfBirthHint => 'Date of Birth';
  @override
  String get phoneNumberHint => 'Phone Number';
  @override
  String get genderHint => 'Gender';
  @override
  String get male => 'Male';
  @override
  String get female => 'Female';
  @override
  String get continueLabel => 'Continue';
  @override
  String get profileUpdated => 'Profile updated.';
  @override
  String get fieldRequired => 'This field is required.';

  @override
  String get addressesTitle => 'Addresses';
  @override
  String get addAddress => 'Add New Address';
  @override
  String get editAddress => 'Edit Address';
  @override
  String get deleteAddress => 'Delete Address';
  @override
  String get setAsDefault => 'Set as Default';
  @override
  String get defaultLabel => 'Default';
  @override
  String get addressLabelHint => 'Address label (Home, Work...)';
  @override
  String get fullNameHint => 'Full name for delivery';
  @override
  String get countryHint => 'Country';
  @override
  String get cityHint => 'City';
  @override
  String get areaHint => 'Area / District';
  @override
  String get streetHint => 'Street';
  @override
  String get buildingNumberHint => 'Building Number';
  @override
  String get floorHint => 'Floor (optional)';
  @override
  String get apartmentHint => 'Apartment (optional)';
  @override
  String get landmarkHint => 'Nearby landmark (optional)';
  @override
  String get noAddressesYet => 'No saved addresses yet.';
  @override
  String get addressSaved => 'Address saved.';
  @override
  String get confirmDeleteAddress => 'Are you sure you want to delete this address?';
  @override
  String get selectAddress => 'Select shipping address';
  @override
  String get addAddressToContinue => 'Add a shipping address to continue.';

  // =========================================================================
  // AI Shopping Features (English)
  // =========================================================================

  @override
  String get aiAssistantTitle => 'AI Assistant';
  @override
  String get aiAssistantHint => 'Ask about anything... e.g. cheap living room sofa';
  @override
  String get aiAssistantWelcome => 'Hi! I\'m your shopping assistant. Ask me anything — I\'ll search, compare, and recommend the best options with reasons.';
  @override
  String get aiAssistantSubtitle => 'Ask → Search → Compare → Recommend → Explain → Track → Redirect';
  @override
  String get aiThinking => 'Thinking...';
  @override
  String get aiSend => 'Send';
  @override
  String get aiVoiceSearch => 'Voice search';
  @override
  String get aiListening => 'Listening...';
  @override
  String get aiTapToSpeak => 'Tap to speak';
  @override
  String get aiSpeakNow => 'Speak now';
  @override
  String get aiVoiceNotSupported => 'Voice search is not supported on this device';
  @override
  String get aiQuickActions => 'Quick actions';
  @override
  String get aiActionSearch => 'Search';
  @override
  String get aiActionCompare => 'Compare';
  @override
  String get aiActionTrack => 'Track price';
  @override
  String get aiActionAlternatives => 'Alternatives';
  @override
  String get aiActionRedirect => 'Take me there';
  @override
  String get aiRecommendedBecause => 'Recommended because';
  @override
  String get aiAskAgain => 'Ask again';
  @override
  String get aiNewChat => 'New chat';
  @override
  String get aiClearHistory => 'Clear chat';
  @override
  String get aiClearHistoryConfirm => 'Clear the entire conversation?';
  @override
  String get aiHistoryCleared => 'Conversation cleared.';
  @override
  String get aiError => 'Something went wrong — try again.';
  @override
  String aiActionChip(String action) => action;

  @override
  String get visualSearchTitle => 'Visual Search';
  @override
  String get visualSearchHint => 'Upload a product photo and we\'ll find it in our catalog and other stores';
  @override
  String get visualSearchPickImage => 'Choose image';
  @override
  String get visualSearchTakePhoto => 'Take photo';
  @override
  String get visualSearchAnalyzing => 'Analyzing image...';
  @override
  String get visualSearchResults => 'Visual search results';
  @override
  String get visualSearchDetected => 'Detected product';
  @override
  String get visualSearchKeywords => 'Search keywords';
  @override
  String get visualSearchNoResults => 'No close matches found — try a clearer photo';
  @override
  String get visualSearchRetry => 'Try again';

  @override
  String get compareTitle => 'Compare Products';
  @override
  String get compareSubtitle => 'Compare price, rating, value, and availability';
  @override
  String get compareSelectProducts => 'Select products to compare';
  @override
  String get compareProducts => 'Products';
  @override
  String get compareSelectHint => 'Pick 2–4 products from the catalog';
  @override
  String get compareSelected => 'Selected';
  @override
  String get compareAddMore => 'Add another';
  @override
  String get compareClear => 'Clear all';
  @override
  String get compareWinner => 'Overall best pick';
  @override
  String get compareSummary => 'Comparison summary';
  @override
  String get compareWhy => 'Why is this the best?';
  @override
  String get compareBestPrice => 'Best price';
  @override
  String get compareBestRating => 'Best rating';
  @override
  String get compareBestValue => 'Best value';
  @override
  String get compareAvailability => 'Availability';
  @override
  String get comparePopularity => 'Popularity';
  @override
  String get compareFreshness => 'Freshness';
  @override
  String get compareEmpty => 'No products to compare';
  @override
  String get compareMinProducts => 'Select at least two products';
  @override
  String compareSelectedCount(int count) => '$count selected';

  @override
  String get priceTrackingTitle => 'Price Tracking';
  @override
  String get priceTrackingSubtitle => 'Price history and drop alerts';
  @override
  String get priceHistory => 'Price history';
  @override
  String get currentPrice => 'Current price';
  @override
  String get lowestPrice => 'Lowest price';
  @override
  String get highestPrice => 'Highest price';
  @override
  String get priceDropSince => 'Drop from peak';
  @override
  String get addPriceAlert => 'New price alert';
  @override
  String get alertTypeTarget => 'Target price';
  @override
  String get alertTypeDrop => 'Drop by percent';
  @override
  String get alertTypeAvailability => 'Back in stock';
  @override
  String get targetPriceHint => 'The price you want to be notified about';
  @override
  String get percentDropHint => 'Drop percentage (e.g. 10 = 10%)';
  @override
  String get createAlert => 'Create alert';
  @override
  String get alertCreated => 'Alert created';
  @override
  String get alertCreatedDesc => 'We\'ll watch the price and notify you when it changes.';
  @override
  String get activeAlerts => 'Active alerts';
  @override
  String get noActiveAlerts => 'No active alerts';
  @override
  String get alertFor => 'Alert for';
  @override
  String get alertTriggered => 'Alert triggered';
  @override
  String get alertNowTriggered => 'Alert triggered just now — check your notifications.';
  @override
  String get alertDisable => 'Disable';
  @override
  String get alertEnable => 'Enable';
  @override
  String get alertDelete => 'Delete alert';
  @override
  String get alertDeleteConfirm => 'Delete this alert?';
  @override
  String get priceHistoryDays => 'Last 90 days';
  @override
  String pricePerUnit(String symbol) => '$symbol per unit';
  @override
  String notifPriceDropTitle() => 'Price drop';
  @override
  String notifPriceDropBody(String title, String price) => 'Price dropped to $price — $title';
  @override
  String notifBackInStockTitle() => 'Back in stock';
  @override
  String notifBackInStockBody(String title) => '$title is available again from the merchant.';

  @override
  String get alternativesTitle => 'Alternatives';
  @override
  String get alternativesSubtitle => 'Cheaper / better / similar / newer';
  @override
  String get alternativesCheaper => 'Cheaper';
  @override
  String get alternativesBetter => 'Better';
  @override
  String get alternativesSimilar => 'Similar';
  @override
  String get alternativesNewer => 'Newer';
  @override
  String get alternativesAll => 'All';
  @override
  String get alternativesSavings => 'Savings';
  @override
  String get alternativesWhy => 'Why this alternative?';
  @override
  String get alternativesEmpty => 'No good alternatives right now';
  @override
  String get alternativesViewProduct => 'View product';

  @override
  String get wishlistTitle => 'Wishlist';
  @override
  String get wishlistSubtitle => 'Your saved products with price tracking';
  @override
  String get wishlistEmpty => 'Your wishlist is empty';
  @override
  String get wishlistEmptyHint => 'Save products here and we\'ll alert you on price drops or availability';
  @override
  String get wishlistAddTarget => 'Set target price';
  @override
  String get wishlistTargetPrice => 'Target price';
  @override
  String get wishlistNotifyDrop => 'Notify me on price drop';
  @override
  String get wishlistNotifyAvailability => 'Notify me when available';
  @override
  String get wishlistRemove => 'Remove';
  @override
  String get wishlistPriceAlertSet => 'Price alert set';
  @override
  String get wishlistCurrentPrice => 'Current price';
  @override
  String get wishlistTargetReached => 'Target reached';
  @override
  String get wishlistBelowTarget => 'Below target';
  @override
  String get wishlistAboveTarget => 'Above target';
  @override
  String get wishlistAdded => 'Added to wishlist';
  @override
  String get wishlistRemoved => 'Removed from wishlist';

  @override
  String get collectionsTitle => 'My Collections';
  @override
  String get collectionsSubtitle => 'Product sets built by AI';
  @override
  String get collectionsEmpty => 'No collections yet';
  @override
  String get collectionsEmptyHint => 'Describe a setup (e.g. "modern living room under $500") and we\'ll build it for you';
  @override
  String get collectionsNew => 'New collection';
  @override
  String get collectionBuilderTitle => 'Collection Builder';
  @override
  String get collectionBuilderHint => 'Describe the setup you want in your own words...';
  @override
  String get collectionBuilderExample => 'e.g. Calm Scandinavian bedroom on a budget';
  @override
  String get collectionBuilderBudget => 'Budget (optional)';
  @override
  String get collectionBuilderName => 'Collection name';
  @override
  String get collectionBuilderBuild => 'Build collection';
  @override
  String get collectionBuilderBuilding => 'Building your collection...';
  @override
  String get collectionBuilderBuilt => 'Your collection is ready';
  @override
  String get collectionBuilderBuiltDesc => 'We picked products that work together based on your description';
  @override
  String get collectionProducts => 'Collection products';
  @override
  String get collectionTotal => 'Total price';
  @override
  String get collectionDelete => 'Delete collection';
  @override
  String get collectionDeleteConfirm => 'Delete this collection?';
  @override
  String get collectionAddMore => 'Add product';
  @override
  String get collectionRemove => 'Remove from collection';
  @override
  String get collectionRename => 'Rename';
  @override
  String get collectionCreated => 'Collection created';
  @override
  String get collectionUpdated => 'Collection updated';

  @override
  String get shoppingProfileTitle => 'Shopping Profile';
  @override
  String get shoppingProfileSubtitle => 'Preferences that power personalization';
  @override
  String get preferredCategories => 'Preferred categories';
  @override
  String get preferredColors => 'Preferred colors';
  @override
  String get budgetRange => 'Budget range';
  @override
  String get budgetMin => 'Minimum';
  @override
  String get budgetMax => 'Maximum';
  @override
  String get styleKeywords => 'Style keywords';
  @override
  String get styleKeywordsHint => 'e.g. modern, minimalist, rustic';
  @override
  String get qualityPreference => 'Quality preference';
  @override
  String get qualityValue => 'Best value';
  @override
  String get qualityBalanced => 'Balanced';
  @override
  String get qualityPremium => 'Premium quality';
  @override
  String get savePreferences => 'Save preferences';
  @override
  String get preferencesSaved => 'Preferences saved';
  @override
  String get privacyTitle => 'Privacy';
  @override
  String get privacySubtitle => 'Control your data and personalization';
  @override
  String get privacyPersonalization => 'Personalized recommendations';
  @override
  String get privacyPersonalizationDesc => 'Use my activity and preferences for recommendations';
  @override
  String get privacyActivity => 'Activity tracking';
  @override
  String get privacyActivityDesc => 'Record my searches, views, and comparisons';
  @override
  String get privacyAnalytics => 'Analytics sharing';
  @override
  String get privacyAnalyticsDesc => 'Send aggregated usage statistics';
  @override
  String get privacyClearData => 'Clear my data';
  @override
  String get privacyClearDataConfirm => 'This will clear your preferences, activity, and feedback — continue?';
  @override
  String get privacyDataCleared => 'Your personal data has been cleared';
  @override
  String get privacyLearnMore => 'How do we use your data?';

  @override
  String get activityTitle => 'Shopping Memory';
  @override
  String get activitySubtitle => 'Your recent in-app activity';
  @override
  String get activityRecentSearches => 'Recent searches';
  @override
  String get activityRecentlyViewed => 'Recently viewed';
  @override
  String get activityRecentComparisons => 'Recent comparisons';
  @override
  String get activityPurchases => 'Purchases';
  @override
  String get activityEmpty => 'No activity yet';
  @override
  String get activityClear => 'Clear activity';
  @override
  String get activityClearConfirm => 'Clear all activity history?';
  @override
  String get activityCleared => 'Activity history cleared';
  @override
  String get activityViewedProduct => 'Viewed product';
  @override
  String get activitySearchedFor => 'Searched for';
  @override
  String get activityCompared => 'Compared';
  @override
  String get activityPurchased => 'Purchased';
  @override
  String get activityRedirected => 'Redirected to';
  @override
  String activityTimeAgo(int minutes) {
    if (minutes < 1) return 'just now';
    if (minutes < 60) return '$minutes min ago';
    final hours = (minutes / 60).round();
    if (hours < 24) return '$hours hr ago';
    final days = (hours / 24).round();
    return '$days days ago';
  }
  @override
  String get activityJustNow => 'just now';

  @override
  String get analyticsTitle => 'Analytics';
  @override
  String get analyticsSubtitle => 'Your activity and recommendation performance';
  @override
  String get analyticsYourActivity => 'Your activity';
  @override
  String get analyticsRecommendations => 'Recommendations';
  @override
  String get analyticsSearches => 'Searches';
  @override
  String get analyticsViews => 'Views';
  @override
  String get analyticsComparisons => 'Comparisons';
  @override
  String get analyticsPurchases => 'Purchases';
  @override
  String get analyticsRedirects => 'Site redirects';
  @override
  String get analyticsAlertsTriggered => 'Alerts triggered';
  @override
  String get analyticsSavings => 'Price savings';
  @override
  String get analyticsTopCategories => 'Top categories';
  @override
  String get analyticsWeeklyActivity => 'Weekly activity';
  @override
  String get analyticsRecShown => 'Recommendations shown';
  @override
  String get analyticsRecClicked => 'Clicked';
  @override
  String get analyticsRecPurchased => 'Accepted (purchased)';
  @override
  String get analyticsRecPositive => 'Positive feedback';
  @override
  String get analyticsRecNegative => 'Negative feedback';
  @override
  String get analyticsAcceptanceRate => 'Acceptance rate';
  @override
  String get analyticsCtr => 'Click-through rate';
  @override
  String get analyticsPositiveRate => 'Satisfaction rate';
  @override
  String analyticsPercent(num value) => '${(value * 100).round()}%';
  @override
  String get analyticsNoData => 'Not enough data yet — use the app and your stats will appear here';

  @override
  String get merchantsTitle => 'Merchants';
  @override
  String get merchantsSubtitle => 'Trust and reliability of selling sites';
  @override
  String get merchantReliability => 'Reliability';
  @override
  String get merchantReviews => 'Rating';
  @override
  String get merchantShipping => 'Shipping';
  @override
  String get merchantReturns => 'Returns';
  @override
  String get merchantVerified => 'Verified';
  @override
  String get merchantNotVerified => 'Not verified';
  @override
  String get merchantVisitStore => 'Visit store';
  @override
  String get merchantViewSite => 'View site';
  @override
  String get merchantExcellent => 'Excellent';
  @override
  String get merchantGood => 'Good';
  @override
  String get merchantAverage => 'Average';
  @override
  String get merchantProducts => 'products';
  @override
  String get merchantLowestPrice => 'Lowest price';
  @override
  String get merchantFreeShipping => 'Free shipping';
  @override
  String merchantShippingCost(String symbol, String amount) => '$symbol$amount shipping';

  @override
  String get webSearchTitle => 'Web Search';
  @override
  String get webSearchSubtitle => 'We search multiple stores and compare prices';
  @override
  String get webSearchResults => 'Store results';
  @override
  String get webSearchNoResults => 'No external offers found — try different keywords';
  @override
  String get webSearchBestDeal => 'Best deal';
  @override
  String get webSearchCheapest => 'Cheapest';
  @override
  String webSearchFrom(String merchant) => 'from $merchant';
  @override
  String get webSearchInStock => 'In stock';
  @override
  String get webSearchOutOfStock => 'Out of stock';
  @override
  String get webSearchFreeShipping => 'Free shipping';
  @override
  String get webSearchShipping => 'Shipping';
  @override
  String get webSearchCompareAll => 'Compare all';
  @override
  String get webSearchTrackThis => 'Track this price';
  @override
  String get webSearchViewDeal => 'View deal';
  @override
  String get webSearchLastSeen => 'Last seen';

  @override
  String get compatibilityTitle => 'Goes well with';
  @override
  String get compatibilitySubtitle => 'Products that complement this one';
  @override
  String get compatibilityGoesWith => 'Pairs with';
  @override
  String get compatibilityEmpty => 'No matching products right now';
  @override
  String get compatibilityFrequentlyBought => 'Frequently bought together';

  @override
  String get duplicatesTitle => 'Duplicate Detection';
  @override
  String get duplicatesSubtitle => 'Same product on multiple sites';
  @override
  String get duplicatesFound => 'Duplicate group found';
  @override
  String get duplicatesAlsoAt => 'Also available at';
  @override
  String get duplicatesSimilar => 'Similarity';
  @override
  String get duplicatesConfidence => 'Detection confidence';

  @override
  String get duplicatesEmpty => 'No duplicates detected yet';

  @override
  String get explainableWhyRecommended => 'Why recommended for you?';
  @override
  String get explainableScore => 'Match score';
  @override
  String get explainableFactors => 'Scoring factors';
  @override
  String get explainableFeedbackPositive => 'Good recommendation';
  @override
  String get explainableFeedbackNegative => 'Not a fit';
  @override
  String get explainableFeedbackThanks => 'Thanks — we\'ll improve recommendations based on your feedback';
  @override
  String get explainableFeedbackLearned => 'Learned from your feedback';

  @override
  String get sentimentTitle => 'Sentiment Analysis';
  @override
  String get sentimentSubtitle => 'Smart summary of buyer reviews';
  @override
  String get sentimentOverall => 'Overall sentiment';
  @override
  String get sentimentPositive => 'Positive';
  @override
  String get sentimentNeutral => 'Neutral';
  @override
  String get sentimentNegative => 'Negative';
  @override
  String get sentimentPros => 'What buyers love';
  @override
  String get sentimentCons => 'What buyers didn\'t love';
  @override
  String get sentimentAspects => 'Key aspects';
  @override
  String get sentimentSummary => 'Summary';
  @override
  String get sentimentMentions => 'mentions';

  @override
  String get redirecting => 'Redirecting...';
  @override
  String get openInBrowser => 'Open in browser';
  @override
  String get bestWebsite => 'Best website';
  @override
  String get bestDeal => 'Best deal';
  @override
  String get save => 'Save';
  @override
  String get remove => 'Remove';
  @override
  String get add => 'Add';
  @override
  String get build => 'Build';
  @override
  String get track => 'Track';
  @override
  String get compare => 'Compare';
  @override
  String get alternatives => 'Alternatives';
  @override
  String get collections => 'Collections';
  @override
  String get analytics => 'Analytics';
  @override
  String get activity => 'Activity';
  @override
  String get wishlist => 'Wishlist';
  @override
  String get preferences => 'Preferences';
  @override
  String get privacy => 'Privacy';
  @override
  String get merchants => 'Merchants';
  @override
  String get aiAssistant => 'AI Assistant';
  @override
  String get visualSearch => 'Visual Search';
  @override
  String get priceTracking => 'Price Tracking';
  @override
  String get compatibility => 'Compatibility';
  @override
  String get duplicates => 'Duplicates';
  @override
  String get why => 'Why?';
  @override
  String get learnMore => 'Learn more';
  @override
  String get clearAll => 'Clear all';
  @override
  String get enabled => 'Enabled';
  @override
  String get disabled => 'Disabled';
  @override
  String get optional => 'Optional';
  @override
  String get delete => 'Delete';
  @override
  String get rename => 'Rename';
  @override
  String get back => 'Back';
  @override
  String get continueLabel2 => 'Continue';
  @override
  String get notNow => 'Not now';
  @override
  String get tryAgain => 'Try again';
  @override
  String get offlineMode => 'Offline mode';
  @override
  String get offlineHint => 'You\'re offline — showing your last saved content';
  @override
  String get cachedData => 'Saved data';
  @override
  String minutesAgo(int minutes) => '$minutes min ago';
  @override
  String hoursAgo(int hours) => '$hours hr ago';
  @override
  String daysAgo(int days) => '$days days ago';
}
