// dashboard_view.dart — Fixed: ProductNetworkThumb inline, pakai TokoModel langsung
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/views/product_management_page.dart';
import 'package:flutter_application_1/models/transaction_model.dart';
import 'package:flutter_application_1/views/transaction_page.dart';
import 'package:flutter_application_1/views/transaction_history_page.dart';
import 'package:flutter_application_1/models/user_login.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart'; // TokoModel

// ── Warna ─────────────────────────────────────────────────────────────────────
const _kGreen      = Color(0xFF2E7D32);
const _kLightGreen = Color(0xFF43A047);
const _kSoftGreen  = Color(0xFFE8F5E9);
const _kBg         = Color(0xFFF8FAF8);
const _kTextDark   = Color(0xFF1B1B1B);
const _kTextGrey   = Color(0xFF9E9E9E);

const _baseUrl = 'https://learn.smktelkom-mlg.sch.id/api/';

String _fmtRp(int v) =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(v);

// ── ProductNetworkThumb ───────────────────────────────────────────────────────
// Widget reusable untuk menampilkan gambar produk dari network
class ProductNetworkThumb extends StatelessWidget {
  final String? imageUrl;
  final String? category;
  final double iconSize;

  const ProductNetworkThumb({
    super.key,
    this.imageUrl,
    this.category,
    this.iconSize = 28,
  });

  String _fullUrl() {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.startsWith('http')) return imageUrl!;
    return '$_baseUrl$imageUrl';
  }

  IconData _catIcon() {
    switch ((category ?? '').toLowerCase()) {
      case 'makanan':         return Icons.fastfood_rounded;
      case 'minuman':         return Icons.local_drink_rounded;
      case 'elektronik':      return Icons.devices_rounded;
      case 'kebutuhan rumah': return Icons.home_rounded;
      default:                return Icons.shopping_bag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _fullUrl();
    if (url.isEmpty) return _placeholder();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _placeholder(),
      loadingBuilder: (_, child, progress) => progress == null
          ? child
          : Container(
              color: _kSoftGreen,
              child: Center(
                child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: _kGreen),
                ),
              ),
            ),
    );
  }

  Widget _placeholder() => Container(
        color: _kSoftGreen,
        child: Center(
          child: Icon(_catIcon(), color: _kGreen, size: iconSize),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  UserLogin? _userObj;
  String _name = '';
  String _role = '';

  int _navIdx = 0;
  final PageController _pageCtrl = PageController();

  int _catIdx = 0;
  final List<String> _cats = [
    'Semua', 'Makanan', 'Minuman', 'Elektronik', 'Kebutuhan Rumah',
  ];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _getUserData() async {
    final user = await UserLogin.getFromPrefs();
    if (!mounted) return;
    setState(() {
      _userObj = user;
      _name    = user?.nama ?? 'Pelanggan';
      _role    = (user?.role ?? 'user').toUpperCase();
    });
  }

  void _go(int i) {
    setState(() => _navIdx = i);
    _pageCtrl.animateToPage(i,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: _kGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1400),
      ));
  }

  Future<void> _logout() async {
    await UserLogin.clearPrefs();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return _role == 'ADMIN' ? _adminScaffold() : _userScaffold();
  }

  // ── USER SCAFFOLD ──────────────────────────────────────────────────────────
  Widget _userScaffold() => Scaffold(
        backgroundColor: _kBg,
        body: PageView(
          controller: _pageCtrl,
          onPageChanged: (i) => setState(() => _navIdx = i),
          children: [_uHome(), _uTransaction(), _uHistory(), _uProfile()],
        ),
        bottomNavigationBar: _uNav(),
      );

  Widget _uNav() {
    final items = [
      {'ic': Icons.home_rounded,          'lb': 'Home'},
      {'ic': Icons.point_of_sale_rounded, 'lb': 'Beli'},
      {'ic': Icons.receipt_long_rounded,  'lb': 'Riwayat'},
      {'ic': Icons.person_rounded,        'lb': 'Profil'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final on = _navIdx == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _go(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                            color: on ? _kSoftGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(12)),
                        child: Icon(items[i]['ic'] as IconData,
                            size: 22,
                            color: on ? _kGreen : Colors.grey[400]),
                      ),
                      const SizedBox(height: 2),
                      Text(items[i]['lb'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                on ? FontWeight.w700 : FontWeight.w400,
                            color: on ? _kGreen : Colors.grey[400],
                          )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _uHome() => SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _uHeader()),
            SliverToBoxAdapter(child: _uSearchBar()),
            SliverToBoxAdapter(child: _uCats()),
            SliverToBoxAdapter(child: _uBanner()),
            SliverToBoxAdapter(child: _uQuickActions()),
            SliverToBoxAdapter(child: _uRecentProducts()),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      );

  Widget _uHeader() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              boxShadow: [BoxShadow(
                  color: _kLightGreen.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4))],
            ),
            child: Center(
              child: Text(
                _name.isEmpty ? 'P' : _name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Selamat datang kembali 👋',
                    style: TextStyle(fontSize: 12, color: _kTextGrey)),
                RichText(
                    text: TextSpan(
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _kTextDark),
                  children: [
                    const TextSpan(text: 'Hello, '),
                    TextSpan(
                        text: _name,
                        style: const TextStyle(color: _kGreen)),
                  ],
                )),
              ],
            ),
          ),
          _icBtn(Icons.notifications_none_rounded, () {}),
        ]),
      );

  Widget _icBtn(IconData ic, VoidCallback fn) => GestureDetector(
        onTap: fn,
        child: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(ic, size: 20, color: const Color(0xFF424242)),
        ),
      );

  Widget _uSearchBar() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
        child: GestureDetector(
          onTap: () => _go(1),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kSoftGreen, width: 1.5)),
            child: Row(children: [
              const SizedBox(width: 14),
              const Icon(Icons.search_rounded, color: _kTextGrey, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Cari produk...',
                      style: TextStyle(
                          color: Color(0xFFBDBDBD), fontSize: 14))),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_kLightGreen, _kGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('Cari',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
        ),
      );

  Widget _uCats() => Container(
        height: 50,
        color: Colors.white,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          itemCount: _cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = _catIdx == i;
            return GestureDetector(
              onTap: () {
                setState(() => _catIdx = i);
                _go(1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: on ? _kGreen : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: on
                      ? [BoxShadow(
                          color: _kGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(_cats[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          on ? FontWeight.w700 : FontWeight.w500,
                      color: on ? Colors.white : Colors.grey[600],
                    )),
              ),
            );
          },
        ),
      );

  Widget _uBanner() => Consumer<ProductProvider>(
        builder: (_, pp, __) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1B5E20),
                    Color(0xFF388E3C),
                    Color(0xFF66BB6A)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(
                  color: _kGreen.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8))],
            ),
            child: Stack(children: [
              Positioned(
                right: -20, top: -20,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6)),
                          child: const Text('✨ Produk Segar',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Text('${pp.products.length} Produk',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900)),
                        const Text('Tersedia untuk kamu hari ini',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _go(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 4))]),
                      child: const Text('Belanja\nSekarang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _kGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              height: 1.3)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );

  Widget _uQuickActions() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Aksi Cepat',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _kTextDark)),
          const SizedBox(height: 12),
          Row(children: [
            _quickCard(Icons.point_of_sale_rounded, 'Transaksi\nBaru',
                _kGreen, () => _go(1)),
            const SizedBox(width: 12),
            _quickCard(Icons.receipt_long_rounded, 'Riwayat\nBelanja',
                _kLightGreen, () => _go(2)),
            const SizedBox(width: 12),
            _quickCard(Icons.person_rounded, 'Profil\nSaya',
                Colors.purple, () => _go(3)),
            const SizedBox(width: 12),
            _quickCard(Icons.local_offer_rounded, 'Promo\nHari Ini',
                Colors.orange,
                () => _toast('Promo belum tersedia')),
          ]),
        ]),
      );

  Widget _quickCard(
          IconData ic, String label, Color col, VoidCallback fn) =>
      Expanded(
        child: GestureDetector(
          onTap: fn,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: col.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(ic, color: col, size: 20),
                ),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700]),
                    maxLines: 2),
              ],
            ),
          ),
        ),
      );

  Widget _uRecentProducts() => Consumer<ProductProvider>(
        builder: (_, pp, __) {
          final products = pp.products.take(6).toList();
          if (products.isEmpty) return const SizedBox();
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Produk Tersedia',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _kTextDark)),
                        Text('${pp.products.length} produk',
                            style: const TextStyle(
                                fontSize: 12, color: _kTextGrey)),
                      ],
                    ),
                    TextButton(
                        onPressed: () => _go(1),
                        child: const Text('Lihat Semua',
                            style: TextStyle(
                                color: _kGreen,
                                fontWeight: FontWeight.w700))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                    itemBuilder: (_, i) {
                      final p = products[i];
                      return GestureDetector(
                        onTap: () => _go(1),
                        child: Container(
                          width: 130,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 10,
                                offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                  // FIXED: p.image bukan p.imageUrl
                                  child: ProductNetworkThumb(
                                    imageUrl: p.image,
                                    category: p.category,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // FIXED: p.nama_barang bukan p.name
                                    Text(p.nama_barang ?? '',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _kTextDark),
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    // FIXED: p.formattedPrice sudah ada di TokoModel
                                    Text(p.formattedPrice,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            color: _kGreen)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );

  Widget _uTransaction() => TransactionPage(userName: _name);
  Widget _uHistory()     => const HistoryPage();

  Widget _uProfile() => Consumer<TransactionProvider>(
        builder: (_, trxProvider, __) {
          final trxs       = trxProvider.transactions;
          final totalSpend =
              trxs.fold(0, (s, r) => s + r.totalAmount);
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 10),
                Stack(alignment: Alignment.bottomRight, children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF1B5E20)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(
                          color: _kGreen.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8))],
                    ),
                    child: Center(
                      child: Text(
                        _name.isEmpty ? 'P' : _name[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8)]),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 16, color: _kGreen),
                  ),
                ]),
                const SizedBox(height: 14),
                Text(_name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _kTextDark)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                      color: _kSoftGreen,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('PELANGGAN',
                      style: TextStyle(
                          color: _kGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2)),
                ),
                const SizedBox(height: 24),
                Row(children: [
                  _statMini('${trxs.length}', 'Transaksi',
                      Icons.receipt_rounded),
                  const SizedBox(width: 12),
                  _statMini(_fmtRp(totalSpend), 'Total Belanja',
                      Icons.payments_rounded),
                ]),
                const SizedBox(height: 20),
                _card([
                  _pRow(Icons.person_outline_rounded, 'Nama', _name),
                  _div(),
                  _pRow(Icons.email_outlined, 'Email',
                      _userObj?.email ?? '-'),
                  _div(),
                  _pRow(Icons.phone_outlined, 'Telepon', '-'),
                ]),
                const SizedBox(height: 20),
                _card([
                  _mRow(Icons.point_of_sale_rounded,
                      'Buat Transaksi', () => _go(1)),
                  _div(),
                  _mRow(Icons.receipt_long_rounded,
                      'Riwayat Transaksi', () => _go(2)),
                  _div(),
                  _mRow(Icons.notifications_outlined, 'Notifikasi',
                      () {}),
                  _div(),
                  _mRow(Icons.help_outline_rounded, 'Bantuan', () {}),
                ]),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded,
                        color: Colors.red),
                    label: const Text('Keluar dari Akun',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.red, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          );
        },
      );

  Widget _card(List<Widget> ch) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))],
        ),
        child: Column(children: ch),
      );

  Widget _statMini(String val, String label, IconData ic) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: _kSoftGreen,
              borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(ic, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(val,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _kGreen),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10, color: _kTextGrey)),
                ],
              ),
            ),
          ]),
        ),
      );

  Widget _pRow(IconData ic, String label, String val) => ListTile(
        leading: Icon(ic, color: _kGreen, size: 20),
        title: Text(label,
            style:
                const TextStyle(fontSize: 12, color: _kTextGrey)),
        trailing: Text(val,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      );

  Widget _mRow(IconData ic, String label, VoidCallback fn) =>
      ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: _kSoftGreen,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(ic, color: _kGreen, size: 18),
        ),
        title: Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: _kTextGrey),
        onTap: fn,
      );

  Widget _div() => Divider(
      height: 1,
      color: Colors.grey[100],
      indent: 16,
      endIndent: 16);

  // ── ADMIN SCAFFOLD ─────────────────────────────────────────────────────────
  Widget _adminScaffold() {
    const titles = [
      'Dashboard Admin', 'Kelola Produk', 'Laporan', 'Manajemen User'
    ];
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        title: Text(titles[_navIdx.clamp(0, 3)],
            style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: _logout),
        ],
      ),
      body: PageView(
        controller: _pageCtrl,
        onPageChanged: (i) => setState(() => _navIdx = i),
        children: [
          _aHome(), _aProducts(), _aReports(), _aUsers()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded), label: 'Produk'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_alt_rounded), label: 'User'),
        ],
        currentIndex: _navIdx,
        selectedItemColor: _kGreen,
        unselectedItemColor: Colors.grey,
        onTap: _go,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
      ),
    );
  }

  Widget _aHome() => Consumer2<ProductProvider, TransactionProvider>(
        builder: (context, pp, trxProvider, _) {
          final trxs     = trxProvider.transactions;
          final totalRev =
              trxs.fold(0, (s, r) => s + r.totalAmount);
          final totalItems =
              trxs.fold(0, (s, r) => s + r.totalQuantity);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Admin ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(
                        color: _kGreen.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6))],
                  ),
                  child: Row(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle),
                      child: const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 30,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Admin Dashboard',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(_name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius:
                                    BorderRadius.circular(20)),
                            child: const Text('SUPER ADMIN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),

                // ── Ringkasan ────────────────────────────────────────
                const Text('Ringkasan',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kTextDark)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    _aStat('Total Penjualan', _fmtRp(totalRev),
                        Icons.payments_rounded, Colors.green,
                        '${trxs.length} trx'),
                    _aStat('Produk', '${pp.products.length}',
                        Icons.inventory_2_rounded, Colors.orange,
                        'item'),
                    _aStat(
                        'Stok Habis',
                        '${pp.products.where((p) => p.isOutOfStock).length}',
                        Icons.cancel_rounded,
                        Colors.red,
                        'produk'),
                    _aStat('Item Terjual', '$totalItems',
                        Icons.shopping_bag_rounded, Colors.purple,
                        'item'),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Aksi cepat ───────────────────────────────────────
                const Text('Aksi Cepat',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kTextDark)),
                const SizedBox(height: 12),
                Row(children: [
                  _aQuick(
                      Icons.add_circle_outline_rounded,
                      'Tambah\nProduk',
                      _kGreen,
                      () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ProductManagementPage()))),
                  const SizedBox(width: 12),
                  _aQuick(Icons.inventory_2_rounded, 'Kelola\nProduk',
                      _kLightGreen, () => _go(1)),
                  const SizedBox(width: 12),
                  _aQuick(Icons.bar_chart_rounded, 'Laporan',
                      Colors.orange, () => _go(2)),
                  const SizedBox(width: 12),
                  _aQuick(Icons.people_alt_rounded, 'Pengguna',
                      Colors.purple, () => _go(3)),
                ]),
                const SizedBox(height: 20),

                // ── Transaksi terbaru ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Transaksi Terbaru',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _kTextDark)),
                    TextButton(
                        onPressed: () => _go(2),
                        child: const Text('Lihat Semua',
                            style: TextStyle(color: _kGreen))),
                  ],
                ),
                const SizedBox(height: 8),
                trxs.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Center(
                            child: Text('Belum ada transaksi',
                                style:
                                    TextStyle(color: _kTextGrey))))
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4))],
                        ),
                        child: Column(
                            children: trxs
                                .take(3)
                                .map(_aTrxTile)
                                .toList()),
                      ),
                const SizedBox(height: 20),

                // ── Stok menipis ─────────────────────────────────────
                if (pp.products
                    .any((p) => p.isLowStock || p.isOutOfStock)) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red[700], size: 20),
                          const SizedBox(width: 8),
                          Text('Perlu Perhatian',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.red[800])),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const ProductManagementPage())),
                            child: const Text('Kelola',
                                style:
                                    TextStyle(color: _kGreen)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        ...pp.products
                            .where(
                                (p) => p.isLowStock || p.isOutOfStock)
                            .take(3)
                            .map(_aLowStock),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Produk terbaru ───────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Produk Terbaru',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _kTextDark)),
                    TextButton(
                        onPressed: () => _go(1),
                        child: const Text('Semua',
                            style: TextStyle(color: _kGreen))),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 170,
                  child: pp.products.isEmpty
                      ? Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(16)),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inventory_2_rounded,
                                  color: _kSoftGreen, size: 40),
                              const SizedBox(height: 8),
                              const Text('Belum ada produk',
                                  style: TextStyle(
                                      color: _kTextGrey)),
                              TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ProductManagementPage())),
                                child: const Text(
                                    'Tambah Sekarang',
                                    style: TextStyle(
                                        color: _kGreen)),
                              ),
                            ],
                          ))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: pp.products.take(8).length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, i) {
                            final p = pp.products[i];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ProductManagementPage())),
                              child: Container(
                                width: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.06),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3))],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius
                                                .vertical(
                                                top: Radius.circular(
                                                    16)),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            // FIXED: p.image bukan p.imageUrl
                                            ProductNetworkThumb(
                                              imageUrl: p.image,
                                              category: p.category,
                                            ),
                                            if (p.isOutOfStock)
                                              Container(
                                                color: Colors.black38,
                                                child: const Center(
                                                    child: Text(
                                                        'Habis',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w800))),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // FIXED: p.nama_barang
                                          Text(p.nama_barang ?? '',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w700),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          // FIXED: p.formattedPrice
                                          Text(p.formattedPrice,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  color: _kGreen)),
                                          // FIXED: p.stock (sudah ada getter di TokoModel)
                                          Text('Stok: ${p.stock}',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: p.isLowStock
                                                      ? Colors.orange
                                                      : _kTextGrey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );

  Widget _aStat(String title, String val, IconData ic, Color color,
          String sub) =>
      Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(ic, color: color, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(sub,
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),
              const SizedBox(height: 14),
              Text(val,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _kTextDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(title,
                  style: const TextStyle(
                      color: _kTextGrey, fontSize: 11)),
            ],
          ),
        ),
      );

  Widget _aQuick(
          IconData ic, String label, Color color, VoidCallback fn) =>
      Expanded(
        child: GestureDetector(
          onTap: fn,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(ic, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700]),
                    maxLines: 2),
              ],
            ),
          ),
        ),
      );

  Widget _aTrxTile(TransactionModel r) => ListTile(
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: _kSoftGreen,
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.receipt_rounded,
              color: _kGreen, size: 20),
        ),
        title: Text('Transaksi #${r.id}',
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: Text(
            DateFormat('dd/MM/yyyy HH:mm').format(r.date),
            style: const TextStyle(fontSize: 11)),
        trailing: Text(r.formattedTotal,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _kGreen,
                fontSize: 13)),
      );

  // FIXED: pakai TokoModel langsung, bukan AdminProduct
  Widget _aLowStock(TokoModel p) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 36, height: 36,
              // FIXED: p.image bukan p.imageUrl
              child: ProductNetworkThumb(
                  imageUrl: p.image,
                  category: p.category,
                  iconSize: 18),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIXED: p.nama_barang
                Text(p.nama_barang ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                    p.isOutOfStock
                        ? 'Stok HABIS!'
                        : 'Sisa ${p.stock} item',
                    style: TextStyle(
                        color: p.isOutOfStock
                            ? Colors.red[700]
                            : Colors.orange[700],
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const ProductManagementPage())),
            style: TextButton.styleFrom(foregroundColor: _kGreen),
            child: const Text('Restock',
                style: TextStyle(fontSize: 12)),
          ),
        ]),
      );

  Widget _aProducts() => const ProductManagementPage();

  Widget _aReports() =>
      Consumer2<ProductProvider, TransactionProvider>(
        builder: (_, pp, trxProvider, __) {
          final trxs     = trxProvider.transactions;
          final totalRev =
              trxs.fold(0, (s, r) => s + r.totalAmount);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14)),
                  child: Row(children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: _kGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '1 Jan 2024 – ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down_rounded,
                        color: _kTextGrey),
                  ]),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.4,
                  children: [
                    _rStat('Pendapatan', _fmtRp(totalRev), _kGreen),
                    _rStat('Transaksi', '${trxs.length}',
                        _kLightGreen),
                    _rStat(
                        'Item Terjual',
                        '${trxs.fold(0, (s, r) => s + r.totalQuantity)}',
                        Colors.orange),
                    _rStat('Produk', '${pp.products.length}',
                        Colors.purple),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            size: 60, color: Colors.grey[200]),
                        Text('Grafik Penjualan',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );

  Widget _rStat(String label, String val, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: _kTextGrey)),
          const SizedBox(height: 6),
          Text(val,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _aUsers() {
    final users = [
      {'name': 'Admin Utama', 'email': 'admin@toko.com',  'role': 'ADMIN', 'active': true},
      {'name': 'Kasir 1',     'email': 'kasir1@toko.com', 'role': 'KASIR', 'active': true},
      {'name': 'Kasir 2',     'email': 'kasir2@toko.com', 'role': 'KASIR', 'active': true},
      {'name': 'Kasir 3',     'email': 'kasir3@toko.com', 'role': 'KASIR', 'active': false},
      {'name': 'Supervisor',  'email': 'spv@toko.com',    'role': 'SPV',   'active': true},
    ];
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari pengguna...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => _toast('Tambah kasir'),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text('Tambah'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final u = users[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3))],
              ),
              child: Row(children: [
                Container(
                  width: 46, height: 46,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: _kSoftGreen),
                  child: Center(
                    child: Text((u['name'] as String)[0],
                        style: const TextStyle(
                            color: _kGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(u['name'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                        const SizedBox(width: 6),
                        if (!(u['active'] as bool))
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius:
                                    BorderRadius.circular(6)),
                            child: const Text('Nonaktif',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey)),
                          ),
                      ]),
                      Text(u['email'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: _kTextGrey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: _kSoftGreen,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(u['role'] as String,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _kGreen)),
                ),
                const SizedBox(width: 4),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded,
                      size: 18, color: _kTextGrey),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                        value: 'toggle',
                        child: Text((u['active'] as bool)
                            ? 'Nonaktifkan'
                            : 'Aktifkan')),
                    const PopupMenuItem(
                        value: 'del',
                        child: Text('Hapus',
                            style:
                                TextStyle(color: Colors.red))),
                  ],
                  onSelected: (v) =>
                      _toast('$v user ${u['name']}'),
                ),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}