part of 'main.dart';

// ======================================================
// TMC EVENTEASE - ENHANCED STUDENT DASHBOARD
// ======================================================

class DashboardPage extends StatelessWidget {
  final ValueChanged<int>? onTabSelected;

  const DashboardPage({super.key, this.onTabSelected});

  static const Color dashboardBlue = Color(0xFF174782);
  static const Color paleBlue = Color(0xFFEAF4FF);
  static const Color paleYellow = Color(0xFFFFF6DE);
  static const Color paleGreen = Color(0xFFEAF8F0);

  // ======================================================
  // DATE HANDLING
  // ======================================================

  DateTime? _parseEventDate(String value) {
    final text = value.trim();

    final isoDate = DateTime.tryParse(text);
    if (isoDate != null) {
      return DateTime(isoDate.year, isoDate.month, isoDate.day);
    }

    const months = {
      'january': 1,
      'jan': 1,
      'february': 2,
      'feb': 2,
      'march': 3,
      'mar': 3,
      'april': 4,
      'apr': 4,
      'may': 5,
      'june': 6,
      'jun': 6,
      'july': 7,
      'jul': 7,
      'august': 8,
      'aug': 8,
      'september': 9,
      'sep': 9,
      'sept': 9,
      'october': 10,
      'oct': 10,
      'november': 11,
      'nov': 11,
      'december': 12,
      'dec': 12,
    };

    final cleaned = text
        .replaceAll(',', '')
        .replaceAll('.', '')
        .replaceAll(RegExp(r'(\d+)(st|nd|rd|th)\b'), r'$1');

    final parts = cleaned.split(RegExp(r'\s+'));

    if (parts.length != 3) return null;

    final month = months[parts[0].toLowerCase()];
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) {
      return null;
    }

    final result = DateTime(year, month, day);

    if (result.year != year || result.month != month || result.day != day) {
      return null;
    }

    return result;
  }

  // ======================================================
  // NAVIGATION
  // ======================================================

  void _goToTab(BuildContext context, int index) {
    if (onTabSelected != null) {
      onTabSelected!(index);
      return;
    }

    Navigator.push(
      context,
      animatedRoute(index == 2 ? const MyEventsPage() : const EventsPage()),
    );
  }

  void _openEvent(BuildContext context, Event event) {
    Navigator.push(context, animatedRoute(EventDetailsPage(event: event)));
  }

  // ======================================================
  // SECTION HEADER
  // ======================================================

  Widget _sectionHeader({
    required String title,
    required IconData icon,
    required VoidCallback onSeeAll,
    String actionText = 'See all',
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: yellow.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: navy, size: 21),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
        ),

        TextButton(
          onPressed: onSeeAll,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'See all',
                style: TextStyle(
                  color: navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 3),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: navy),
            ],
          ),
        ),
      ],
    );
  }

  // ======================================================
  // WELCOME BANNER
  // ======================================================

  Widget _welcomeBanner() {
    final studentName = savedName.trim().isEmpty ? 'Student' : savedName.trim();

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -55,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: yellow.withValues(alpha: 0.18),
              ),
            ),
          ),

          Positioned(
            right: 10,
            bottom: -30,
            child: Icon(
              Icons.event_available_rounded,
              size: 125,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 24),
            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.waving_hand_rounded,
                      size: 34,
                      color: yellow,
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'WELCOME BACK',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Hello, $studentName!',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 7),

                      const Text(
                        'Discover events, manage registrations, '
                        'and stay connected.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // EVENT STATISTIC CARD
  // ======================================================

  Widget _statCard({
    required String label,
    required int value,
    required IconData icon,
    required Color accent,
    required Color background,
  }) {
    return Expanded(
      child: Container(
        height: 145,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 23),
            ),

            const Spacer(),

            Text(
              '$value',
              style: const TextStyle(
                color: textDark,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: textDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // REUSABLE EVENT CARD
  // ======================================================

  Widget _eventCard({
    required BuildContext context,
    required Event event,
    required bool attended,
    bool registered = false,
  }) {
    final label = registered
        ? 'REGISTERED'
        : attended
        ? 'ATTENDED'
        : 'PAST';

    final labelColor = registered
        ? dashboardBlue
        : attended
        ? const Color(0xFF198754)
        : textGrey;

    final labelBackground = registered
        ? paleBlue
        : attended
        ? paleGreen
        : const Color(0xFFF0F2F5);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () => _openEvent(context, event),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 67,
                height: 74,
                decoration: BoxDecoration(
                  gradient: appGradient,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: yellow,
                  size: 35,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: textGrey,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            event.date,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: textGrey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: labelBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: labelColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),

              const Icon(Icons.chevron_right_rounded, color: navy),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // EMPTY STATE
  // ======================================================

  Widget _emptyCard({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: textGrey),
          const SizedBox(height: 9),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: textGrey, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // LATEST ANNOUNCEMENTS CARD
  // ======================================================

  Widget _announcementCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () {
          Navigator.push(context, animatedRoute(const AnnouncementsPage()));
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 65,
                decoration: BoxDecoration(
                  color: paleYellow,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  size: 34,
                  color: Color(0xFFD49B06),
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Announcements',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Check the latest event reminders, '
                      'schedules, and college updates.',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),

              const Icon(Icons.chevron_right_rounded, color: navy),
            ],
          ),
        ),
      ),
    );
  }

  // ======================================================
  // MAIN DASHBOARD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    // Remove the time portion when comparing event dates.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Registered events that have not yet happened.
    final upcomingRegistered = registeredEvents.where((event) {
      final date = _parseEventDate(event.date);
      return date != null && !date.isBefore(today);
    }).toList();

    upcomingRegistered.sort((a, b) {
      return _parseEventDate(a.date)!.compareTo(_parseEventDate(b.date)!);
    });

    // Events whose date has already passed.
    final recentEvents = eventList.where((event) {
      final date = _parseEventDate(event.date);
      return date != null && date.isBefore(today);
    }).toList();

    recentEvents.sort((a, b) {
      return _parseEventDate(b.date)!.compareTo(_parseEventDate(a.date)!);
    });

    // Attendance is only counted when recorded as Present.
    final attendedCount = registeredEvents.where((event) {
      return attendanceStatus[eventKey(event)] == 'Present';
    }).length;

    final registeredCount = registeredEvents.length;
    final upcomingCount = upcomingRegistered.length;

    final Event? nextEvent = upcomingRegistered.isEmpty
        ? null
        : upcomingRegistered.first;

    return Scaffold(
      backgroundColor: lightBg,

      // ==================================================
      // HEADER
      // ==================================================
      appBar: AppBar(
        titleSpacing: 18,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TMC EventEase',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Student Event Portal',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip: 'Announcements',
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(context, animatedRoute(const AnnouncementsPage()));
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ==================================================
      // SCROLLABLE DASHBOARD CONTENT
      // ==================================================
      body: ListView(
        padding: const EdgeInsets.fromLTRB(17, 20, 17, 30),
        children: [
          // ================================================
          // WELCOME BANNER
          // ================================================
          _welcomeBanner(),

          const SizedBox(height: 27),

          // ================================================
          // MY EVENT OVERVIEW
          // ================================================
          _sectionHeader(
            title: 'My Event Overview',
            icon: Icons.bar_chart_rounded,
            actionText: 'See all',
            onSeeAll: () => _goToTab(context, 2),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              _statCard(
                label: 'Registered',
                value: registeredCount,
                icon: Icons.event_available_rounded,
                accent: const Color(0xFF2169C9),
                background: paleBlue,
              ),

              const SizedBox(width: 9),

              _statCard(
                label: 'Upcoming',
                value: upcomingCount,
                icon: Icons.access_time_filled_rounded,
                accent: const Color(0xFFD89A00),
                background: paleYellow,
              ),

              const SizedBox(width: 9),

              _statCard(
                label: 'Attended',
                value: attendedCount,
                icon: Icons.check_circle_rounded,
                accent: const Color(0xFF20955C),
                background: paleGreen,
              ),
            ],
          ),

          const SizedBox(height: 27),

          // ================================================
          // MY NEXT REGISTERED EVENT
          // ================================================
          _sectionHeader(
            title: 'My Next Event',
            icon: Icons.calendar_month_rounded,
            onSeeAll: () => _goToTab(context, 2),
          ),

          const SizedBox(height: 10),

          if (nextEvent != null)
            _eventCard(
              context: context,
              event: nextEvent,
              attended: false,
              registered: true,
            )
          else
            _emptyCard(
              icon: Icons.event_busy_outlined,
              message:
                  'You have no upcoming registered events. '
                  'Browse Events to find something new.',
            ),

          const SizedBox(height: 24),

          // ================================================
          // RECENT EVENTS
          // ================================================
          _sectionHeader(
            title: 'Recent Events',
            icon: Icons.history_rounded,
            onSeeAll: () => _goToTab(context, 1),
          ),

          const SizedBox(height: 10),

          if (recentEvents.isEmpty)
            _emptyCard(
              icon: Icons.history_toggle_off_rounded,
              message: 'No recent events to display.',
            )
          else
            ...recentEvents.take(2).map((event) {
              final attended = attendanceStatus[eventKey(event)] == 'Present';

              return _eventCard(
                context: context,
                event: event,
                attended: attended,
              );
            }),

          const SizedBox(height: 16),

          // ================================================
          // LATEST ANNOUNCEMENTS
          // ================================================
          _sectionHeader(
            title: 'Latest Announcements',
            icon: Icons.campaign_rounded,
            onSeeAll: () {
              Navigator.push(context, animatedRoute(const AnnouncementsPage()));
            },
          ),

          const SizedBox(height: 10),

          _announcementCard(context),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
