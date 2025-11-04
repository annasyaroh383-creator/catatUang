import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // untuk format tanggal & uang

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // controller form
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _type = "Pemasukan";

  // daftar transaksi disimpan di list
  final List<Map<String, dynamic>> _transactions = [];

  // format tanggal dan mata uang
  final _currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
  final _dateFormat = DateFormat('dd MMM yyyy, HH:mm');

  void _addTransaction() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _transactions.insert(0, {
          'type': _type,
          'amount': double.parse(_amountController.text),
          'note': _noteController.text,
          'date': DateTime.now(),
        });
      });

      // reset form
      _amountController.clear();
      _noteController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil ditambahkan ✅')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaksi"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // === FORM INPUT ===
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: "Tipe Transaksi",
                      border: OutlineInputBorder(),
                    ),
                    items: ["Pemasukan", "Pengeluaran"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _type = val!),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Jumlah (Rp)",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Masukkan jumlah uang" : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: "Catatan (opsional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _addTransaction,
                    icon: const Icon(Icons.save),
                    label: const Text("Simpan Transaksi"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(),

            // === LIST TRANSAKSI ===
            Expanded(
              child: _transactions.isEmpty
                  ? const Center(
                      child: Text(
                        "Belum ada transaksi",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final trx = _transactions[index];
                        final isIncome = trx['type'] == "Pemasukan";

                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isIncome
                                  ? Colors.green[200]
                                  : Colors.red[200],
                              child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            title: Text(
                              "${trx['type']} - ${_currencyFormat.format(trx['amount'])}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Text(
                              "${trx['note'].isEmpty ? '-' : trx['note']} \n${_dateFormat.format(trx['date'])}",
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
