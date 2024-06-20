import 'package:hive/hive.dart';

part 'invoice_item.g.dart';

@HiveType(typeId: 0)
class InvoiceItem extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  List<Item> items;

  @HiveField(2)
  bool selected;

  InvoiceItem({
    required this.title,
    required this.items,
    required this.selected,
  });
}

@HiveType(typeId: 1)
class Item extends HiveObject {
  @HiveField(0)
  String item;

  @HiveField(1)
  int quantity;

  @HiveField(2)
  double rate;

  Item({
    required this.item,
    required this.quantity,
    required this.rate,
  });
}
