import 'package:flutter/material.dart';
import 'package:the_movie_data_base__pet/domain/api_client/api_client.dart';
import 'package:the_movie_data_base__pet/domain/entity/movie.dart';
import 'package:the_movie_data_base__pet/library/widgets/inherited/provider.dart';
import 'package:the_movie_data_base__pet/ui/widgets/movie_list/movie_list_model.dart';

class MovieListWidget extends StatelessWidget {
  const MovieListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieListModel>(context);
    if (model == null) return const SizedBox.shrink();
    return Stack(children: [
      ListView.separated(
        padding: const EdgeInsets.only(top: 75),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: model.movies.length,
        itemBuilder: (context, index) {
          model.searchMovieAtIndex(index);
          final moviedata = model.movies[index];
          return MoviePreviewWidget(moviedata: moviedata);
        },
        separatorBuilder: ((context, index) => const SizedBox(height: 20)),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          // controller: _searchController,
          onChanged: model.searchMovie,
          decoration: InputDecoration(
              labelText: 'Поиск',
              filled: true,
              fillColor: Colors.white.withAlpha(235),
              border: const OutlineInputBorder()),
        ),
      ),
    ]);
  }
}

class MoviePreviewWidget extends StatelessWidget {
  final Movie moviedata;

  const MoviePreviewWidget({super.key, required this.moviedata});

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieListModel>(context);
    final posterPath = moviedata.posterPath;
    if (model == null) return const SizedBox();
    final releaseDate = model.stringFromDate(moviedata.releaseDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(children: [
        Container(
          width: double.infinity,
          height: 141,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
              color: Colors.white,
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.circular(5)),
          child: Row(children: [
            posterPath != null
                ? Image.network(
                    ApiClient.imageUrl(posterPath),
                    width: 95,
                  )
                : const SizedBox.shrink(),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      moviedata.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      releaseDate,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      moviedata.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            )
          ]),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            child:
                InkWell(onTap: () => model.onMovieTap(context, moviedata.id)),
          ),
        )
      ]),
    );
  }
}
