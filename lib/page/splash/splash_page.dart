import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixez/bloc/bloc.dart';
import 'package:pixez/generated/i18n.dart';
import 'package:pixez/network/api_client.dart';
import 'package:pixez/network/oauth_client.dart';
import 'package:pixez/network/onezero_client.dart';
import 'package:pixez/page/hello/hello_page.dart';
import 'package:pixez/page/login/login_page.dart';
import 'package:pixez/page/progress/progress_page.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  @override
  void initState() {
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    super.initState();
    controller.forward();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  String helloWord = "= w =";
  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnezeroBloc>(
      child: BlocBuilder<OnezeroBloc, OnezeroState>(
        builder: (BuildContext context, OnezeroState state) {
          return Scaffold(
            body: MultiBlocListener(
              listeners: [
                BlocListener<AccountBloc, AccountState>(
                  listener: (_, state) {
                    BlocProvider.of<OnezeroBloc>(context)
                        .add(FetchOnezeroEvent());
                    if (state is NoneUserState) {
                      setState(() {
                        helloWord = "(>○<)";
                      });
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => LoginPage()));
                    }
                  },
                ),
                BlocListener<OnezeroBloc, OnezeroState>(
                  listener: (_, state) {
                    if (state is DataOnezeroState) {
                      var address = state.onezeroResponse.answer.first.data;
                      print('address:$address');
                      if (address != null && address.isNotEmpty) {
                        setState(() {
                          helloWord = '♪^∀^●)ノ';
                        });
                        RepositoryProvider.of<ApiClient>(context)
                            .httpClient
                            .options
                            .baseUrl = 'https://$address';
                        RepositoryProvider.of<OAuthClient>(context)
                            .httpClient
                            .options
                            .baseUrl = 'https://$address';
                      }
                      if (BlocProvider.of<AccountBloc>(context).state
                          is HasUserState)
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => BlocListener<
                                        SaveBloc, SaveState>(
                                    listener: (context, state) {
                                      if (state is SaveStartState) {
                                        BotToast.showNotification(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ProgressPage())),
                                            trailing: (_) =>
                                                Icon(Icons.chevron_right),
                                            leading: (_) =>
                                                Icon(Icons.save_alt),
                                            title: (_) => Text(I18n.of(context)
                                                .Append_to_query));
                                      }
                                      if (state is SaveSuccesState)
                                        BotToast.showNotification(
                                            leading: (_) => Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                ),
                                            title: (_) =>
                                                Text(I18n.of(context).Saved));
                                      if (state is SaveAlreadyGoingOnState)
                                        BotToast.showNotification(
                                            onTap: () =>
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            ProgressPage())),
                                            trailing: (_) =>
                                                Icon(Icons.chevron_right),
                                            leading: (_) =>
                                                Icon(Icons.save_alt),
                                            title: (_) =>
                                                Text(I18n
                                                    .of(context)
                                                    .Already_in_query));
                                    },
                                    child: HelloPage())));
                    } else if (state is FailOnezeroState) {
                      if (BlocProvider.of<AccountBloc>(context).state
                          is HasUserState)
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    HelloPage()));
                    }
                  },
                ),
              ],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  RotationTransition(
                      child: Image.asset(
                        'assets/images/icon.png',
                        height: 80,
                        width: 80,
                      ),
                      alignment: Alignment.center,
                      turns: controller),
                  Container(
                    child: Text(
                      helloWord,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      create: (BuildContext context) => OnezeroBloc(OnezeroClient()),
    );
  }
}