// import 'package:get/get.dart';
//
// import '../model/movie.dart';
// import '../repository/movies_repository.dart';
//
// enum MoviesStatus { initial, loading, loaded, failure }
//
// class MoviesController extends GetxController {
//   final MoviesRepository repository;
//
//   MoviesController(this.repository);
//
//   final Rx<MoviesStatus> status = MoviesStatus.initial.obs;
//   final RxList<Movie> upcoming = <Movie>[].obs;
//   final RxList<Movie> popular = <Movie>[].obs;
//   final RxList<Movie> nowPlaying = <Movie>[].obs;
//   final RxList<Movie> searchResults = <Movie>[].obs;
//   final Rxn<Movie> selected = Rxn<Movie>();
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadAll();
//   }
//
//   // Load all upcoming movies
//   Future<void> loadAll() async {
//     try {
//       status.value = MoviesStatus.loading;
//       final movies = await repository.getUpcomingMovies();
//       upcoming.value = movies;
//       status.value = MoviesStatus.loaded;
//     } catch (e) {
//       status.value = MoviesStatus.failure;
//       Get.snackbar(
//         'Error',
//         'Failed to load movies',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   // Select a movie
//   void selectMovie(Movie movie) {
//     selected.value = movie;
//   }
//
//   // Load movie details
//   Future<void> loadMovieDetails(int movieId) async {
//     try {
//       final movie = await repository.getMovieDetails(movieId);
//       selected.value = movie;
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to load movie details',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   // Search movies
//   Future<void> searchMovies(String query) async {
//     if (query.trim().isEmpty) {
//       searchResults.clear();
//       return;
//     }
//
//     try {
//       status.value = MoviesStatus.loading;
//       final results = await repository.searchMovies(query);
//       searchResults.value = results;
//       status.value = MoviesStatus.loaded;
//     } catch (e) {
//       status.value = MoviesStatus.failure;
//       Get.snackbar(
//         'Error',
//         'Failed to search movies',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }
//
//   // Retry loading
//   void retry() {
//     loadAll();
//   }
// }
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

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  // Load all upcoming movies (initial load)
  Future<void> loadAll({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      status.value = MoviesStatus.loading;
      final movies = await repository.getUpcomingMovies(page: currentPage.value);

      if (isRefresh) {
        upcoming.value = movies;
      } else {
        upcoming.value = movies;
      }

      status.value = MoviesStatus.loaded;

      // Check if there's more data (adjust based on your API response)
      if (movies.isEmpty || movies.length < 20) {
        hasMoreData.value = false;
      }
    } catch (e) {
      status.value = MoviesStatus.failure;
      Get.snackbar(
        'Error',
        'Failed to load movies',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Load more movies (pagination)
  Future<void> loadMoreMovies() async {
    if (isLoadingMore.value || !hasMoreData.value) return;

    try {
      isLoadingMore.value = true;
      currentPage.value++;

      final movies = await repository.getUpcomingMovies(page: currentPage.value);

      if (movies.isEmpty || movies.length < 20) {
        hasMoreData.value = false;
      }

      upcoming.addAll(movies);
      isLoadingMore.value = false;
    } catch (e) {
      isLoadingMore.value = false;
      currentPage.value--; // Revert page increment on error
      Get.snackbar(
        'Error',
        'Failed to load more movies',
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
    currentPage.value = 1;
    hasMoreData.value = true;
    loadAll();
  }
}