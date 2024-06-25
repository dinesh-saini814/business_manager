import 'package:flutter/material.dart';

class InvoiceItemForm extends StatefulWidget {
  final Function(Map<String, dynamic>, [int?]) onSubmit;
  final Map<String, dynamic>? itemToEdit;
  final int? editIndex;

  InvoiceItemForm({
    required this.onSubmit,
    this.itemToEdit,
    this.editIndex,
  });

  @override
  _InvoiceItemFormState createState() => _InvoiceItemFormState();
}

class _InvoiceItemFormState extends State<InvoiceItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  int? _editIndex;

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _itemController.text = widget.itemToEdit!['item'];
      _quantityController.text = widget.itemToEdit!['quantity'].toString();
      _rateController.text = widget.itemToEdit!['rate'].toString();
      _editIndex = widget.editIndex;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'item': _itemController.text,
        'quantity': int.parse(_quantityController.text),
        'rate': double.parse(_rateController.text),
      }, _editIndex);
      _clearForm();
    }
  }

  void _clearForm() {
    _itemController.clear();
    _quantityController.clear();
    _rateController.clear();
    setState(() {
      _editIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _itemController,
            decoration: const InputDecoration(labelText: 'Item'),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            maxLines: null,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an item';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _rateController,
                  decoration: const InputDecoration(labelText: 'Rate'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a rate';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(_editIndex == null ? Icons.add : Icons.check),
                onPressed: _submitForm,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
