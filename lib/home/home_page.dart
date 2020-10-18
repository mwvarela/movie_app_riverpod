import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'movie.dart';
import 'movie_exception.dart';
import 'movie_service.dart';

final moviesFutureProvider = FutureProvider.autoDispose<List<Movie>>((ref) async {
  ref.maintainState = true;
  final movieService = ref.read(movieServideProvider);
  final movies = await movieService.getMovies();

  return movies;
});

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: watch(moviesFutureProvider).when(
        error: (e, s) {
          if (e is MovieException) {
            return _ErrorBody(message: e.message);
          }

          return _ErrorBody(message: 'Ops! Algo inesperado aconteceu.');
        },
        loading: () => Center(child: CircularProgressIndicator()),
        data: (movies) => RefreshIndicator(
          onRefresh: () {
            return context.refresh(moviesFutureProvider);
          },
          child: GridView.extent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
            children: movies.map((movie) => _MovieBox(movie: movie)).toList(),
          ),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;

  const _ErrorBody({Key key, @required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          ElevatedButton(
            onPressed: () => context.refresh(moviesFutureProvider),
            child: Text('Tente Novamente'),
          ),
        ],
      ),
    );
  }
}

class _MovieBox extends StatelessWidget {
  final Movie movie;

  const _MovieBox({Key key, this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          movie.fullImageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _FrontBanner(text: movie.title),
        ),
      ],
    );
  }
}

class _FrontBanner extends StatelessWidget {
  const _FrontBanner({Key key, @required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: Colors.grey.shade200.withOpacity(0.5),
          height: 60,
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
