import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'income'; // default

  // 🧠 Fungsi menyimpan transaksi baru ke SharedPreferences
  Future<void> _saveTransaction() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data terlebih dahulu!')),
      );
      return;
    }

    // 1️⃣ Buat objek transaksi baru
    final newTransaction = TransactionModel(
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: DateTime.now(),
      type: _selectedType,
    );

    // 2️⃣ Ambil data lama (jika ada)
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString('transactions');

    List<TransactionModel> transactions = [];
    if (storedData != null) {
      final List decoded = jsonDecode(storedData);
      transactions = decoded.map((e) => TransactionModel.fromMap(e)).toList();
    }

    // 3️⃣ Tambah transaksi baru
    transactions.add(newTransaction);

    // 4️⃣ Simpan kembali ke SharedPreferences
    final String encoded =
        jsonEncode(transactions.map((e) => e.toMap()).toList());
    await prefs.setString('transactions', encoded);

    // 5️⃣ Tampilkan pesan sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil disimpan!')),
    );

    // 6️⃣ Kosongkan form
    _titleController.clear();
    _amountController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nama Transaksi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (Rp)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Jenis Transaksi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveTransaction,
              icon: const Icon(Icons.save),
              label: const Text('Simpan Transaksi'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
