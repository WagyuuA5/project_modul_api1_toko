// transaction_page.dart — Fixed: pakai TokoModel langsung (tanpa ProductModel mapping)
import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/cart_page.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/cart_icon_button.dart';

// ── Warna ────────────────────────────────────────────────────────────────────
const _kGreen = Color(0xFF2E7D32);
const _kSoftGreen = Color(0xFFE8F5E9);
const _kBg = Color(0xFFF4F7F4);

class TransactionPage extends StatefulWidget {
  final String userName;
  const TransactionPage({super.key, required this.userName});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _search = TextEditingController();
  String _selectedCat = 'Semua';
  String _sortBy = 'Default';

  final List<String> _cats = [
    'Semua',
    'Makanan',
    'Minuman',
    'Elektronik',
    'Kebutuhan Rumah',
  ];
  final List<String> _sorts = ['Default', 'Harga ↑', 'Harga ↓', 'Nama A-Z'];

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: _kBg,
      body: Consumer<ProductProvider>(
        builder: (ctx, pp, _) {
          // ── Loading state ────────────────────────────────────────────────
          if (pp.isLoading) {
            return _loadingView();
          }
          // ── Error state ──────────────────────────────────────────────────
          if (pp.error != null && pp.products.isEmpty) {
            return _errorView(pp);
          }

          // ── Filter & sort ────────────────────────────────────────────────
          // FIXED: pakai TokoModel langsung, field Indonesia
          var list = pp.products.where((p) {
            final matchSearch = (p.nama_barang ?? '').toLowerCase().contains(
              _search.text.toLowerCase(),
            );
            final matchCat =
                _selectedCat == 'Semua' || (p.kategori ?? '') == _selectedCat;
            return matchSearch && matchCat && !p.isOutOfStock;
          }).toList();

          switch (_sortBy) {
            case 'Harga ↑':
              list.sort((a, b) => (a.harga ?? 0).compareTo(b.harga ?? 0));
              break;
            case 'Harga ↓':
              list.sort((a, b) => (b.harga ?? 0).compareTo(a.harga ?? 0));
              break;
            case 'Nama A-Z':
              list.sort(
                (a, b) => (a.nama_barang ?? '').compareTo(b.nama_barang ?? ''),
              );
              break;
          }

          // FIXED: tidak ada lagi mapping ke ProductModel — langsung pakai list TokoModel
          return CustomScrollView(
            slivers: [
              // ── App Bar dengan search ──────────────────────────────────
              _buildSliverAppBar(context, list.length),

              // ── Filter chips ───────────────────────────────────────────
              SliverToBoxAdapter(child: _buildFilters()),

              // ── Info row ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${list.length} produk tersedia',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.sort_rounded,
                                size: 14,
                                color: _kGreen,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _sortBy,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _kGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 14,
                                color: _kGreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Grid produk ─────────────────────────────────────────────
              list.isEmpty
                  ? SliverFillRemaining(child: _emptyView())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          // FIXED: langsung pass TokoModel ke ProductCard
                          (_, i) => ProductCard(product: list[i]),
                          childCount: list.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                      ),
                    ),
            ],
          );
        },
      ),

      // ── FAB keranjang ────────────────────────────────────────────────────
      floatingActionButton: Consumer<CartProvider>(
        builder: (_, cart, __) {
          if (cart.itemCount == 0) return const SizedBox();
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _kGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_cart_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rp ${cart.totalPrice}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, int count) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: true,
      pinned: true,
      backgroundColor: _kGreen,
      foregroundColor: Colors.white,
      actions: const [CartIconButton()],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 72, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Halo, ${widget.userName} 👋',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Mau beli apa hari ini?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 72, 12),
        title: Container(
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
            ],
          ),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 16,
                color: Colors.grey,
              ),
              suffixIcon: _search.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 14),
                      onPressed: _search.clear,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SizedBox(
        height: 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = _selectedCat == _cats[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = _cats[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: on ? _kGreen : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _cats[i],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: on ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSortSheet() => showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Urutkan Produk',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ..._sorts.map(
            (s) => ListTile(
              leading: Icon(
                s == _sortBy
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: s == _sortBy ? _kGreen : Colors.grey,
              ),
              title: Text(
                s,
                style: TextStyle(
                  fontWeight: s == _sortBy
                      ? FontWeight.w700
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() => _sortBy = s);
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  Widget _loadingView() => Scaffold(
    backgroundColor: _kBg,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _kSoftGreen,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              color: _kGreen,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Memuat produk...',
            style: TextStyle(
              fontSize: 15,
              color: _kGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _errorView(ProductProvider pp) => Scaffold(
    backgroundColor: _kBg,
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 40,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gagal memuat produk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              pp.error ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: pp.fetchProducts,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: _kSoftGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.search_off_rounded, size: 40, color: _kGreen),
        ),
        const SizedBox(height: 16),
        const Text(
          'Tidak ada produk',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Coba ubah filter atau kata kunci pencarian',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  );
}
