import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class NavigationEvent {}

class NavigateToMainScreen extends NavigationEvent {}

class NavigateToScreen2 extends NavigationEvent {}

// States
abstract class NavigationState {}

class MainScreenState extends NavigationState {}

class Screen2State extends NavigationState {}

// Bloc
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(MainScreenState()) {
    // Register event handlers using `on<Event>`

    on<NavigateToMainScreen>((event, emit) {
      emit(MainScreenState());
    });

    on<NavigateToScreen2>((event, emit) {
      emit(Screen2State());
    });
  }
}
