import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:vilsa/core/init/navigation/navigation_service.dart';
import 'package:vilsa/core/init/network/firebase_options.dart';
import 'package:vilsa/core/init/notifier/provider_manager.dart';
import 'package:vilsa/core/init/theme/app_theme.dart';
import 'package:vilsa/features/main/view/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('tr', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ...ProviderManager.instance.providers,
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peasy',
      theme: LightTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const MainView(),
      navigatorKey: NavigationService.instance.navigatorKey,
    );
  }
}
