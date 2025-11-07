import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final double saldo;

  const DashboardPage({
    super.key,
    required this.transactions,
    required this.saldo,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    final recent = transactions.reversed.take(5).toList();

    return Scaffold(
      appBar:
          AppBar(title: const Text('Beranda'), backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.indigoAccent]),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Saldo',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text(formatCurrency.format(saldo),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Transaksi Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: recent.isEmpty
                ? const Center(
                    child: Text('Belum ada transaksi',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: recent.length,
                    itemBuilder: (context, i) {
                      final tx = recent[i];
                      final date = DateTime.tryParse(tx['date'].toString()) ??
                          DateTime.now();
                      final isIncome = tx['isIncome'] ?? false;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isIncome ? Colors.green[100] : Colors.red[100],
                            child: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isIncome ? Colors.green : Colors.red),
                          ),
                          title: Text(tx['name'] ?? 'Tanpa keterangan'),
                          subtitle:
                              Text(DateFormat('dd MMM yyyy').format(date)),
                          trailing: Text(
                            (isIncome ? '+ ' : '- ') +
                                formatCurrency
                                    .format((tx['amount'] ?? 0).toDouble()),
                            style: TextStyle(
                                color: isIncome ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
