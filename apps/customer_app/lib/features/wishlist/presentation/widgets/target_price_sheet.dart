import 'package:customer_app/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:decoze_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ورقة تعيين السعر
/// المستهدف لعنصر في
/// قائمة الرغبات.
class TargetPriceSheet extends StatefulWidget {
  final String productId;
  final double? currentTarget;

  const TargetPriceSheet({
    super.key,
    required this.productId,
    this.currentTarget,
  });

  @override
  State<TargetPriceSheet> createState() => _TargetPriceSheetState();
}

class _TargetPriceSheetState extends State<TargetPriceSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentTarget?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final brand = BrandConfig.decoze;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.wishlistAddTarget,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: strings.targetPriceHint,
              prefixText: '${brand.currencySymbol} ',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context
                      .read<WishlistCubit>()
                      .setTargetPrice(
                        widget.productId,
                        null,
                      )
                      .then((_) => Navigator.of(context).pop()),
                  child: Text(strings.remove),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final target = double.tryParse(
                      _controller.text,
                    );
                    if (target == null) return;

                    context
                        .read<WishlistCubit>()
                        .setTargetPrice(
                          widget.productId,
                          target,
                        )
                        .then((_) => Navigator.of(context).pop());
                  },
                  child: Text(strings.save),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
