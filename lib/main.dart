import 'package:app_berita/config/service_locator.dart';
import 'package:app_berita/features/home/cubit/home_news_cubit.dart';
import 'package:app_berita/firebase_options.dart';
import 'package:app_berita/splash_screen.dart';
import 'package:app_berita/ui/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setUpLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<HomeNewsCubit>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child,
          );
        },
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
