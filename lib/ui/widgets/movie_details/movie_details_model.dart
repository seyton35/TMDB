import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:the_movie_data_base__pet/domain/api_client/api_client.dart';
import 'package:the_movie_data_base__pet/domain/api_client/data_providers/session_data_provider.dart';
import 'package:the_movie_data_base__pet/domain/entity/movie_details.dart';

class MovieDetailsModel extends ChangeNotifier {
  final int movieId;
  final _sessionDataProvider = SessionDataProvider();
  MovieDetails? _movieDetails;
  MovieDetails? get movieDetails => _movieDetails;
  bool _isFavorite = false;
  bool? get isFavorite => _isFavorite;

  String _locale = '';
  final _apiClient = ApiClient();
  late DateFormat _dateFormat;

  Future<void>? Function()? onSessionExpired;

  MovieDetailsModel({
    required this.movieId,
  });

  String stringFromDate(DateTime? date) {
    return date != null ? _dateFormat.format(date) : '';
  }

  Future<void> setupLocale(BuildContext context) async {
    final locale = Localizations.localeOf(context).toLanguageTag();
    if (locale == _locale) return;
    _locale = locale;
    _dateFormat = DateFormat.yMd(locale);
    await loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      _movieDetails = await _apiClient.movieDetails(movieId, _locale);
      // final sessionId = await _sessionDataProvider.getSessionId();
      final sessionId = await _sessionDataProvider.getSessionId();
      if (sessionId != null) {
        _isFavorite = await _apiClient.isFavoriteMovie(movieId, sessionId);
      }
      notifyListeners();
    } on ApiClientExeption catch (e) {
      _handleApiClientExeption(e);
    }
  }

  Future<void> toggleFavorite() async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final accountId = await _sessionDataProvider.getAccountId();
    if (sessionId == null || accountId == null) return;
    var success = false;
    try {
      success = await _apiClient.addToFavorite(
          //TODO: sessionId is variable!
          accountId,
          sessionId,
          MediaType.Movie,
          movieId,
          !_isFavorite);
    } on ApiClientExeption catch (e) {
      _handleApiClientExeption(e);
    }
    if (success == true) {
      _isFavorite = !_isFavorite;
      notifyListeners();
    }
  }

  void _handleApiClientExeption(ApiClientExeption e) {
    switch (e.type) {
      case ApiClientExeptionType.SessionExpired:
        onSessionExpired?.call();
      default:
        print(e);
        break;
    }
  }
}
