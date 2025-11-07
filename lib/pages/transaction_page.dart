import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  final Future<void> Function(List<Map<String, dynamic>>) onSaveTransactions;
  final VoidCallback onFinish;

  const TransactionPage({
    super.key,
    required this.onSaveTransactions,
    required this.onFinish,
  });

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final List<Map<String, dynamic>> _temp = [];
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  bool _isIncome = true;

  void _addTemp() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final tx = {
      'name': _nameCtrl.text.trim(),
      'amount': double.tryParse(_amountCtrl.text) ?? 0.0,
      'isIncome': _isIncome,
      'date': now.toIso8601String(),
    };
    setState(() {
      _temp.add(tx);
    });
    _nameCtrl.clear();
    _amountCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi ditambahkan (sementara)')));
  }

  Future<void> _saveAll() async {
    if (_temp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum ada transaksi untuk disimpan')));
      return;
    }
    // kirim ke main
    await widget.onSaveTransactions(_temp);
    setState(() => _temp.clear());
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua transaksi disimpan')));
    // panggil finish setelah delay agar snack terlihat
    Future.delayed(const Duration(milliseconds: 400), () {
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
          title: const Text('Tambah Transaksi'),
          backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nama Transaksi',
                      border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Isi nama transaksi'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Nominal (Rp)', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Isi nominal';
                    if (double.tryParse(v) == null)
                      return 'Masukkan angka valid';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                        label: const Text('Pemasukan'),
                        selected: _isIncome,
                        onSelected: (_) => setState(() => _isIncome = true)),
                    const SizedBox(width: 8),
                    ChoiceChip(
                        label: const Text('Pengeluaran'),
                        selected: !_isIncome,
                        onSelected: (_) => setState(() => _isIncome = false)),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Transaksi'),
                  onPressed: _addTemp,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _temp.isEmpty
                  ? const Center(child: Text('Belum ada transaksi sementara'))
                  : ListView.builder(
                      itemCount: _temp.length,
                      itemBuilder: (context, i) {
                        final tx = _temp[i];
                        final date = DateTime.parse(tx['date']);
                        return Card(
                          child: ListTile(
                            leading: Icon(
                                tx['isIncome']
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color:
                                    tx['isIncome'] ? Colors.green : Colors.red),
                            title: Text(tx['name']),
                            subtitle: Text(dateFmt.format(date)),
                            trailing: Text(
                              (tx['isIncome'] ? '+ ' : '- ') +
                                  formatCurrency.format(tx['amount']),
                              style: TextStyle(
                                  color: tx['isIncome']
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: const Text('Selesai'),
                onPressed: _saveAll,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
