import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_web/presentation/bloc/home/home_cubit.dart';
import 'package:radio_web/presentation/bloc/test/test_cubit.dart';
import 'package:radio_web/presentation/widget/home/home_screen.dart';
import 'package:radio_web/core/app_path.dart' as app_path;

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings routeSettings,
      BuildContext context) {
    switch (routeSettings.name) {
      case app_path.home:
        return MaterialPageRoute<HomeScreen>(
          builder: (context) =>
              BlocProvider(
                create: (context) => HomeCubit(0),
                child: HomeScreen(title: 'Flutter Demo - App Routes - Home'),
              ),
        ); 

      default:
        return MaterialPageRoute<Scaffold>(
          builder: (_) =>
              Scaffold(
                body: Center(
                  child:
                    Text('No route defined for ${routeSettings.name}')
                ),
              ));
    }
  }
}