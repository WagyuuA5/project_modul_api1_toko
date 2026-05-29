// ============================================================
// cart_item_tile.dart — Modern Redesign
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item_model.dart';

const _kGreen     = Color(0xFF2E7D32);
const _kSoftGreen = Color(0xFFE8F5E9);

String _rp(int v) =>
    'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          // ── Gambar produk ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72, height: 72,
              child: _ProductImage(imageUrl: item.product.image),
            ),
          ),
          const SizedBox(width: 12),

          // ── Info produk ──────────────────────────────────────────────────
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Badge kategori
              if (item.product.kategori != null && item.product.kategori!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kSoftGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.product.kategori!,
                    style: const TextStyle(fontSize: 9, color: _kGreen, fontWeight: FontWeight.w700),
                  ),
                ),
              // Nama
              Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1B1B1B)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Harga satuan
              Text(
                _rp(item.price),
                style: const TextStyle(color: _kGreen, fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 2),
              // Subtotal
              Text(
                'Subtotal: ${_rp(item.subtotal)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
              ),
            ]),
          ),
          const SizedBox(width: 8),

          // ── Kontrol qty + hapus ──────────────────────────────────────────
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Tombol +/-
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F4F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                // Tombol kurang
                _QtyButton(
                  icon: item.quantity <= 1 ? Icons.delete_outline_rounded : Icons.remove_rounded,
                  iconColor: item.quantity <= 1 ? Colors.red[400]! : Colors.grey[700]!,
                  onTap: () => cart.updateQuantity(item.product, item.quantity - 1),
                ),
                // Angka qty
                SizedBox(
                  width: 28,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF1B1B1B)),
                  ),
                ),
                // Tombol tambah
                _QtyButton(
                  icon: Icons.add_rounded,
                  iconColor: _kGreen,
                  onTap: () => cart.updateQuantity(item.product, item.quantity + 1),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            // Tombol hapus
            GestureDetector(
              onTap: () => _confirmRemove(context, cart),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.delete_outline_rounded, size: 13, color: Colors.red[400]),
                  const SizedBox(width: 3),
                  Text('Hapus', style: TextStyle(fontSize: 11, color: Colors.red[400], fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  void _confirmRemove(BuildContext context, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          Container(width: 56, height: 56,
              decoration: BoxDecoration(color: Colors.red[50], shape: BoxShape.circle),
              child: Icon(Icons.delete_outline_rounded, color: Colors.red[400], size: 28)),
          const SizedBox(height: 12),
          const Text('Hapus dari keranjang?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'Item "${item.product.name}" akan dihapus dari keranjang.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Batal', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                cart.removeItem(item.product);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
              ),
              child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }
}

// ── Widget gambar produk ──────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, prog) =>
            prog == null ? child : _placeholder(loading: true),
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder({bool loading = false}) => Container(
    color: _kSoftGreen,
    child: Center(
      child: loading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _kGreen))
          : const Icon(Icons.shopping_bag_rounded, color: _kGreen, size: 28),
    ),
  );
}

// ── Tombol qty ────────────────────────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData  icon;
  final Color     iconColor;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 30, height: 30,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: iconColor),
    ),
  );
}