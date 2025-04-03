import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TransactionForm extends StatefulWidget {
  final void Function(String, double, DateTime) onSubmit;

  const TransactionForm(this.onSubmit, {Key? key}) : super(key: key);

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _titleController = TextEditingController();
  final _valueController = TextEditingController();
  DateTime? _selectedDate = DateTime.now();

  _submitForm() {
    final title = _titleController.text;
    final value = double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0;

    if (title.isEmpty || value <= 0 || _selectedDate == null) {
      return;
    }

    widget.onSubmit(title, value, _selectedDate!);
    Navigator.of(context).pop(); // Fecha o modal após cadastrar
  }

  _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }

      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  String _formatCurrency(String value) {
    value = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return '';

    double parsed = double.parse(value) / 100;
    return parsed.toStringAsFixed(2).replaceAll('.', ',');
  }

  @override
  void initState() {
    super.initState();
    _valueController.addListener(() {
      final newText = _formatCurrency(_valueController.text);
      if (_valueController.text != newText) {
        _valueController.value = _valueController.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newText.length),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    onSubmitted: (_) => _submitForm(),
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onSubmitted: (_) => _submitForm(),
                    decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                  ),
                  SizedBox(
                    height: 70,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _selectedDate == null
                                ? 'Nenhuma data selecionada!'
                                : 'Data Selecionada: ${DateFormat('dd/MM/y').format(_selectedDate!)}',
                          ),
                        ),
                        TextButton(
                          child: const Text(
                            'Selecionar Data',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          onPressed: _showDatePicker,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Nova Transação'),
              onPressed: _submitForm,
            ),
          ),
          Container(height: 1, color: Colors.transparent),
        ],
      ),
    );
  }
}