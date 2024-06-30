import 'package:bill_maker/components/invoice_item.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart' as gsheet; // Prefixing gsheets
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';

final _credentials = r'''
{
  "type": "service_account",
  "project_id": "bill-maker-427520",
  "private_key_id": "fd05fddd505b47af5321caa3c92d6757e67dff62",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCyUgFF3z8CEYTY\njwPz/YBjdAeU3TtH2J6JKJo9kCxp7WAS08tXICxj2lwPKs2bXjF8CGb4f+gSoJxj\nVr/1VGgtODgiGDeDLRoNe9vOOcf9siKPCUkriJbSXnl6+qTHlvHRe8OmZwuaD7PE\nVhmzjlXJJLOSoNNNhWS45SAUcXPZH1kwUCaonuMgqZKPBFL+vRcXWrJ9jpUlMMQY\nr7BZbdGb0tf0eFg60LqQv6nX68uAlh8MQdkODsxP1UIP+GP4lD3LSzT850F0QARM\nTuZNynXO+T6BmSxdHKqdc+A9NZbNzbl0+esngRnhyS9dKFBYSyu5z3sd10xa5cNI\nTJ+pmpe9AgMBAAECggEABza8kPJPVvrU9DrS5t24Qi25Ocs6YPVxMmzHUprAxTdC\nZfiV9wwY56A3jbCGWVT17QXc/owUHB7NvNIPWXIk9cFaufxfUIn0ThvW4FCjl86L\nSdyPDnkL2u5R/Uji/iUL2tTmLRbpl/2vIM/34bTuIQFAV3v0mGP/V2CDi/gr/tpN\ntYsJxCjhXVyYPdUWN4KhjmB7vcwHAhCDBMyGyBlJiq52k1RKWls7h2dQM/KTTAC3\n41UlFf+IKTStixY/T8KJg60p0dDGH0dzOV0m4fM6LnqfIH2J/jDDzDck0rif0k+E\ndf5HMtgDHhS9bEWLh7KHoLCnE4+8T0ZaelgGEK/XgQKBgQDoDHqANmXTOFWvelUU\nldlay01yZVWU7bSmVDDNOZfvhiJldMQad5CZl7o5NKkjOHNolgPtwjaF+42uqsGZ\nod2dMmmMIZqQK1pzvR1hy4AT8zCb93vn5c+AqCzKflH60O6KMkjh6sw3q2I6s0PQ\nt+6GF5Tc3DKcyzmQj968gWaCgQKBgQDEudaJoOs1r8v4qym5IDhWmKq5tO9SVKS8\nMIo5mrL86CMukOeFLW6h9h2X6Wg+QNgPRDKIerA2OrUMels6Dk8v3nVrD7i/R9Pe\nvb8YsRxV3Ypw8jAlbK3kaflT5NdwWYj0vsUaBshYB1gDULMzWJ0FG8r4nT83LR6F\n1of3gq//PQKBgQCslCNDWbGvPnWTlXLTZYMKoKsPyke1BHjXP0QwTYYvMN5CAG6c\nlJHpeUuZog2s0R4cCX4QhOGSEf1Ui1CDFzw/3i9bdd6DHIsgCuVgRz4RGEvto0j2\nthb2Q51UWFBWLq9J/o3v33VUbdUXfR2RjEoMVltzSx0lOYutdSKdpct8gQKBgGAN\nmPnED3Q8LKxy7kFMwRVPH3TjKkMZvwF/9c2ggipIMf1nlROKlk0QPWzR8ysKQDRc\nCQxoUyd3TLUV/PsAx5tI1C39FCiZKpLENM0alQo7zH/PUMDFKravI6TZxHM/1EYj\n61sE2sdYdpnPyl+Usb4vzs/K/3WyWwfgMq0gK0zFAoGACi/UPpkMzyqQBz3RR7eC\nwn4MqL5OTEwaa+RcK5QBMZA3DY/lPJUnr7m6PQ/27eESaIQDfe/FsCbZAQ68yNq+\npBbtPxOP9LAKNQB1tfH6qNVt31DnsdUwV7GnjYcahgQjlYELe8ciYMmh8XfinzaP\nq0PJsn2bmJ0i9GmPtHhHVVE=\n-----END PRIVATE KEY-----\n",
  "client_email": "bill-maker-427@bill-maker-427520.iam.gserviceaccount.com",
  "client_id": "116359643929522580259",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/bill-maker-427%40bill-maker-427520.iam.gserviceaccount.com",
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
    var sheet = ss.worksheetByTitle('Invoice1');
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
