import 'dart:io';
import 'package:bill_maker/components/invoice_item.dart';
import 'package:bill_maker/components/pdf_generator.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class InvoiceScreen extends StatefulWidget {
  final List<Item>? initialItems;
  final String initialTitle;

  const InvoiceScreen({
    Key? key,
    this.initialItems,
    this.initialTitle = 'Invoice',
  }) : super(key: key);

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<Item> _invoiceItems = [];
  TextEditingController _titleController = TextEditingController();
  int? _editingIndex;
  final _formKey = GlobalKey<FormState>();

  late stt.SpeechToText _speech;
  bool _isListening = false;

  TextEditingController _itemController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _rateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _speech = stt.SpeechToText();
    if (widget.initialItems != null) {
      _invoiceItems.addAll(widget.initialItems!);
    }
    _titleController.text = widget.initialTitle;
  }

  void _checkPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
          context,
          {'items': _invoiceItems, 'title': _titleController.text},
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () async {
              final newName = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Edit Invoice Name'),
                  content: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(hintText: 'Enter new name'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(_titleController.text);
                      },
                      child: Text('Save'),
                    ),
                  ],
                ),
              );
              if (newName != null) {
                setState(() {
                  _titleController.text = newName;
                });
              }
            },
            child: Text(_titleController.text),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _generatePDF,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_editingIndex == null) _buildInputSection(),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _invoiceItems.length,
                    itemBuilder: (context, index) {
                      var item = _invoiceItems[index];
                      if (_editingIndex == index) {
                        return _buildEditSection(item, index);
                      }
                      return Card(
                        child: ListTile(
                          title: Text('Item: ${item.item}'),
                          subtitle: item.quantity == 0 && item.rate == 0.0
                              ? null
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Quantity: ${item.quantity}'),
                                    Text('Rate: ${item.rate}'),
                                  ],
                                ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _editItem(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteItem(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: 'Item',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an item';
                  }
                  return null;
                },
              ),
            ),
            IconButton(
              iconSize: 22.0,
              icon: const Icon(Icons.clear),
              onPressed: () {
                _itemController.clear();
              },
            ),
            IconButton(
              iconSize: 22.0,
              icon: Icon(Icons.mic),
              onPressed: _startListening,
              color: Colors.grey,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  border: UnderlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addItemToList();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditSection(Item item, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _itemController..text = item.item,
          decoration: const InputDecoration(
            labelText: 'Item',
            border: UnderlineInputBorder(),
          ),
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
                controller: _quantityController
                  ..text = item.quantity.toString(),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _rateController..text = item.rate.toString(),
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  border: UnderlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveEditedItem(index);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _addItemToList() {
    setState(() {
      var newItem = Item(
        item: _itemController.text,
        quantity: int.tryParse(_quantityController.text) ?? 0,
        rate: double.tryParse(_rateController.text) ?? 0.0,
      );
      _invoiceItems.add(newItem);
      _itemController.clear();
      _quantityController.clear();
      _rateController.clear();
    });
  }

  void _editItem(int index) {
    setState(() {
      _editingIndex = index;
      _itemController.text = _invoiceItems[index].item;
      _quantityController.text = _invoiceItems[index].quantity.toString();
      _rateController.text = _invoiceItems[index].rate.toString();
    });
  }

  void _saveEditedItem(int index) {
    setState(() {
      if (_invoiceItems[index].quantity == 0 &&
          _invoiceItems[index].rate == 0.0) {
        // Preserve the item name for title rows
        _invoiceItems[index] = Item(
          item: _itemController.text,
          quantity: 0,
          rate: 0.0,
        );
      } else {
        // Update regular item rows
        _invoiceItems[index] = Item(
          item: _itemController.text,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          rate: double.tryParse(_rateController.text) ?? 0.0,
        );
      }

      _editingIndex = null;
      _itemController.clear();
      _quantityController.clear();
      _rateController.clear();
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _invoiceItems.removeAt(index);
    });
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _itemController.text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _generatePDF() async {
    final pdfBytes = await PdfGenerator.generatePdf(
      InvoiceItem(
        title: _titleController.text,
        items: _invoiceItems,
        selected: false,
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/invoice.pdf');
    await file.writeAsBytes(pdfBytes);
    await OpenFile.open(file.path);
  }
}
