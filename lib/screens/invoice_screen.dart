import 'package:bill_maker/components/invoice_item.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart' as gsheet; // Prefixing gsheets
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

final _credentials = r'''
{
  "type": "service_account",
  "project_id": "business-maker-cdad3",
  "private_key_id": "f8cb560a849e11b7bc7ef9e39a69db4b8cb08087",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCrnmqDQhc58HMz\nzJ15NIze8VN98VmIyAvDD9fekz9tTKzhQWfN4VmeL1BtpIHv1aKzn0qSg4tjigLY\nF6PkvZX67YuzNonJW64X41NdO6ANhPgwRlvTMvHsP4uEqjpLi0/FwhScwu/I/hS3\nhH+RFaHZTT9N9emL5He3jNYBzmEx7pUEV56foHq17A8fldygtW/E3AItQDBhoF24\n2LMHOOJ8A4YqK8hc9+gdgrHI/fQSastjr0672e9NSBLaYGVKOSjWWTPdC5BO4gX3\nEFIMR7Zg4eyKtxF4UKaKacbMUnj+nc9xxpn+A3TItrNhqzKFdUMQhej2hI0Wo6/X\nV9As6eoxAgMBAAECggEARLRQRsjkHH1e2UtedYHsrWnmN2KyKdiQIOCMVp4TQ9Hw\n2eLByEGhi3q8k5BKtnWLw6YPCBWibVB4cAMSyUV+r+x+Q1ofkh1iVkza+FWg7xie\n9VCNfUEFacNMuukdGlYksvJOJy3BKfFR4OAp467J0wEiSTcb7rWhmblHiYSSE5cc\nb+ZUhpnhGS1wOGxtf2nqAcYXlgCdPbBpXPuDZpd4/QQiG6CTttnzM7pVW7oyQaWt\n8SQkMhOjwErPKXf+MGTYY2+RossGDaz39T4fk4BjAPjdoK9o0E1npoqAlUZTqa8p\njz0YaVmGYYlHc3OSrujkYFC6GN7iYYQf1ZUTRj1NKwKBgQDWydxQzSJuPG4yRAU6\nH2hn3Hfl/17BN2slbl43b5dIshOJiNf9GBYtJ6wDwxy8oOWqzhRM8hw/9wn74InS\neOddw9R/Q3nVwgSG81Mqzd6UsUp5HhVNI6Dxv0+ojXAjLRQ7H8BHcJSOdcmJBvZ/\ng9em5yBKofQ7Ezvx10qs8dTaswKBgQDMjB1Ejaoj9cfyX8Q7kOnhwSfUihsHoEua\nVFWqFJXzGnCPElIyAqMd1w28LOxnUdQgj88MttZtLXD+mqc6pCH1sJ4w65VhJWmE\ntfs7TIUt3pCjpRj82nVKBMgJpmL49kzVEkwwWTPUvtE66k4lzWIxxRcCQ8B+vMB6\nOSmJta2piwKBgEErnIKTy2ehRFpSEzfwgbBJz8Nkea6sjwEbfNDbNg7joVPwxoBP\nx6LJz8KQd+6v7x+lSbmTGIk7/raDCa5n6uOjYJ2Arr3yEYeU2t44+tko9gzL2PC/\n57ySLKxaxfSWX/YUizXh7eFP0eeWykIkkdFdfYnHnCA0lNKrXUgeVFRLAoGAA77N\nCmRNqTrm3llCjpSos6mFwS6GMC2PNNQ2fVbDKCBjzzrWpnPF6NX3OmrYKUwmRjJb\n6C+w3W7nksHiLgCzXnxNaTfnFFBLDlMGtp9AEQbyPwzW2Epnu2M7BnI1fbmEzqH3\nIyt+93ZG/n0r0SVhlue09CWpcKikHZjOWecptuECgYEAyxXU2SB6RPZkDQ7mfNCl\n42lJKuzuBYX/cudafJ9iK53oLoJQdTRLpmqslvNXotiqEP501KrqVc49iKtEPOwB\n87ixxDKe/fgObSr+2UXVErdzBudMNt7b7gUfZxeME8Wxz0YBKtfmEx6LZb04dsZ4\nNlpA4r/6kVADEiVD2kDc35I=\n-----END PRIVATE KEY-----\n",
  "client_email": "business-maker-cdad3@appspot.gserviceaccount.com",
  "client_id": "106520396962702083691",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/business-maker-cdad3%40appspot.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
  ''';

final _spreadsheetId = '1uHYoqJjufmMev2mQCFF2M6Iqo887nk5SeaExrpvU9LA';

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
  TextEditingController _sizeControllerA = TextEditingController();
  TextEditingController _sizeControllerB = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  TextEditingController _rateController = TextEditingController();
  bool _isRActive = false;

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

  void _toggleRIcon() {
    setState(() {
      _isRActive = !_isRActive;
      if (!_isRActive) {
        _sizeControllerB.clear();
      }
      _calculateAndSetValues();
    });
  }

  void _calculateAndSetValues() {
    double sizeA = double.tryParse(_sizeControllerA.text) ?? 0.0;
    double sizeB =
        _isRActive ? 1.0 : (double.tryParse(_sizeControllerB.text) ?? 0.0);

    double totalSquareFeet = convertToFeet(sizeA) * convertToFeet(sizeB);

    setState(() {
      _quantityController.text = totalSquareFeet.toStringAsFixed(2);
    });
  }

  double convertToFeet(double feetInches) {
    int feet = feetInches.floor();
    double inches = (feetInches - feet) * 10;
    return feet + (inches / 12);
  }

  String formatSize(double feetInches) {
    int feet = feetInches.floor();
    int inches = ((feetInches - feet) * 10).round();
    return "$feet'.${inches}\"";
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
              onPressed: _generateSheet,
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
                if (_editingIndex != null)
                  _buildEditSection(_invoiceItems[_editingIndex!]),
                Expanded(
                  child: ReorderableListView(
                    physics: const BouncingScrollPhysics(),
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final item = _invoiceItems.removeAt(oldIndex);
                        _invoiceItems.insert(newIndex, item);
                      });
                    },
                    children: [
                      for (int index = 0; index < _invoiceItems.length; index++)
                        Card(
                          key: ValueKey(_invoiceItems[index]),
                          child: ListTile(
                            title: Text('${_invoiceItems[index].item}'),
                            subtitle: _invoiceItems[index].quantity == 0 &&
                                    _invoiceItems[index].rate == 0.0
                                ? null
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Size: ${_invoiceItems[index].size}'),
                                      Text(
                                          'Quantity: ${_invoiceItems[index].quantity.toStringAsFixed(2)}'),
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
                        ),
                    ],
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
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  border: UnderlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 10),
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
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _sizeControllerA,
                decoration: const InputDecoration(
                  labelText: 'Size A',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateAndSetValues(),
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.clear, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: _sizeControllerB,
                decoration: const InputDecoration(
                  labelText: 'Size B',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                enabled: !_isRActive,
                onChanged: (value) => _calculateAndSetValues(),
              ),
            ),
            GestureDetector(
              onTap: _toggleRIcon,
              child: Container(
                decoration: BoxDecoration(
                  color: _isRActive ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: _isRActive
                    ? Icon(
                        Icons.radio_button_checked,
                        size: 24,
                        color: Colors.blueGrey,
                      )
                    : Icon(Icons.radio_button_off, size: 24),
              ),
            ),
            IconButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _addItemToList();
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditSection(Item item) {
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
                controller: _rateController..text = item.rate.toString(),
                decoration: const InputDecoration(
                  labelText: 'Rate',
                  border: UnderlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 10),
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
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveEditedItem();
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
      String size;
      double sizeA = double.tryParse(_sizeControllerA.text) ?? 0.0;
      double sizeB =
          _isRActive ? 1.0 : (double.tryParse(_sizeControllerB.text) ?? 0.0);

      double totalSquareFeet = convertToFeet(sizeA) * convertToFeet(sizeB);

      if (_isRActive) {
        size = '${formatSize(sizeA)} R';
      } else {
        size = '${formatSize(sizeA)} x ${formatSize(sizeB)}';
      }

      _invoiceItems.add(
        Item(
          item: _itemController.text,
          size: size,
          quantity: double.parse(totalSquareFeet.toStringAsFixed(2)),
          rate: double.tryParse(_rateController.text) ?? 0.0,
        ),
      );

      _itemController.clear();
      _sizeControllerA.clear();
      _sizeControllerB.clear();
      _quantityController.clear();
      _rateController.clear();
      _isRActive = false;
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

  void _saveEditedItem() {
    setState(() {
      _invoiceItems[_editingIndex!] = Item(
        item: _itemController.text,
        size: _invoiceItems[_editingIndex!].size,
        quantity: double.parse((_quantityController.text.isNotEmpty
                ? double.tryParse(_quantityController.text)
                : 0.0)!
            .toStringAsFixed(2)),
        rate: double.tryParse(_rateController.text) ?? 0.0,
      );
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

  Future<void> _generateSheet() async {
    final gsheets = gsheet.GSheets(_credentials);
    final ss = await gsheets.spreadsheet(_spreadsheetId);

    // Get the worksheet or create if it does not exist
    var sheet = ss.worksheetByTitle('Invoice');
    sheet ??= await ss.addWorksheet(_titleController.text);

    // Prepare data
    final invoiceData = [
      [
        'Item',
        'Size',
        'Quantity',
        'Rate',
        'Total',
      ],
      ..._invoiceItems.map((item) => [
            item.item,
            item.size,
            item.quantity.toString(),
            item.rate.toString(),
            (item.quantity * item.rate).toString(),
          ]),
    ];

    // Clear the existing content
    await sheet.clear();

    // Insert data into the sheet starting from row 13 and column B (which is the 2nd column)
    int startRow = 13;
    int startCol = 2;

    for (int i = 0; i < invoiceData.length; i++) {
      await sheet.values.insertRow(
        startRow + i,
        invoiceData[i],
        fromColumn: startCol,
      );
    }

    // Generate download URL
    final downloadUrl =
        'https://docs.google.com/spreadsheets/d/$_spreadsheetId/export?format=xlsx';

    // Open the download URL
    if (await canLaunch(downloadUrl)) {
      await launch(downloadUrl);
    } else {
      throw 'Could not launch $downloadUrl';
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) => print('onError: $errorNotification'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _itemController.text = result.recognizedWords;
          }),
          localeId: 'hi-IN', // Set the locale to Hindi
        );
      }
    }
  }
}
