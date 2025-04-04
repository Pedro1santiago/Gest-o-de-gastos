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

  void _onSalaryInputChanged(String value) {
    String newValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (newValue.isEmpty) return;

    double parsedValue = double.parse(newValue) / 100;
    _salaryController.value = TextEditingValue(
      text: currencyFormat.format(parsedValue),
      selection: TextSelection.collapsed(offset: currencyFormat.format(parsedValue).length),
    );
  }

  void _confirmSalary() {
    setState(() {
      _salary = double.tryParse(_salaryController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      _salary /= 100;
    });
  }

  void _toggleSalaryVisibility() {
    setState(() {
      _showSalary = !_showSalary;
    });
  }

  void _addFixedExpense(String title, double value) {
    String capitalizedTitle = title.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    setState(() {
      _fixedExpenses.add({'title': capitalizedTitle, 'value': value});
    });
  }

  void _removeFixedExpense(int index) {
    setState(() {
      _fixedExpenses.removeAt(index);
    });
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
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+([,.][0-9]{0,2})?'))
                ],
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

  List<PieSeries<Map<String, dynamic>, String>> _getPieChartSections() {
  List<Map<String, dynamic>> chartData = [];

  if (_salary > 0) {
    double totalExpenses = _fixedExpenses.fold(0, (sum, item) => sum + item['value']);
    for (var expense in _fixedExpenses) {
      int percent = ((expense['value'] / _salary) * 100).round();
      chartData.add({
        'title': '${expense['title']} ($percent%)',
        'value': percent.toDouble(),
      });
    }

    int remaining = (100 - (totalExpenses / _salary * 100)).round();
    if (remaining > 0) {
      chartData.add({
        'title': 'Saldo ($remaining%)',
        'value': remaining.toDouble(),
      });
    }
  }

  return [
    PieSeries<Map<String, dynamic>, String>(
      dataSource: chartData,
      xValueMapper: (Map<String, dynamic> expense, _) => expense['title'],
      yValueMapper: (Map<String, dynamic> expense, _) => expense['value'],
      dataLabelSettings: const DataLabelSettings(
        isVisible: true,
        labelPosition: ChartDataLabelPosition.outside,
        labelIntersectAction: LabelIntersectAction.shift,
        textStyle: TextStyle(fontSize: 12),
      ),
      pointColorMapper: (expense, index) => _chartColors[index % _chartColors.length],
    ),
  ];
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Gastos'),
        backgroundColor: Colors.purple,
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
                      'Salário: ${_showSalary ? currencyFormat.format(_salary) : '******'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _showSalary ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                          ),
                          onPressed: _toggleSalaryVisibility,
                        ),
                        if (_salary > 0)
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _salary = 0;
                                _salaryController.clear();
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_salary == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: TextField(
                  controller: _salaryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: 'Digite seu salário'),
                  onChanged: _onSalaryInputChanged,
                  onSubmitted: (_) => _confirmSalary(),
                ),
              ),
            if (_salary > 0 && _fixedExpenses.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SfCircularChart(series: _getPieChartSections()),
              ),
            ..._fixedExpenses.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> expense = entry.value;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(expense['title']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(currencyFormat.format(expense['value'])),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeFixedExpense(index),
                      ),
                    ],
                  ),
                ),
              );
            }),
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