import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_app/features/ai_assistant/presentation/cubit/assistant_cubit.dart';
import 'package:customer_app/features/product/presentation/cubit/product_cubit.dart';
import 'package:customer_app/features/product/presentation/cubit/product_state.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// فقاعة رسالة واحدة في
/// المحادثة — نص + كروت
/// منتجات مرتبطة + اقتراحات.
class AssistantMessageBubble extends StatelessWidget {
  final AssistantMessageEntity message;
  final ValueChanged<ProductEntity> onProductTap;

  const AssistantMessageBubble({
    super.key,
    required this.message,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    const brand = BrandConfig.decoze;
    final isUser = message.role == AssistantRole.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // نص الرسالة.
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isUser ? brand.accent : brand.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: isUser ? brand.onAccent : brand.textPrimary,
              ),
            ),
          ),

          // كروت المنتجات المرتبطة.
          if (message.productIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            _ProductCarousel(
              productIds: message.productIds,
              onProductTap: onProductTap,
            ),
          ],

          // اقتراحات سريعة تحت
          // رد المساعد.
          if (!isUser && message.suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final suggestion in message.suggestions)
                  ActionChip(
                    label: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 12,
                        color: brand.accent,
                      ),
                    ),
                    side: BorderSide(color: brand.accent.withValues(alpha: 0.4)),
                    onPressed: () {
                      // بتنفّذ الاقتراح
                      // كسؤال جديد.
                      context.read<AssistantCubit>().runSuggestion(suggestion);
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// شريط أفقي من كروت المنتجات
/// المرتبطة برد المساعد.
class _ProductCarousel extends StatelessWidget {
  final List<String> productIds;
  final ValueChanged<ProductEntity> onProductTap;

  const _ProductCarousel({
    required this.productIds,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: productIds.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 150,
            child: _AssistantProductCard(
              productId: productIds[index],
              onTap: onProductTap,
            ),
          );
        },
      ),
    );
  }
}

/// كارت منتج داخل المحادثة —
/// بنحمل المنتج بالـ ID.
class _AssistantProductCard extends StatelessWidget {
  final String productId;
  final ValueChanged<ProductEntity> onTap;

  const _AssistantProductCard({
    required this.productId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductCubit(
        productRepository: ProductRepositoryImpl(),
      )..loadProduct(productId),
      child: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is! ProductLoaded) {
            return Card(
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final product = state.product;
          const brand = BrandConfig.decoze;

          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onTap(product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: CachedNetworkImage(
                      imageUrl: product.thumbnail,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(
                        color: brand.surface,
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${brand.currencySymbol} ${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: brand.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
