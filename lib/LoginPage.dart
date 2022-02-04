import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_notes/PersonalNotes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final firestoreInstance = FirebaseFirestore.instance;
    final SmsAutoFill _autoFill = SmsAutoFill();
   int str = 0;
  bool isLoading = false;
  var key = "null";
  String? encryptedS,decryptedS;
  var password = "null";
  var phoneNum = "null";
  // PlatformStringCryptor? cryptor;
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool hideSignUp = false;
  Future<int> _askPhoneHint() async {
    String? hint = await _autoFill.hint;

    if (hint == null) {
      str = 1;
    } else {
      str = 2;
      txtPhone.value = TextEditingValue(
          text: hint.replaceAll("+91", '').replaceAll('+1', ''));
    }
    return str;
  }

  signUpcall() async {
     SharedPreferences preferences = await SharedPreferences.getInstance();
     var result = await firestoreInstance.collection("users").add({
       "Name":txtName.text,
       "PhoneNum":txtPhone.text,
       "Password":txtPassword.text
     });
     if(result.id !=null){
       
        preferences.setString("userId", result.id );
       Navigator.of(context).push(MaterialPageRoute(builder: (context)=>PersonalNotes()));
     }
  }
   logincall() async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
     var result = await firestoreInstance.collection("users").where("PhoneNum",isEqualTo: txtPhone.text).where("Password",isEqualTo: txtPassword.text).get();
     if(result.docs.isNotEmpty){
       print( result.docs.first.id);
      preferences.setString("userId", result.docs.first.id );
       Navigator.of(context).pushNamedAndRemoveUntil(
          '/AfterLoginHome', ModalRoute.withName('/login'));
     }else{
       invalidUser();
     }
  }
      invalidUser() {
       showDialog(
     context: context,
     builder:(BuildContext context) {
    return AlertDialog(
      shape:RoundedRectangleBorder(
		borderRadius: BorderRadius.circular(30),
	),
      title:Text('Alert',style: TextStyle(color: Colors.red),),
      content:Container(
        decoration:  BoxDecoration(
      borderRadius: new BorderRadius.all( Radius.circular(8.0)),
    ),
        height: 50,
        child: Column(
          children: [
            Text('Invalid Login User Details ',style: TextStyle(fontSize: 16),) ,
          ],
        ),
      ),
      actions: [
        FlatButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          child: Text('ok')
          ),
      ],
    );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              const SizedBox(
                height: 200,
              ),
              const Text('Peronal Notes',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,color: Colors.orange),),
              const SizedBox(
                height: 10,
              ),
              if(!hideSignUp)
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                    controller: txtName,
                    decoration:InputDecoration(
                      labelText: 'Enter Name',
                      hintText: 'Enter Name',
                      border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0))),
                       ),
              ),
               SizedBox(height: 5,),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: TextFormField(
                  controller: txtPhone,
                  // style: GoogleFonts.montserrat(color: Colors.black),
                  onFieldSubmitted: (value) {
                  },
                  onEditingComplete: () {
                    
                  },
                  onChanged: (value) {
                    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                    RegExp regExp =  RegExp(pattern);
                    if (regExp.hasMatch(value)) {
                      setState(() {
                        FocusScope.of(context).unfocus();
                      });
                    }
                  },
                  onTap: () async {
                    if (Platform.isAndroid) {
                      if (str == 0) {
                        str = await _askPhoneHint();
                        if (str == 2) {
                        }
                      }
                    }
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
                    RegExp regExp =  RegExp(pattern);
                    if (value!.length == 0) {
                      return "please enter a valid mobile no";
                    } else if (!regExp.hasMatch(value)) {
                      return "please enter a valid mobile no";
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                      border:  OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                      contentPadding: EdgeInsets.only(left: 10),
                      prefixText: "+91",
                      labelText: 'Enter mobile number'),
                ),
              ),
              
                     SizedBox(height: 5,),
                     Padding(
                       padding: const EdgeInsets.only(left: 20, right: 20),
                       child: TextFormField(
                  controller: txtPassword,
                  keyboardType: TextInputType.text,
                  decoration:InputDecoration(
                    labelText: 'Enter Password',
                    hintText: 'Enter Password',
                    border:OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0))),
                       ),
                     ), 
              // if (hideSignUp)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: !hideSignUp?FlatButton(
                        height: 40,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        onPressed: () {
                          if(txtName.text==''){
                            Fluttertoast.showToast(
                              msg:'Please Enter Name');
                              return;
                          }
                          if(txtPassword.text==''){
                            Fluttertoast.showToast(
                              msg:'Please Enter Password');
                              return;
                          }
                          setState(() {
                            isLoading = true;
                            hideSignUp = false;
                          });
                          signUpcall();
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.montserrat(),
                        ),
                        color: Colors.green,
                        textColor: Colors.white,
                      ):
                      FlatButton(
                        height: 40,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        onPressed: () {
                          if(txtPassword.text==''){
                            Fluttertoast.showToast(
                              msg:'Please Enter Password');
                              return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          logincall();
                        },
                        child: Text(
                          'LogIn',
                          style: GoogleFonts.montserrat(),
                        ),
                        color: Colors.green,
                        textColor: Colors.white,
                      ),
                    ),
                    if(!hideSignUp)
                    FlatButton(
                        height: 40,
                        onPressed: () {
                          setState(() {
                            hideSignUp = true;
                          });
                        },
                        child: Text(
                          'Login?',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                        textColor: Colors.red,
                      ),
                  ],
                ),
              if (isLoading)
                Padding(
                  padding:  EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                )
            ],
          ),
        ),
      ),
    );
  }

  
}
