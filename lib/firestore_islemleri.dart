import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class FireStoreIslemleri extends StatefulWidget {
  @override
  _FireStoreIslemleriState createState() => _FireStoreIslemleriState();
}

class _FireStoreIslemleriState extends State<FireStoreIslemleri> {



  void initState() {
    // TODO: implement initState
    super.initState();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore İşlemleri"),
      ),
      body: Center(
        child: Column(
          children: [
            RaisedButton(
              child: Text("Veri Ekle"),
              color: Colors.green,
              onPressed: _veriEkle,
            ),
            RaisedButton(
              child: Text("Transaction Ekle"),
              color: Colors.blue,
              onPressed: _transactionEkle,
            ),
            RaisedButton(
              child: Text("Veri Sil"),
              color: Colors.red,
              onPressed: _veriSil,
            ),
            RaisedButton(
              child: Text("Veri Oku"),
              color: Colors.pink,
              onPressed: _veriOku,
            ),
            RaisedButton(
              child: Text("Veri Sorgula"),
              color: Colors.brown,
              onPressed: _veriSorgula,
            ),
            RaisedButton(
                child: Text("Galeriden Storagea Resim"),
                color: Colors.orange,
                onPressed: _galeriResimUpload,
            ),
            RaisedButton(
                child: Text("Kameradan Storagea Resim"),
                color: Colors.purple,
                onPressed: _kameraResimUpload,
            ),
            Expanded(
              child: _secilenResim == null
                  ? Text("Resim YOK")
                  : Image.file(File(_secilenResim.path)),
            )
          ],
        ),
      ),
    );
  }

  void _veriEkle() {
    Map<String, dynamic> dogukanEkle = Map();
    dogukanEkle["ad"] = "dogukan";
    dogukanEkle["okul"] = "daü";
    dogukanEkle["lisansMezunu"] = true;
    _firestore.collection("users").doc("dogukan_atis").set(dogukanEkle).then((value) => debugPrint("dogukan eklendi"));
    
    _firestore.collection("users").doc("hasan_yilmaz").set({"ad":"Hasan","Cinsiyet":"erkek"}).whenComplete(() => debugPrint("hasan eklendi"));

    _firestore.doc("/users/ayse").set({"ad":"ayse"});

    _firestore.collection("users").add({"ad":"can", "yas": 20});

    String yeniKullaniciID = _firestore.collection("users").doc().id;
    debugPrint("yeni doc id : $yeniKullaniciID");
    _firestore.doc("users/$yeniKullaniciID").set({"yas":21});
    
    _firestore.doc("users/dogukan_atis").update({"okul":"akdeniz","eklenme":FieldValue.serverTimestamp()}).then((value){
      debugPrint("dogukan güncellendi");
    });
  }

  void _transactionEkle() {
    final DocumentReference dogukanRef = _firestore.doc("users/dogukan_atis");

    _firestore.runTransaction((transaction) async {
      DocumentSnapshot dogukanData = await dogukanRef.get();

      var dogukaninParasi = (dogukanData.data() as Map)["para"];
      if(dogukanData.exists){
        if(dogukaninParasi > 100){
           transaction.update(dogukanRef, {"para": (dogukaninParasi-100)});
           transaction.update(_firestore.doc("users/hasan_yilmaz"), {"para":FieldValue.increment(100)});
        }else{
          debugPrint("Yetersiz bakiye");
        }
      }else{
        debugPrint("dogukan dökümanı yok");
      }

    });
  }

  void _veriSil() {

    _firestore.doc("users/ayse").delete().then((value) => debugPrint("Ayse silindi"));

  }

  Future<void> _veriOku() async {
    DocumentSnapshot documentSnapshot= await _firestore.doc("users/dogukan_atis").get();
    debugPrint("döküman id: " + documentSnapshot.id);
    debugPrint("döküman var mı: " + documentSnapshot.exists.toString());
    debugPrint("döküman içerik: " + documentSnapshot.toString());
    debugPrint("bekleyen yazma var mı: " + documentSnapshot.metadata.hasPendingWrites.toString());
    debugPrint("cahce den mi geldi:  " + documentSnapshot.metadata.isFromCache.toString());
    debugPrint("data:   " + documentSnapshot.data.toString());
    debugPrint("data:   " + (documentSnapshot.data() as Map )["ad"]);


    _firestore.collection("users").get().then((querySnapshots){
      debugPrint("users kolek eleman sayısı:" + querySnapshots.docs.length.toString());
      for(int i=0; i<querySnapshots.docs.length; i++){
        debugPrint(querySnapshots.docs[i].data().toString());
      }
     var ref = _firestore.collection("users").doc("dogukan_atis");
      ref.snapshots().listen((degisenVeri) {
        debugPrint("anlık : " + degisenVeri.data().toString());
      });
    });
  }

  Future<void> _veriSorgula() async {
   var dokumanlar = await _firestore.collection("users").where("email", isEqualTo: "dogukanatis@gmail.com").get();
   for(var dokuman in dokumanlar.docs){
     debugPrint(dokuman.data().toString());
   }
   var limitliGetir = await _firestore.collection("users").limit(2).get();
   for(var dokuman in limitliGetir.docs){
     debugPrint("limitli getirilenler: " + dokuman.data().toString());
   }
   var diziSorgula = await _firestore.collection("users").where("dizi", arrayContains: "breaking bad").get();
   for(var dokuman in diziSorgula.docs){
     debugPrint("dizi şartı ile getirilenler: " + dokuman.data().toString());
   }
   _firestore.collection("users").doc("dogukan_atis").get().then((docSnap) {
     debugPrint(" dogukanın verileri : " + docSnap.data().toString());
     _firestore.collection("users").orderBy("begeni").startAt([(docSnap.data() as Map )["begeni"]]).get().then((querySnap){
       if(querySnap.docs.length > 0){
         for(var bb in querySnap.docs){
           debugPrint(" dogukanın begenisinden fazla olan user : " + bb.data().toString());
         }
       }
     });
   });
  }

  late PickedFile _secilenResim;

  void _galeriResimUpload() async {
    var _picker = ImagePicker();
    var resim = await _picker.getImage(source: ImageSource.gallery);
    setState(() {
      _secilenResim = resim!;
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child("user")
        .child("emre")
        .child("profil.png");
    var uploadTask = ref.putFile(File(_secilenResim.path));

    var url = (await ref.getDownloadURL().toString());
    debugPrint("upload edilen resmin urlsi : " + url);
  }

  void _kameraResimUpload() async {
    var resim = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _secilenResim = resim!;
    });

    var ref = FirebaseStorage.instance
        .ref()
        .child("user")
        .child("hasan")
        .child("profil.png");
    var uploadTask = ref.putFile(File(_secilenResim.path));

    var url = (await ref.getDownloadURL().toString());
    debugPrint("upload edilen resmin urlsi : " + url);
  }

}

