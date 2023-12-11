import 'package:flutter/material.dart';
import 'package:the_movie_data_base__pet/library/widgets/inherited/provider.dart';
import 'package:the_movie_data_base__pet/ui/widgets/auth/auth_widget.dart';
import 'package:the_movie_data_base__pet/ui/widgets/main_screen/main_screen_model.dart';
import 'package:the_movie_data_base__pet/ui/widgets/main_screen/main_screen_widget.dart';
import 'package:the_movie_data_base__pet/ui/widgets/movie_details/movie_details_model.dart';
import 'package:the_movie_data_base__pet/ui/widgets/movie_details/movie_details_widget.dart';
import 'package:the_movie_data_base__pet/ui/widgets/movie_trailer/movie_tarailer_widget.dart';

abstract class MainNavigationRouteNames {
  static const mainScreen = '/';
  static const movieDetails = '/movie_details';
  static const movieDetailsTrailerWidget = '/movie_details/trailer';
  static const auth = 'auth';
}

class MainNavigation {
  String initialRoute(bool isAuth) => isAuth
      ? MainNavigationRouteNames.mainScreen
      : MainNavigationRouteNames.auth;
  final routes = <String, Widget Function(BuildContext)>{
    MainNavigationRouteNames.mainScreen: (context) => NotifierProvider(
          create: () => MainScreenModel(),
          child: const MainScreenWidget(),
        ),
    MainNavigationRouteNames.auth: (context) => const AuthWidget()
  };

  Route<Object> onGeneratedRoute(RouteSettings settings) {
    switch (settings.name) {
      case MainNavigationRouteNames.movieDetails:
        final arguments = settings.arguments;
        final movieId = arguments is int ? arguments : 0;
        return MaterialPageRoute(
          builder: (context) => NotifierProvider(
              create: () => MovieDetailsModel(movieId: movieId),
              child: const MovieDetailsWidget()),
        );
      case MainNavigationRouteNames.movieDetailsTrailerWidget:
        final arguments = settings.arguments as Map<String, String>;
        final trailerKey =
            arguments['trailerKey'] is String ? arguments['trailerKey'] : '';
        final title = arguments['title'] is String ? arguments['title'] : '';
        return MaterialPageRoute(
          builder: (context) =>
              MovieTrailerWidget(trailerKey: trailerKey!, title: title!),
        );
      default:
        const widget = Text('Navigation Error!');
        return MaterialPageRoute(builder: (context) => widget);
    }
  }
}
