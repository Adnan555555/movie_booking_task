import 'package:flutter/material.dart';

import '../model/movie.dart';
import '../view/date_selection/date_selection.dart';
import '../view/home/home_page.dart';
import '../view/movie_details/movie_details_page.dart';
import '../view/movie_search/movie_search.dart';
import '../view/seat_selection/seat_selection.dart';
import '../view/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String search = '/search';
  static const String dateSelection = '/date-selection';
  static const String seatSelection = '/seat-selection';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());

      case detail:
        final movie = settings.arguments as Movie;
        return MaterialPageRoute(builder: (_) => MovieDetailPage(movie: movie));

      case search:
        return MaterialPageRoute(builder: (_) => const MovieSearchPage());

      case dateSelection:
        final movie = settings.arguments as Movie;
        return MaterialPageRoute(
          builder: (_) => DateSelectionPage(movie: movie),
        );

      case seatSelection:
        final args = settings.arguments;
        if (args is Movie) {
          return MaterialPageRoute(
            builder: (_) => SeatSelectionPage(movie: args),
          );
        } else if (args is SeatSelectionArgs) {
          return MaterialPageRoute(
            builder: (_) => SeatSelectionPage(
              movie: args.movie,
              dateLabel: args.dateLabel,
              timeLabel: args.timeLabel,
              hallLabel: args.hallLabel,
            ),
          );
        } else if (args is Map) {
          final movie = args['movie'] as Movie;
          return MaterialPageRoute(
            builder: (_) => SeatSelectionPage(
              movie: movie,
              dateLabel: args['dateLabel'] as String?,
              timeLabel: args['timeLabel'] as String?,
              hallLabel: args['hallLabel'] as String?,
            ),
          );
        } else {
          return MaterialPageRoute(builder: (_) => const HomePage());
        }

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}