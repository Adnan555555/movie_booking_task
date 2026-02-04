import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movie_booking_app/widgets/movie_card_shimmer.dart';

import '../../controller/movie_controller.dart';
import '../../core/app_route.dart';
import '../../core/app_theme.dart';
import '../../model/movie.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // Watch is selected by default

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
    final MoviesController controller = Get.find<MoviesController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: _buildTopBar(),
      ),
      body: Obx(() {
        if (controller.status.value == MoviesStatus.loading) {
          return const Center(child: CustomShimmer());
        }

        if (controller.status.value == MoviesStatus.failure) {
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
                  onPressed: () => controller.retry(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: controller.upcoming.isEmpty
                  ? Center(
                child: Text(
                  'No upcoming movies found',
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.upcoming.length,
                itemBuilder: (context, index) {
                  return _buildMovieCard(controller.upcoming[index]);
                },
              ),
            ),
          ],
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