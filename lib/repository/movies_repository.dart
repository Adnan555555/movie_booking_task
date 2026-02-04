
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/movie.dart';
import '../model/upcoming_movie.dart';

class MoviesRepository {
  static const String _apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: '0d15df7acd7ee29f70b4cc4d3236309e',
  );
  static const String _apiToken = String.fromEnvironment(
    'TMDB_TOKEN',
    defaultValue: '',
  );
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageW500 = 'https://image.tmdb.org/t/p/w500';
  static const String _imageW1280 = 'https://image.tmdb.org/t/p/w1280';

  Map<String, String> _headers() {
    if (_apiToken.isNotEmpty) {
      return {'Authorization': 'Bearer $_apiToken'};
    }
    return {};
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    final q = Map<String, String>.from(query ?? {});
    // Always use API Key if token is missing, or as fallback
    if (_apiToken.isEmpty && _apiKey.isNotEmpty) {
      q['api_key'] = _apiKey;
    }
    // Note: TMDb V3 works with api_key query param even if using Bearer, but Bearer is preferred.
    // If we have no token, we MUST use api_key.
    // The previous logic was: if _apiKey is not empty, add it.
    // Let's stick to adding it if available, as it doesn't hurt usually,
    // but typically one auth method is enough.
    // However, to be safe and ensure the user's key works:
    if (_apiKey.isNotEmpty) q['api_key'] = _apiKey;

    return Uri.parse('$_baseUrl$path').replace(queryParameters: q);
  }

  Future<List<Movie>> getUpcomingMovies() async {
    try {
      final uri = _buildUri('/movie/upcoming');
      print('Calling API: $uri');

      final res = await http.get(uri, headers: _headers());

      if (res.statusCode != 200) {
        print('API Error: ${res.statusCode} ${res.body}');
        throw Exception('TMDb error ${res.statusCode}: ${res.body}');
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final model = UpcomingMoviesModel.fromJson(data);
      final list = model.results ?? [];
      return list.map(_mapResultToMovie).toList();
    } catch (e, stackTrace) {
      print('Error in getUpcomingMovies: $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final uri = _buildUri('/movie/$movieId');
      print('Calling API: $uri');

      final res = await http.get(uri, headers: _headers());
      if (res.statusCode != 200) {
        print('API Error: ${res.statusCode} ${res.body}');
        throw Exception('TMDb error ${res.statusCode}: ${res.body}');
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final m = Movie(
        id: json['id'],
        title: json['title'] ?? '',
        posterUrl: json['poster_path'] != null
            ? '$_imageW500${json['poster_path']}'
            : '',
        backdropUrl: json['backdrop_path'] != null
            ? '$_imageW1280${json['backdrop_path']}'
            : '',
        overview: json['overview'] ?? '',
        genres:
            (json['genres'] as List<dynamic>?)
                ?.map((g) => g['name'] as String)
                .toList() ??
            [],
        releaseDate: json['release_date'] ?? '',
        rating: (json['vote_average'] is num)
            ? (json['vote_average'] as num).toDouble()
            : 0.0,
        runtime: json['runtime'],
        trailerKey: await getMovieTrailer(movieId),
      );
      return m;
    } catch (e, stackTrace) {
      print('Error in getMovieDetails: $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<String?> getMovieTrailer(int movieId) async {
    try {
      final uri = _buildUri('/movie/$movieId/videos');
      print('Calling API: $uri');

      final res = await http.get(uri, headers: _headers());
      if (res.statusCode != 200) {
        print('API Error: ${res.statusCode} ${res.body}');
        return null;
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final results = (json['results'] as List<dynamic>? ?? []);
      final yt = results.firstWhere(
        (v) => (v['site'] == 'YouTube') && (v['type'] == 'Trailer'),
        orElse: () => null,
      );
      return yt != null ? yt['key'] as String? : null;
    } catch (e, stackTrace) {
      print('Error in getMovieTrailer: $e');
      print(stackTrace);
      return null;
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final uri = _buildUri('/search/movie', {'query': query});
      print('Calling API: $uri');

      final res = await http.get(uri, headers: _headers());
      if (res.statusCode != 200) {
        print('API Error: ${res.statusCode} ${res.body}');
        throw Exception('TMDb error ${res.statusCode}: ${res.body}');
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List<dynamic>? ?? []);
      return results.map((r) {
        return Movie(
          id: r['id'],
          title: r['title'] ?? '',
          posterUrl: r['poster_path'] != null
              ? '$_imageW500${r['poster_path']}'
              : '',
          backdropUrl: r['backdrop_path'] != null
              ? '$_imageW1280${r['backdrop_path']}'
              : '',
          overview: r['overview'] ?? '',
          genres: const [],
          releaseDate: r['release_date'] ?? '',
          rating: (r['vote_average'] is num)
              ? (r['vote_average'] as num).toDouble()
              : 0.0,
        );
      }).toList();
    } catch (e, stackTrace) {
      print('Error in searchMovies: $e');
      print(stackTrace);
      rethrow;
    }
  }

  // Legacy methods for backward compatibility
  List<Movie> upcoming() {
    return [];
  }

  List<Movie> popular() {
    return [];
  }

  List<Movie> nowPlaying() {
    return [];
  }

  Movie _mapResultToMovie(Results r) {
    return Movie(
      id: r.id ?? 0,
      title: r.title ?? '',
      posterUrl: r.posterPath != null ? '$_imageW500${r.posterPath}' : '',
      backdropUrl: r.backdropPath != null
          ? '$_imageW1280${r.backdropPath}'
          : '',
      overview: r.overview ?? '',
      genres: const [],
      releaseDate: r.releaseDate ?? '',
      rating: (r.voteAverage ?? 0).toDouble(),
    );
  }
}
