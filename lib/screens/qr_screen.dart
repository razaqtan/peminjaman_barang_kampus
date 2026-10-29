import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/loan.dart';
import '../widgets/status_badge.dart';

class QrScreen extends StatelessWidget {
  final Loan loan;
  const QrScreen({super.key,required this.loan});
  @override
  Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('QR Peminjaman')),body:Center(child:SingleChildScrollView(
    padding:const EdgeInsets.all(24),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
      const Icon(Icons.verified_outlined,color:Colors.green,size:44),
      const SizedBox(height:12),Text('Transaksi disetujui',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
      const SizedBox(height:8),Text(loan.loanCode,style:const TextStyle(color:Colors.black54)),
      const SizedBox(height:20),
      Container(padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20)),
        child:QrImageView(data:loan.qrPayload.isEmpty?loan.loanCode:loan.qrPayload,size:240)),
      const SizedBox(height:20),StatusBadge(loan.status),
      const SizedBox(height:12),const Text('Tunjukkan QR ini kepada Super Admin saat pengambilan sarana.',textAlign:TextAlign.center),
    ]))));
}
