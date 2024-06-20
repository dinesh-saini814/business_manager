import 'package:flutter/material.dart';
import 'invoice_item_form.dart';

class InvoiceItemList extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(int) onDelete;
  final Function(Map<String, dynamic>, int) onEdit;

  InvoiceItemList({
    required this.items,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _InvoiceItemListState createState() => _InvoiceItemListState();
}

class _InvoiceItemListState extends State<InvoiceItemList> {
  int? _editIndex;

  void _startEdit(int index) {
    setState(() {
      _editIndex = index;
    });
  }

  void _endEdit() {
    setState(() {
      _editIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        if (_editIndex == index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: InvoiceItemForm(
                onSubmit: (updatedItem, [editIndex]) {
                  widget.onEdit(updatedItem, index);
                  _endEdit();
                },
                itemToEdit: item,
                editIndex: index,
              ),
            ),
          );
        } else {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              title: Text(
                item['item'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Quantity: ${item['quantity']}, Rate: ${item['rate']}',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _startEdit(index),
                    color: Theme.of(context).primaryColor,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => widget.onDelete(index),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
