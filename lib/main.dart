import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mirror_wall/controller/provider/bookmark_provider.dart';
import 'package:mirror_wall/controller/provider/connectivity_provider.dart';
import 'package:mirror_wall/view/home_page.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //  for error goto /android/app/build.gradle
  // and change targetSdkVersion 34, compileSdkVersion 34
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ConnectivityProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BookMarkProvider(),
        ),
      ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Hello",
          initialRoute: '/',
          routes: {
            '/': (context) => MyWebView(url: "https://www.google.com/"),
          },
        );
      },
    );
  }
}
