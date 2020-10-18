import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../environment_config.dart';
import 'movie.dart';
import 'movie_exception.dart';

final movieServideProvider = Provider<MovieService>((ref) {
  final config = ref.read(environmentConfigProvider);
  return MovieService(config, Dio());
});

class MovieService {
  final EnvironmentConfig _environmentConfig;
  final Dio _dio;

  MovieService(this._environmentConfig, this._dio);

  Future<List<Movie>> getMovies() async {
    try {
      final response = await _dio.get(
        "https://api.themoviedb.org/3/movie/popular?api_key=${_environmentConfig.movieApiKey}&language=pt-BR&page=1",
      );

      final results = List<Map<String, dynamic>>.from(response.data['results']);
      List<Movie> movies = results.map((movieData) => Movie.fromMap(movieData)).toList(growable: false);
      return movies;
    } on DioError catch (e) {
      throw MovieException.fromDioError(e);
    }
  }
}
