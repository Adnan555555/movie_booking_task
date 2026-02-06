import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:movie_booking_app/widgets/simmer_effect.dart';
import 'package:movie_booking_app/controller/movie_controller.dart';
import 'package:movie_booking_app/core/app_route.dart';
import 'package:movie_booking_app/core/app_theme.dart';
import 'package:movie_booking_app/model/movie.dart';

class MovieSearchPage extends StatefulWidget {
  const MovieSearchPage({super.key});

  @override
  State<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final MoviesController controller = Get.find<MoviesController>();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  String _currentQuery = '';
  bool _hasSearched = false;
  int _currentPage = 1;
  List<Movie> _displayMovies = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    setState(() {
      _displayMovies = List.from(controller.upcoming);
    });
  }

  void _onRefresh() async {
    _currentPage = 1;
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentQuery.isEmpty) {
      setState(() {
        _displayMovies = List.from(controller.upcoming);
      });
    } else {
      controller.searchMovies(_currentQuery);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _displayMovies = List.from(controller.searchResults);
      });
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _currentPage++;
    await Future.delayed(const Duration(milliseconds: 500));

    // Mark as complete since all data is loaded at once
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _currentQuery = '';
        _hasSearched = false;
        _currentPage = 1;
        _displayMovies = List.from(controller.upcoming);
      });
      controller.searchResults.clear();
      return;
    }

    setState(() {
      _currentQuery = query;
      _hasSearched = true;
      _currentPage = 1;
    });

    controller.searchMovies(query);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayMovies = List.from(controller.searchResults);
        });
      }
    });
  }

  void _openDetail(Movie movie) {
    FocusScope.of(context).unfocus();
    Get.toNamed(AppRouter.detail, arguments: movie);
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _openDetail(movie),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 130,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 130,
                  height: 120,
                  color: AppTheme.surface,
                  child: const Center(child: CustomShimmer()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 130,
                  height: 120,
                  color: AppTheme.surface,
                  child: const Icon(Icons.error, color: AppTheme.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      movie.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textSecondary202C,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      movie.releaseDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textColorDB,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    if (movie.genres.isNotEmpty)
                      Text(
                        movie.genres.first,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.more_horiz_outlined,
                color: AppTheme.lightBlueColor,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieGridItem(Movie movie) {
    return GestureDetector(
      onTap: () => _openDetail(movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                child: const Icon(Icons.error),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 10,
              right: 10,
              child: Text(
                movie.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!, width: 1),
            ),
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'TV shows, movies and more',
                      hintStyle:
                      Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      isDense: false,
                      alignLabelWithHint: false,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _performSearch(value);
                    },
                  ),
                ),
                if (_searchController.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _searchController.clear();
                        _performSearch('');
                        Get.back();
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Obx(() {
          if (controller.status.value == MoviesStatus.loading && _displayMovies.isEmpty) {
            return const Center(child: CustomShimmer());
          }

          if (_currentQuery.isEmpty && !_hasSearched) {
            // Show grid view for browsing
            if (_displayMovies.isEmpty) {
              return Center(
                child: Text(
                  'No upcoming movies found',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              );
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
                    body = const Text("Pull up to load more");
                  } else if (mode == LoadStatus.loading) {
                    body = const CircularProgressIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = const Text("Load Failed! Click retry!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = const Text("Release to load more");
                  } else {
                    body = const Text("No more data");
                  }
                  return Container(
                    height: 55.0,
                    child: Center(child: body),
                  );
                },
              ),
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 50),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _displayMovies.length,
                itemBuilder: (context, index) {
                  return _buildMovieGridItem(_displayMovies[index]);
                },
              ),
            );
          }

          // Show search results
          if (_hasSearched && _displayMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Item not found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            );
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
                  body = const Text("Pull up to load more");
                } else if (mode == LoadStatus.loading) {
                  body = const CircularProgressIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = const Text("Load Failed! Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = const Text("Release to load more");
                } else {
                  body = const Text("No more data");
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top Results',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_displayMovies.length} Results Found',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      return _buildMovieCard(_displayMovies[index]);
                    },
                    childCount: _displayMovies.length,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}