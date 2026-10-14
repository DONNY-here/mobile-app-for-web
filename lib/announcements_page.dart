part of 'main.dart';

// ======================================================
// NOTIFICATION CENTER
// Uses shared notification state in config_and_data.dart.
// ======================================================

class _EventEaseNotification {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final String category;
  final Event? event;

  const _EventEaseNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.category,
    this.event,
  });
}

class AnnouncementsPage extends StatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  String _filter = 'All';

  List<_EventEaseNotification> _notifications() {
    final items = <_EventEaseNotification>[
      const _EventEaseNotification(
        id: 'announcement_techtalk',
        title: 'TechTalk Registration Open',
        message: 'Registration for TechTalk 2026 is now open.',
        icon: Icons.campaign_rounded,
        category: 'Announcements',
      ),
      const _EventEaseNotification(
        id: 'announcement_reminder',
        title: 'Event Reminder',
        message: 'Please arrive 15 minutes before your registered event.',
        icon: Icons.alarm_rounded,
        category: 'Announcements',
      ),
      const _EventEaseNotification(
        id: 'announcement_qr',
        title: 'Bring Your QR Code',
        message: 'Your QR code will be used during attendance checking.',
        icon: Icons.qr_code_2_rounded,
        category: 'Announcements',
      ),
    ];

    for (final event in registeredEvents) {
      final key = eventKey(event);
      items.add(_EventEaseNotification(
        id: 'registration_$key',
        title: 'Registration Confirmed',
        message: 'You are registered for ${event.title}.',
        icon: Icons.how_to_reg_rounded,
        category: 'Events',
        event: event,
      ));

      if (attendanceStatus[key] == 'Present') {
        items.add(_EventEaseNotification(
          id: 'attendance_$key',
          title: 'Attendance Confirmed',
          message: 'Your attendance for ${event.title} was recorded.',
          icon: Icons.check_circle_rounded,
          category: 'Events',
          event: event,
        ));

        if ((eventRatings[key] ?? 0) > 0) {
          items.add(_EventEaseNotification(
            id: 'certificate_$key',
            title: 'E-Certificate Available',
            message: 'Your certificate for ${event.title} is ready to view.',
            icon: Icons.workspace_premium_rounded,
            category: 'Certificates',
            event: event,
          ));
        } else {
          items.add(_EventEaseNotification(
            id: 'evaluation_$key',
            title: 'Complete Your Evaluation',
            message: 'Evaluate ${event.title} to unlock your E-Certificate.',
            icon: Icons.rate_review_rounded,
            category: 'Events',
            event: event,
          ));
        }
      }
    }

    return items.reversed.toList();
  }

  Future<void> _openNotification(_EventEaseNotification notification) async {
    markNotificationAsRead(notification.id);
    if (notification.event != null) {
      await Navigator.push(
        context,
        animatedRoute(EventDetailsPage(event: notification.event!)),
      );
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ValueListenableBuilder<Set<String>>(
        valueListenable: readNotificationIds,
        builder: (context, readIds, _) {
          final notifications = _notifications();
          final unread = notifications.where((n) => !readIds.contains(n.id)).length;
          final visible = notifications
              .where((n) => _filter == 'All' || n.category == _filter)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: appGradient,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded,
                        color: yellow, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stay Updated',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 3),
                          Text('$unread unread notification${unread == 1 ? '' : 's'}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text('Recent Updates',
                        style: TextStyle(
                            color: textDark, fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: unread == 0 ? null : markAllNotificationsAsRead,
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Events', 'Certificates', 'Announcements']
                      .map((category) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _filter == category,
                      onSelected: (_) =>
                          setState(() => _filter = category),
                    ),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('No notifications in this category.',
                        style: TextStyle(color: textGrey)),
                  ),
                ),
              ...visible.map((notification) {
                final isUnread = !readIds.contains(notification.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: isUnread ? lightNavy : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _openNotification(notification),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF5D8),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(notification.icon,
                                  color: navy, size: 23),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification.title,
                                      style: const TextStyle(
                                          color: textDark,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Text(notification.message,
                                      style: const TextStyle(
                                          color: textGrey, fontSize: 12.5)),
                                ],
                              ),
                            ),
                            if (isUnread)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: CircleAvatar(
                                    radius: 4, backgroundColor: yellow),
                              )
                            else
                              const Icon(Icons.chevron_right_rounded,
                                  color: textGrey),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
