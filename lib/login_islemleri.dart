import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


FirebaseAuth _auth = FirebaseAuth.instance;


class LoginIslemleri extends StatefulWidget {
  @override
  _LoginIslemleriState createState() => _LoginIslemleriState();
}

class _LoginIslemleriState extends State<LoginIslemleri> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _auth
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login İşlemleri"),
      ),
      body: Center(
        child: Column(
          children: [
            RaisedButton(
              child: Text("Email/Sifre User Create"),
              color: Colors.blueAccent,
              onPressed: _emailSifreKullaniciOlustur,
            ),
            RaisedButton(
              child: Text("Email/Sifre User Login"),
              color: Colors.green,
              onPressed: _emailSifreKullaniciGirisYap,
            ),
            RaisedButton(
              child: Text("Şifremi unuttum"),
              color: Colors.orange,
              onPressed: _resetPassword,
            ),
            RaisedButton(
              child: Text("Şifremi güncelle"),
              color: Colors.purple,
              onPressed: _updatePassword,
            ),
            RaisedButton(
              child: Text("Şifremi güncelle"),
              color: Colors.brown,
              onPressed: _updateEmail,
            ),
            RaisedButton(
              child: Text("Google ile giriş"),
              color: Colors.yellow,
              onPressed: _googleIleGiris,
            ),
            RaisedButton(
              child: Text("Telefon ile giriş"),
              color: Colors.yellow,
              onPressed: _telNoGiris,
            ),
            RaisedButton(
              child: Text("Email/Sifre Logout"),
              color: Colors.teal,
              onPressed: _cikisYap,
            )
          ],
        ),
      ),
    );
  }

  Future<UserCredential> _googleIleGiris() async {

     // Trigger the authentication flow
     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

     // Obtain the auth details from the request
     final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

     // Create a new credential
     final credential = GoogleAuthProvider.credential(
       accessToken: googleAuth.accessToken,
       idToken: googleAuth.idToken,
     );

     // Once signed in, return the UserCredential
     return await _auth.signInWithCredential(credential);

  }

  void _emailSifreKullaniciOlustur() async{
    String _email = "dogukanatis@gmail.com";
    String _password = "123456";

   try{
     UserCredential _credential = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
     User? _yeniUser = _credential.user;
     await _yeniUser!.sendEmailVerification();
     if(_auth.currentUser != null){
       debugPrint("Maili onaylayın");
       await _auth.signOut();
     }
     debugPrint(_yeniUser.toString());
   }catch(e){
     print("Hata " + e.toString());
   }

  }



  void _emailSifreKullaniciGirisYap() async{
    String _email = "dogukanatis@gmail.com";
    String _password = "123456";

    try{
      if(_auth.currentUser == null){
        User? _oturumAcanUser = (await _auth.signInWithEmailAndPassword(email: _email, password: _password)).user;

        if(_oturumAcanUser!.emailVerified){
         debugPrint("Mail onaylı anasayfaya gidebilir");
        }else{
          debugPrint("Lütfen önce mailinizi onaylayın!");
          _auth.signOut();
        }

      }else{
        debugPrint("Zaten giriş yapmış kullanıcı var");
      }
    }catch(e){
      debugPrint("hata! " + e.toString());
    }

  }

  void _cikisYap() async{
    if(_auth.currentUser != null){
      await _auth.signOut();
    }else{
      debugPrint("Oturum açmış kullanıcı yok!");
    }
  }

  void _resetPassword() async{
    String _email = "dogukanatis@gmail.com";
    try{
      await _auth.sendPasswordResetEmail(email: _email);
      debugPrint("Reset mail gönderildi");
    }
    catch(e){
      debugPrint("şifre resetlenirken bir hata oluştu" + e.toString());
    }
  }



  void _updatePassword() async{
    String _email = "dogukanatis@gmail.com";
    String _password = "123456123";
    try{
      await _auth.currentUser!.updatePassword(_password);
      debugPrint("şifre güncellendi");
    }catch(e){

      try{
        AuthCredential credential = EmailAuthProvider.credential(email: _email, password: _password);
        await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
        debugPrint("Girilen eski email şifre bilgisi doğru");
        await _auth.currentUser!.updatePassword(_password);
        debugPrint("auth yeniden sağlandı, şifrede güncel");
      }catch(e){
        debugPrint("hata çıktı $e");
      }
      debugPrint("Şifre güncellenirken hata oluştu! " +e.toString());
    }
  }

  void _updateEmail() async{
    String _email = "dogukanatis2@gmail.com";
    String _password = "123456123";
    try{
      await _auth.currentUser!.updateEmail(_email);
      debugPrint("email güncellendi");
    }  on FirebaseAuthException catch(e){
      try{
        AuthCredential credential = EmailAuthProvider.credential(email: _email, password: _password);
        await FirebaseAuth.instance.currentUser!.reauthenticateWithCredential(credential);
        debugPrint("Girilen eski email şifre bilgisi doğru");
        await _auth.currentUser!.updateEmail(_email);
        debugPrint("auth yeniden sağlandı, şifrede güncel");
      }catch(e){
        debugPrint("hata çıktı $e");
      }
      debugPrint("email güncellenirken hata oluştu! " +e.toString());
    }
  }

  void _telNoGiris() async{
    await _auth.verifyPhoneNumber(
      phoneNumber: '+90 533 838 31 85',
      verificationCompleted: (PhoneAuthCredential credential) async{
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Verification failed: $e");
      },
      codeSent: (String verificationId, int? resendToken) async{
        debugPrint("kod yollandı");
        try{
          // Update the UI - wait for the user to enter the SMS code
          String smsCode = '123456';

          // Create a PhoneAuthCredential with the code
          AuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

          // Sign the user in (or link) with the credential
          // await _auth.signInWithCredential(credential);
        }catch(e){
          debugPrint("kod yollanamadı $e");
        }

      },
      codeAutoRetrievalTimeout: (String verificationId) {
        debugPrint("Timeout");
      },
    );
  }

}
