// ============================================================
// cart_page.dart — Modern Redesign
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/cart_item_tile.dart';
import 'package:flutter_application_1/services/checkout_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
// import '../widgets/cart_item_tile.dart';
// import 'checkout_page.dart';

const _kGreen     = Color(0xFF2E7D32);
const _kSoftGreen = Color(0xFFE8F5E9);
const _kBg        = Color(0xFFF3F5F3);

String _rp(int v) =>
    'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          return CustomScrollView(
            slivers: [
              // ── App bar ────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 100,
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                actions: [
                  if (cart.itemCount > 0)
                    TextButton.icon(
                      onPressed: () => _clearAll(ctx, cart),
                      icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white70, size: 18),
                      label: const Text('Kosongkan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  title: Row(children: [
                    const Text('Keranjang',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(width: 8),
                    if (cart.itemCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${cart.itemCount}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      ),
                  ]),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Konten keranjang ───────────────────────────────────────
              if (cart.itemCount == 0)
                SliverFillRemaining(child: _emptyCart(context))
              else ...[
                // Header info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cart.itemCount} item di keranjang',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                        Text('Total: ${_rp(cart.totalPrice)}',
                            style: const TextStyle(fontSize: 12, color: _kGreen, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),

                // List item
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => CartItemTile(item: cart.items[i]),
                      childCount: cart.items.length,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),

      // ── Bottom checkout bar ────────────────────────────────────────────────
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.itemCount == 0) return const SizedBox.shrink();
          return _CheckoutBar(cart: cart);
        },
      ),
    );
  }

  void _clearAll(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Kosongkan Keranjang', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Semua item akan dihapus dari keranjang. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); cart.clearCart(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400], foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }

  Widget _emptyCart(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 100, height: 100,
        decoration: const BoxDecoration(color: _kSoftGreen, shape: BoxShape.circle),
        child: const Icon(Icons.shopping_cart_outlined, size: 50, color: _kGreen),
      ),
      const SizedBox(height: 20),
      const Text('Keranjang Kosong', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1B1B1B))),
      const SizedBox(height: 8),
      Text('Tambahkan produk ke keranjang\nuntuk mulai belanja',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5)),
      const SizedBox(height: 28),
      ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.store_rounded, size: 18),
        label: const Text('Mulai Belanja', style: TextStyle(fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _kGreen, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    ]),
  );
}

// ── Bottom bar ────────────────────────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  final CartProvider cart;
  const _CheckoutBar({required this.cart});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4)),
      ],
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      // Ringkasan harga
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _kSoftGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${cart.itemCount} item dipilih',
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
            const SizedBox(height: 2),
            const Text('Total Belanja', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ])),
          Text(_rp(cart.totalPrice),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: _kGreen)),
        ]),
      ),
      const SizedBox(height: 12),

      // Tombol checkout
      SizedBox(
        width: double.infinity, height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: _kGreen.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const CheckoutPage())),
            icon: const Icon(Icons.shopping_cart_checkout_rounded, size: 20),
            label: const Text('Checkout Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),
    ]),
  );
}