import 'package:get/get.dart';

import '../model/movie.dart';
import '../repository/movies_repository.dart';

enum MoviesStatus { initial, loading, loaded, failure }

class MoviesController extends GetxController {
  final MoviesRepository repository;

  MoviesController(this.repository);

  final Rx<MoviesStatus> status = MoviesStatus.initial.obs;
  final RxList<Movie> upcoming = <Movie>[].obs;
  final RxList<Movie> popular = <Movie>[].obs;
  final RxList<Movie> nowPlaying = <Movie>[].obs;
  final RxList<Movie> searchResults = <Movie>[].obs;
  final Rxn<Movie> selected = Rxn<Movie>();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  // Load all upcoming movies
  Future<void> loadAll() async {
    try {
      status.value = MoviesStatus.loading;
      final movies = await repository.getUpcomingMovies();
      upcoming.value = movies;
      status.value = MoviesStatus.loaded;
    } catch (e) {
      status.value = MoviesStatus.failure;
      Get.snackbar(
        'Error',
        'Failed to load movies',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Select a movie
  void selectMovie(Movie movie) {
    selected.value = movie;
  }

  // Load movie details
  Future<void> loadMovieDetails(int movieId) async {
    try {
      final movie = await repository.getMovieDetails(movieId);
      selected.value = movie;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load movie details',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Search movies
  Future<void> searchMovies(String query) async {
    if (query.trim().isEmpty) {
      searchResults.clear();
      return;
    }

    try {
      status.value = MoviesStatus.loading;
      final results = await repository.searchMovies(query);
      searchResults.value = results;
      status.value = MoviesStatus.loaded;
    } catch (e) {
      status.value = MoviesStatus.failure;
      Get.snackbar(
        'Error',
        'Failed to search movies',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Retry loading
  void retry() {
    loadAll();
  }
}