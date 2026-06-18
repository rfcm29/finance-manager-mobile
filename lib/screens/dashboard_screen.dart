import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().fetchAccounts();
      context.read<TransactionProvider>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final accounts = context.watch<AccountProvider>();
    final transactions = context.watch<TransactionProvider>();
    final now = DateTime.now();
    final monthPrefix = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final monthlyIncome = transactions.transactions
        .where((t) => t.type == 'INCOME' && t.date.startsWith(monthPrefix))
        .fold(0.0, (s, t) => s + t.amount);
    final monthlyExpenses = transactions.transactions
        .where((t) => t.type == 'EXPENSE' && t.date.startsWith(monthPrefix))
        .fold(0.0, (s, t) => s + t.amount);

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<AccountProvider>().fetchAccounts();
        await context.read<TransactionProvider>().fetchTransactions();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hello, ${user?.name ?? ''} 👋', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Balance card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo.shade600, Colors.indigo.shade400]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text('\$${accounts.totalBalance.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 16),
          // Income / Expense row
          Row(children: [
            Expanded(child: _statCard('Monthly Income', monthlyIncome, Colors.green)),
            const SizedBox(width: 12),
            Expanded(child: _statCard('Monthly Expenses', monthlyExpenses, Colors.red)),
          ]),
          const SizedBox(height: 24),
          Text('Recent Transactions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (transactions.loading) const Center(child: CircularProgressIndicator()),
          if (transactions.transactions.isEmpty && !transactions.loading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No transactions yet.'))),
          ...transactions.transactions.take(10).map((t) => Card(
            child: ListTile(
              title: Text(t.description),
              subtitle: Text('${t.accountName} · ${t.date}'),
              trailing: Text(
                '${t.type == 'EXPENSE' ? '-' : '+'}£${t.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: t.type == 'INCOME' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _statCard(String label, double amount, Color color) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: color, fontSize: 12)),
      const SizedBox(height: 4),
      Text('\$${amount.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
    ]),
  );
}
