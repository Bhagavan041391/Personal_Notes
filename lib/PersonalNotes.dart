import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalNotes extends StatefulWidget {

  @override
  _PersonalNotesState createState() => _PersonalNotesState();
}

class _PersonalNotesState extends State<PersonalNotes> {
    final firestoreInstance = FirebaseFirestore.instance;
    TextEditingController txtTitle=TextEditingController();
    TextEditingController txtDescription=TextEditingController();
     TextEditingController txtSearchController=TextEditingController();
final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
     
    @override
  void initState() {
    // TODO: implement initState
    initialCall();
    super.initState();
  }
  CollectionReference?  data;
  bool isLoading=true;
  String? intServiceId;
  bool isSaving=true;
  String name = "";
  String? strUserId;
  bool isPublished = false;
     Future<Null> initialCall() async {
       SharedPreferences pre = await SharedPreferences.getInstance();
              strUserId=pre.getString('userId');
      setState(() {
         isLoading=true;
      });
    firestoreInstance.collection("users").get().then((querySnapshot) {
      querySnapshot.docs.forEach((element) {
   if(strUserId==element.id){
  data= firestoreInstance.collection("users").doc(element.id).collection("Notes");
            print(data);
            intServiceId = element.id;
   }
      });
      setState(() {
         isLoading=false;
      });
     
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Personal Notes'),
            Switch(
           value: isPublished,
           onChanged: (value) {
             setState(() {
               isPublished = !isPublished;
             });
           },
            activeTrackColor: Colors.green[300],
            activeColor: Colors.green,
          ),
          ],
        ),),
      body:!isLoading?
       StreamBuilder<QuerySnapshot>(
        stream:(name != "" && name != null)?
        firestoreInstance.collection("users").doc(strUserId).collection("Notes").where("title",arrayContains:name).snapshots()
         :data?.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                     final key =encrypt. Key.fromLength(32);
                      final iv = encrypt.IV.fromLength(8);
                      final encrypter =encrypt. Encrypter(Salsa20(key));
                      final encryptedTitle = encrypter.decrypt16(documentSnapshot['title'], iv: iv);
                      final encryptedDesc = encrypter.decrypt16(documentSnapshot['description'], iv: iv);
                  return Card(
                    elevation: 5,
                    shadowColor: Colors.green,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                text: TextSpan(children: [
                                  const TextSpan(
                                      text: 'TiTle : ',
                                      style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: encryptedTitle,style:  TextStyle(fontSize: 18),),
                                ],style: TextStyle(color: Colors.black))),
                              RichText(
                                text: TextSpan(children: [
                                  const TextSpan(
                                      text: 'DESCRIPTION : ',
                                      style: TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: encryptedDesc,style: const TextStyle(fontSize: 16),),
                                ], style: TextStyle(color: Colors.black)),
                              ),
                            
                              ],
                            ),
                          ),
                        ),
                          IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: ()async {
                                      SharedPreferences pre = await SharedPreferences.getInstance();
                                      var userId=pre.getString('userId');
                                        var firebaseUser =  documentSnapshot.id;
                                   var res=   firestoreInstance.collection("users").doc(userId).collection("Notes").doc(firebaseUser).delete();
                                    }),
                      ],
                    )
                  );
                },
              ),
            );
          }
    
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ):Center(child: CircularProgressIndicator()),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: (){
        addData();
        },
        child: const Icon(Icons.add,),
      ),
    );
  }
   void addData() {
    showDialog(context: context,
    barrierDismissible: false,
     builder: (BuildContext context){
       return AlertDialog(
           shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
         title: Text('Add Personal Notes',style: TextStyle(),),
        content:Container(
          height: 160,
          child: Column(
          children: [
            TextFormField(
              controller: txtTitle,
              decoration:InputDecoration(
                labelText: 'Enter Title',
                hintText: 'Enter Title',
                border:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
                 ),
                 SizedBox(height: 5,),
                 TextFormField(
                   maxLines: 3,
              controller: txtDescription,
              keyboardType: TextInputType.text,
              decoration:InputDecoration(
                labelText: 'Enter Description',
                hintText: 'Enter Description',
                border:OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0))),
                 ), 
                  ],
        ),
        ) ,
      actions: [
        FlatButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: Text('No')),
        isSaving?
        FlatButton(onPressed: ()async{
          if(txtTitle.text==''){
            Fluttertoast.showToast(
              msg:'Please Enter Title');
              return;
          }
          if(txtDescription.text==''){
             Fluttertoast.showToast(
               msg:'Please Enter Description');
              return;
          }
          final key =encrypt. Key.fromLength(32);
          final iv = encrypt.IV.fromLength(8);
          final encrypter =encrypt. Encrypter(Salsa20(key));
          final encryptedTitle = encrypter.encrypt(txtTitle.text, iv: iv);
          final encryptedDesc = encrypter.encrypt(txtDescription.text, iv: iv);
          setState(() {
            isSaving=false;
          });
          var res=
          firestoreInstance.collection("users").doc(intServiceId).collection("Notes").add({
            "title":encryptedTitle.base16,
            "description":encryptedDesc.base16
          });
          setState(() {
            isSaving=true;
            txtDescription.clear();
            txtTitle.clear();
            Navigator.of(context).pop();
            // initialCall();
          });
        }, child: Text('Yes')):CircularProgressIndicator(),
      ],
       );
     });
  }
      Future<bool> _exitApp() async {
      
      return (await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => StatefulBuilder(
              builder: (context, setState) =>  AlertDialog(
                title: Text(
                  'Alert',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
                content: Text(
                  'Are you sure you want to exit?',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                actions: <Widget>[
                   FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text(
                      'No',
                      style: TextStyle(
                        color: Colors.blue,
                      ),
                    ),
                  ),
                   FlatButton(
                    onPressed: () async {
                      Navigator.pop(context);
                    },
                    child: Text(
                            'Yes',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ))
          ;
    }
}