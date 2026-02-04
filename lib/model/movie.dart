
class Movie  {
  final int id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final String overview;
  final List<String> genres;
  final String releaseDate;
  final double rating;
  final String? trailerKey;
  final int? runtime;
  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.overview,
    required this.genres,
    required this.releaseDate,
    required this.rating,
    this.trailerKey,
    this.runtime,
  });

  Movie copyWith({
    int? id,
    String? title,
    String? posterUrl,
    String? backdropUrl,
    String? overview,
    List<String>? genres,
    String? releaseDate,
    double? rating,
    String? trailerKey,
    int? runtime,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      backdropUrl: backdropUrl ?? this.backdropUrl,
      overview: overview ?? this.overview,
      genres: genres ?? this.genres,
      releaseDate: releaseDate ?? this.releaseDate,
      rating: rating ?? this.rating,
      trailerKey: trailerKey ?? this.trailerKey,
      runtime: runtime ?? this.runtime,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    posterUrl,
    backdropUrl,
    overview,
    genres,
    releaseDate,
    rating,
    trailerKey,
    runtime,
  ];
}
