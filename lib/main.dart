import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:senior/Admin/selectScreen.dart';
import 'package:senior/auth/loginScreen.dart';
import 'package:senior/forceField/forceFieldNavigator.dart';
import 'package:senior/providers/authenticationProvider.dart';
import 'package:senior/providers/driverProvider.dart';
import 'package:senior/providers/fieldForceProvider.dart';
import 'package:senior/providers/location.dart';
import 'package:senior/providers/sellsProvider.dart';
import 'package:senior/providers/seniorProvider.dart';
import 'package:senior/sells/sellsNavigator.dart';
import 'package:senior/sells/startDay.dart';
import 'package:senior/senior/tabBarForceField.dart';
import 'package:senior/senior/tabBarSells.dart';

main() {
  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ar', 'DZ'),
      ],
      path: 'resources/langs',
    ),
  );
}

class MyApp extends StatelessWidget {
  Widget navigator(String type, BuildContext context) {
    Widget temp;
    switch (Provider.of<Auth>(context, listen: false).type) {
      case 'driver':
        temp = SellsNavigator(
          isDriver: true,
        );
        break;
      case 'salles_man':
        temp = FutureBuilder(
          future: Provider.of<SellsData>(context, listen: false).checkDay(),
          builder: (ctx, snapShot) =>
              snapShot.connectionState == ConnectionState.waiting
                  ? Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Provider.of<SellsData>(context, listen: false).date ==
                          DateTime.now().toIso8601String().substring(0, 10)
                      ? SellsNavigator(
                          isDriver: false,
                        )
                      : StartDay(),
        );
        break;
      case 'filed_force_man':
        temp = ForceFieldNavigator();
        break;
      case 'general_manager':
        temp = SelectScreen();
        break;
      case 'sales_senior':
        temp = TabBarScreenSells();
        break;
      case 'field_force_senior':
        temp = TabBarForceFieldScreen();
        break;
    }
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => GPS(),
        ),
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => FieldForceData(),
        ),
        ChangeNotifierProvider(
          create: (context) => SeniorData(),
        ),
        ChangeNotifierProvider(
          create: (context) => SellsData(),
        ),
        ChangeNotifierProvider(
          create: (context) => DriverData(),
        ),
        ChangeNotifierProvider(
          create: (context) => SeniorData(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          showSemanticsDebugger: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            EasyLocalization.of(context).delegate,
          ],
          supportedLocales: EasyLocalization.of(context).supportedLocales,
          locale: EasyLocalization.of(context).locale,
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
          home: auth.isAuth
              ? navigator(auth.type, context)
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, snapShot) =>
                      snapShot.connectionState == ConnectionState.waiting
                          ? Scaffold(
                              body: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : LoginScreen(),
                ),
        ),
      ),
    );
  }
}
