import 'dart:convert';
import 'dart:io';

import 'package:the_movie_data_base__pet/domain/entity/movie_details.dart';
import 'package:the_movie_data_base__pet/domain/entity/popular_movie_response.dart';

enum ApiClientExeptionType { Network, Auth, Other, SessionExpired }

class ApiClientExeption implements Exception {
  final ApiClientExeptionType type;

  ApiClientExeption(this.type);
}

enum MediaType { TV, Movie }

extension MediaTypeAsString on MediaType {
  String asString() {
    switch (this) {
      case MediaType.Movie:
        return 'movie';
      case MediaType.TV:
        return 'tv';
    }
  }
}

class ApiClient {
  final _client = HttpClient();
  static const _host = 'https://api.themoviedb.org/3';
  static const _imageUrl = 'https://image.tmdb.org/t/p/w500';
  static const _apiKey = '7504922c7c1368d413457469a21af180';

  static String imageUrl(String path) => _imageUrl + path;

  Future<String> auth({
    required String password,
    required String username,
  }) async {
    final token = await _makeToken();
    final validToken = await _validateUser(
      username: username,
      password: password,
      requestToken: token,
    );
    final sessionId = await _makeSection(requestToken: validToken);
    return sessionId;
  }

  Uri _makeUri(String path, [Map<String, dynamic>? params]) {
    var uri = Uri.parse('$_host/$path');
    if (params != null) {
      return uri.replace(queryParameters: params);
    } else {
      return uri;
    }
  }

  Future<T> _get<T>(
    String path,
    T Function(dynamic json) parser, [
    Map<String, dynamic>? parametrs,
  ]) async {
    final url = _makeUri(path, parametrs);
    try {
      final req = await _client.getUrl(url);
      final res = await req.close();
      final dynamic json = await res.jsonDecode();
      _validateResponse(res, json);
      final result = parser(json);
      return result;
    } on SocketException {
      throw ApiClientExeption(ApiClientExeptionType.Network);
    } on ApiClientExeption {
      rethrow;
    } catch (_) {
      throw ApiClientExeption(ApiClientExeptionType.Other);
    }
  }

  Future<T> _post<T>(
    String path,
    Map<String, dynamic> bodyParametrs,
    T Function(dynamic json) parser, [
    Map<String, dynamic>? urlParametrs,
  ]) async {
    try {
      final url = _makeUri(path, urlParametrs);
      final req = await _client.postUrl(url);

      req.headers.contentType = ContentType.json;
      req.write(jsonEncode(bodyParametrs));
      final res = await req.close();
      final dynamic json = await res.jsonDecode();
      _validateResponse(res, json);

      final result = parser(json);
      return result;
    } on SocketException {
      throw ApiClientExeption(ApiClientExeptionType.Network);
    } on ApiClientExeption {
      rethrow;
    } catch (_) {
      throw ApiClientExeption(ApiClientExeptionType.Other);
    }
  }

  Future<int> getAccountInfo(
    String sessionId,
  ) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['id'] as int;
      return result;
    }

    final accountId = _get(
      '/account',
      parser,
      <String, dynamic>{
        'api_key': _apiKey,
        'session_id': sessionId,
      },
    );
    return accountId;
  }

  Future<bool> isFavoriteMovie(
    int movieId,
    String sessionId,
  ) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final result = jsonMap['favorite'] as bool;
      return result;
    }

    final result = _get(
      'movie/$movieId/account_states',
      parser,
      <String, dynamic>{
        'api_key': _apiKey,
        'session_id': sessionId,
      },
    );
    return result;
  }

  Future<bool> addToFavorite(
    int accountId,
    String sessionId,
    MediaType mediaType,
    int mediaId,
    bool isFavorite,
  ) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final success = jsonMap['success'] as bool;
      return success;
    }

    final params = <String, dynamic>{
      'media_type': mediaType.asString(),
      'media_id': mediaId,
      'favorite': isFavorite,
    };
    final result = _post(
      'account/$accountId/favorite',
      params,
      parser,
      <String, dynamic>{
        'session_id': sessionId,
        'api_key': _apiKey,
      },
    );
    return result;
  }

  Future<PopularMovieResponse> popularMovie(int rawPage, String locale) async {
    String page = rawPage.toString();
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result = _get(
      '/movie/popular',
      parser,
      <String, dynamic>{
        'api_key': _apiKey,
        'page': page,
        'language': locale,
      },
    );
    return result;
  }

  Future<PopularMovieResponse> searchMovie(
      int rawPage, String locale, String query) async {
    String page = rawPage.toString();
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result = _get(
      '/search/movie',
      parser,
      <String, dynamic>{
        'api_key': _apiKey,
        'page': page,
        'language': locale,
        'query': query,
        'include_adult': false.toString(),
      },
    );
    return result;
  }

  Future<MovieDetails> movieDetails(
    int movieId,
    String locale,
  ) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = MovieDetails.fromJson(jsonMap);
      return response;
    }

    final result = _get(
      '/movie/$movieId',
      parser,
      <String, dynamic>{
        'api_key': _apiKey,
        'language': locale,
        'append_to_response': 'credits,videos',
      },
    );
    return result;
  }

  Future<String> _makeToken() async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    }

    final result = _get(
      '/authentication/token/new',
      parser,
      <String, dynamic>{'api_key': _apiKey},
    );
    return result;
  }

  Future<String> _validateUser({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    }

    final parametrs = <String, dynamic>{
      'username': username,
      'password': password,
      'request_token': requestToken,
    };
    final result = _post<String>(
      '/authentication/token/validate_with_login',
      parametrs,
      parser,
      <String, dynamic>{'api_key': _apiKey},
    );
    return result;
  }

  Future<String> _makeSection({
    required String requestToken,
  }) async {
    parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final sessionId = jsonMap['session_id'] as String;
      return sessionId;
    }

    final params = <String, dynamic>{
      'request_token': requestToken,
    };
    final result = _post(
      '/authentication/session/new',
      params,
      parser,
      <String, dynamic>{'api_key': _apiKey},
    );
    return result;
  }

  void _validateResponse(HttpClientResponse res, dynamic json) {
    if (res.statusCode == 401) {
      final dynamic status = json['status_code'];
      final code = status is int ? status : 0;
      if (code == 30) {
        throw ApiClientExeption(ApiClientExeptionType.Auth);
      } else if (code == 3) {
        throw ApiClientExeption(ApiClientExeptionType.SessionExpired);
      } else {
        throw ApiClientExeption(ApiClientExeptionType.Other);
      }
    }
  }
}

extension HttpClientResponseJsonDecode on HttpClientResponse {
  Future<dynamic> jsonDecode() async {
    return transform(utf8.decoder)
        .toList()
        .then((value) => value.join())
        .then<dynamic>((v) => json.decode(v));
  }
}
