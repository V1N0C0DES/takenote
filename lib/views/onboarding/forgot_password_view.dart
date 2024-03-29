import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:takenote/widgets/animations/fade_animation.dart';
import 'package:takenote/constants/k_constants.dart';
import 'package:takenote/enums/login_field_control.dart';
import 'package:takenote/services/auth/bloc/auth_bloc.dart';
import 'package:takenote/services/auth/bloc/auth_event.dart';
import 'package:takenote/services/auth/bloc/auth_state.dart';
import 'package:takenote/utilities/dialogs/error_dialog.dart';
import '../../utilities/utils.dart';
import '../../../utilities/dialogs/password_reset_email_sent_dialog.dart';
import '../../../widgets/animations/background_colour_animate.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _controller = TextEditingController();

  // Colors
  Color enabled = const Color(0xFF827F8A);
  Color enabledtxt = Colors.white;
  Color deaible = Colors.grey;
  Color backgroundColor = const Color(0xFF1F1A30);
  ForgotPassField? selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = Utils(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _controller.clear();
            await showPasswordResetSentDialog(context);
          }
          if (state.exception != null && mounted) {
            await showErrorDialog(context,
                'We could not process your request. Please make sure that you are a registered user. If not, please try again later.');
          }
        }
      },
      child: FadeAnimation(
        delay: 0.1,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: BackgroundColourAnimation(
            delay: 0.1,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(
                          left: size.width * 0.04, top: size.height * 0.04),
                      child: const Icon(
                        Icons.arrow_back_outlined,
                        color: Colors.white,
                        size: 35.0,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  FadeAnimation(
                    delay: 1,
                    child: Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "FORGOT PASSWORD",
                        style: GoogleFonts.heebo(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            letterSpacing: 2),
                      ),
                    ),
                  ),
                  FadeAnimation(
                    delay: 0.8,
                    child: Image.asset(
                      'assets/images/forgotpass.png',
                      height: size.height * 0.2,
                      width: size.width * 0.8,
                    ),
                  ),
                  FadeAnimation(
                    delay: 0.8,
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 30.0,
                        bottom: 10,
                        right: 10,
                      ),
                      child: Text(
                          "Enter your registered email address to reset your password.",
                          style: GoogleFonts.heebo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 1)),
                    ),
                  ),
                  FadeAnimation(
                    delay: 1,
                    child: Container(
                      width: size.width * 0.88,
                      height: size.height * 0.07,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: selected == ForgotPassField.Email
                              ? kJungleDarkGreen.withOpacity(1)
                              : kJungleDarkGreen.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(25.0),
                        color: selected == ForgotPassField.Email
                            ? enabled
                            : backgroundColor,
                      ),
                      child: TextField(
                        controller: _controller,
                        clipBehavior: Clip.antiAlias,
                        onTap: () {
                          setState(() {
                            selected = ForgotPassField.Email;
                          });
                        },
                        decoration: InputDecoration(
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: selected == ForgotPassField.Email
                                ? enabledtxt
                                : deaible,
                          ),
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: selected == ForgotPassField.Email
                                ? enabledtxt
                                : deaible,
                          ),
                        ),
                        style: TextStyle(
                            color: selected == ForgotPassField.Email
                                ? enabledtxt
                                : deaible,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  FadeAnimation(
                    delay: 0.8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.07,
                            vertical: size.height * 0.01,
                          ),
                          child: SizedBox(
                            width: size.width * 0.45,
                            height: size.height * 0.07,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    selected == ForgotPassField.Email
                                        ? kJungleDarkGreen.withOpacity(0.5)
                                        : kBdazalledBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                final email = _controller.text;
                                context
                                    .read<AuthBloc>()
                                    .add(AuthEventForgotPassword(email: email));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Sending email...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor:
                                        kJungleGreen.withOpacity(0.8),
                                  ),
                                );
                              },
                              child: Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const <Widget>[
                                    Text(
                                      'Send',
                                      style: TextStyle(
                                        color: kPlatinum,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.send_rounded,
                                      color: kPlatinum,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FadeAnimation(
                    delay: 0.8,
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 30.0,
                        bottom: 10,
                        right: 10,
                        top: 20,
                      ),
                      child: Text(
                          "Tip: Check your spam/junk folder if you don't see the email in your inbox.",
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: 1)),
                    ),
                  ),
                  SizedBox(height: size.height * 0.20),
                  TextButton(
                    onPressed: () {
                      if (!mounted) {
                        return;
                      }
                      FocusScope.of(context).unfocus();
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: Text(
                      "Back to login",
                      style: GoogleFonts.heebo(
                        color: const Color(0xFF0DF5E4).withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
