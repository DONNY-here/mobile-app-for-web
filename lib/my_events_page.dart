part of 'main.dart';

// ======================================================
// MY REGISTERED EVENTS - ENHANCED UI
// ======================================================

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  Future<void> cancelRegistration(Event event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 34,
          ),
          title: const Text('Cancel registration?'),
          content: Text(
            'Are you sure you want to cancel your registration for ${event.title}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final key = eventKey(event);

    setState(() {
      registeredEvents.remove(event);
      attendanceStatus.remove(key);
      eventRatings.remove(key);
      eventComments.remove(key);
      qrTokens.remove(key);
      attendanceCheckInTime.remove(key);
    });

    if (!mounted) return;
    showMessage(context, 'Registration cancelled.');
  }

  IconData _eventIcon(Event event) {
    final title = event.title.toLowerCase();

    if (title.contains('leadership')) {
      return Icons.groups_rounded;
    } else if (title.contains('workshop') || title.contains('web')) {
      return Icons.code_rounded;
    } else if (title.contains('esport')) {
      return Icons.sports_esports_rounded;
    } else if (title.contains('programming')) {
      return Icons.terminal_rounded;
    }

    return Icons.confirmation_num_rounded;
  }

  Color _attendanceColor(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFF27834A);
      case 'Absent':
        return Colors.red;
      default:
        return textGrey;
    }
  }

  Color _attendanceBg(String status) {
    switch (status) {
      case 'Present':
        return const Color(0xFFEAF7EE);
      case 'Absent':
        return const Color(0xFFFFECEC);
      default:
        return const Color(0xFFF4F6F9);
    }
  }

  String _attendanceLabel(String status, String? time) {
    if (status == 'Present' && time != null && time.isNotEmpty) {
      return 'Present • $time';
    }
    if (status == 'Absent' && time != null && time.isNotEmpty) {
      return 'Absent • $time';
    }
    return status;
  }

  Widget _sectionHeader() {
    final presentCount = registeredEvents.where((event) {
      final key = eventKey(event);
      return attendanceStatus[key] == 'Present';
    }).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: const BoxDecoration(
        gradient: appGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Events',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage your registrations, attendance, and evaluation status.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  icon: Icons.confirmation_num_rounded,
                  label: 'Registered',
                  value: '${registeredEvents.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryCard(
                  icon: Icons.verified_rounded,
                  label: 'Present',
                  value: '$presentCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: yellow),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _developerTestMode(Event event, String key) {
    final currentStatus = attendanceStatus[key] ?? 'Not Recorded';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAEC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF3D36B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science_outlined, color: Color(0xFFE38A00), size: 18),
              SizedBox(width: 6),
              Text(
                'DEVELOPER TEST MODE',
                style: TextStyle(
                  color: Color(0xFFE38A00),
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: currentStatus,
            decoration: const InputDecoration(
              labelText: 'Simulate Attendance',
              prefixIcon: Icon(Icons.fact_check_outlined),
            ),
            items: const [
              DropdownMenuItem(
                value: 'Not Recorded',
                child: Text('Not Recorded'),
              ),
              DropdownMenuItem(value: 'Present', child: Text('Present')),
              DropdownMenuItem(value: 'Absent', child: Text('Absent')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                if (value == 'Not Recorded') {
                  attendanceStatus.remove(key);
                  attendanceCheckInTime.remove(key);
                } else {
                  attendanceStatus[key] = value;
                  attendanceCheckInTime[key] = formatCheckInTime(
                    DateTime.now(),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    bool outlined = false,
    Color? foregroundColor,
    Color? borderColorOverride,
  }) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor ?? navy,
          side: BorderSide(color: borderColorOverride ?? borderColor),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildEventCard(Event event) {
    final key = eventKey(event);
    final status = attendanceStatus[key] ?? 'Not Recorded';
    final checkInTime = attendanceCheckInTime[key];
    final canEvaluate = status == 'Present';
    final canCancel = status != 'Present';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP INFO
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  gradient: appGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(_eventIcon(event), color: yellow, size: 30),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 16.8,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${event.date} • ${event.venue}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Registered',
                  style: TextStyle(
                    color: Color(0xFF27834A),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ATTENDANCE STATUS CHIP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: _attendanceBg(status),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _attendanceBg(status)),
            ),
            child: Row(
              children: [
                Icon(
                  status == 'Present'
                      ? Icons.verified_rounded
                      : status == 'Absent'
                      ? Icons.cancel_rounded
                      : Icons.schedule_rounded,
                  size: 18,
                  color: _attendanceColor(status),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _attendanceLabel(status, checkInTime),
                    style: TextStyle(
                      color: _attendanceColor(status),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // DEVELOPER TEST MODE
          _developerTestMode(event, key),

          const SizedBox(height: 16),

          // ACTION BUTTONS
          _actionButton(
            onPressed: canEvaluate
                ? () {
                    Navigator.push(
                      context,
                      animatedRoute(EvaluationPage(event: event)),
                    );
                  }
                : null,
            icon: canEvaluate ? Icons.star_rounded : Icons.lock_outline_rounded,
            label: canEvaluate ? 'Evaluate Event' : 'Evaluation Locked',
          ),

          const SizedBox(height: 10),

          _actionButton(
            onPressed: () {
              Navigator.push(
                context,
                animatedRoute(StudentQrPassPage(event: event)),
              );
            },
            icon: Icons.qr_code_2_rounded,
            label: 'View QR Pass',
          ),

          const SizedBox(height: 10),

          if (canCancel)
            _actionButton(
              onPressed: () => cancelRegistration(event),
              icon: Icons.cancel_outlined,
              label: 'Cancel Registration',
              outlined: true,
              foregroundColor: Colors.red,
              borderColorOverride: const Color(0xFFF1CFCF),
            )
          else
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('Cancellation Unavailable'),
              style: OutlinedButton.styleFrom(
                foregroundColor: textGrey,
                side: const BorderSide(color: borderColor),
              ),
            ),

          const SizedBox(height: 8),

          Text(
            canCancel
                ? 'You may cancel while attendance has not yet been recorded.'
                : 'Cancellation is unavailable because attendance has already been recorded.',
            style: const TextStyle(
              color: textGrey,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _sectionHeader(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: registeredEvents.isEmpty
                  ? const Center(
                      key: ValueKey('empty'),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: EmptyState(
                          icon: Icons.event_busy_rounded,
                          title: 'No registered events yet',
                          message:
                              'Register for an event and it will appear here.',
                        ),
                      ),
                    )
                  : ListView.separated(
                      key: const ValueKey('events'),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
                      itemCount: registeredEvents.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final event = registeredEvents[index];

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 300 + index * 70),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 14 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: _buildEventCard(event),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
