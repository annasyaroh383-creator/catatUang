import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const ReportPage({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    // Hitung total pemasukan dan pengeluaran
    double totalIncome = 0;
    double totalExpense = 0;
    for (var tx in transactions) {
      final amount = (tx['amount'] ?? 0).toDouble();
      if (tx['isIncome'] == true) {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Ringkasan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard('Pemasukan',
                    formatCurrency.format(totalIncome), Colors.green),
                _buildSummaryCard('Pengeluaran',
                    formatCurrency.format(totalExpense), Colors.red),
              ],
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 Daftar Transaksi
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada transaksi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final tx =
                            transactions[transactions.length - 1 - index];
                        final isIncome = tx['isIncome'] ?? false;
                        final amount = tx['amount'] ?? 0;
                        final name = tx['name'] ?? 'Tanpa keterangan';
                        final date = tx['date'] ?? '';

                        return Card(
                          child: ListTile(
                            leading: Icon(
                              isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                            title: Text(name),
                            subtitle: Text(date),
                            trailing: Text(
                              (isIncome ? '+' : '-') +
                                  formatCurrency.format(amount),
                              style: TextStyle(
                                color: isIncome ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }
}
