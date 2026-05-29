import 'package:flutter/material.dart';
import '../views/login_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Discover Latest\nTrends',
      subtitle: 'Explore the newest fashion trends and find\nyour unique style',
      illustration: _ShoppingIllustration(),
      accentColor: const Color(0xFFFF6B35),
    ),
    OnboardingData(
      title: 'Fast & Secure\nDelivery',
      subtitle: 'Get your orders delivered quickly and safely\nright to your doorstep',
      illustration: _DeliveryIllustration(),
      accentColor: const Color(0xFF2E7D32),
    ),
    OnboardingData(
      title: 'Easy & Secure\nPayment',
      subtitle: 'Pay with confidence using multiple\npayment methods available',
      illustration: _PaymentIllustration(),
      accentColor: const Color(0xFF1565C0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(parent: _contentController, curve: Curves.easeOut);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOut));
    _contentController.forward();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _contentController.reset();
    _contentController.forward();
  }

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginView(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.accentColor.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: -40,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: page.accentColor.withOpacity(0.05),
              ),
            ),
          ),

          Column(
            children: [
              SizedBox(
                height: size.height * 0.52,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (_, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _pages[index].illustration,
                    );
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SlideTransition(
                    position: _contentSlide,
                    child: FadeTransition(
                      opacity: _contentFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF8E8E9A),
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (index) {
                        final isActive = index == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? page.accentColor
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 36),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: _navigateToLogin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9E9E9E),
                              ),
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: _goToNext,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: page.accentColor,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: page.accentColor.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == _pages.length - 1
                                      ? 'Mulai'
                                      : 'Next',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final Widget illustration;
  final Color accentColor;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.illustration,
    required this.accentColor,
  });
}
class _ShoppingIllustration extends StatefulWidget {
  const _ShoppingIllustration();

  @override
  State<_ShoppingIllustration> createState() => _ShoppingIllustrationState();
}

class _ShoppingIllustrationState extends State<_ShoppingIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _float,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        ),
        child: SizedBox(
          width: 280,
          height: 260,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 40,
                top: 20,
                child: Container(
                  width: 160,
                  height: 210,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E7D32).withOpacity(0.3),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(
                            5,
                            (_) => Container(
                              width: 2,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: GridView.count(
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: [
                              _ProductCard(color: const Color(0xFF81C784)),
                              _ProductCard(color: const Color(0xFF4CAF50)),
                              _ProductCard(color: const Color(0xFFA5D6A7)),
                              _ProductCard(color: const Color(0xFF66BB6A)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                left: 0,
                bottom: 10,
                child: _PersonSilhouette(),
              ),
              Positioned(
                right: 0,
                bottom: 10,
                child: _CartWidget(),
              ),
              Positioned(
                right: 30,
                top: 30,
                child: Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFF6B35).withOpacity(0.8),
                  size: 22,
                ),
              ),
              Positioned(
                right: 55,
                top: 15,
                child: Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFF6B35).withOpacity(0.5),
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Color color;
  const _ProductCard({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Container(
            width: 24,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 16,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonSilhouette extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 160,
      child: Stack(
        children: [
          Positioned(
            left: 15,
            top: 30,
            child: Container(
              width: 38,
              height: 85,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 0,
            child: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB74D),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 55,
            child: Container(
              width: 20,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            left: -8,
            top: 90,
            child: Container(
              width: 28,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(Icons.shopping_bag, color: Colors.white, size: 14),
              ),
            ),
          ),
          Positioned(
            left: 15,
            top: 110,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF37474F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 16,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF37474F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 65,
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: const Center(
            child: Icon(
              Icons.shopping_cart_rounded,
              color: Color(0xFF2E7D32),
              size: 30,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF757575).withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF757575).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeliveryIllustration extends StatefulWidget {
  const _DeliveryIllustration();

  @override
  State<_DeliveryIllustration> createState() => _DeliveryIllustrationState();
}

class _DeliveryIllustrationState extends State<_DeliveryIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _move;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _move = Tween<double>(begin: -10, end: 10)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _move,
        builder: (_, child) => Transform.translate(
          offset: Offset(_move.value, 0),
          child: child,
        ),
        child: Container(
          width: 220,
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 70,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'On the way!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentIllustration extends StatefulWidget {
  const _PaymentIllustration();

  @override
  State<_PaymentIllustration> createState() => _PaymentIllustrationState();
}

class _PaymentIllustrationState extends State<_PaymentIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 220,
          height: 160,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1565C0).withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.credit_card_rounded,
                color: Colors.white,
                size: 60,
              ),
              const SizedBox(height: 12),
              const Text(
                '**** **** **** 1234',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Secure Payment',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}