part of 'main.dart';

// ======================================================
// DASHBOARD PAGE
// ======================================================

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TMC EventEase'),
            Text(
              'Student Event Portal',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [


          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ValueListenableBuilder<Set<String>>(
              valueListenable: readNotificationIds,
              builder: (context, readIds, child) {
                final unreadCount = getUnreadNotificationCount();

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Notifications',
                      style: IconButton.styleFrom(
                        backgroundColor:
                        Colors.white.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          animatedRoute(const AnnouncementsPage()),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 19,
                            minHeight: 19,
                          ),
                          decoration: BoxDecoration(
                            color: yellow,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: navy,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 9
                                  ? '9+'
                                  : '$unreadCount',
                              style: const TextStyle(
                                color: navy,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),


        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 15 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: appGradient,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.waving_hand_rounded,
                        color: yellow,
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            savedName.isEmpty
                                ? 'Hello, Student!'
                                : 'Hello, $savedName!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Discover events, manage registrations, and stay connected.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionTitle('Upcoming Events'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      animatedRoute(const EventsPage()),
                    );
                  },
                  child: const Text('See all'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            EventDashboardCard(event: eventList[0], delay: 80),
            const SizedBox(height: 12),
            EventDashboardCard(event: eventList[1], delay: 160),
            const SizedBox(height: 28),
            sectionTitle('Quick Access'),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                QuickAccessButton(
                  icon: Icons.event_rounded,
                  title: 'Events',
                  subtitle: 'Browse events',
                  onTap: () {
                    Navigator.push(
                      context,
                      animatedRoute(const EventsPage()),
                    );
                  },
                ),
                QuickAccessButton(
                  icon: Icons.confirmation_num_rounded,
                  title: 'My Events',
                  subtitle: 'Your registrations',
                  onTap: () {
                    Navigator.push(
                      context,
                      animatedRoute(const MyEventsPage()),
                    );
                  },
                ),
                QuickAccessButton(
                  icon: Icons.qr_code_scanner_rounded,
                  title: 'Scan QR',
                  subtitle: 'Record attendance',
                  onTap: () {
                    Navigator.push(
                      context,
                      animatedRoute(const QRCodePage()),
                    );
                  },
                ),
                QuickAccessButton(
                  icon: Icons.person_rounded,
                  title: 'Profile',
                  subtitle: 'Account details',
                  onTap: () {
                    Navigator.push(
                      context,
                      animatedRoute(const ProfilePage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                sectionTitle('Announcements'),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      animatedRoute(const AnnouncementsPage()),
                    );
                  },
                  child: const Text('View all'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const AnnouncementCard(
              icon: Icons.campaign_rounded,
              title: 'TechTalk Registration Open',
              message: 'Registration for TechTalk 2026 is now open.',
            ),
            const SizedBox(height: 10),
            const AnnouncementCard(
              icon: Icons.alarm_rounded,
              title: 'Event Reminder',
              message: 'Please arrive 15 minutes before your event.',
            ),
          ],
        ),
      ),
    );
  }
}
