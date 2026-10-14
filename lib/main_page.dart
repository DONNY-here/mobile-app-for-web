part of 'main.dart';

// ======================================================
// MAIN PAGE / ROLE-BASED BOTTOM NAVIGATION
// ======================================================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  bool get isScanner => savedUserRole == 'scanner' || savedUserRole == 'admin';

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = isScanner
        ? const [QRCodePage(), ScannerProfilePage()]
        : [
            DashboardPage(
              onTabSelected: (index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
            const EventsPage(),
            const MyEventsPage(),
            const ProfilePage(),
          ];

    final List<NavigationDestination> destinations = isScanner
        ? const [
            NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_outlined, color: textGrey),
              selectedIcon: Icon(Icons.qr_code_scanner_rounded, color: navy),
              label: 'Scan QR',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: textGrey),
              selectedIcon: Icon(Icons.person_rounded, color: navy),
              label: 'Profile',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: textGrey),
              selectedIcon: Icon(Icons.home_rounded, color: navy),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined, color: textGrey),
              selectedIcon: Icon(Icons.event_rounded, color: navy),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.confirmation_num_outlined, color: textGrey),
              selectedIcon: Icon(Icons.confirmation_num_rounded, color: navy),
              label: 'My Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: textGrey),
              selectedIcon: Icon(Icons.person_rounded, color: navy),
              label: 'Profile',
            ),
          ];

    final safeIndex = selectedIndex < pages.length ? selectedIndex : 0;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey('${savedUserRole}_$safeIndex'),
          child: pages[safeIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 72,
          selectedIndex: safeIndex,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: lightNavy,
          onDestinationSelected: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: destinations,
        ),
      ),
    );
  }
}
