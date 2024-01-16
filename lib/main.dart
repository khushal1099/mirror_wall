import 'package:flutter/material.dart';
import 'package:mirror_wall/controller/provider/url_provider.dart';
import 'package:mirror_wall/view/home_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences prefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UrlProvider(),
        )
      ],
      builder: (context, child) => MaterialApp(
        theme: ThemeData.light(
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        title: "Hello",
        home: MyWebView(url: "https://www.google.com"),
      ),
    );
  }
}