import 'package:flutter/material.dart';
import 'package:flutter_application_1/modeller/kullanici.dart';
import 'package:flutter_application_1/sayfalar/anasayfa.dart';
import 'package:flutter_application_1/sayfalar/girissayfasi.dart';
import 'package:flutter_application_1/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';
class Yonlendirme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final _yetkilendirmeServisi = Provider.of<YetkilendirmeServisi>(context, listen: false);
    
    return StreamBuilder(
      stream: _yetkilendirmeServisi.durumTakipcisi,
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if(snapshot.hasData){
          Kullanici aktifKullanici = snapshot.data;
          _yetkilendirmeServisi.aktifKullaniciId = aktifKullanici.id;
          return AnaSayfa();
        } else {
          return GirisSayfasi();
        }

      }
      );
  }
}
