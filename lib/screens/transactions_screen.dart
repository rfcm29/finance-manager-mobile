import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _desc = TextEditingController();
  final _amount = TextEditingController();
  String _type = 'EXPENSE';
  int? _accountId;
  String _date = DateTime.now().toIso8601String().split('T').first;

  Future<void> _addTransaction() async {
    if (_desc.text.isEmpty || _amount.text.isEmpty || _accountId == null) return;
    try {
      await context.read<TransactionProvider>().createTransaction(
        amount: double.parse(_amount.text),
        description: _desc.text.trim(),
        date: _date, type: _type, accountId: _accountId!,
      );
      await context.read<AccountProvider>().fetchAccounts();
      _desc.clear(); _amount.clear();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add transaction')));
    }
  }

  void _showAddDialog() {
    final accounts = context.read<AccountProvider>().accounts;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Add Transaction', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _accountId,
              decoration: const InputDecoration(labelText: 'Account', border: OutlineInputBorder()),
              items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
              onChanged: (v) => setModalState(() => _accountId = v),
            ),
            const SizedBox(height: 12),
            TextField(controller: _amount, decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: ['EXPENSE', 'INCOME', 'TRANSFER'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setModalState(() => _type = v!),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_date),
              onPressed: () async {
                final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (picked != null) setModalState(() => _date = picked.toIso8601String().split('T').first);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _addTransaction, child: const Text('Add'))),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add)),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.transactions.isEmpty
              ? const Center(child: Text('No transactions yet. Tap + to add one.'))
              : ListView.builder(
                  itemCount: provider.transactions.length,
                  itemBuilder: (_, i) {
                    final t = provider.transactions[i];
                    return Dismissible(
                      key: Key(t.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (_) async {
                        await provider.deleteTransaction(t.id);
                        await context.read<AccountProvider>().fetchAccounts();
                      },
                      child: ListTile(
                        title: Text(t.description),
                        subtitle: Text('${t.accountName} · ${t.date}'),
                        trailing: Text(
                          '${t.type == 'EXPENSE' ? '-' : '+'}£${t.amount.toStringAsFixed(2)}',
                          style: TextStyle(color: t.type == 'INCOME' ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
