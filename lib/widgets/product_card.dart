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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: const Color(0xFFE5E9E6),
          ),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO PRODUK
            AspectRatio(
              aspectRatio: 1.05,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 5),

            // NAMA PRODUK
            Text(
              product.shortName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 2),

            // PENJUAL DAN UNIT
            Text(
              '${product.seller} • ${product.unit}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 7.5,
                color: AppColors.muted,
              ),
            ),

            const SizedBox(height: 3),

            // HARGA
            Money(
              value: product.price,
              size: 11,
            ),

            const SizedBox(height: 2),

            // RATING + KERANJANG
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFB300),
                  size: 11,
                ),
                Text(
                  ' ${product.rating}',
                  style: const TextStyle(
                    fontSize: 8,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    context.read<CartProvider>().add(product);
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.green,
                        size: 13,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'Keranjang',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.green,
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
