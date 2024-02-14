import 'package:ev_charging_station/pages/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'charge_state.dart';
import 'pages/login_page.dart';
import 'auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChargeState()),
        Provider<Auth>(create: (context) => Auth()), // Use Provider instead of ChangeNotifierProvider
        // Add other providers if needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LanguageProvider>(
      create: (context) => LanguageProvider(),
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, _) {
          return MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: languageProvider.currentLocale,
            debugShowCheckedModeBanner: false,
            home: FutureBuilder(
              // Initialize FlutterFire:
              future: Firebase.initializeApp(),
              builder: (context, snapshot) {
                // Check for errors
                if (snapshot.hasError) {
                  print('Error initializing Firebase: ${snapshot.error}');
                  return const Scaffold(
                    body: Center(
                      child: Text('Error initializing Firebase'),
                    ),
                  );
                }

                // Once complete, show your application
                if (snapshot.connectionState == ConnectionState.done) {
                  return LoginPage(auth: Provider.of<Auth>(context)); // Ensure proper Auth provider usage
                }

                // Otherwise, show a loading indicator
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
