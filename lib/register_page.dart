part of 'main.dart';

// ======================================================
// TMC EVENTEASE - REGISTER PAGE
// ======================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ====================================================
  // TEXT CONTROLLERS
  // ====================================================

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final studentIdController = TextEditingController();
  final passwordController = TextEditingController();

  // ====================================================
  // SELECTED STUDENT INFORMATION
  // ====================================================

  String selectedDepartment = 'College of Computer Studies';
  String selectedCourse = 'BSIT';
  String selectedYear = '1st Year';
  String selectedBlock = '';

  bool hidePassword = true;


// ======================================================
// PASSWORD STRENGTH VALIDATION
// ======================================================

  bool hasMinLength(String password) =>
      password.length >= 8;

  bool hasUppercase(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);

  bool hasLowercase(String password) =>
      RegExp(r'[a-z]').hasMatch(password);

  bool hasNumber(String password) =>
      RegExp(r'[0-9]').hasMatch(password);

  bool hasSpecialCharacter(String password) =>
      RegExp(
        r'[!@#$%^&*(),.?":{}|<>_\-+=]',
      ).hasMatch(password);

// Count satisfied requirements.
  int passwordStrength(String password) {
    int strength = 0;

    if (hasMinLength(password)) strength++;
    if (hasUppercase(password)) strength++;
    if (hasLowercase(password)) strength++;
    if (hasNumber(password)) strength++;
    if (hasSpecialCharacter(password)) strength++;

    return strength;
  }

// All five requirements must be satisfied.
  bool isStrongPassword(String password) {
    return passwordStrength(password) == 5;
  }

// Strength indicator color.
  Color strengthColor(int strength) {
    if (strength == 5) {
      return Colors.green;
    }

    if (strength >= 3) {
      return Colors.orange;
    }

    return Colors.red;
  }

// Strength indicator label.
  String strengthLabel(int strength) {
    if (strength == 5) {
      return 'Strong';
    }

    if (strength >= 3) {
      return 'Moderate';
    }

    return 'Weak';
  }

// Reusable requirement indicator.
  Widget passwordRequirement(
      String title,
      bool isPassed,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(
            isPassed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            size: 17,
            color: isPassed ? Colors.green : textGrey,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isPassed ? Colors.green : textGrey,
            ),
          ),
        ],
      ),
    );
  }


  // ====================================================
  // TMC DEPARTMENTS AND COURSES
  // ====================================================

  final Map<String, List<String>> departmentCourses = {
    'College of Computer Studies': ['BSIT'],
    'College of Education': ['BEED', 'BSED'],
    'College of Criminal Justice Education': ['BSCRIM'],
    'College of Office Administration': ['BSOA'],
    'College of Arts and Sciences': [
      'AB Political Science',
      'AB Communication',
    ],
  };

  // ====================================================
  // REGISTER STUDENT
  // ====================================================

  void registerUser() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final studentId = studentIdController.text.trim();
    final password = passwordController.text;

    // VALIDATE REQUIRED FIELDS

    if (name.isEmpty ||
        email.isEmpty ||
        studentId.isEmpty ||
        password.isEmpty) {
      showMessage(context, 'Please complete all required fields.');
      return;
    }

    // VALIDATE EMAIL

    if (!isValidEmail(email)) {
      showMessage(context, 'Please enter a valid email address.');
      return;
    }

    // VALIDATE STUDENT ID

    if (studentId.isEmpty) {
      showMessage(context, 'Please enter your Student ID.');
      return;
    }

    // VALIDATE BLOCK

    if (selectedBlock.trim().isEmpty) {
      showMessage(context, 'Please enter your block.');
      return;
    }


// ======================================================
// PASSWORD SECURITY STANDARD
// ======================================================

    if (!isStrongPassword(password)) {
      showMessage(
        context,
        'Password must contain at least 8 characters, '
            'uppercase and lowercase letters, '
            'a number, and a special character.',
      );
      return;
    }


    // ==================================================
    // CLEAR PREVIOUS LOCAL STUDENT DATA
    // ==================================================

    // This local demo supports one registered account
    // at a time. If the email or Student ID changes,
    // clear activity belonging to the previous account.

    if (savedEmail.isNotEmpty &&
        (savedEmail.toLowerCase() != email.toLowerCase() ||
            savedStudentId != studentId)) {
      clearStudentActivityData();
    }

    // ==================================================
    // SAVE STUDENT INFORMATION LOCALLY
    // ==================================================

    savedName = name;
    savedEmail = email;
    savedStudentId = studentId;

    savedDepartment = selectedDepartment;
    savedCourse = selectedCourse;
    savedYear = selectedYear;
    savedBlock = selectedBlock;

    savedPassword = password;

    // ==================================================
    // REGISTRATION SUCCESS
    // ==================================================

    showMessage(context, 'Account created successfully!');

    Navigator.pop(context);
  }

  // ====================================================
  // DISPOSE CONTROLLERS
  // ====================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    studentIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ====================================================
  // REGISTRATION PAGE UI
  // ====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),

        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,

            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - value)),
                  child: child,
                ),
              );
            },

            child: Container(
              constraints: const BoxConstraints(maxWidth: 560),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: navy.withValues(alpha: 0.07),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                children: [
                  // ========================================
                  // REGISTRATION HEADER
                  // ========================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),

                    decoration: const BoxDecoration(
                      gradient: appGradient,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          width: 62,
                          height: 62,

                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white24),
                          ),

                          child: const Icon(
                            Icons.person_add_alt_1_rounded,
                            color: yellow,
                            size: 32,
                          ),
                        ),

                        const SizedBox(width: 14),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Create your account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              SizedBox(height: 3),

                              Text(
                                'Enter your student information below.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ========================================
                  // REGISTRATION FORM
                  // ========================================
                  Padding(
                    padding: const EdgeInsets.all(22),

                    child: Column(
                      children: [
                        // ==================================
                        // FULL NAME
                        // ==================================
                        TextField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Juan Dela Cruz',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================
                        // EMAIL
                        // ==================================
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'juandelacruz@gmail.com',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================
                        // STUDENT ID - NEW FIELD
                        // ==================================
                        TextField(
                          controller: studentIdController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Student ID',
                            hintText: '00-000000',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ==================================
                        // DEPARTMENT
                        // ==================================
                        DropdownButtonFormField<String>(
                          initialValue: selectedDepartment,
                          isExpanded: true,

                          decoration: const InputDecoration(
                            labelText: 'Department',
                            prefixIcon: Icon(Icons.account_balance_outlined),
                          ),

                          items: departmentCourses.keys.map((department) {
                            return DropdownMenuItem<String>(
                              value: department,
                              child: Text(
                                department,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),

                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedDepartment = value;
                              selectedCourse = departmentCourses[value]!.first;
                            });
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================
                        // COURSE / PROGRAM
                        // ==================================
                        DropdownButtonFormField<String>(
                          key: ValueKey(selectedDepartment),
                          initialValue: selectedCourse,
                          isExpanded: true,

                          decoration: const InputDecoration(
                            labelText: 'Course / Program',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),

                          items: departmentCourses[selectedDepartment]!.map((
                            course,
                          ) {
                            return DropdownMenuItem<String>(
                              value: course,
                              child: Text(course),
                            );
                          }).toList(),

                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedCourse = value;
                            });
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================
                        // YEAR LEVEL
                        // ==================================
                        DropdownButtonFormField<String>(
                          initialValue: selectedYear,
                          isExpanded: true,

                          decoration: const InputDecoration(
                            labelText: 'Year Level',
                            prefixIcon: Icon(Icons.calendar_month_outlined),
                          ),

                          items: const [
                            DropdownMenuItem(
                              value: '1st Year',
                              child: Text('1st Year'),
                            ),
                            DropdownMenuItem(
                              value: '2nd Year',
                              child: Text('2nd Year'),
                            ),
                            DropdownMenuItem(
                              value: '3rd Year',
                              child: Text('3rd Year'),
                            ),
                            DropdownMenuItem(
                              value: '4th Year',
                              child: Text('4th Year'),
                            ),
                          ],

                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              selectedYear = value;
                            });
                          },
                        ),

                        const SizedBox(height: 14),


                        // ==================================
                        // BLOCK - MANUAL TEXT INPUT
                        // ==================================

                        TextField(
                          keyboardType: TextInputType.text,
                          textCapitalization:
                          TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Block',
                            hintText: 'Enter your Block (e.g. 1)',
                            prefixIcon: Icon(
                              Icons.groups_rounded,
                            ),
                          ),
                          onChanged: (value) {
                            selectedBlock = value.trim();
                          },
                        ),


                        const SizedBox(height: 14),


// ======================================================
// PASSWORD INPUT WITH LIVE STRENGTH INDICATOR
// ======================================================

                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,

                          // Automatically update strength while typing.
                          onChanged: (value) {
                            setState(() {});
                          },

                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),

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

                        const SizedBox(height: 12),

// ======================================================
// PASSWORD REQUIREMENTS
// ======================================================

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Show strength only when the user starts typing.
                            if (passwordController.text.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Password Strength',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),

                                  Text(
                                    strengthLabel(
                                      passwordStrength(
                                        passwordController.text,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: strengthColor(
                                        passwordStrength(
                                          passwordController.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // ================================================
                              // STRENGTH PROGRESS BAR
                              // ================================================

                              Row(
                                children: List.generate(5, (index) {
                                  final strength = passwordStrength(
                                    passwordController.text,
                                  );

                                  return Expanded(
                                    child: Container(
                                      height: 7,
                                      margin: EdgeInsets.only(
                                        right: index == 4 ? 0 : 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: index < strength
                                            ? strengthColor(strength)
                                            : borderColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }),
                              ),

                              const SizedBox(height: 14),
                            ],

                            const Text(
                              'Password Requirements',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: textDark,
                              ),
                            ),

                            const SizedBox(height: 8),

                            passwordRequirement(
                              'At least 8 characters',
                              hasMinLength(passwordController.text),
                            ),

                            passwordRequirement(
                              'At least 1 uppercase letter',
                              hasUppercase(passwordController.text),
                            ),

                            passwordRequirement(
                              'At least 1 lowercase letter',
                              hasLowercase(passwordController.text),
                            ),

                            passwordRequirement(
                              'At least 1 number',
                              hasNumber(passwordController.text),
                            ),

                            passwordRequirement(
                              'At least 1 special character',
                              hasSpecialCharacter(passwordController.text),
                            ),

                            // ================================================
                            // PASSWORD APPROVED MESSAGE
                            // ================================================

                            if (isStrongPassword(passwordController.text))
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.verified_user_rounded,
                                      color: Colors.green,
                                      size: 19,
                                    ),
                                    SizedBox(width: 7),
                                    Expanded(
                                      child: Text(
                                        'Password meets all requirements!',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ==================================
                        // CREATE ACCOUNT BUTTON
                        // ==================================
                        ElevatedButton.icon(
                          onPressed: registerUser,
                          icon: const Icon(Icons.person_add_alt_rounded),
                          label: const Text('Create Account'),
                        ),

                        const SizedBox(height: 8),

                        // ==================================
                        // BACK TO LOGIN
                        // ==================================
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Already have an account? Login',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
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
