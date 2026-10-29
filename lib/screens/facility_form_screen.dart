import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class FacilityFormScreen extends StatefulWidget {
  const FacilityFormScreen({super.key});
  @override
  State<FacilityFormScreen> createState()=>_FacilityFormScreenState();
}
class _FacilityFormScreenState extends State<FacilityFormScreen>{
  final _key=GlobalKey<FormState>();
  final _code=TextEditingController();final _name=TextEditingController();
  final _category=TextEditingController();final _location=TextEditingController();
  final _description=TextEditingController();final _quantity=TextEditingController(text:'1');
  bool _busy=false;
  @override
  void dispose(){for(final c in [_code,_name,_category,_location,_description,_quantity]){c.dispose();}super.dispose();}
  Future<void> _save()async{
    if(!_key.currentState!.validate())return;
    setState(()=>_busy=true);
    try{
      await context.read<AppProvider>().addFacility(code:_code.text,name:_name.text,category:_category.text,
        location:_location.text,description:_description.text,quantity:int.parse(_quantity.text));
      if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Data sarana berhasil ditambahkan.')));Navigator.pop(context);
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Gagal menyimpan: $e')));}
    finally{if(mounted)setState(()=>_busy=false);}
  }
  String? _required(String? v)=>v==null||v.trim().isEmpty?'Kolom ini wajib diisi.':null;
  @override
  Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Tambah Sarana')),body:Form(key:_key,child:ListView(padding:const EdgeInsets.all(16),children:[
    TextFormField(controller:_code,decoration:const InputDecoration(labelText:'Kode sarana'),validator:_required),
    const SizedBox(height:12),TextFormField(controller:_name,decoration:const InputDecoration(labelText:'Nama sarana'),validator:_required),
    const SizedBox(height:12),TextFormField(controller:_category,decoration:const InputDecoration(labelText:'Kategori'),validator:_required),
    const SizedBox(height:12),TextFormField(controller:_location,decoration:const InputDecoration(labelText:'Lokasi'),validator:_required),
    const SizedBox(height:12),TextFormField(controller:_description,minLines:2,maxLines:4,decoration:const InputDecoration(labelText:'Deskripsi'),validator:_required),
    const SizedBox(height:12),TextFormField(controller:_quantity,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Jumlah stok'),validator:(v)=>int.tryParse(v??'')==null||int.parse(v!)<1?'Jumlah minimal 1.':null),
    const SizedBox(height:24),FilledButton.icon(onPressed:_busy?null:_save,icon:const Icon(Icons.save),label:Text(_busy?'Menyimpan...':'Simpan Sarana')),
  ])));
}
