import 'package:flutter/material.dart';
import 'package:pantau/widgets/kronologi_widget.dart';

import '../models/kronologi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantau/provider/kronologis_provider.dart';
class KronologiScreen extends ConsumerStatefulWidget {
  const KronologiScreen({super.key, });
  @override
  _KronologiScreenState createState() => _KronologiScreenState();
}

class _KronologiScreenState extends ConsumerState<KronologiScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  final _formKey = GlobalKey<FormState>();
  TextEditingController _judulController = TextEditingController();
  TextEditingController _kontenController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  int? lastYearLabel;
  @override
  void dispose() {
    _judulController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _kronologiList = ref.watch(kronologisListProvider);
    return Scaffold(
      body: _kronologiList.isEmpty? Center(
        child: Text('Mulai tambahkan kronologi', style: TextStyle(
          color: Colors.black
        ),),
      ) : ListView.builder(

        itemCount: _kronologiList.length,
        itemBuilder: (context, index) {
          final kronologi = _kronologiList[index];
          if(lastYearLabel == null || lastYearLabel!= kronologi.tanggal.year){
            lastYearLabel = kronologi.tanggal.year;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _buildYearLabel(lastYearLabel!),
                ),
                GestureDetector(
                    child: KronologiWidget(kronologi: kronologi, maxLines: 3,),
                    onLongPress: (){
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Konfirmasi Hapus'),
                            content: Text('Apakah Anda yakin ingin menghapus kronologi ini?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Tutup dialog
                                },
                                child: Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Hapus kronologi
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _kronologiList.remove(kronologi);
                                  });// Tutup dialog
                                },
                                child: Text('Hapus'),
                              ),
                            ],
                          );
                        },
                      );
                    },)
              ],
            );
          }
          return GestureDetector(
            child: KronologiWidget(kronologi: kronologi, maxLines: 3,),
            onLongPress: (){
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Konfirmasi Hapus'),
                    content: Text('Apakah Anda yakin ingin menghapus kronologi ini?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                        },
                        child: Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Hapus kronologi
                          Navigator.of(context).pop();
                          setState(() {
                            _kronologiList.remove(kronologi);
                          });// Tutup dialog
                        },
                        child: Text('Hapus'),
                      ),
                    ],
                  );
                },
              );
            },);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddKronologiDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
  Widget _buildYearLabel(int year) {
    return Container(
      alignment: Alignment.center,
      color: Colors.blue,
      child: Text(year.toString(), style: TextStyle(fontWeight: FontWeight.bold,
      fontSize: 16)),
    );
  }

  void _showAddKronologiDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Tambah Kronologi'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null && pickedDate.isBefore(DateTime.now())) {
                          setState(() {
                            _selectedDate = pickedDate;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      controller: _judulController,
                      decoration: InputDecoration(labelText: 'Judul'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Judul harus diisi';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _kontenController,
                      decoration: InputDecoration(labelText: 'Konten'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Konten harus diisi';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _addKronologi(
                        _selectedDate,
                        _judulController.text,
                        _kontenController.text,
                      );
                      _formKey.currentState!.reset();
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _addKronologi(DateTime tanggal, String judul, String konten) {
    final kronologiList = ref.watch(kronologisListProvider);
    kronologiList.add(Kronologi(tanggal: tanggal, judul: judul, konten:  konten));
    kronologiList.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    lastYearLabel = null;
    ref.read(kronologisListProvider.notifier).state = [...kronologiList];

  }
}