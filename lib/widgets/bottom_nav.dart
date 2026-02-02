
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  const BottomNav({super.key, required this.activePage});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String _role = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _selectedIndex = widget.activePage;
  }

  Future<void> _getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role') ?? '';
      if (mounted) {
        setState(() {
          _role = role.toUpperCase();
        });
      }
    } catch (e) {
      print('Error getting role: $e');
    }
  }

  void _getLink(int index) {
    if (index == _selectedIndex) return;

    if (_role == 'ADMIN') {
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (index == 1) {
        Navigator.pushReplacementNamed(context, '/produk');
      }
    } else if (_role == 'KASIR' || _role == 'USER') {
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else if (index == 1) {
        Navigator.pushReplacementNamed(context, '/transaksi');
      }
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    if (_role == 'ADMIN') {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: 'Produk',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale),
          label: 'Kasir',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Transaksi',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_role.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = _getBottomNavItems();

    return BottomNavigationBar(
      items: items,
      currentIndex: _selectedIndex,
      selectedItemColor: _role == 'ADMIN' ? Colors.blue[800] : Colors.green[700],
      unselectedItemColor: Colors.grey,
      onTap: _getLink,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
    );
  }
}