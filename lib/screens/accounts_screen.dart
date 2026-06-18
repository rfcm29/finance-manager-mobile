import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final _name = TextEditingController();
  final _balance = TextEditingController();
  String _type = 'CHECKING';

  final _types = ['CHECKING', 'SAVINGS', 'CREDIT_CARD', 'INVESTMENT', 'CASH'];

  Future<void> _addAccount() async {
    if (_name.text.isEmpty || _balance.text.isEmpty) return;
    try {
      await context.read<AccountProvider>().createAccount(_name.text.trim(), _type, double.parse(_balance.text));
      _name.clear(); _balance.clear();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create account')));
    }
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add Account', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Account Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
            items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: _balance, decoration: const InputDecoration(labelText: 'Initial Balance', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: _addAccount, child: const Text('Add Account'))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AccountProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add)),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : provider.accounts.isEmpty
              ? const Center(child: Text('No accounts yet. Tap + to add one.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.accounts.length,
                  itemBuilder: (_, i) {
                    final a = provider.accounts[i];
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.account_balance)),
                        title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(a.type),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('${a.currency} ${a.balance.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => provider.deleteAccount(a.id)),
                        ]),
                      ),
                    );
                  },
                ),
    );
  }
}
