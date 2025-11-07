import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportPage extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Future<void> Function(List<Map<String, dynamic>>) onUpdateTransactions;

  const ReportPage({
    super.key,
    required this.transactions,
    required this.onUpdateTransactions,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late List<Map<String, dynamic>> filtered;
  String search = '';
  String selectedMonth = 'Semua';
  String selectedYear = 'Semua';

  @override
  void initState() {
    super.initState();
    filtered = List.from(widget.transactions);
  }

  DateTime _parseDate(dynamic d) {
    if (d is DateTime) return d;
    if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
    return DateTime.now();
  }

  void _applyFilters() {
    setState(() {
      filtered = widget.transactions.where((tx) {
        final name = (tx['name'] ?? '').toString().toLowerCase();
        final date = _parseDate(tx['date']);
        final month = DateFormat('MM').format(date);
        final year = DateFormat('yyyy').format(date);

        final matchesSearch = name.contains(search.toLowerCase());
        final matchesMonth = selectedMonth == 'Semua' || selectedMonth == month;
        final matchesYear = selectedYear == 'Semua' || selectedYear == year;
        return matchesSearch && matchesMonth && matchesYear;
      }).toList();
    });
  }

  Future<void> _deleteAtIndex(int displayIndex) async {
    // displayIndex is index in filtered reversed order; we will compute actual index in widget.transactions
    final actualIndex = widget.transactions.length - 1 - displayIndex;
    final updated = List<Map<String, dynamic>>.from(widget.transactions);
    updated.removeAt(actualIndex);
    await widget.onUpdateTransactions(updated);
    setState(() {
      filtered = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double income = 0;
    double expense = 0;
    for (var tx in filtered) {
      final a = (tx['amount'] ?? 0).toDouble();
      if (tx['isIncome'] == true)
        income += a;
      else
        expense += a;
    }

    final months = [
      'Semua',
      ...List.generate(12, (i) => (i + 1).toString().padLeft(2, '0'))
    ];
    final yearsSet = widget.transactions
        .map((t) => DateFormat('yyyy').format(_parseDate(t['date'])))
        .toSet()
        .toList();
    final years = ['Semua', ...yearsSet];

    return Scaffold(
      appBar: AppBar(
          title: const Text('Laporan Keuangan'),
          backgroundColor: Colors.indigo),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedMonth,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: months.map((m) {
                  final label = m == 'Semua'
                      ? 'Semua'
                      : DateFormat.MMMM().format(DateTime(0, int.parse(m)));
                  return DropdownMenuItem(value: m, child: Text(label));
                }).toList(),
                onChanged: (v) {
                  selectedMonth = v ?? 'Semua';
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedYear,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                    .toList(),
                onChanged: (v) {
                  selectedYear = v ?? 'Semua';
                  _applyFilters();
                },
              ),
            )
          ]),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari transaksi...',
                border: OutlineInputBorder()),
            onChanged: (v) {
              search = v;
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),

          // ringkasan
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Column(children: [
              const Text('Pemasukan'),
              const SizedBox(height: 6),
              Text(formatCurrency.format(income),
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            Column(children: [
              const Text('Pengeluaran'),
              const SizedBox(height: 6),
              Text(formatCurrency.format(expense),
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
          ]),
          const SizedBox(height: 12),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('Tidak ada transaksi'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final displayIndex = filtered.length - 1 - idx;
                      final tx = filtered[displayIndex];
                      final date = _parseDate(tx['date']);
                      final isIncome = tx['isIncome'] ?? false;
                      return Card(
                        child: ListTile(
                          leading: Icon(
                              isIncome
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isIncome ? Colors.green : Colors.red),
                          title: Text(tx['name'] ?? 'Tanpa keterangan'),
                          subtitle:
                              Text(DateFormat('dd MMM yyyy').format(date)),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(
                                (isIncome ? '+ ' : '- ') +
                                    formatCurrency
                                        .format((tx['amount'] ?? 0).toDouble()),
                                style: TextStyle(
                                    color: isIncome ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Hapus transaksi?'),
                                    content: const Text(
                                        'Yakin ingin menghapus transaksi ini?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Batal')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Hapus',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteAtIndex(idx);
                                }
                              },
                            )
                          ]),
                        ),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}
