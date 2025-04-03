import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({Key? key}) : super(key: key);

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  final List<Map<String, dynamic>> _fixedExpenses = [];
  double _salary = 0;
  bool _showSalary = true;

  final TextEditingController _salaryController = TextEditingController();
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  final List<Color> _chartColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.pink
  ];

  void _formatSalaryInput(String value) {
    String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (newValue.isEmpty) {
      setState(() {
        _salary = 0;
      });
      return;
    }

    double parsedValue = double.parse(newValue) / 100;
    _salaryController.value = TextEditingValue(
      text: currencyFormat.format(parsedValue),
      selection: TextSelection.collapsed(offset: currencyFormat.format(parsedValue).length),
    );

    setState(() {
      _salary = parsedValue;
    });
  }

  void _addFixedExpense(String title, double value) {
    setState(() {
      _fixedExpenses.add({'title': title, 'value': value});
    });
  }

  List<PieSeries<Map<String, dynamic>, String>> _getPieChartSections() {
    List<Map<String, dynamic>> chartData = List.from(_fixedExpenses);
    double totalExpenses = _fixedExpenses.fold(0, (sum, item) => sum + item['value']);

    double remainingSalary = _salary - totalExpenses;
    if (remainingSalary > 0) {
      chartData.add({'title': 'Restante do Salário', 'value': remainingSalary});
    }

    return [
      PieSeries<Map<String, dynamic>, String>(
        dataSource: chartData,
        xValueMapper: (Map<String, dynamic> expense, _) => expense['title'],
        yValueMapper: (Map<String, dynamic> expense, _) => expense['value'],
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
        pointColorMapper: (expense, index) => _chartColors[index % _chartColors.length],
      ),
    ];
  }

  void _showAddExpenseDialog() {
    String title = '';
    final TextEditingController valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Adicionar Gasto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Nome do Gasto'),
                onChanged: (text) => title = text,
              ),
              TextField(
                controller: valueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+([,.][0-9]{0,2})?'))],
                decoration: const InputDecoration(labelText: 'Valor'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                String inputValue = valueController.text.replaceAll(',', '.');
                double parsedValue = double.tryParse(inputValue) ?? 0;

                if (title.isNotEmpty && parsedValue > 0) {
                  _addFixedExpense(title, parsedValue);
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Gastos'),
        backgroundColor: Colors.purple,
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
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Gastos Fixos'),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                      _showSalary ? 'Salário: ${currencyFormat.format(_salary)}' : 'Salário: ******',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: Icon(
                        _showSalary ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _showSalary = !_showSalary;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _salaryController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Digite seu salário',
                  labelStyle: TextStyle(color: Colors.purple),
                ),
                onChanged: _formatSalaryInput,
              ),
            ),
            if (_salary > 0 && _fixedExpenses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCircularChart(series: _getPieChartSections()),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
        onPressed: _showAddExpenseDialog,
      ),
    );
  }
}
