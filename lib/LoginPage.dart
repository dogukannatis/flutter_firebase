import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 270,
                color: Colors.lightBlueAccent,
              ),
              SizedBox(height: 30,),
              LoginScreenText("Login"),
              SizedBox(height: 20,),
              Form(
                key: _formKey,
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.alternate_email),
                            ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.lock),
                            ),
                            suffix:  GestureDetector(
                              child: Text("Forgot?", style: TextStyle(color: Colors.blue),
                              ),
                              onTap: (){
                                debugPrint("Forgot Password Function");
                              },
                            )
                          //TextButton(child: Text("Forgot?"), onPressed: (){}, style: TextButton.styleFrom(fixedSize: Size(5, 5)),)
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


}


Widget LoginScreenText(String text){

  return Padding(
    padding:  EdgeInsets.only(left:40.0),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
          text,
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold
        ),
      ),
    ),
  );

}

