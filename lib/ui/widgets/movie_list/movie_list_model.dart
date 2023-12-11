import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:the_movie_data_base__pet/domain/api_client/api_client.dart';
import 'package:the_movie_data_base__pet/domain/entity/movie.dart';
import 'package:the_movie_data_base__pet/domain/entity/popular_movie_response.dart';
import 'package:the_movie_data_base__pet/ui/navigation/main_navigation.dart';

class MovieListModel extends ChangeNotifier {
  final _apiClient = ApiClient();
  final _movies = <Movie>[];
  List<Movie> get movies => List.unmodifiable(_movies);
  late DateFormat _dateFormat;
  String _locale = '';
  bool _isLoadingProgress = false;
  late int _currentPage;
  late int _totalPages;
  String? _searchQuery;
  Timer? searchDebounce;

  String stringFromDate(DateTime? date) {
    return date != null ? _dateFormat.format(date) : '';
  }

  Future<void> setupLocalization(BuildContext context) async {
    final locale = Localizations.localeOf(context).toLanguageTag();
    if (locale == _locale) return;
    _dateFormat = DateFormat.yMMMMd(locale);
    _locale = locale;
    await _resetList();
  }

  Future<void> _resetList() async {
    _currentPage = 0;
    _totalPages = 1;
    _movies.clear();
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingProgress || _currentPage >= _totalPages) return;
    _isLoadingProgress = true;
    final nextPage = _currentPage + 1;
    try {
      final moviesResponse = await _loadMovies(nextPage, _locale);
      _currentPage = moviesResponse.page;
      _movies.addAll(moviesResponse.movies);
      _totalPages = moviesResponse.totalPages;
      _isLoadingProgress = false;
      notifyListeners();
    } catch (e) {
      _isLoadingProgress = false;
    }
  }

  Future<PopularMovieResponse> _loadMovies(int rawPage, String locale) async {
    final query = _searchQuery;
    if (query == null) {
      return await _apiClient.popularMovie(rawPage, locale);
    }
    return await _apiClient.searchMovie(rawPage, locale, query);
  }

  void onMovieTap(BuildContext context, int id) {
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.movieDetails,
      arguments: id,
    );
  }

  void searchMovieAtIndex(int movieIndex) {
    if (movieIndex < _movies.length - 1) return;
    _loadNextPage();
  }

  Future<void> searchMovie(String text) async {
    searchDebounce?.cancel();
    searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      final searchQuery = text.isNotEmpty ? text : null;
      if (searchQuery == _searchQuery) return;
      _searchQuery = searchQuery;
      await _resetList();
    });
  }
}
