// checkout_page.dart — Fixed: imageUrl diteruskan ke TransactionItem
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

// ── Warna ─────────────────────────────────────────────────────────────────────
const _kGreen     = Color(0xFF2E7D32);
const _kSoftGreen = Color(0xFFE8F5E9);

String _rp(int v) =>
    'Rp ${NumberFormat('#,###', 'id_ID').format(v)}';

// ══════════════════════════════════════════════════════════════════════════════
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _payment  = 'Bank Transfer (BCA)';
  String _shipping = 'Reguler (3-5 hari)';
  int    _ongkir   = 10000;
  String _address  = 'Jl. Contoh No. 123, Malang';
  bool   _loading  = false;

  final _payments = [
    {'label': 'Bank Transfer (BCA)',     'icon': Icons.account_balance_rounded},
    {'label': 'Bank Transfer (Mandiri)', 'icon': Icons.account_balance_rounded},
    {'label': 'E-Wallet (Dana)',          'icon': Icons.wallet_rounded},
    {'label': 'E-Wallet (OVO)',           'icon': Icons.wallet_rounded},
    {'label': 'COD (Bayar di Tempat)',    'icon': Icons.local_shipping_rounded},
  ];

  final _shippings = [
    {'name': 'Reguler (3-5 hari)', 'cost': 10000, 'icon': Icons.directions_bike_rounded},
    {'name': 'Express (1-2 hari)', 'cost': 20000, 'icon': Icons.electric_rickshaw_rounded},
    {'name': 'Same Day',           'cost': 35000, 'icon': Icons.flash_on_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final cart     = context.watch<CartProvider>();
    final subtotal = cart.totalPrice;
    final total    = subtotal + _ongkir;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F3),
      body: _loading ? _loadingView() : CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: _kGreen,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: const Text('Checkout',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Progress step ────────────────────────────────────────
                _StepBar(current: 1),
                const SizedBox(height: 20),

                // ── Alamat pengiriman ────────────────────────────────────
                _Section(
                  icon: Icons.location_on_rounded,
                  title: 'Alamat Pengiriman',
                  color: Colors.blue[600]!,
                  child: Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.home_rounded, color: Colors.blue[600], size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Alamat Utama',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(_address,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ])),
                    IconButton(
                      icon: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8)),
                        child: Icon(Icons.edit_rounded,
                            size: 16, color: Colors.blue[600]),
                      ),
                      onPressed: _editAddress,
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                // ── Ringkasan pesanan ────────────────────────────────────
                _Section(
                  icon: Icons.shopping_bag_rounded,
                  title: 'Ringkasan Pesanan',
                  color: Colors.orange[600]!,
                  badge: '${cart.itemCount} item',
                  child: Column(children: [
                    ...cart.items.map((item) => _OrderItemRow(item: item)),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _PriceRow(
                        label: 'Subtotal (${cart.itemCount} item)',
                        value: subtotal,
                        bold: false),
                  ]),
                ),
                const SizedBox(height: 14),

                // ── Pengiriman ───────────────────────────────────────────
                _Section(
                  icon: Icons.local_shipping_rounded,
                  title: 'Metode Pengiriman',
                  color: Colors.teal[600]!,
                  child: Column(
                    children: _shippings.map((s) {
                      final on = _shipping == s['name'];
                      return GestureDetector(
                        onTap: () => setState(() {
                          _shipping = s['name'] as String;
                          _ongkir   = s['cost'] as int;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: on ? _kSoftGreen : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: on ? _kGreen : Colors.grey[200]!,
                                width: on ? 1.5 : 1),
                          ),
                          child: Row(children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                  color: on ? _kGreen : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(s['icon'] as IconData,
                                  size: 17,
                                  color: on ? Colors.white : Colors.grey[600]),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(s['name'] as String,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: on ? _kGreen : Colors.black87))),
                            Text(_rp(s['cost'] as int),
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: on ? _kGreen : Colors.grey[700])),
                            const SizedBox(width: 8),
                            Icon(
                                on
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: on ? _kGreen : Colors.grey[300],
                                size: 20),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Metode pembayaran ────────────────────────────────────
                _Section(
                  icon: Icons.payment_rounded,
                  title: 'Metode Pembayaran',
                  color: Colors.purple[600]!,
                  child: Column(
                    children: _payments.map((p) {
                      final on = _payment == p['label'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _payment = p['label'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: on
                                ? const Color(0xFFF3E5F5)
                                : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: on
                                    ? Colors.purple[400]!
                                    : Colors.grey[200]!,
                                width: on ? 1.5 : 1),
                          ),
                          child: Row(children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                  color: on
                                      ? Colors.purple[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(p['icon'] as IconData,
                                  size: 17,
                                  color: on
                                      ? Colors.purple[700]
                                      : Colors.grey[600]),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(p['label'] as String,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: on
                                          ? Colors.purple[700]
                                          : Colors.black87)),
                            ),
                            Icon(
                                on
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color:
                                    on ? Colors.purple[400] : Colors.grey[300],
                                size: 20),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Ringkasan biaya ──────────────────────────────────────
                _Section(
                  icon: Icons.receipt_long_rounded,
                  title: 'Rincian Biaya',
                  color: _kGreen,
                  child: Column(children: [
                    _PriceRow(label: 'Subtotal', value: subtotal, bold: false),
                    const SizedBox(height: 6),
                    _PriceRow(
                        label: 'Ongkos Kirim ($_shipping)',
                        value: _ongkir,
                        bold: false),
                    const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1)),
                    _PriceRow(
                        label: 'Total Pembayaran',
                        value: total,
                        bold: true,
                        big: true),
                  ]),
                ),
              ]),
            ),
          ),
        ],
      ),

      // ── Bottom pay button ──────────────────────────────────────────────────
      bottomNavigationBar: _loading
          ? null
          : _BottomBar(
              total: total,
              itemCount: cart.itemCount,
              onPay: () => _pay(context, cart, total),
            ),
    );
  }

  // ── FIXED: imageUrl sekarang diteruskan dari product.image ─────────────────
  Future<void> _pay(BuildContext ctx, CartProvider cart, int total) async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));

    final tx = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId:
          'INV/${DateTime.now().year}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      items: cart.items.map((i) => TransactionItem(
            productName: i.productName,
            quantity: i.quantity,
            price: i.price,
            imageUrl: i.product.image, // ← FIXED: ambil dari TokoModel.image
          )).toList(),
      totalAmount: total,
      paymentMethod: _payment,
      status: 'Completed',
      shippingAddress: _address,
      shippingCost: _ongkir,
    );

    if (!ctx.mounted) return;
    ctx.read<TransactionProvider>().addTransaction(tx);
    cart.clearCart();
    setState(() => _loading = false);

    Navigator.pushReplacement(
        ctx,
        MaterialPageRoute(
            builder: (_) => PaymentSuccessPage(transaction: tx)));
  }

  void _editAddress() {
    final ctrl = TextEditingController(text: _address);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Ubah Alamat Pengiriman',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Masukkan alamat lengkap...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: _kGreen, width: 1.5)),
                prefixIcon: const Icon(Icons.location_on_rounded,
                    color: _kGreen),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _kGreen),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Batal',
                      style: TextStyle(color: _kGreen)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _address = ctrl.text.trim());
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Simpan',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _loadingView() => Container(
        color: const Color(0xFFF3F5F3),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                      color: _kSoftGreen, shape: BoxShape.circle),
                  child: const CircularProgressIndicator(
                      color: _kGreen, strokeWidth: 3),
                ),
                const SizedBox(height: 20),
                const Text('Memproses Pembayaran...',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kGreen)),
                const SizedBox(height: 8),
                Text('Mohon tunggu sebentar',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ]),
        ),
      );
}

// ── Bottom bar ────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int total, itemCount;
  final VoidCallback onPay;
  const _BottomBar(
      {required this.total, required this.itemCount, required this.onPay});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$itemCount item',
                  style:
                      TextStyle(fontSize: 11, color: Colors.grey[500])),
              const SizedBox(height: 2),
              const Text('Total Pembayaran',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            Text(_rp(total),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _kGreen)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: _kGreen.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.lock_rounded, size: 18),
                label: const Text('Bayar Sekarang',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),
        ]),
      );
}

// ── Step bar ──────────────────────────────────────────────────────────────────
class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    const steps = ['Keranjang', 'Checkout', 'Selesai'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
              child: Container(
                  height: 2,
                  color:
                      i < current * 2 ? _kGreen : Colors.grey[200]));
        }
        final idx  = i ~/ 2;
        final done = idx < current;
        final curr = idx == current;
        return Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: done || curr ? _kGreen : Colors.grey[200],
              shape: BoxShape.circle,
              border: curr
                  ? Border.all(
                      color: _kGreen.withOpacity(0.3), width: 3)
                  : null,
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : Text('${idx + 1}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: curr
                              ? Colors.white
                              : Colors.grey[400])),
            ),
          ),
          const SizedBox(height: 4),
          Text(steps[idx],
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: done || curr ? _kGreen : Colors.grey[400])),
        ]);
      }),
    );
  }
}

// ── Reusable section card ─────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;
  final String? badge;
  const _Section(
      {required this.icon,
      required this.title,
      required this.color,
      required this.child,
      this.badge});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
              if (badge != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(badge!,
                      style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ]),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ]),
      );
}

// ── Order item row ────────────────────────────────────────────────────────────
class _OrderItemRow extends StatelessWidget {
  final dynamic item; // CartItem
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          // FIXED: tampilkan foto produk dari network jika ada
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (item.product.image != null &&
                    (item.product.image as String).isNotEmpty)
                ? Image.network(
                    item.product.image.startsWith('http')
                        ? item.product.image
                        : 'https://learn.smktelkom-mlg.sch.id/api/${item.product.image}',
                    width: 42, height: 42, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgPlaceholder(),
                  )
                : _imgPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.productName,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${item.quantity}x  •  ${_rp(item.price)}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey[600])),
                ]),
          ),
          Text(_rp(item.price * item.quantity),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _kGreen)),
        ]),
      );

  Widget _imgPlaceholder() => Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: _kSoftGreen,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.shopping_bag_rounded,
            color: _kGreen, size: 20),
      );
}

// ── Price row ─────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final String label;
  final int value;
  final bool bold, big;
  const _PriceRow(
      {required this.label,
      required this.value,
      this.bold = false,
      this.big = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: big ? 15 : 13,
                  fontWeight:
                      bold ? FontWeight.w800 : FontWeight.normal,
                  color: big ? Colors.black87 : Colors.grey[700])),
          Text(_rp(value),
              style: TextStyle(
                  fontSize: big ? 18 : 13,
                  fontWeight:
                      bold ? FontWeight.w900 : FontWeight.w600,
                  color: big ? _kGreen : Colors.black87)),
        ],
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// PAYMENT SUCCESS PAGE
// ══════════════════════════════════════════════════════════════════════════════
class PaymentSuccessPage extends StatelessWidget {
  final TransactionModel transaction;
  const PaymentSuccessPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 20),

            // ── Animasi sukses ─────────────────────────────────────────────
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: _kGreen.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8))
                ],
              ),
              child:
                  const Icon(Icons.check_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 20),

            const Text('Pembayaran Berhasil! 🎉',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _kGreen)),
            const SizedBox(height: 6),
            Text('Pesanan kamu sedang diproses',
                style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 28),

            // ── Detail transaksi ───────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12)
                ],
              ),
              child: Column(children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _kGreen.withOpacity(0.06),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Column(children: [
                    Text(transaction.orderId,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: _kGreen)),
                    const SizedBox(height: 2),
                    Text(
                        DateFormat('dd MMMM yyyy, HH:mm')
                            .format(transaction.date),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _DetailRow('Status',
                        badge: 'Berhasil ✓', badgeColor: _kGreen),
                    const Divider(height: 20),
                    _DetailRow('Metode Bayar',
                        value: transaction.paymentMethod),
                    const Divider(height: 20),
                    _DetailRow('Alamat',
                        value: transaction.shippingAddress),
                    const Divider(height: 20),

                    // Item list dengan foto
                    ...transaction.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(children: [
                            // Foto item di success page
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: (item.imageUrl != null &&
                                      item.imageUrl!.isNotEmpty)
                                  ? Image.network(
                                      item.imageUrl!.startsWith('http')
                                          ? item.imageUrl!
                                          : 'https://learn.smktelkom-mlg.sch.id/api/${item.imageUrl}',
                                      width: 36, height: 36,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _successImgPlaceholder(),
                                    )
                                  : _successImgPlaceholder(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                  '${item.productName} x${item.quantity}',
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Text(_rp(item.price * item.quantity),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        )),

                    const Divider(height: 20),
                    Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Bayar',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                          Text(_rp(transaction.totalAmount),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: _kGreen)),
                        ]),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // ── Tombol aksi ────────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/history'),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Riwayat',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kGreen,
                    side: const BorderSide(color: _kGreen),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/'),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Beranda',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => Navigator.pushReplacementNamed(
                    context, '/transaction'),
                icon: const Icon(Icons.add_shopping_cart_rounded,
                    size: 18, color: _kGreen),
                label: const Text('Lanjut Belanja',
                    style: TextStyle(
                        color: _kGreen, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  backgroundColor: _kSoftGreen,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _successImgPlaceholder() => Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _kSoftGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.shopping_bag_rounded,
            color: _kGreen, size: 16),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final String? badge;
  final Color? badgeColor;
  const _DetailRow(this.label,
      {this.value, this.badge, this.badgeColor});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(width: 16),
          badge != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? _kGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: badgeColor ?? _kGreen)),
                )
              : Flexible(
                  child: Text(value ?? '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600))),
        ],
      );
}