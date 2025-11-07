import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'pages/dashboard_page.dart';
import 'pages/transaction_page.dart';
import 'pages/report_page.dart';

void main() {
  runApp(const KoenkuApp());
}

class KoenkuApp extends StatelessWidget {
  const KoenkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koenku',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _transactions = [];
  double _saldo = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('transactions');
    if (jsonStr != null) {
      try {
        final List decoded = jsonDecode(jsonStr);
        final loaded = decoded.cast<Map<String, dynamic>>();
        setState(() {
          _transactions = loaded;
          _saldo = _calculateSaldo(_transactions);
        });
      } catch (_) {
        // jika parsing gagal, kosongkan
        setState(() {
          _transactions = [];
          _saldo = 0.0;
        });
      }
    }
  }

  double _calculateSaldo(List<Map<String, dynamic>> txs) {
    double total = 0;
    for (var tx in txs) {
      final amount = (tx['amount'] ?? 0).toDouble();
      if (tx['isIncome'] == true) {
        total += amount;
      } else {
        total -= amount;
      }
    }
    return total;
  }

  /// Simpan banyak transaksi (dipanggil oleh TransactionPage)
  Future<void> _saveTransactions(List<Map<String, dynamic>> newTxs) async {
    setState(() {
      _transactions.addAll(newTxs);
      _saldo = _calculateSaldo(_transactions);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', jsonEncode(_transactions));
  }

  /// Update seluruh daftar transaksi (misal setelah hapus di ReportPage)
  Future<void> _updateTransactions(List<Map<String, dynamic>> updated) async {
    setState(() {
      _transactions = updated;
      _saldo = _calculateSaldo(_transactions);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', jsonEncode(_transactions));
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(transactions: _transactions, saldo: _saldo),
      TransactionPage(
        onSaveTransactions: _saveTransactions,
        onFinish: () {
          // setelah selesai di TransactionPage langsung ke Beranda
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      ReportPage(
        transactions: _transactions,
        onUpdateTransactions: _updateTransactions,
      ),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Transaksi'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Laporan'),
        ],
      ),
    );
  }
}
