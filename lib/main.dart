import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'navigation_bloc.dart';

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
    final transaction = Sentry.startTransaction('startUnlimitedSpan()', 'task');
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
        if (state is Screen1State) {
          return const Screen1();
        } else if (state is Screen2State) {
          return Screen2();
        } else if (state is Screen3State) {
          return Screen3(text: state.text);
        }
        return Container();
      },
    );
  }
}

// Screen 1
class Screen1 extends StatelessWidget {
  const Screen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 1')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<NavigationBloc>().add(NavigateToScreen2());
          },
          child: const Text('Go to Screen 2'),
        ),
      ),
    );
  }
}

// Screen 2
class Screen2 extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  Screen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 2')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Enter some text'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context
                    .read<NavigationBloc>()
                    .add(NavigateToScreen3(_controller.text));
              },
              child: const Text('Go to Screen 3'),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen 3
class Screen3 extends StatelessWidget {
  final String text;

  const Screen3({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen 3')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('You entered: $text'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationBloc>().add(NavigateToScreen1());
              },
              child: const Text('Go back to Screen 1'),
            ),
          ],
        ),
      ),
    );
  }
}
