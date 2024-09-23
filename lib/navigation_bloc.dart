import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class NavigationEvent {}

class NavigateToScreen1 extends NavigationEvent {}

class NavigateToScreen2 extends NavigationEvent {}

class NavigateToScreen3 extends NavigationEvent {
  final String text;
  NavigateToScreen3(this.text);
}

// States
abstract class NavigationState {}

class Screen1State extends NavigationState {}

class Screen2State extends NavigationState {}

class Screen3State extends NavigationState {
  final String text;
  Screen3State(this.text);
}

// Bloc
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(Screen1State()) {
    // Register event handlers using `on<Event>`

    on<NavigateToScreen1>((event, emit) {
      emit(Screen1State());
    });

    on<NavigateToScreen2>((event, emit) {
      emit(Screen2State());
    });

    on<NavigateToScreen3>((event, emit) {
      emit(Screen3State(event.text));
    });
  }
}
