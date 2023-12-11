import 'package:flutter/material.dart';
import 'package:the_movie_data_base__pet/library/widgets/inherited/provider.dart';
import 'package:the_movie_data_base__pet/ui/widgets/auth/auth_widget_model.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({super.key});

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  @override
  Widget build(BuildContext context) {
    return NotifierProvider(
      create: () => AuthWidgetModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login to your account'),
        ),
        body: ListView(children: const [
          _HeaderWidget(),
        ]),
      ),
    );
  }
}

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.black,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
              'Чтобы пользоваться правкой и возможностями рейтинга TMDB, а также '
              'получить персональные рекомендации, необходимо войти в свою учётную '
              'запись. Если у вас нет учётной записи, её регистрация является '
              'бесплатной и простой. Нажмите здесь что-бы начать',
              style: textStyle),
          const SizedBox(height: 16),
          const Text(
              'Если Вы зарегистрировались, но не получили письмо для подтверждения, '
              'нажмите здесь что-бы отправить письмо повторно.',
              style: textStyle),
          const SizedBox(height: 16),
          _FormWidget(),
        ],
      ),
    );
  }
}

class _FormWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<AuthWidgetModel>(context);

    const Color btnColor = Color.fromRGBO(31, 51, 56, 1);
    const textStyle =
        TextStyle(fontSize: 16, color: Color.fromRGBO(33, 37, 41, 1));

    const inputDecoration = InputDecoration(
      border: OutlineInputBorder(),
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: btnColor)),
      contentPadding: EdgeInsets.all(10),
      isCollapsed: true,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ErrorMessageWidget(),
        const Text('Имя пользоателя', style: textStyle),
        const SizedBox(height: 5),
        TextField(
          controller: model?.loginTextController,
          decoration: inputDecoration,
        ),
        const SizedBox(height: 16),
        const Text('Пароль', style: textStyle),
        const SizedBox(height: 5),
        TextField(
          controller: model?.passwordTextController,
          obscureText: true,
          decoration: inputDecoration,
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          children: [
            const _AuthButtonWidget(btnColor: btnColor),
            const SizedBox(width: 30),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(btnColor),
                textStyle: MaterialStateProperty.all(
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              onPressed: () {},
              child: const Text('Сбросить пароль'),
            ),
          ],
        )
      ],
    );
  }
}

class _AuthButtonWidget extends StatelessWidget {
  const _AuthButtonWidget({
    required this.btnColor,
  });

  final Color btnColor;

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<AuthWidgetModel>(context);
    final child = model?.isAuthProgress == true
        ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeAlign: 2),
          )
        : const Text('Войти');
    final onPressed =
        model?.canStartAuth == true ? () => model?.auth(context) : null;
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(btnColor),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        textStyle: MaterialStateProperty.all(
          const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 19, vertical: 6),
        ),
      ),
      onPressed: onPressed,
      child: child,
    );
  }
}

class _ErrorMessageWidget extends StatelessWidget {
  const _ErrorMessageWidget();

  @override
  Widget build(BuildContext context) {
    final errorMessage =
        NotifierProvider.watch<AuthWidgetModel>(context)?.errorMessage;
    if (errorMessage == null) {
      return const SizedBox.shrink();
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 17),
        ),
      );
    }
  }
}
