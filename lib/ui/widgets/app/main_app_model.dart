import 'package:flutter/widgets.dart';
import 'package:the_movie_data_base__pet/domain/api_client/data_providers/session_data_provider.dart';
import 'package:the_movie_data_base__pet/ui/navigation/main_navigation.dart';

class MainAppModel {
  final _sessionDataProvider = SessionDataProvider();
  var _isAuth = false;
  bool get isAuth => _isAuth;

  Future<void> checkAuth() async {
    final sessionId = await _sessionDataProvider.getSessionId();
    _isAuth = sessionId != null;
  }

  Future<void> resetSession(BuildContext context) async {
    await SessionDataProvider().setSessionId(null);
    await SessionDataProvider().setAccountId(null);
    Navigator.of(context).pushNamedAndRemoveUntil(
      MainNavigationRouteNames.auth,
      (route) => false,
    );
  }
}
