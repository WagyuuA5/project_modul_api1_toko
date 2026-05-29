// history_page.dart — Modern E-Commerce Style Redesign
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

// ── Palet warna ───────────────────────────────────────────────────────────────
const _kGreen     = Color(0xFF2E7D32);
const _kSoftGreen = Color(0xFFE8F5E9);
const _kBg        = Color(0xFFF5F6FA);
const _kCard      = Colors.white;
const _kTextDark  = Color(0xFF1A1A2E);
const _kTextGrey  = Color(0xFF9E9E9E);

// ── Helper ────────────────────────────────────────────────────────────────────
const _baseUrl = 'https://learn.smktelkom-mlg.sch.id/api/';

String _imageUrl(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http')) return raw;
  return '$_baseUrl$raw';
}

bool _differentDay(DateTime a, DateTime b) =>
    a.day != b.day || a.month != b.month || a.year != b.year;

// ── Page ──────────────────────────────────────────────────────────────────────
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          final list = provider.transactions;

          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                expandedHeight: 110,
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                actions: [
                  if (list.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, size: 22),
                      tooltip: 'Hapus semua',
                      onPressed: () => _confirmClear(context, provider),
                    ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.fromLTRB(20, 0, 60, 16),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Riwayat Transaksi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (list.isNotEmpty)
                        Text(
                          '${list.length} transaksi',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70),
                        ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Opacity(
                        opacity: 0.06,
                        child: Icon(Icons.receipt_long_rounded,
                            size: 130, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Empty state ──────────────────────────────────────────────
              if (list.isEmpty)
                SliverFillRemaining(child: _EmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final trx = list[i];
                        final showDate = i == 0 ||
                            _differentDay(list[i - 1].date, trx.date);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showDate) _DateDivider(date: trx.date),
                            _TransactionCard(trx: trx),
                          ],
                        );
                      },
                      childCount: list.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, TransactionProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Semua Riwayat',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
            'Semua riwayat transaksi akan dihapus permanen. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearTransactions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ── Date divider ──────────────────────────────────────────────────────────────
class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Hari Ini';
    if (d == today.subtract(const Duration(days: 1))) return 'Kemarin';
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 6, left: 2),
      child: Row(children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            color: _kGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _label(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _kGreen,
            letterSpacing: 0.3,
          ),
        ),
      ]),
    );
  }
}

// ── Transaction card ──────────────────────────────────────────────────────────
class _TransactionCard extends StatelessWidget {
  final TransactionModel trx;
  const _TransactionCard({required this.trx});

  @override
  Widget build(BuildContext context) {
    final firstItem = trx.items.first;
    final extraCount = trx.items.length - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header order ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _kSoftGreen,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_rounded, size: 14, color: _kGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    trx.orderId,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _kGreen,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(trx.date),
                  style: const TextStyle(fontSize: 11, color: _kGreen),
                ),
              ],
            ),
          ),

          // ── Item pertama ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto produk
                _ProductImage(imageUrl: _imageUrl(firstItem.imageUrl)),
                const SizedBox(width: 12),

                // Info item
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kTextDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${firstItem.quantity}x',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _kTextDark),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          firstItem.formattedPrice,
                          style: const TextStyle(
                              fontSize: 12, color: _kTextGrey),
                        ),
                      ]),

                      // Kalau ada lebih dari 1 produk
                      if (extraCount > 0) ...[
                        const SizedBox(height: 6),
                        _MoreItems(items: trx.items.skip(1).toList()),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          Divider(height: 1, color: Colors.grey[100]),

          // ── Footer total + status ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              children: [
                // Payment method
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.payment_rounded,
                        size: 12, color: _kTextGrey),
                    const SizedBox(width: 4),
                    Text(
                      trx.paymentMethod,
                      style: const TextStyle(
                          fontSize: 10,
                          color: _kTextGrey,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
                const Spacer(),

                // Total
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${trx.totalQuantity} item',
                      style: const TextStyle(
                          fontSize: 10, color: _kTextGrey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trx.formattedTotal,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: _kGreen,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 10),

                // Status badge
                _StatusBadge(status: trx.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Product image widget ───────────────────────────────────────────────────────
class _ProductImage extends StatelessWidget {
  final String imageUrl;
  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      width: 64,
                      height: 64,
                      color: _kSoftGreen,
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _kGreen),
                        ),
                      ),
                    ),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        width: 64,
        height: 64,
        color: _kSoftGreen,
        child: const Icon(Icons.shopping_bag_outlined,
            color: _kGreen, size: 28),
      );
}

// ── Lebih banyak item (collapsed) ─────────────────────────────────────────────
class _MoreItems extends StatelessWidget {
  final List<TransactionItem> items;
  const _MoreItems({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Stack thumbnail kecil
        SizedBox(
          width: items.length > 2 ? 52.0 : (items.length * 20.0 + 8),
          height: 24,
          child: Stack(
            children: List.generate(
              items.length > 2 ? 2 : items.length,
              (i) => Positioned(
                left: i * 18.0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    color: _kSoftGreen,
                  ),
                  child: ClipOval(
                    child: items[i].imageUrl != null &&
                            items[i].imageUrl!.isNotEmpty
                        ? Image.network(
                            _imageUrl(items[i].imageUrl),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.shopping_bag_outlined,
                                    size: 12, color: _kGreen),
                          )
                        : const Icon(Icons.shopping_bag_outlined,
                            size: 12, color: _kGreen),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '+ ${items.length} produk lainnya',
          style: const TextStyle(
              fontSize: 11,
              color: _kTextGrey,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg, text;
    IconData icon;

    if (s == 'completed' || s == 'selesai') {
      bg = _kSoftGreen; text = _kGreen;
      icon = Icons.check_circle_rounded;
    } else if (s == 'pending' || s == 'menunggu') {
      bg = const Color(0xFFFFF8E1); text = const Color(0xFFF57F17);
      icon = Icons.schedule_rounded;
    } else if (s == 'cancelled' || s == 'dibatalkan') {
      bg = const Color(0xFFFFEBEE); text = const Color(0xFFC62828);
      icon = Icons.cancel_rounded;
    } else {
      bg = const Color(0xFFE3F2FD); text = const Color(0xFF1565C0);
      icon = Icons.local_shipping_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: text),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: text),
        ),
      ]),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: _kSoftGreen, shape: BoxShape.circle),
          child: const Icon(Icons.receipt_long_rounded,
              size: 50, color: _kGreen),
        ),
        const SizedBox(height: 20),
        const Text(
          'Belum Ada Transaksi',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _kTextDark),
        ),
        const SizedBox(height: 8),
        Text(
          'Riwayat pembelian kamu\nakan muncul di sini',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13, color: Colors.grey[500], height: 1.6),
        ),
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.store_rounded, size: 18),
          label: const Text('Mulai Belanja',
              style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 13),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ]),
    );
  }
}