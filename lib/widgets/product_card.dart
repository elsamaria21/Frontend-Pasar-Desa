import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  bool get _soldOut => product.stock <= 0;

  @override
  Widget build(BuildContext context) {
    final cartColor = _soldOut ? const Color(0xFF9AA39E) : AppColors.green;

    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: const Color(0xFFE5E9E6)),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.05,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF0F3F1),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.muted,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              product.shortName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              '${product.seller} • ${product.unit}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 7.5, color: AppColors.muted),
            ),
            const SizedBox(height: 3),
            Money(value: product.price, size: 11),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFB300), size: 11),
                Text(
                  ' ${product.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 8),
                ),
                const Spacer(),
                InkWell(
                  onTap: _soldOut
                      ? null
                      : () => context.read<CartProvider>().add(product),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: cartColor,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _soldOut ? 'Stok Habis' : 'Keranjang',
                        style: TextStyle(
                          fontSize: 8,
                          color: cartColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
