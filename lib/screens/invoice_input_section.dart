// import 'package:flutter/material.dart';

// class InvoiceInputSection extends StatelessWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController itemController;
//   final TextEditingController quantityController;
//   final TextEditingController rateController;
//   final VoidCallback onAdd;

//   InvoiceInputSection({
//     required this.formKey,
//     required this.itemController,
//     required this.quantityController,
//     required this.rateController,
//     required this.onAdd,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           TextFormField(
//             controller: itemController,
//             decoration: const InputDecoration(
//               labelText: 'Item',
//               border: UnderlineInputBorder(),
//             ),
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter an item';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 10),
//           Row(
//             children: [
//               Expanded(
//                 child: TextFormField(
//                   controller: quantityController,
//                   decoration: const InputDecoration(
//                     labelText: 'Quantity',
//                     border: UnderlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a quantity';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: TextFormField(
//                   controller: rateController,
//                   decoration: const InputDecoration(
//                     labelText: 'Rate',
//                     border: UnderlineInputBorder(),
//                   ),
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a rate';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.add),
//                 onPressed: () {
//                   if (formKey.currentState!.validate()) {
//                     onAdd();
//                   }
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
