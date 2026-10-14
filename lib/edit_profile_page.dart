part of 'main.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;


  String selectedDepartment = 'College of Computer Studies';
  String selectedCourse = 'BSIT';
  String selectedYear = '1st Year';
  String selectedBlock = '';

  final Map<String, List<String>> departmentCourses = {
    'College of Computer Studies': ['BSIT'],
    'College of Education': ['BEED', 'BSED'],
    'College of Criminal Justice Education': ['BSCRIM'],
    'College of Office Administration': ['BSOA'],
    'College of Arts and Sciences': ['AB Political Science', 'AB Communication'],
  };



  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: savedName);
    emailController = TextEditingController(text: savedEmail);

    if (departmentCourses.containsKey(savedDepartment)) {
      selectedDepartment = savedDepartment;
    }

    final availableCourses =
    departmentCourses[selectedDepartment]!;

    selectedCourse = availableCourses.contains(savedCourse)
        ? savedCourse
        : availableCourses.first;

    const allowedYears = [
      '1st Year',
      '2nd Year',
      '3rd Year',
      '4th Year',
    ];

    if (allowedYears.contains(savedYear)) {
      selectedYear = savedYear;
    }

    selectedBlock = blockOptions.contains(savedBlock)
        ? savedBlock
        : '';
  }



  void saveChanges() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      showMessage(context, 'Please complete all fields.');
      return;
    }

    if (!isValidEmail(email)) {
      showMessage(
        context,
        'Please enter a valid email address.',
      );
      return;
    }

    if (selectedBlock.isEmpty) {
      showMessage(context, 'Please select your block.');
      return;
    }

    // Validate the department and course combination.
    if (!(departmentCourses[selectedDepartment]
        ?.contains(selectedCourse) ?? false)) {
      showMessage(context, 'Please select a valid course.');
      return;
    }

    // Save all changes together.
    savedName = name;
    savedEmail = email;
    savedDepartment = selectedDepartment;
    savedCourse = selectedCourse;
    savedYear = selectedYear;
    savedBlock = selectedBlock;

    showMessage(context, 'Profile updated successfully!');
    Navigator.pop(context);
  }


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: appGradient,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(23),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.manage_accounts_rounded,
                        color: yellow,
                        size: 32,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Keep your student information up to date.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
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

// DEPARTMENT
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

// DYNAMIC COURSE
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




                      DropdownButtonFormField<String>(
                        initialValue:
                        selectedBlock.isEmpty ? null : selectedBlock,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Block',
                          prefixIcon: Icon(Icons.groups_rounded),
                          border: OutlineInputBorder(),
                        ),
                        hint: const Text('Select Block'),
                        items: blockOptions.map((block) {
                          return DropdownMenuItem<String>(
                            value: block,
                            child: Text(block),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;

                          setState(() {
                            selectedBlock = value;
                          });
                        },
                      ),



                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: saveChanges,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfo({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: lightNavy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: navy, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
