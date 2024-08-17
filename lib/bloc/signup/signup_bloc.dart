import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_rms/Services/dbhelper.dart';
import 'package:project_rms/bloc/signup/signup_event.dart';
import 'package:project_rms/bloc/signup/signup_state.dart';


class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc() : super(InitialState()) {
    on<OnSignupSuccessEvent>(_SignupSuccessEvent);
    on<OnSignupFailureEvent>(_SignupFailureEvent);
    on<OnLoginEvent>(_LoginEvent);
  }
  void _SignupSuccessEvent(
      OnSignupSuccessEvent event, Emitter<SignupState> emit) async {
   await AppDataBase()
        .insertAdmin(event.username, event.email, event.password, event.phone,event.designation);
    emit(SignupSuccessState());
  }

  void _SignupFailureEvent(
      OnSignupFailureEvent event, Emitter<SignupState> emit) {
    emit(SignupFailureState(message:event.message));
  }

  void _LoginEvent(OnLoginEvent event, Emitter<SignupState> emit) {
    emit(AlreadySignupState());
  }
}
