import 'package:crypto_wallet/UI/pages/home/home_cubit.dart';
import 'package:crypto_wallet/UI/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(create: (_) => HomeCubit()),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }
}
