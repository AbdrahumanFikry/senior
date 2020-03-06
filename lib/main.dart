import 'package:flutter/material.dart';
import 'package:senior/addStore.dart';
import 'package:senior/models/newItem.dart';

import 'package:provider/provider.dart';
import 'package:senior/seniorAds/seniorAdsNavigator.dart';
import 'package:senior/seniorAds/store.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NewItem(),
        ),
      ],
      child: MaterialApp(
        showSemanticsDebugger: false,
//          locale: Locale.fromSubtags(
//            languageCode: 'en',
//          ),
//          localizationsDelegates: [
//            const LocalizationDelegate(),
//            GlobalMaterialLocalizations.delegate,
//            GlobalWidgetsLocalizations.delegate,
//          ],
//          supportedLocales: [
//            const Locale('en', ''),
//            const Locale('ar', ''),
//          ],
        theme: ThemeData(
          iconTheme: IconThemeData(
            size: 16,
          ),
          textTheme: TextTheme(
            subhead: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          scaffoldBackgroundColor: Colors.white,
        ),
        debugShowCheckedModeBanner: false,
        home: SeniorAdsNavigator(),
      ),
    );
  }
}
