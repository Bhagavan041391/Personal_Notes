import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:personal_notes/LoginPage.dart';
import 'package:personal_notes/PersonalNotes.dart';
import 'package:personal_notes/Utilities/Splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

var classload;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
        builder: (context, child) {
        return MediaQuery(
          child: child!,
          data: MediaQuery.of(context)
              .copyWith(textScaleFactor: 0.8, devicePixelRatio: 10),
        );
      },
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/login': (context) => LoginPage(),
        '/AfterLoginHome': (context) => PersonalNotes(),
      },
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    @override
  void initState() {
    super.initState();
    classload = SplashLoader();
    nextFunction();
  }
    nextFunction() async {
        SharedPreferences pre = await SharedPreferences.getInstance();
      setState(() {
        if(pre.getString('userId') !=null ){
          classload=PersonalNotes();
        }else{
          classload = LoginPage();
        }
        
      });
    
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return classload;
  }
}
