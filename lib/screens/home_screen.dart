import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/facility.dart';
import '../models/loan.dart';
import '../providers/app_provider.dart';
import '../widgets/status_badge.dart';
import 'loan_form_screen.dart';
import 'loan_detail_screen.dart';
import 'qr_screen.dart';
import 'scan_screen.dart';
import 'facility_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _query = '';

  Future<void> _logout() async {
    await context.read<AppProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.user;
    if (user == null) return const Scaffold(body: Center(child: Text('Sesi berakhir. Silakan login kembali.')));
    final isStudent = user.role == 'MAHASISWA';
    final isAdmin = user.role == 'ADMIN';
    final titles = isStudent ? ['Beranda','Sarana','Peminjaman','Profil'] :
      isAdmin ? ['Dashboard','Pengajuan','Profil'] : ['Dashboard','Transaksi','Sarana','Profil'];
    final pages = isStudent
      ? [_dashboard(app), _facilityList(app), _loanList(app), _profile(user.name,user.email,user.role)]
      : isAdmin
        ? [_dashboard(app), _loanList(app, admin:true), _profile(user.name,user.email,user.role)]
        : [_dashboard(app), _loanList(app, admin:true), _facilityList(app), _profile(user.name,user.email,user.role)];
    final icons = isStudent ? [Icons.home_outlined,Icons.inventory_2_outlined,Icons.receipt_long,Icons.person_outline] :
      isAdmin ? [Icons.dashboard_outlined,Icons.fact_check_outlined,Icons.person_outline] :
      [Icons.dashboard_outlined,Icons.receipt_long,Icons.inventory_2_outlined,Icons.person_outline];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_tab]), actions: [
        IconButton(tooltip:'Muat ulang data', onPressed: () async {
          await app.refreshFacilities(); await app.refreshLoans();
        }, icon: const Icon(Icons.refresh))
      ]),
      body: IndexedStack(index:_tab, children:pages),
      floatingActionButton: !isStudent && !isAdmin && _tab == 2
        ? FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FacilityFormScreen())),
            icon: const Icon(Icons.add), label: const Text('Tambah sarana'))
        : !isStudent && !isAdmin && _tab == 1
          ? FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen())),
              icon: const Icon(Icons.qr_code_scanner), label: const Text('Scan QR'))
          : null,
      bottomNavigationBar: NavigationBar(selectedIndex:_tab, onDestinationSelected:(i)=>setState(()=>_tab=i),
        destinations: List.generate(titles.length, (i) => NavigationDestination(icon:Icon(icons[i]),label:titles[i]))),
    );
  }

  Widget _dashboard(AppProvider app) {
    final user = app.user!;
    final visibleLoans = app.loans;
    return RefreshIndicator(onRefresh: () async { await app.refreshFacilities(); await app.refreshLoans(); },
      child: ListView(padding:const EdgeInsets.all(16), children:[
        Container(padding:const EdgeInsets.all(22), decoration:BoxDecoration(
          gradient:const LinearGradient(colors:[Color(0xFF2457C5),Color(0xFF5684E8)]),
          borderRadius:BorderRadius.circular(24)),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            const Text('SELAMAT DATANG',style:TextStyle(color:Colors.white70,fontWeight:FontWeight.bold,letterSpacing:1)),
            const SizedBox(height:8),
            Text(user.name,style:const TextStyle(color:Colors.white,fontSize:24,fontWeight:FontWeight.bold)),
            const SizedBox(height:8),
            Text('Akses ${user.role.replaceAll('_',' ')} • Data tersimpan secara lokal',style:const TextStyle(color:Colors.white)),
          ])),
        const SizedBox(height:16),
        GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:2,
          crossAxisSpacing:12,mainAxisSpacing:12,childAspectRatio:1.45,children:[
            _statCard('Total sarana','${app.facilities.length}',Icons.inventory_2_outlined,Colors.blue),
            _statCard('Stok tersedia','${app.facilities.fold<int>(0,(s,f)=>s+f.availableQty)}',Icons.check_circle_outline,Colors.green),
            _statCard('Pengajuan','${visibleLoans.where((l)=>l.status=='SUBMITTED').length}',Icons.hourglass_top,Colors.orange),
            _statCard('Disetujui','${visibleLoans.where((l)=>l.status=='APPROVED').length}',Icons.verified_outlined,Colors.teal),
          ]),
        const SizedBox(height:20),
        Text('Sarana pilihan',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
        const SizedBox(height:10),
        ...app.facilities.take(3).map((f)=>_facilityTile(f, app.user!.role=='MAHASISWA')),
        const SizedBox(height:20),
        Text('Transaksi terbaru',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
        const SizedBox(height:10),
        if(visibleLoans.isEmpty) const _EmptyState(message:'Belum ada transaksi.'),
        ...visibleLoans.take(3).map(_loanTile),
      ]));
  }

  Widget _statCard(String title,String value,IconData icon,Color color) => Card(
    child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
      Icon(icon,color:color,size:25), Text(value,style:const TextStyle(fontSize:25,fontWeight:FontWeight.bold)),
      Text(title,style:const TextStyle(color:Colors.black54)),
    ])));

  Widget _facilityList(AppProvider app) {
    final list = app.facilities.where((f)=>('${f.name} ${f.code} ${f.category} ${f.location}').toLowerCase().contains(_query.toLowerCase())).toList();
    return Column(children:[
      Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),child:TextField(
        decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Cari nama, kode, kategori, atau lokasi',),
        onChanged:(v)=>setState(()=>_query=v))),
      Expanded(child:list.isEmpty?const _EmptyState(message:'Sarana tidak ditemukan.'):ListView(
        padding:const EdgeInsets.all(12),children:list.map((f)=>_facilityTile(f,app.user!.role=='MAHASISWA')).toList())),
    ]);
  }

  Widget _facilityTile(Facility f,bool canBorrow) => Card(
    margin:const EdgeInsets.only(bottom:10),
    child:ListTile(contentPadding:const EdgeInsets.all(12),
      leading:Container(width:52,height:52,decoration:BoxDecoration(color:Colors.blue.withOpacity(.1),borderRadius:BorderRadius.circular(14)),
        child:const Icon(Icons.inventory_2_outlined,color:Color(0xFF2457C5))),
      title:Text(f.name,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Padding(padding:const EdgeInsets.only(top:5),child:Text('${f.code} • ${f.category}\n${f.location}\nStok tersedia: ${f.availableQty}/${f.totalQty}')),
      isThreeLine:true,
      trailing:canBorrow?const Icon(Icons.chevron_right):null,
      onTap:canBorrow?()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LoanFormScreen(facility:f))):null,
    ));

  Widget _loanList(AppProvider app,{bool admin=false}) {
    final list = admin ? app.loans : app.loans.where((l)=>l.borrowerId==app.user!.id).toList();
    if(list.isEmpty) return const _EmptyState(message:'Belum ada pengajuan peminjaman.');
    return RefreshIndicator(onRefresh:app.refreshLoans,child:ListView(padding:const EdgeInsets.all(12),
      children:list.map((loan)=>_loanTile(loan, admin:admin)).toList()));
  }

  Widget _loanTile(Loan loan,{bool admin=false}) => Card(
    margin:const EdgeInsets.only(bottom:10),
    child:ListTile(
      leading:CircleAvatar(backgroundColor:Colors.blue.withOpacity(.1),child:const Icon(Icons.receipt_long,color:Color(0xFF2457C5))),
      title:Text(loan.facilityName,style:const TextStyle(fontWeight:FontWeight.bold)),
      subtitle:Padding(padding:const EdgeInsets.only(top:6),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('${loan.loanCode} • ${loan.quantity} unit'),
        if(admin) Text('Peminjam: ${loan.borrowerName}'),
        const SizedBox(height:6),StatusBadge(loan.status),
      ])),
      isThreeLine:true,
      trailing:const Icon(Icons.chevron_right),
      onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LoanDetailScreen(loan:loan,admin:admin))),
    ));

  Widget _profile(String name,String email,String role) => ListView(padding:const EdgeInsets.all(16),children:[
    CircleAvatar(radius:42,backgroundColor:Theme.of(context).colorScheme.primary,child:const Icon(Icons.person,size:44,color:Colors.white)),
    const SizedBox(height:16),Center(child:Text(name,style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold))),
    Center(child:Text(email,style:const TextStyle(color:Colors.black54))),
    const SizedBox(height:20),
    Card(child:Column(children:[
      ListTile(leading:const Icon(Icons.badge_outlined),title:const Text('Peran'),subtitle:Text(role.replaceAll('_',' '))),
      const Divider(height:1),
      const ListTile(leading:Icon(Icons.offline_bolt_outlined),title:Text('Mode offline'),subtitle:Text('Data tersimpan di perangkat ini dan tidak tersinkron antarperangkat.')),
    ])),
    const SizedBox(height:16),FilledButton.tonalIcon(onPressed:_logout,icon:const Icon(Icons.logout),label:const Text('Keluar')),
  ]);
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context)=>Center(child:Padding(padding:const EdgeInsets.all(30),child:Column(mainAxisSize:MainAxisSize.min,children:[
    Icon(Icons.inbox_outlined,size:54,color:Colors.grey.shade400),const SizedBox(height:12),Text(message,textAlign:TextAlign.center,style:const TextStyle(color:Colors.black54))
  ])));
}
