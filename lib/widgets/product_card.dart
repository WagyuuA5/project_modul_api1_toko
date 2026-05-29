import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider =
        Provider.of<CartProvider>(context, listen: false);

    final cartItem =
        cartProvider.getItemByProduct(product);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: product.image != null &&
                    product.image!.isNotEmpty
                ? Image.network(
                    product.image!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Row(
                  children: [

                    Text(
                      'Rp ${_formatPrice(product.finalPrice)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),

                    if (product.hasDiscount) ...[
                      const SizedBox(width: 8),

                      Text(
                        'Rp ${_formatPrice(product.originalPrice)}',
                        style: TextStyle(
                          decoration:
                              TextDecoration.lineThrough,
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  'Stok: ${product.stock}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 8),

                if (cartItem == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cartProvider.addItem(product);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                                '${product.name} ditambahkan'),
                            duration:
                                const Duration(seconds: 1),
                            backgroundColor:
                                const Color(0xFF2E7D32),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                                vertical: 8),
                      ),
                      child: const Text(
                        'Tambah',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  )

                else

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            const Color(0xFF2E7D32),
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            size: 18,
                            color:
                                Color(0xFF2E7D32),
                          ),
                          onPressed: () {
                            cartProvider.updateQuantity(
                              product,
                              cartItem.quantity - 1,
                            );
                          },
                        ),

                        Text(
                          '${cartItem.quantity}',
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
        
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                            color:
                                Color(0xFF2E7D32),
                          ),
                          onPressed: () {
                            cartProvider.updateQuantity(
                              product,
                              cartItem.quantity + 1,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}