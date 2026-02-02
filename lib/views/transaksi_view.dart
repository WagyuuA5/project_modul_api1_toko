
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_login.dart';
import '../widgets/bottom_nav.dart';

class TransaksiView extends StatefulWidget {
  const TransaksiView({super.key});

  @override
  State<TransaksiView> createState() => _TransaksiViewState();
}

class _TransaksiViewState extends State<TransaksiView> {
  String? _userName;
  String? _userRole;
  
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TRX-001',
      'customer': 'John Doe',
      'total': 85000,
      'payment': 'Cash',
      'status': 'Selesai',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'items': [
        {'name': 'Indomie Goreng', 'qty': 5, 'price': 3500},
        {'name': 'Aqua 600ml', 'qty': 10, 'price': 3000},
      ],
    },
    {
      'id': 'TRX-002',
      'customer': 'Jane Smith',
      'total': 45000,
      'payment': 'QRIS',
      'status': 'Selesai',
      'time': DateTime.now().subtract(const Duration(hours: 4)),
      'items': [
        {'name': 'Rinso 500g', 'qty': 2, 'price': 12500},
        {'name': 'Aqua 600ml', 'qty': 5, 'price': 3000},
      ],
    },
    {
      'id': 'TRX-003',
      'customer': 'Robert Johnson',
      'total': 120000,
      'payment': 'Debit Card',
      'status': 'Selesai',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'items': [
        {'name': 'Indomie Goreng', 'qty': 20, 'price': 3500},
        {'name': 'Rinso 500g', 'qty': 3, 'price': 12500},
      ],
    },
    {
      'id': 'TRX-004',
      'customer': 'Lisa Wong',
      'total': 23000,
      'payment': 'Cash',
      'status': 'Pending',
      'time': DateTime.now().subtract(const Duration(minutes: 30)),
      'items': [
        {'name': 'Aqua 600ml', 'qty': 5, 'price': 3000},
        {'name': 'Snack Ringan', 'qty': 2, 'price': 4000},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final user = await UserLogin.getFromPrefs();
    if (mounted) {
      setState(() {
        _userName = user?.nama ?? 'Kasir';
        _userRole = user?.role?.toUpperCase() ?? 'KASIR';
      });
    }
  }

  Future<void> _logout() async {
    await UserLogin.clearPrefs();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'qris':
        return Colors.blue;
      case 'debit card':
        return Colors.purple;
      case 'credit card':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showTransactionDetail(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction['id'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(
                        transaction['status'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(transaction['status']),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Pelanggan: ${transaction['customer']}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Waktu: ${DateFormat('dd/MM/yyyy HH:mm').format(transaction['time'])}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const Text(
                  'Detail Item',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...transaction['items'].map<Widget>((item) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item['qty']}x ${item['name']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                              .format(item['qty'] * item['price']),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  )
                ).toList(),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                          .format(transaction['total']),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Metode Pembayaran:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Chip(
                      label: Text(
                        transaction['payment'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getPaymentColor(transaction['payment']),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startNewTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Memulai transaksi baru...'),
        backgroundColor: Colors.green[700],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[700]!, Colors.green[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.point_of_sale,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kasir Aktif',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userName ?? 'Kasir',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.person, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  _userRole ?? 'KASIR',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.receipt, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  '${_transactions.length} Transaksi',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari transaksi...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.green),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'all',
                      child: Text('Semua Transaksi'),
                    ),
                    const PopupMenuItem(
                      value: 'today',
                      child: Text('Hari Ini'),
                    ),
                    const PopupMenuItem(
                      value: 'completed',
                      child: Text('Selesai'),
                    ),
                    const PopupMenuItem(
                      value: 'pending',
                      child: Text('Pending'),
                    ),
                  ],
                  onSelected: (value) {
                    // Implement filter logic
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final transaction = _transactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () => _showTransactionDetail(transaction),
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.green[700],
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transaction['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            transaction['status'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                          backgroundColor: _getStatusColor(transaction['status']),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          transaction['customer'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yy HH:mm').format(transaction['time']),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getPaymentColor(transaction['payment']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getPaymentColor(transaction['payment']).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                transaction['payment'],
                                style: TextStyle(
                                  color: _getPaymentColor(transaction['payment']),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total:',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                                  .format(transaction['total']),
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(activePage: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startNewTransaction,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Transaksi Baru'),
        elevation: 4,
      ),
    );
  }
}