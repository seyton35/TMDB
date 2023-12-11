import 'package:flutter/material.dart';
import 'package:the_movie_data_base__pet/domain/api_client/api_client.dart';
import 'package:the_movie_data_base__pet/domain/api_client/data_providers/session_data_provider.dart';
import 'package:the_movie_data_base__pet/ui/navigation/main_navigation.dart';

class AuthWidgetModel extends ChangeNotifier {
  final _apiClient = ApiClient();
  final _sessionDataProvider = SessionDataProvider();
  final loginTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isAuthProgress = false;
  bool get canStartAuth => !_isAuthProgress;
  bool get isAuthProgress => _isAuthProgress;

  Future<void> auth(BuildContext context) async {
    final login = loginTextController.text;
    final password = passwordTextController.text;

    // const login = 'seyton35';
    // const password = 'LvB-42s-QBD-G8G';
    if (login.isEmpty || password.isEmpty) {
      _errorMessage = 'Введите логин и пароль';
      notifyListeners();
      return;
    }
    _errorMessage = null;
    _isAuthProgress = true;
    notifyListeners();
    String? sessionId;
    int? accountId;
    try {
      sessionId = await _apiClient.auth(password: password, username: login);
      accountId = await _apiClient.getAccountInfo(sessionId);
    } on ApiClientExeption catch (e) {
      switch (e.type) {
        case ApiClientExeptionType.Network:
          _errorMessage = 'Сервер недостепен. Проверьте интернет соединение';
        case ApiClientExeptionType.Auth:
          _errorMessage = 'Неправильный логин и/или пароль.';
        case ApiClientExeptionType.Other:
          _errorMessage = 'Что-то пошло не так... Попробуйте позже';
          break;
        default:
          print(e);
          break;
      }
    }
    _isAuthProgress = false;
    if (_errorMessage != null) {
      notifyListeners();
      return;
    }
    if (sessionId == null) {
      _errorMessage = 'Неизвестная ошибка, повторите попытку.';
      notifyListeners();
      return;
    }
    _sessionDataProvider.setSessionId(sessionId);
    _sessionDataProvider.setAccountId(accountId);
    Navigator.of(context)
        .pushReplacementNamed(MainNavigationRouteNames.mainScreen);
  }
}
