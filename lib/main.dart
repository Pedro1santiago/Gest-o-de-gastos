import 'package:flutter/material.dart';
import 'dart:math';
import 'componets/transaction_form.dart';
import 'componets/transacton_list.dart';
import 'componets/chart.dart';
import 'models/transaction.dart';
import 'models/FixedExpensesScreen.dart'; // Import your FixedExpensesScreen

void main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MyHomePage(),
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'OpenSans',
      ),
      routes: {
        '/fixed-expenses': (ctx) => const FixedExpensesScreen(), // Add route for FixedExpensesScreen
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Transaction> _transactions = [];
  bool _showTotal = true;

  double get _totalExpenses {
    return _transactions.fold(0.0, (sum, tr) => sum + tr.value);
  }

  void _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );
    setState(() {
      _transactions.add(newTransaction);
    });
  }

  void _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  void _toggleTotalVisibility() {
    setState(() {
      _showTotal = !_showTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas Pessoais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openTransactionFormModal(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Página Inicial'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Gastos Fixos'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/fixed-expenses');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.purple,
              elevation: 5,
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _showTotal ? 'Total: R\$${_totalExpenses.toStringAsFixed(2)}' : 'Total: ******',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _showTotal ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: _toggleTotalVisibility,
                    ),
                  ],
                ),
              ),
            ),
            Chart(_transactions),
            TransactionList(_transactions, _removeTransaction),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _openTransactionFormModal(context),
      ),
    );
  }

  void _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: TransactionForm(_addTransaction),
        );
      },
    );
  }
}