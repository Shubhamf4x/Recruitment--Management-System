// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_null_comparison, must_be_immutable, non_constant_identifier_names, use_build_context_synchronously, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_rms/Screens/home.dart';
import 'package:project_rms/Services/sp.dart';
import 'package:project_rms/bloc/login/login_bloc.dart';
import 'package:project_rms/bloc/login/login_state.dart';
import 'package:project_rms/components/button.dart';
import 'package:project_rms/components/customInput.dart';
import 'package:project_rms/components/customSnackbar.dart';
import '../bloc/login/login_event.dart';
import '../constant/constant.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  late bool _rememberMe;
  bool rememberPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLoginDetails();
  }

  Future<void> _loadSavedLoginDetails() async {
    final loginDetails = await SharedPreferencesService().loadLoginDetails();
    if (loginDetails['rememberMe'] == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(email: loginDetails['email'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(),
            child: BlocListener<LoginBloc, LoginState>(listener:
                (context, state) {
              if (state is LoginSuccessState) {
                CustomSnackBar.show(
                  context,
                  "Login Successful!",
                  backgroundColor: Theme.of(context).primaryColor,
                );

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            email: emailController.text.toString())));
              }
              if (state is LoginFailureState) {
                CustomSnackBar.show(
                  context,
                  state.message,
                  backgroundColor: Theme.of(context).primaryColor,
                );
              }
              if (state is SignupState) {
                Navigator.pushNamed(context, '/signup');
              }
              if (state is ForgotPassState) {
                Navigator.pushNamed(context, '/forgot');
              }
            }, child:
                BlocBuilder<LoginBloc, LoginState>(builder: (context, state) {
              return Stack(
                children: [
                  Container(
                      height: MediaQuery.of(context).size.height,
                      color: Theme.of(context).primaryColor),
                  Column(children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage("assets/images/chetu.jpeg"))),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(25, 50, 25, 50),
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40)),
                        ),
                        child: Form(
                            key: formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(loginHeader,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 30),
                                  CustomInputField(
                                    controller: emailController,
                                    icon: Icon(Icons.email_outlined),
                                    labelText: 'Email',
                                    hintText: "Enter your email",
                                    validator: (value) {
                                      if (value!.isEmpty || value == null) {
                                        return 'Please enter Email';
                                      }

                                      return null;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  CustomInputField(
                                    controller: passwordController,
                                    icon: Icon(Icons.key_sharp),
                                    labelText: 'password',
                                    hintText: "Enter your password",
                                    validator: (value) {
                                      if (value!.isEmpty || value == null) {
                                        return 'Please enter Password';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    suffixIcon: true,
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: rememberPassword,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                rememberPassword = value!;
                                              });
                                            },
                                            activeColor:
                                                Theme.of(context).primaryColor,
                                          ),
                                          Text("Remember me",
                                              style: TextStyle(
                                                  color: Colors.black45)),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context
                                              .read<LoginBloc>()
                                              .add(OnForgotEvent());
                                        },
                                        child: Text(
                                          'Forgot password?',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .highlightColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  CustomButton(
                                      innerText: "Log in",
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          onLogin();

                                          context.read<LoginBloc>().add(
                                              OnLoginEvent(
                                                  email: emailController.text,
                                                  password:
                                                      passwordController.text));
                                        }
                                      }),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Doesn't have an account? "),
                                      GestureDetector(
                                          onTap: () {
                                            context
                                                .read<LoginBloc>()
                                                .add(OnSignupEvent());
                                          },
                                          child: Text("Sign up",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .highlightColor)))
                                    ],
                                  )
                                ],
                              ),
                            )),
                      ),
                    ),
                  ])
                ],
              );
            }))));
  }

  onLogin() {
    if (rememberPassword) {
      SharedPreferencesService().saveLoginDetails(
        emailController.text,
        passwordController.text,
        rememberPassword,
      );
    } else {
      SharedPreferencesService().clearLoginDetails();
    }
  }
}
