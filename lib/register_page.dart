part of 'main.dart';

// ======================================================
// REGISTER PAGE
// ======================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();


  String selectedDepartment = 'College of Computer Studies';
  String selectedCourse = 'BSIT';
  String selectedYear = '1st Year';
  String selectedBlock = '';
  bool hidePassword = true;

  final Map<String, List<String>> departmentCourses = {
    'College of Computer Studies': [
      'BSIT',
    ],
    'College of Education': [
      'BEED',
      'BSED',
    ],
    'College of Criminal Justice Education': [
      'BSCRIM',
    ],
    'College of Office Administration': [
      'BSOA',
    ],
    'College of Arts and Sciences': [
      'AB Political Science',
      'AB Communication',
    ],
  };


  void registerUser() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage(context, 'Please complete all fields.');
      return;
    }
    if (selectedBlock.trim().isEmpty) {
      showMessage(context, 'Please select your block.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage(context, 'Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      showMessage(context, 'Password must contain at least 6 characters.');
      return;
    }

    // This local prototype stores one account at a time.
    // Creating another account replaces the previous local account,
    // so old event activity is cleared to avoid mixing student data.
    if (savedEmail.isNotEmpty &&
        savedEmail.toLowerCase() != email.toLowerCase()) {
      clearStudentActivityData();
    }


    savedName = name;
    savedEmail = email;
    savedDepartment = selectedDepartment;
    savedCourse = selectedCourse;
    savedYear = selectedYear;
    savedBlock = selectedBlock;
    savedPassword = password;


    showMessage(context, 'Account created successfully!');
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const SizedBox(height: 14),

// DEPARTMENT DROPDOWN
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


// DYNAMIC COURSE DROPDOWN
                        DropdownButtonFormField<String>(
                          key: ValueKey(selectedDepartment),
                          initialValue: selectedCourse,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Course / Program',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          items: departmentCourses[selectedDepartment]!
                              .map((course) {
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
                        DropdownButtonFormField<String>(
                          initialValue: selectedYear,
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

                        const SizedBox(height: 16),


                        DropdownButtonFormField<String>(
                          initialValue: null,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Block',
                            prefixIcon: Icon(Icons.groups_rounded),
                          ),
                          hint: const Text('Select Block'),
                          items: blockOptions.map((block) {
                            return DropdownMenuItem<String>(
                              value: block,
                              child: Text(block),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBlock = value ?? '';
                            });
                          },
                        ),


                        const SizedBox(height: 14),
                        TextField(
                          controller: passwordController,
                          obscureText: hidePassword,
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
                        const SizedBox(height: 22),
                        ElevatedButton.icon(
                          onPressed: registerUser,
                          icon: const Icon(Icons.person_add_alt_rounded),
                          label: const Text('Create Account'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
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
