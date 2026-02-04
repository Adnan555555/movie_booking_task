import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_booking_app/widgets/simmer_effect.dart';

import '../../controller/movie_controller.dart';
import '../../core/app_route.dart';
import '../../core/app_theme.dart';
import '../../model/movie.dart';

class MovieSearchPage extends StatefulWidget {
  const MovieSearchPage({super.key});

  @override
  State<MovieSearchPage> createState() => _MovieSearchPageState();
}

class _MovieSearchPageState extends State<MovieSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final MoviesController controller = Get.find<MoviesController>();
  String _currentQuery = '';
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _currentQuery = '';
        _hasSearched = false;
      });
      controller.searchResults.clear();
      return;
    }
    setState(() {
      _currentQuery = query;
      _hasSearched = true;
    });
    controller.searchMovies(query);
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
                  width: 80,
                  height: 120,
                  color: AppTheme.surface,
                  child: const Center(child: CustomShimmer()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
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
                    SizedBox(height: 5),
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
            Padding(
              padding: const EdgeInsets.all(12),
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

  Widget _buildMovieGrid(List<Movie> movies) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 50),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
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
                  right: 0,
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
      },
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
                      prefixIcon: Icon(
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
                        // Navigate back when clear is pressed
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
          if (_currentQuery.isEmpty && !_hasSearched) {
            if (controller.status.value == MoviesStatus.loading &&
                controller.upcoming.isEmpty) {
              return const Center(child: CustomShimmer());
            }
            if (controller.upcoming.isEmpty) {
              return Center(
                child: Text(
                  'No upcoming movies found',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildMovieGrid(controller.upcoming),
            );
          }

          // Show loading state
          if (controller.status.value == MoviesStatus.loading) {
            return const Center(child: CustomShimmer());
          }

          // Show error state
          if (controller.status.value == MoviesStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to search movies'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _performSearch(_currentQuery),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Show "item not found" when search results are empty
          if (_hasSearched && controller.searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
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

          // Show search results
          if (controller.searchResults.isNotEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  Padding(
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
                          '${controller.searchResults.length} Results Found',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.searchResults.length,
                    itemBuilder: (context, index) {
                      return _buildMovieCard(controller.searchResults[index]);
                    },
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        }),
      ),
    );
  }
}