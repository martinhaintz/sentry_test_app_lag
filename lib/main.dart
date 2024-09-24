import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'navigation_bloc.dart';

int frames = 0;
int counter = 0;
late Timer timer;
late ISentrySpan sentrySpan;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'xxxxx';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
      options.navigatorKey = navigatorKey;
    },
    appRunner: () => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    sentrySpan = Sentry.startTransaction(
        '${DateTime.now()} startUnlimitedSpan()', 'task');
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [
        SentryNavigatorObserver(),
      ],
      home: BlocProvider(
        create: (_) => NavigationBloc(),
        child: const Home(),
      ),
    );
  }
}

// The main Home Widget that listens to NavigationBloc
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        if (state is MainScreenState) {
          return const MainScreen();
        } else if (state is Screen2State) {
          return const Screen2();
        }
        return Container();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int maxCounter = 72 * 1000;

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 1), (Timer timer) {
      setState(() {
        counter++; // This will update the UI every second.
        frames++;
      });
      sentrySpan.setData(frames.toString(), frames);
      if (counter >= maxCounter) {
        counter = 0;
        timer.cancel();
        sentrySpan.finish();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MainScreen')),
      body: Center(
        child: Column(
          children: [
            Text("Frame: $frames"),
            ElevatedButton(
                onPressed: () {
                  startTimer();
                },
                child: Text("Start $maxCounter Frames")),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationBloc>().add(NavigateToScreen2());
              },
              child: const Text('Go to Screen 2'),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen 2
class Screen2 extends StatelessWidget {
  const Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 2')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Screen 2"),
              ElevatedButton(
                onPressed: () {
                  context.read<NavigationBloc>().add(NavigateToMainScreen());
                },
                child: const Text('Go back to MainScreen'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(index.toString()),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
