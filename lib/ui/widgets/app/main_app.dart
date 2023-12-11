import 'package:flutter/material.dart';
import 'package:the_movie_data_base__pet/library/widgets/inherited/provider.dart';
import 'package:the_movie_data_base__pet/theme/app_colors.dart';
import 'package:the_movie_data_base__pet/ui/navigation/main_navigation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:the_movie_data_base__pet/ui/widgets/app/main_app_model.dart';

class MainApp extends StatelessWidget {
  static final mainNavigation = MainNavigation();
  const MainApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = InheritedProvider.read<MainAppModel>(context);
    return MaterialApp(
      title: 'THE movie DB',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.mainDarkBlue,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.mainDarkBlue,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ru', 'RU'), // Russian
      ],
      routes: mainNavigation.routes,
      initialRoute: mainNavigation.initialRoute(model?.isAuth == true),
      onGenerateRoute: mainNavigation.onGeneratedRoute,
    );
  }
}
