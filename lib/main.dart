import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:takenote/services/auth/bloc/auth_bloc.dart';
import 'package:takenote/services/auth/bloc/auth_event.dart';
import 'package:takenote/services/auth/bloc/auth_state.dart';
import 'package:takenote/services/auth/firebase_auth_provider.dart';
import 'package:takenote/views/homepage.dart';
import 'package:takenote/views/notes/default/create_update_archive_note_view.dart';
import 'package:takenote/views/notes/default/create_update_note_view.dart';
import 'package:takenote/views/onboarding/onboarding_view.dart';
import 'constants/routes.dart';
import 'helpers/loading/splash_screen.dart';
import 'views/onboarding/forgot_password_view.dart';
import 'views/onboarding/login_view.dart';
import 'views/onboarding/register_view.dart';
import 'views/onboarding/verify_email_view.dart';

// theme button toggle
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:takenote/providers/theme_provider.dart';
// import 'package:takenote/services/Utils/utils.dart';
//
// class ThemeButton extends StatelessWidget {
//   const ThemeButton({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       icon: Icon(
//         Icons.brightness_4,
//         color: Utils(context).getColor,
//       ),
//       onPressed: () {
//         Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
//       },
//     );
//   }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Take Note',
        // Show splash screen while loading then show introduction
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // if android or ios
            if (state is AuthStateUninitialized) {
              if (BlocProvider.of<AuthBloc>(context).state
                  is AuthStateUninitialized) {
                // splash screen
                return const SplashScreen();
              } else {
                BlocProvider.of<AuthBloc>(context)
                    .add(const AuthEventInitialize());
              }
            }

            if (state is AuthStateLoggedIn) {
              return const HomePage();
            } else if (state is AuthStateNeedsVerification) {
              return const VerifiyEmailView();
            } else if (state is AuthStateLoggedOut) {
              return const LoginView();
            } else if (state is AuthStateInitializing) {
              return const IntroductionPage();
            } else if (state is AuthStateForgotPassword) {
              return const ForgotPasswordView();
            } else if (state is AuthStateRegistering) {
              return const RegisterView();
            } else {
              return const Scaffold(
                body: CircularProgressIndicator(),
              );
            }
          },
        ),
        routes: {
          //
          // Routes for the app
          createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
          createOrUpdateArchiveNoteRoute: (context) =>
              const CreateUpdateArchiveNoteView(),
        },
      ),
    ),
  );
  // add fields to all documents in a collection in firestore add firstNameField and lastNameField to all documents in a collection in firestore
}
