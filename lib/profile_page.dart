
part of 'main.dart';

// ======================================================
// TMC EVENTEASE - ENHANCED PROFILE PAGE
// ======================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // ====================================================
  // OPEN EDIT PROFILE
  // ====================================================

  Future<void> openEditProfile() async {
    await Navigator.push(
      context,
      animatedRoute(
        const EditProfilePage(),
      ),
    );

    if (!mounted) return;

    // Refresh profile details after editing.
    setState(() {});
  }

  // ====================================================
  // LOGOUT WITH CONFIRMATION
  // ====================================================

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.logout_rounded,
            color: navy,
            size: 34,
          ),

          title: const Text(
            'Logout?',
          ),

          content: const Text(
            'Are you sure you want to end '
                'your current session?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Stay'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: navy,
              ),
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) {
      return;
    }

    // Keep your existing authentication cleanup,
    // logout handling and navigation.
    logoutEventEaseUser(context);
  }

  // ====================================================
  // RESET PASSWORD
  // ====================================================

  void openResetPassword() {
    Navigator.push(
      context,
      animatedRoute(
        ForgotPasswordPage(
          initialEmail: savedEmail,
        ),
      ),
    );
  }

  // ====================================================
  // ENHANCED PROFILE USER INTERFACE
  // ====================================================

  @override
  Widget build(BuildContext context) {
    return EventEaseProfileView(

      // ================================================
      // STUDENT PERSONAL INFORMATION
      // ================================================

      name: savedName,

      email: savedEmail,

      studentId: savedStudentId,

      department: savedDepartment,

      course: savedCourse,

      year: savedYear,

      block: savedBlock,

      // ================================================
      // PROFILE ACTIONS
      // ================================================

      onEdit: openEditProfile,

      onResetPassword: openResetPassword,

      onLogout: logout,
    );
  }
}
