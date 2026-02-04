import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movie_booking_app/widgets/simmer_effect.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../controller/movie_controller.dart';
import '../../core/app_route.dart';
import '../../core/app_theme.dart';
import '../../model/movie.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final MoviesController controller = Get.find<MoviesController>();

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  void _loadMovieDetails() {
    controller.loadMovieDetails(widget.movie.id);
  }

  void _watchTrailer() {
    final movie = controller.selected.value ?? widget.movie;
    if (movie.trailerKey != null && movie.trailerKey!.isNotEmpty) {
      Get.to(
            () => TrailerPlayerPage(trailerKey: movie.trailerKey!),
        transition: Transition.fadeIn,
      );
    } else {
      Get.snackbar(
        'Trailer',
        'Trailer not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _bookTickets() {
    Get.toNamed(
      AppRouter.dateSelection,
      arguments: controller.selected.value ?? widget.movie,
    );
  }

  // Genre colors matching the screenshot
  Color _getGenreColor(String genre, int index) {
    final colors = [
      const Color(0xFF15D2BC),
      const Color(0xFFE26CA5),
      const Color(0xFF564CA3),
      const Color(0xFFCD9D0F),
    ];
    return colors[index % colors.length];
  }

  String _formatReleaseDate(String date) {
    if (date.isEmpty) return 'In Theaters';
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December',
        ];
        return 'In Theaters ${months[month - 1]} $day, $year';
      }
    } catch (e) {
      // If parsing fails, return as is
    }
    return 'In Theaters $date';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final detailedMovie = controller.selected.value ?? widget.movie;

      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Stack(
          children: [
            // Movie poster background
            Positioned.fill(
              bottom: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: detailedMovie.backdropUrl,
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
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Column(
              children: [
                // AppBar with back button
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Text(
                          'Watch',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          detailedMovie.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppTheme.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatReleaseDate(detailedMovie.releaseDate),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppTheme.white),
                        ),
                        const SizedBox(height: 24),
                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightBlueColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _bookTickets,
                            child: Text(
                              'Select Seats',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppTheme.lightBlueColor,
                              side: BorderSide(
                                color: AppTheme.lightBlueColor,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _watchTrailer,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  size: 24,
                                  color: AppTheme.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Watch Trailer',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genres',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppTheme.textSecondary202C),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: detailedMovie.genres
                              .asMap()
                              .entries
                              .map(
                                (entry) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _getGenreColor(
                                  entry.value,
                                  entry.key,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                entry.value,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.white),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        // Overview
                        Text(
                          'Overview',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppTheme.textSecondary202C),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          detailedMovie.overview,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary8F),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class TrailerPlayerPage extends StatefulWidget {
  final String trailerKey;
  const TrailerPlayerPage({super.key, required this.trailerKey});

  @override
  State<TrailerPlayerPage> createState() => _TrailerPlayerPageState();
}

class _TrailerPlayerPageState extends State<TrailerPlayerPage> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.trailerKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_controller.value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
      });
    }
    if (_controller.value.playerState == PlayerState.ended) {
      Get.back();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppTheme.primary,
                progressColors: ProgressBarColors(
                  playedColor: AppTheme.primary,
                  handleColor: AppTheme.primary,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}