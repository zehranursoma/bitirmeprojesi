import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/modeller/gonderi.dart';
import 'package:flutter_application_1/modeller/kullanici.dart';
import 'package:flutter_application_1/modeller/yorum.dart';
import 'package:flutter_application_1/servisler/firestoreservisi.dart';
import 'package:flutter_application_1/servisler/yetkilendirmeservisi.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class Yorumlar extends StatefulWidget {
  final Gonderi gonderi;

  const Yorumlar({Key key, this.gonderi}) : super(key: key);
  @override
  _YorumlarState createState() => _YorumlarState();
}

class _YorumlarState extends State<Yorumlar> {
  TextEditingController _yorumKontrolcusu = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    timeago.setLocaleMessages("tr", timeago.TrMessages()); //yorumun yapıldığı zamanı türkçe yazmak için
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[100],
          title: Text(
            "Yorumlar",
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: <Widget>[_yorumlariGoster(), _yorumEkle()],
        ));
  }

  _yorumlariGoster() {
    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: FireStoreServisi().yorumlariGetir(widget.gonderi.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    Yorum yorum =
                        Yorum.dokumandanUret(snapshot.data.documents[index]);
                    return _yorumSatiri(yorum);
                  });
            }));
  }

  _yorumSatiri(Yorum yorum) {
    return FutureBuilder<Kullanici>(
        future: FireStoreServisi().kullaniciGetir(yorum.yayinlayanId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(
              height: 0.0,
            );
          }

          Kullanici yayinlayan = snapshot.data;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(yayinlayan.fotoUrl),
            ),
            title: RichText(
                text: TextSpan(
                    text: yayinlayan.kullaniciAdi + " ",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    children: [
                  TextSpan(
                      text: yorum.icerik,
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14.0)),
                ])),
            subtitle: Text(timeago.format(yorum.olusturulmaZamani.toDate(),locale:"tr")), //yorumun yapıldığı zaman
          );
        });
  }

  _yorumEkle() {
    return ListTile(
      title: TextFormField(
        controller: _yorumKontrolcusu,
        decoration: InputDecoration(hintText: "Yorum yap..."),
      ),
      trailing: IconButton(
        icon: Icon(Icons.send),
        onPressed: _yorumGonder,
      ),
    );
  }

  void _yorumGonder() {
    String aktifKullaniciId =
        Provider.of<YetkilendirmeServisi>(context, listen: false)
            .aktifKullaniciId;

    FireStoreServisi().yorumEkle(
        aktifKullaniciId: aktifKullaniciId,
        gonderi: widget.gonderi,
        icerik: _yorumKontrolcusu.text);
    _yorumKontrolcusu.clear(); //yorum yazıldıktan sonra klavyeyi temizler
  }
}
