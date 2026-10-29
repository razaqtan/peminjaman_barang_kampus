import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState()=>_ScanScreenState();
}
class _ScanScreenState extends State<ScanScreen>{
  final _manual=TextEditingController();
  bool _busy=false;
  bool _handled=false;
  @override
  void dispose(){_manual.dispose();super.dispose();}

  Future<void> _process(String code,bool checkout) async {
    if(code.trim().isEmpty)return;
    setState(()=>_busy=true);
    try{
      await context.read<AppProvider>().handover(code.trim(),checkout);
      if(!mounted)return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(checkout?'Pengambilan berhasil dikonfirmasi.':'Pengembalian berhasil dikonfirmasi.')));
      _manual.clear();
      setState(()=>_handled=true);
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString().replaceFirst('Exception: ',' '))));}
    finally{if(mounted)setState(()=>_busy=false);}
  }

  @override
  Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Scan QR / Serah-terima')),body:ListView(padding:const EdgeInsets.all(16),children:[
    ClipRRect(borderRadius:BorderRadius.circular(20),child:SizedBox(height:280,child:MobileScanner(
      onDetect:(capture){
        if(_handled||_busy||capture.barcodes.isEmpty)return;
        final code=capture.barcodes.first.rawValue;
        if(code!=null&&code.isNotEmpty){_manual.text=code;setState(()=>_handled=true);}
      },
    ))),
    const SizedBox(height:12),const Text('Arahkan kamera ke QR transaksi yang telah disetujui. Pastikan kode terisi sebelum mengonfirmasi.'),
    const SizedBox(height:20),TextField(controller:_manual,decoration:const InputDecoration(labelText:'Kode transaksi (atau input manual)',prefixIcon:Icon(Icons.qr_code))),
    const SizedBox(height:12),FilledButton.icon(onPressed:_busy?null:()=>_process(_manual.text,true),icon:const Icon(Icons.outbox),label:const Text('Konfirmasi Pengambilan')),
    const SizedBox(height:8),OutlinedButton.icon(onPressed:_busy?null:()=>_process(_manual.text,false),icon:const Icon(Icons.assignment_return),label:const Text('Konfirmasi Pengembalian')),
    const SizedBox(height:8),TextButton(onPressed:()=>setState(()=>_handled=false),child:const Text('Scan QR berikutnya')),
  ]));
}
