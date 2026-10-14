part of 'main.dart';

// ======================================================
// PROFILE
// ======================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> openEditProfile() async {
    await Navigator.push(context, animatedRoute(const EditProfilePage()));

    if (!mounted) return;
    setState(() {});
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.logout_rounded, color: navy, size: 34),
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to end your current session?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Stay'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: navy),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    logoutEventEaseUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Edit Profile',
              onPressed: openEditProfile,
              icon: const Icon(Icons.edit_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: appGradient,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: navy.withValues(alpha: 0.16),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 56,
                      color: yellow,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    savedName.isEmpty ? 'Student' : savedName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      savedCourse.isEmpty
                          ? 'TMC Student'
                          : '$savedCourse • $savedYear',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          sectionTitle('Account Information'),
          const SizedBox(height: 12),

          // EMAIL
          ProfileInfo(
            icon: Icons.email_outlined,
            title: 'Email',
            value: savedEmail,
          ),

          const SizedBox(height: 10),

          // DEPARTMENT
          ProfileInfo(
            icon: Icons.account_balance_outlined,
            title: 'Department',
            value: savedDepartment.isEmpty ? 'Not specified' : savedDepartment,
          ),

          const SizedBox(height: 10),

          // COURSE / PROGRAM
          ProfileInfo(
            icon: Icons.school_outlined,
            title: 'Course / Program',
            value: savedCourse,
          ),

          const SizedBox(height: 10),

          // YEAR LEVEL
          ProfileInfo(
            icon: Icons.calendar_month_outlined,
            title: 'Year Level',
            value: savedYear,
          ),

          const SizedBox(height: 10),

          // BLOCK
          ProfileInfo(
            icon: Icons.groups_outlined,
            title: 'Block',
            value: savedBlock.isEmpty ? 'Not specified' : savedBlock,
          ),

          const SizedBox(height: 22),
          OutlinedButton.icon(
            onPressed: openEditProfile,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
               onPressed: () async {
                await logoutEventEaseUser(context);
                },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
