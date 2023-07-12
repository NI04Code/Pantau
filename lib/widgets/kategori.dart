

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/kasus.dart';

final selectedCategoryProvider = StateProvider<int>((ref) => -1);
final categoryExtendedProvider = StateProvider<bool>((ref) => false);
final isSelectedProvider = StateProvider<bool>((ref) => false);
class CategorySelection extends ConsumerStatefulWidget{
  @override
  ConsumerState<CategorySelection> createState() {
    // TODO: implement createState
    return _CategorySelectionState();
  }
}
class _CategorySelectionState extends ConsumerState<CategorySelection> {
  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(isSelectedProvider);
    final selectedCategory =  ref.watch(selectedCategoryProvider);
    final isExtended = ref.watch(categoryExtendedProvider);

   return Container(
     constraints: const BoxConstraints(maxWidth: 850),
     child: Column(
       mainAxisSize:  MainAxisSize.min,
       children: [
         Wrap(
           spacing: 8,
           runSpacing: 8,
           children: !isExtended?
           [
             for(int i = 0; i < 8; i++) if(TipeKasus.values[i].name != TipeKasus.LaporanCepat.name &&
                 TipeKasus.values[i].name != TipeKasus.SemuaKategori.name)ElevatedButton(
           onPressed: (){
             ref.read(isSelectedProvider.notifier).state = true;
          ref.read(selectedCategoryProvider.notifier).state = i;

    },
    child: Text(TipeKasus.values[i].name),
    style: ElevatedButton.styleFrom(
    foregroundColor: selectedCategory != i? Color.fromRGBO(40,65,100,1) : Colors.white,
    backgroundColor: selectedCategory == i? Colors.blue : Color.fromRGBO(240, 240, 240, 1),
    ),),
    ]
               :[
             for(int i = 0; i < TipeKasus.values.length; i++) if(
             TipeKasus.values[i].name != TipeKasus.LaporanCepat.name && TipeKasus.values[i].name != TipeKasus.SemuaKategori.name)ElevatedButton(
                 onPressed: (){
                   ref.read(selectedCategoryProvider.notifier).state = i;
                   ref.read(isSelectedProvider.notifier).state = true;
                 },
                 child: Text(TipeKasus.values[i].name),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: selectedCategory != i? Color.fromRGBO(40,65,100,1) : Colors.white,
                    backgroundColor: selectedCategory == i? Colors.blue : Color.fromRGBO(240, 240, 240, 1),
                  ),),
           ],
         ),
         SizedBox(height: 24,),
         if(selectedCategory == -1 && !isSelected ) const Text('Silahkan memilih kategori kasus', style: TextStyle(color: Colors.red),)
       ],
     ),
   );
  }
}