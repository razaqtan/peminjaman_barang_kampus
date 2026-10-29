import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/facility.dart';
import '../providers/app_provider.dart';

class LoanFormScreen extends StatefulWidget {
  final Facility facility;
  const LoanFormScreen({super.key,required this.facility});
  @override
  State<LoanFormScreen> createState()=>_LoanFormScreenState();
}
class _LoanFormScreenState extends State<LoanFormScreen>{
  final _key=GlobalKey<FormState>();
  final _quantity=TextEditingController(text:'1');
  final _purpose=TextEditingController();
  DateTime? _start;
  DateTime? _end;
  bool _busy=false;
  @override
  void dispose(){_quantity.dispose();_purpose.dispose();super.dispose();}

  Future<DateTime?> _pick(DateTime? initial) async {
    final now=DateTime.now();
    return showDatePicker(context:context,initialDate:initial??now,firstDate:DateTime(now.year,now.month,now.day),lastDate:DateTime(now.year+2));
  }
  String _date(DateTime? d)=>d==null?'Pilih tanggal':'${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';

  Future<void> _submit() async {
    if(!_key.currentState!.validate())return;
    if(_start==null||_end==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Tanggal mulai dan selesai wajib dipilih.')));return;}
    if(!_end!.isAfter(_start!)){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Tanggal selesai harus setelah tanggal mulai.')));return;}
    setState(()=>_busy=true);
    try{
      await context.read<AppProvider>().createLoan(facility:widget.facility,quantity:int.parse(_quantity.text),start:_start!,end:_end!,purpose:_purpose.text.trim());
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Pengajuan berhasil dikirim. Status: SUBMITTED.')));
      Navigator.pop(context);
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString().replaceFirst('Exception: ',' '))));
    }finally{if(mounted)setState(()=>_busy=false);}
  }

  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Form Peminjaman')),
    body:Form(key:_key,child:ListView(padding:const EdgeInsets.all(16),children:[
      Card(child:ListTile(leading:const Icon(Icons.inventory_2_outlined),title:Text(widget.facility.name,style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${widget.facility.code} • ${widget.facility.location}\nStok tersedia: ${widget.facility.availableQty}'))),
      const SizedBox(height:16),
      TextFormField(controller:_quantity,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Jumlah sarana',prefixIcon:Icon(Icons.numbers)),
        validator:(v){final n=int.tryParse(v??'');if(n==null||n<1)return 'Jumlah minimal 1.';if(n>widget.facility.availableQty)return 'Jumlah melebihi stok yang tersedia.';return null;}),
      const SizedBox(height:16),
      OutlinedButton.icon(onPressed:()async{final d=await _pick(_start);if(d!=null)setState(()=>_start=d);},icon:const Icon(Icons.calendar_today),label:Text('Tanggal mulai: ${_date(_start)}')),
      const SizedBox(height:8),
      OutlinedButton.icon(onPressed:()async{final d=await _pick(_end??_start);if(d!=null)setState(()=>_end=d);},icon:const Icon(Icons.event_available),label:Text('Tanggal selesai: ${_date(_end)}')),
      const SizedBox(height:16),
      TextFormField(controller:_purpose,minLines:3,maxLines:5,decoration:const InputDecoration(labelText:'Tujuan penggunaan',hintText:'Contoh: seminar, presentasi, kegiatan organisasi'),
        validator:(v)=>v==null||v.trim().isEmpty?'Tujuan penggunaan wajib diisi.':null),
      const SizedBox(height:24),
      FilledButton.icon(onPressed:_busy?null:_submit,icon:const Icon(Icons.send),label:Text(_busy?'Mengirim...':'Kirim Pengajuan'),style:FilledButton.styleFrom(padding:const EdgeInsets.all(16))),
    ])));
}
