import 'package:flutter/material.dart';
import 'package:the_movie_data_base__pet/library/widgets/inherited/provider.dart';
import 'package:the_movie_data_base__pet/ui/widgets/app/main_app.dart';
import 'package:the_movie_data_base__pet/ui/widgets/app/main_app_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final model = MainAppModel();
  await model.checkAuth();
  const app = MainApp();
  final widget = InheritedProvider(model: model, child: app);
  runApp(widget);
}
