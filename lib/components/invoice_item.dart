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
    this.selected = false,
  });

  // Add this method
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'items': items.map((item) => item.toJson()).toList(),
      'selected': selected,
    };
  }
}

@HiveType(typeId: 1)
class Item {
  @HiveField(0)
  String item;

  @HiveField(1)
  String size;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  double rate;

  Item({
    required this.item,
    required this.size,
    required this.quantity,
    required this.rate,
  });

  // Add this method
  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'size': size,
      'quantity': quantity,
      'rate': rate,
    };
  }
}
