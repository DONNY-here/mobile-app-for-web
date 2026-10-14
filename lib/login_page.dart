part of 'main.dart';

// ======================================================
// TMC EVENTEASE - LOGIN PAGE
// Supports Demo Mode and Real API Mode
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoggingIn = false;
  bool rememberDemoStudent = false;

  // ======================================================
  // LOGIN USER
  // ======================================================

  Future<void> loginUser() async {
    if (isLoggingIn) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    // STEP 1: VALIDATE INPUTS
    if (email.isEmpty || password.isEmpty) {
      showMessage(context, 'Please enter your email and password.');
      return;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      showMessage(context, 'Please enter a valid email address.');
      return;
    }

    setState(() {
      isLoggingIn = true;
    });

    try {
      // ==================================================
      // STEP 2: REAL API AUTHENTICATION
      // ==================================================

      if (ApiConfig.useRealApi) {
        final loginUri = ApiConfig.loginUri;

        if (loginUri == null) {
          throw const ApiAuthException(
            'API URL is not configured. '
            'Contact the developer.',
          );
        }

        // Remove any previously stored API token.
        await authTokenStorage.clear();

        final client = http.Client();

        try {
          final apiService = ApiAuthService(client: client, loginUri: loginUri);

          // Send credentials to the web backend.
          final session = await apiService.login(
            email: email,
            password: password,
          );

          // Confirm the returned account is permitted
          // to use the mobile application.
          if (!session.user.isStudent && !session.user.isScanner) {
            throw const ApiAuthException(
              'This account cannot access the mobile app.',
            );
          }

          // Clear any remembered demo login.
          await demoSessionStorage.clear();

          // Store the backend-issued access token.
          await authTokenStorage.save(session);

          if (!mounted) {
            await authTokenStorage.clear();
            return;
          }

          // Remove old mock authentication state.
          authService.logout();

          // Remove previous local account data.
          clearTemporaryAccountData();

          // Populate temporary display information
          // from the authenticated API response.
          savedName = session.user.name;
          savedEmail = session.user.email;
          savedUserRole = session.user.role;

          if (session.user.isScanner) {
            demoScannerName = session.user.name;
          } else {
            demoScannerName = 'TMC Event Officer';
          }

          // Open the navigation appropriate for role.
          Navigator.pushReplacement(context, animatedRoute(const MainPage()));

          return;
        } finally {
          client.close();
        }
      }

      // ==================================================
      // STEP 3: DEMO AUTHENTICATION
      // ==================================================

      final user = await authService.login(email: email, password: password);

      if (!mounted) return;

      if (user != null) {
        if (!user.isStudent && !user.isScanner) {
          authService.logout();

          showMessage(context, 'This account role is not supported.');
          return;
        }

        // Remember only the fixed student demo account.
        final shouldRemember =
            user.isStudent &&
            user.email.toLowerCase() == 'student@test.local' &&
            rememberDemoStudent;

        await demoSessionStorage.setRememberStudent(shouldRemember);

        if (!mounted) return;

        savedUserRole = user.role;

        demoScannerName = user.isScanner ? user.name : 'TMC Event Officer';

        Navigator.pushReplacement(context, animatedRoute(const MainPage()));

        return;
      }

      // ==================================================
      // STEP 4: EXISTING LOCALLY REGISTERED STUDENTS
      // ==================================================

      final validLocalStudent =
          savedEmail.isNotEmpty &&
          savedPassword.isNotEmpty &&
          email.toLowerCase() == savedEmail.toLowerCase() &&
          password == savedPassword;

      if (validLocalStudent) {
        await demoSessionStorage.clear();

        if (!mounted) return;

        authService.startLocalStudentSession(
          name: savedName,
          email: savedEmail,
        );

        savedUserRole = 'student';
        demoScannerName = 'TMC Event Officer';

        Navigator.pushReplacement(context, animatedRoute(const MainPage()));

        return;
      }

      // ==================================================
      // STEP 5: INVALID LOGIN
      // ==================================================

      showMessage(context, 'Incorrect email or password.');
    } on ApiAuthException catch (error) {
      if (ApiConfig.useRealApi) {
        try {
          await authTokenStorage.clear();
        } catch (_) {}
      }

      if (mounted) {
        showMessage(context, error.message);
      }
    } catch (error) {
      if (ApiConfig.useRealApi) {
        try {
          await authTokenStorage.clear();
        } catch (_) {}
      } else {
        authService.logout();
      }

      // Never log passwords, access tokens,
      // or full server response bodies.
      debugPrint('Login failed: ${error.runtimeType}');

      if (mounted) {
        showMessage(context, 'Unable to sign in. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoggingIn = false;
        });
      }
    }
  }

  // ======================================================
  // DISPOSE CONTROLLERS
  // ======================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ======================================================
  // LOGIN PAGE DESIGN
  // ======================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: appGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // TOP DECORATIVE CIRCLE
              Positioned(
                top: -70,
                right: -60,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),

              // BOTTOM DECORATIVE CIRCLE
              Positioned(
                bottom: -90,
                left: -70,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: yellow.withValues(alpha: 0.09),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(22),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,

                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - value)),
                          child: child,
                        ),
                      );
                    },

                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 460),
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 34,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // APP ICON
                          Center(
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                gradient: appGradient,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: navy.withValues(alpha: 0.18),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.event_available_rounded,
                                size: 46,
                                color: yellow,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // APP TITLE
                          const Text(
                            'TMC EventEase',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: textDark,
                              letterSpacing: -0.6,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Your Events, Easy Access.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: textGrey),
                          ),

                          const SizedBox(height: 30),

                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Sign in to access events and attendance.',
                            style: TextStyle(color: textGrey, fontSize: 13),
                          ),

                          const SizedBox(height: 18),

                          // EMAIL FIELD
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // PASSWORD FIELD
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            autofillHints: const [AutofillHints.password],
                            onSubmitted: (_) => loginUser(),

                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // ======================================================
                          // FORGOT PASSWORD BUTTON
                          // ======================================================
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoggingIn
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        animatedRoute(
                                          ForgotPasswordPage(
                                            initialEmail: emailController.text
                                                .trim(),
                                          ),
                                        ),
                                      );
                                    },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          // REMEMBER ME - DEMO MODE ONLY
                          if (!ApiConfig.useRealApi) ...[
                            const SizedBox(height: 8),

                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              controlAffinity: ListTileControlAffinity.leading,
                              activeColor: navy,
                              value: rememberDemoStudent,

                              onChanged: isLoggingIn
                                  ? null
                                  : (value) {
                                      setState(() {
                                        rememberDemoStudent = value ?? false;
                                      });
                                    },

                              title: const Text(
                                'Remember student demo login',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: textDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // LOGIN BUTTON
                          ElevatedButton.icon(
                            onPressed: isLoggingIn ? null : loginUser,
                            icon: isLoggingIn
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: navy,
                                    ),
                                  )
                                : const Icon(Icons.login_rounded),
                            label: Text(
                              isLoggingIn ? 'Signing In...' : 'Login',
                            ),
                          ),

                          // REGISTRATION - DEMO MODE ONLY
                          if (!ApiConfig.useRealApi) ...[
                            const SizedBox(height: 8),

                            TextButton(
                              onPressed: isLoggingIn
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        animatedRoute(const RegisterPage()),
                                      );
                                    },
                              child: const Text(
                                "Don't have an account? Register",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
