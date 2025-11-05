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
        primarySwatch: Colors.indigo,
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

  /// 🔹 Load data dari SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('transactions');
    if (data != null) {
      final loadedTransactions =
          List<Map<String, dynamic>>.from(jsonDecode(data));
      setState(() {
        _transactions = loadedTransactions;
        _saldo = _calculateSaldo(_transactions);
      });
    }
  }

  /// 🔹 Hitung total saldo
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

  /// 🔹 Menyimpan transaksi baru
  Future<void> _saveTransaction(Map<String, dynamic> transaction) async {
    setState(() {
      _transactions.add(transaction);
      _saldo = _calculateSaldo(_transactions);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transactions', jsonEncode(_transactions));
  }

  /// 🔹 Inisialisasi halaman
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 🔹 Ubah halaman ketika tap menu bawah
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(transactions: _transactions, saldo: _saldo),
      TransactionPage(onSaveTransaction: _saveTransaction),
      ReportPage(transactions: _transactions),
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
