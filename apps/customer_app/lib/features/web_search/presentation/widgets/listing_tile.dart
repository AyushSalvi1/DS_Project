import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// كارت عرض خارجي واحد —
/// بيعرض السعر والتاجر
/// والتوفر + أزرار "زيارة
/// المتجر" و"تتبع السعر".
class ListingTile extends StatelessWidget {
  final ExternalListingEntity listing;
  final String uid;
  final bool isBestDeal;

  const ListingTile({
    super.key,
    required this.listing,
    required this.uid,
    this.isBestDeal = false,
  });

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final strings = context.strings;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openUrl(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة العرض.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: listing.imageUrl == null
                        ? Container(
                            width: 64,
                            height: 64,
                            color: brand.surface,
                            child: Icon(
                              Icons.storefront_outlined,
                              color: brand.textSecondary,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: listing.imageUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: 64,
                              height: 64,
                              color: brand.surface,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),

                  // العنوان والبائع.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isBestDeal)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: brand.accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              strings.webSearchBestDeal,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: brand.onAccent,
                              ),
                            ),
                          ),
                        Text(
                          listing.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.storefront,
                              size: 14,
                              color: brand.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                strings.webSearchFrom(
                                  listing.merchantId,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: brand.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // السعر.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${brand.currencySymbol} ${listing.effectivePrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: brand.accent,
                        ),
                      ),
                      if (listing.originalPrice != null &&
                          listing.originalPrice! > listing.price)
                        Text(
                          '${brand.currencySymbol} ${listing.originalPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: brand.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // التوفر + الشحن + التقييم.
              Row(
                children: [
                  // التوفر.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: listing.isInStock
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      listing.isInStock
                          ? strings.webSearchInStock
                          : strings.webSearchOutOfStock,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: listing.isInStock
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                  if (listing.shippingCost != null) ...[
                    const SizedBox(width: 10),
                    Text(
                      listing.shippingCost == 0
                          ? strings.webSearchFreeShipping
                          : strings.webSearchShipping,
                      style: TextStyle(
                        fontSize: 11,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                  if (listing.deliveryDays != null) ...[
                    const SizedBox(width: 10),
                    Icon(
                      Icons.local_shipping,
                      size: 14,
                      color: brand.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${listing.deliveryDays}d',
                      style: TextStyle(
                        fontSize: 11,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (listing.rating > 0) ...[
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      listing.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: brand.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 10),

              // أزرار الإجراء.
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openUrl(context),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: Text(strings.webSearchViewDeal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // تتبع السعر.
                  OutlinedButton.icon(
                    onPressed: () => _trackPrice(context),
                    icon: const Icon(Icons.trending_down, size: 16),
                    label: Text(strings.webSearchTrackThis),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يفتح رابط المنتج في
  /// المتصفح الخارجي ويسجل
  /// التحويل في التحليلات.
  Future<void> _openUrl(BuildContext context) async {
    final url = listing.productUrl;
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // بنسجل التحويل (تحليلات
    // + ذاكرة التسوق).
    unawaited(
      MerchantRepositoryImpl().recordRedirect(uid, listing),
    );

    // بنسجل نشاط "تحويل"
    // في ذاكرة التسوق.
    unawaited(
      ActivityRepositoryImpl().recordActivity(
        UserActivityEntity(
          id: 'activity-${DateTime.now().millisecondsSinceEpoch}',
          uid: uid,
          type: ActivityType.redirect,
          productId: listing.productId,
          query: listing.title,
          timestamp: DateTime.now(),
        ),
      ),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _trackPrice(BuildContext context) {
    // بيضيف تنبيه سعر مستهدف
    // للعرض ده عبر الـ repository
    // مباشرة (مش Cubit — مفيش
    // Cubit متسجل في الشاشة دي).
    unawaited(
      PriceTrackingRepositoryImpl().addAlert(
        PriceAlertEntity(
          id: 'alert-${DateTime.now().millisecondsSinceEpoch}',
          uid: uid,
          productId: listing.productId,
          listingId: listing.id,
          type: PriceAlertType.targetPrice,
          targetPrice: listing.effectivePrice,
          active: true,
          createdAt: DateTime.now(),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.alertCreated),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
