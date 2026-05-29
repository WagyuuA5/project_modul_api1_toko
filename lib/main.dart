import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/transaction_provider.dart';
import 'views/splash_screen.dart';
import 'views/onboarding_screen.dart';
import 'views/login_view.dart';
import 'views/register_user_view.dart';
import 'views/dashboard_view.dart';
import 'views/transaction_page.dart';
import 'views/cart_page.dart';
import 'views/transaction_history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Toko Online',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,

          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
          ),

          scaffoldBackgroundColor:
              const Color(0xFFF8FAF8),

          primaryColor:
              const Color(0xFF2E7D32),

          appBarTheme: const AppBarTheme(
            backgroundColor:
                Color(0xFF2E7D32),
            foregroundColor:
                Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),

          elevatedButtonTheme:
              ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF2E7D32),
              foregroundColor:
                  Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12),
              ),
            ),
          ),

          inputDecorationTheme:
              InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF2E7D32),
                width: 2,
              ),
            ),
          ),

          bottomNavigationBarTheme:
              const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor:
                Color(0xFF2E7D32),
            unselectedItemColor:
                Colors.grey,
            type:
                BottomNavigationBarType.fixed,
            elevation: 8,
          ),
        ),

        initialRoute: '/splash',

        routes: {
          '/splash': (context) =>
              const SplashScreen(),

          '/onboarding': (context) =>
              const OnboardingScreen(),

          '/login': (context) =>
              const LoginView(),

          '/register': (context) =>
              const RegisterUserView(),

          '/dashboard': (context) =>
              const DashboardView(),

          '/cart': (context) =>
              const CartPage(),

          '/history': (context) =>
              const HistoryPage(),
        },

        onGenerateRoute: (settings) {
          if (settings.name == '/transaction') {
            final userName =
                settings.arguments is String
                    ? settings.arguments
                        as String
                    : 'Pengguna';

            return MaterialPageRoute(
              builder: (_) =>
                  TransactionPage(
                userName: userName,
              ),
            );
          }

          /// fallback jika route salah
          return MaterialPageRoute(
            builder: (_) =>
                const NotFoundPage(),
          );
        },
      ),
    );
  }
}
class NotFoundPage extends StatefulWidget {
  const NotFoundPage({super.key});

  @override
  State<NotFoundPage> createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredRoutes = [];

  final List<Map<String, dynamic>> _availableRoutes = [
    {
      'title': 'Beranda / Dashboard',
      'subtitle': 'Kembali ke halaman utama toko',
      'route': '/dashboard',
      'icon': Icons.home_rounded,
    },
    {
      'title': 'Keranjang Belanja',
      'subtitle': 'Lihat produk yang telah Anda pilih',
      'route': '/cart',
      'icon': Icons.shopping_cart_rounded,
    },
    {
      'title': 'Riwayat Transaksi',
      'subtitle': 'Periksa daftar transaksi Anda sebelumnya',
      'route': '/history',
      'icon': Icons.history_rounded,
    },
    {
      'title': 'Halaman Login',
      'subtitle': 'Masuk ke akun Anda kembali',
      'route': '/login',
      'icon': Icons.login_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _filteredRoutes = List.from(_availableRoutes);
  }

  void _filterRoutes(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRoutes = List.from(_availableRoutes);
      } else {
        _filteredRoutes = _availableRoutes
            .where((item) =>
                item['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
                item['subtitle'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              // Beautiful 404 Illustration representation
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.explore_off_rounded,
                    size: 72,
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: theme.primaryColor,
                  letterSpacing: 2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Halaman Tidak Ditemukan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Maaf, halaman yang Anda cari tidak dapat ditemukan. Cari menu atau gunakan pintasan di bawah untuk kembali menjelajah.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              
              // Clean Search Bar
              TextField(
                controller: _searchController,
                onChanged: _filterRoutes,
                decoration: InputDecoration(
                  hintText: 'Cari menu atau halaman...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _filterRoutes('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Dynamic results header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchController.text.isEmpty
                        ? 'Pintasan Menu Utama'
                        : 'Hasil Pencarian (${_filteredRoutes.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Dynamic list of routes
              if (_filteredRoutes.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'Pencarian tidak ditemukan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredRoutes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _filteredRoutes[index];
                    return InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, item['route']);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: theme.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['title'] as String,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['subtitle'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 28),
              
              // Primary button back to home
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}