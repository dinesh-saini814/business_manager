// import 'package:flutter/material.dart';
// import 'package:bill_maker/screens/invoice_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.0,
//         backgroundColor: Colors.transparent,
//         toolbarHeight: 100.0,
//         title: Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             SizedBox(height: 24.0),
//             IconButton(
//                 onPressed: () {
//                   Scaffold.of(context).openDrawer();
//                 },
//                 icon: Icon(Icons.auto_awesome_rounded),
//                 color: Colors.black),
//             SizedBox(width: 8.0),
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(30.0),
//             child: Container(
//               width: 40.0,
//               height: 30.0,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(25),
//                 image: const DecorationImage(
//                   image: AssetImage('assets/images/profile.jpeg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: Container(
//         color: Colors.transparent,
//         child: Align(
//           alignment: Alignment
//               .bottomRight, // Aligns the FAB to the bottom right corner
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: FloatingActionButton(
//               child: Icon(Icons.playlist_add),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => InvoiceScreen()),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:bill_maker/components/invoice_item.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'invoice_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

@override
_HomeScreenState createState() => _HomeScreenState();

class _HomeScreenState extends State<HomeScreen> {
  final Box<InvoiceItem> _invoiceBox = Hive.box<InvoiceItem>('invoices');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: Text(
            'Invoices',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Implement menu action
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.image, color: Colors.black),
            onPressed: () {
              // Implement image option action
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _invoiceBox.listenable(),
        builder: (context, Box<InvoiceItem> box, _) {
          if (box.values.isEmpty) {
            return Center(child: Text('No invoices yet.'));
          } else {
            return GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: box.values.length,
              itemBuilder: (context, index) {
                var invoice = box.getAt(index);
                return GestureDetector(
                  onLongPress: () {
                    setState(() {
                      invoice.selected = !invoice.selected;
                      invoice.save();
                    });
                  },
                  onTap: () {
                    if (box.values.any((invoice) => invoice.selected)) {
                      setState(() {
                        invoice.selected = !invoice.selected;
                        invoice.save();
                      });
                    } else {
                      _editInvoice(index, invoice);
                    }
                  },
                  child: Stack(
                    children: [
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      invoice?.title ?? 'Invoice ${index + 1}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  if (invoice!.selected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: invoice.items.length,
                                  itemBuilder: (context, itemIndex) {
                                    var item = invoice.items[itemIndex];
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Item: ${item.item}'),
                                        SizedBox(height: 10),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToInvoiceScreen,
        tooltip: 'Create Invoice',
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  void _navigateToInvoiceScreen() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => InvoiceScreen()),
    );

    if (result != null) {
      final invoice = InvoiceItem(
        title: result['title'],
        items: result['items'],
        selected: false,
      );
      _invoiceBox.add(invoice);
    }
  }

  void _editInvoice(int index, InvoiceItem invoice) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => InvoiceScreen(
          initialItems: invoice.items,
          initialTitle: invoice.title,
        ),
      ),
    );

    if (result != null) {
      invoice.title = result['title'];
      invoice.items = result['items'];
      invoice.selected = false;
      invoice.save();
    }
  }

  void _deleteInvoice(int index) {
    _invoiceBox.deleteAt(index);
  }

  void _deleteSelectedInvoices() {
    setState(() {
      final selectedInvoices =
          _invoiceBox.values.where((invoice) => invoice.selected).toList();
      for (var invoice in selectedInvoices) {
        invoice.delete();
      }
    });
  }

  Widget _buildBottomAppBar() {
    bool anySelected = _invoiceBox.values.any((invoice) => invoice.selected);

    if (anySelected) {
      return BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedInvoices,
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
