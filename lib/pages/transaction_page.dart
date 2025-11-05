import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSaveTransaction;

  const TransactionPage({
    super.key,
    required this.onSaveTransaction,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final List<Map<String, dynamic>> _tempTransactions = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isIncome = true;

  /// 🔹 Menambahkan transaksi sementara
  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final dateFormat = DateFormat('dd MMM yyyy');

      setState(() {
        _tempTransactions.add({
          'name': _nameController.text,
          'amount': double.tryParse(_amountController.text) ?? 0,
          'isIncome': _isIncome,
          'date': dateFormat.format(now),
        });
      });

      // Reset form input
      _nameController.clear();
      _amountController.clear();
    }
  }

  /// 🔹 Simpan transaksi ke storage utama dan kembali ke beranda
  void _saveAllTransactions() {
    if (_tempTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada transaksi yang ditambahkan')),
      );
      return;
    }

    for (var tx in _tempTransactions) {
      widget.onSaveTransaction(tx);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil disimpan!')),
    );

    // 🔄 Kembali ke halaman Beranda
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Form Input
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Transaksi',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nama transaksi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan jumlah';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Pilihan Jenis Transaksi
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Pemasukan'),
                        selected: _isIncome,
                        onSelected: (val) {
                          setState(() => _isIncome = true);
                        },
                        selectedColor: Colors.green.shade200,
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: !_isIncome,
                        onSelected: (val) {
                          setState(() => _isIncome = false);
                        },
                        selectedColor: Colors.red.shade200,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 🔹 Tombol Tambah Transaksi
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Transaksi'),
                    onPressed: _addTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Daftar Transaksi yang baru dimasukkan
            Expanded(
              child: _tempTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada transaksi ditambahkan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tempTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = _tempTransactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: Icon(
                              tx['isIncome']
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: tx['isIncome'] ? Colors.green : Colors.red,
                            ),
                            title: Text(tx['name']),
                            subtitle: Text(tx['date']),
                            trailing: Text(
                              (tx['isIncome'] ? '+' : '-') +
                                  formatCurrency.format(tx['amount']),
                              style: TextStyle(
                                color:
                                    tx['isIncome'] ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // 🔹 Tombol Selesai
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Selesai'),
              onPressed: _saveAllTransactions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
