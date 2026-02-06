import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:movie_booking_app/widgets/simmer_effect.dart';
import 'package:movie_booking_app/controller/movie_controller.dart';
import 'package:movie_booking_app/core/app_route.dart';
import 'package:movie_booking_app/core/app_theme.dart';
import 'package:movie_booking_app/model/movie.dart';
import 'package:movie_booking_app/widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Watch is selected by default
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final MoviesController controller = Get.find<MoviesController>();

  // Pagination variables
  static const int _itemsPerPage = 3;
  int _currentDisplayCount = _itemsPerPage;
  List<Movie> _displayedMovies = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Controller already loads data in onInit()
    if (controller.status.value == MoviesStatus.initial) {
      controller.loadAll();
    }
    _updateDisplayedMovies();
  }

  void _updateDisplayedMovies() {
    // Get only the items we want to display
    final totalMovies = controller.upcoming.length;
    final endIndex = _currentDisplayCount > totalMovies ? totalMovies : _currentDisplayCount;

    setState(() {
      _displayedMovies = controller.upcoming.sublist(0, endIndex);
    });
  }

  void _onRefresh() async {
    // Reset pagination and reload from API
    _currentDisplayCount = _itemsPerPage;
    await controller.loadAll();
    _updateDisplayedMovies();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    final totalMovies = controller.upcoming.length;

    // Check if there are more items to load
    if (_currentDisplayCount >= totalMovies) {
      _refreshController.loadNoData();
      return;
    }

    // Load 3 more items
    setState(() {
      _currentDisplayCount += _itemsPerPage;
    });

    _updateDisplayedMovies();
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _openDetail(Movie movie) {
    Get.toNamed(AppRouter.detail, arguments: movie);
  }

  void _openSearch() {
    Get.toNamed(AppRouter.search);
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Watch',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        GestureDetector(
          onTap: _openSearch,
          child: const Icon(
            Icons.search,
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _openDetail(movie),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.surface,
                  child: const Center(child: CustomShimmer()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.surface,
                  child: const Icon(Icons.error, color: AppTheme.textSecondary),
                ),
              ),
              // Gradient overlay for better text readability
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(color: AppTheme.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: _buildTopBar(),
      ),
      body: Obx(() {
        if (controller.status.value == MoviesStatus.loading && controller.upcoming.isEmpty) {
          return const Center(child: CustomShimmer());
        }

        if (controller.status.value == MoviesStatus.failure && controller.upcoming.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Failed to load movies',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    controller.retry();
                    _currentDisplayCount = _itemsPerPage;
                    _updateDisplayedMovies();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.upcoming.isEmpty) {
          return Center(
            child: Text(
              'No upcoming movies found',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppTheme.textSecondary),
            ),
          );
        }

        // Update displayed movies when controller data changes
        if (controller.status.value == MoviesStatus.loaded && _displayedMovies.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateDisplayedMovies();
          });
        }

        return SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          header: WaterDropHeader(
            complete: Text(
              'Refresh Completed',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            waterDropColor: AppTheme.primary,
          ),
          footer: CustomFooter(
            builder: (BuildContext context, LoadStatus? mode) {
              Widget body;
              if (mode == LoadStatus.idle) {
                body = Text(
                  "Pull up to load more (${_displayedMovies.length}/${controller.upcoming.length})",
                  style: TextStyle(color: AppTheme.textSecondary),
                );
              } else if (mode == LoadStatus.loading) {
                body = const CircularProgressIndicator();
              } else if (mode == LoadStatus.failed) {
                body = const Text("Load Failed! Click retry!");
              } else if (mode == LoadStatus.canLoading) {
                body = const Text("Release to load more");
              } else {
                body = Text(
                  "All  movies loaded",
                  style: TextStyle(color: AppTheme.textSecondary),
                );
              }
              return Container(
                height: 55.0,
                child: Center(child: body),
              );
            },
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _displayedMovies.length,
            itemBuilder: (context, index) {
              return _buildMovieCard(_displayedMovies[index]);
            },
          ),
        );
      }),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}