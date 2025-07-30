import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/expense_model.dart';
class AddExpenseView extends StatefulWidget {
  const AddExpenseView({super.key});

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _selectedCaseId;
  DateTime _selectedDate = DateTime.now();

  final caseList = Hive.box<CaseModel>('cases').values.toList();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      caseId: _selectedCaseId!,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _selectedDate,
    );

    await Hive.box<ExpenseModel>('expenses').add(expense);

    Get.back();
    Get.snackbar("Success", "Expense saved successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCaseId,
                decoration: const InputDecoration(labelText: "Select Case"),
                items: caseList.map((c) {
                  return DropdownMenuItem(
                    value: c.id,
                    child: Text(c.title),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCaseId = val),
                validator: (val) =>
                    val == null ? "Please select a case" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Expense Title",
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter title" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Amount (₹)",
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val == null || double.tryParse(val) == null
                        ? "Enter valid amount"
                        : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Date"),
                subtitle: Text(
                  "${_selectedDate.toLocal()}".split(" ")[0],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text("Save Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
