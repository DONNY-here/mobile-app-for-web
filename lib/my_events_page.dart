part of 'main.dart';

// ======================================================
// MY REGISTERED EVENTS
// ======================================================

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {

  // TEMPORARY: Used for testing before API integration.
  // Remove this function before production deployment.

  void simulateAttendance(Event event, String status) {
    final key = eventKey(event);

    setState(() {
      attendanceStatus[key] = status;

      if (status == 'Present') {
        final now = DateTime.now();

        // Convert DateTime to String
        attendanceCheckInTime[key] =
        '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}';
      } else {
        attendanceCheckInTime.remove(key);
      }
    });

    showMessage(
      context,
      'TEST MODE: Attendance changed to $status',
    );
  }



  // Check whether the registration deadline has passed.
  bool deadlinePassed(Event event) {
    final dateText =
    event.registrationDeadline.replaceAll(',', '').trim();

    final parts = dateText.split(RegExp(r'\s+'));

    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };

    if (parts.length != 3) return true;

    final month = months[parts[0]];
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);

    if (month == null || day == null || year == null) {
      return true;
    }

    final deadline = DateTime(year, month, day);

    if (deadline.year != year ||
        deadline.month != month ||
        deadline.day != day) {
      return true;
    }

    // Cancellation is permitted until the end
    // of the registration deadline date.
    final closingTime = DateTime(year, month, day + 1);

    return !DateTime.now().isBefore(closingTime);
  }

  // Check whether a student has already attended.
  bool attendanceRecorded(Event event) {
    final key = eventKey(event);
    final status = attendanceStatus[key] ?? 'Not Recorded';

    return status != 'Not Recorded';
  }

  bool canCancel(Event event) {
    return registeredEvents.contains(event) &&
        !deadlinePassed(event) &&
        !attendanceRecorded(event);
  }


  Future<void> cancelRegistration(Event event) async {
    if (!registeredEvents.contains(event)) {
      showMessage(context, 'No active registration found.');
      return;
    }

    if (deadlinePassed(event)) {
      showMessage(
        context,
        'Cancellation is no longer allowed after the deadline.',
      );
      return;
    }

    if (attendanceRecorded(event)) {
      showMessage(
        context,
        'You cannot cancel because attendance has been recorded.',
      );
      return;
    }

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
            'Are you sure you want to cancel your '
                'registration for ${event.title}?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    // Check again after the confirmation dialog.
    if (!canCancel(event)) {
      showMessage(
        context,
        'This registration can no longer be cancelled.',
      );
      return;
    }

    final key = eventKey(event);

    setState(() {
      registeredEvents.remove(event);

      // Clear active registration information.
      attendanceStatus.remove(key);
      qrTokens.remove(key);
      attendanceCheckInTime.remove(key);
    });

    showMessage(
      context,
      'Your registration has been cancelled successfully.',
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: registeredEvents.isEmpty
            ? const Center(
          key: ValueKey('empty'),
          child: EmptyState(
            icon: Icons.event_busy_rounded,
            title: 'No registered events yet',
            message: 'Register for an event and it will appear here.',
          ),
        )
            : ListView.separated(
          key: const ValueKey('events'),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          itemCount: registeredEvents.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.045),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            gradient: appGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.confirmation_num_rounded,
                            color: yellow,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: const TextStyle(
                                        color: textDark,
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE7F6EC),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Registered',
                                      style: TextStyle(
                                        color: Color(0xFF27834A),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${event.date} • ${event.venue}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),


// TEMPORARY ATTENDANCE TESTING CONTROL
// Remove after evaluation testing.
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFE082),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DEVELOPER TEST MODE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            key: ValueKey(
                              'attendance_${eventKey(event)}_'
                                  '${attendanceStatus[eventKey(event)]}',
                            ),
                            initialValue:
                            attendanceStatus[eventKey(event)] == 'Present' ||
                                attendanceStatus[eventKey(event)] == 'Absent'
                                ? attendanceStatus[eventKey(event)]
                                : 'Not Recorded',
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Simulate Attendance',
                              prefixIcon: Icon(Icons.fact_check_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Not Recorded',
                                child: Text('Not Recorded'),
                              ),
                              DropdownMenuItem(
                                value: 'Present',
                                child: Text('Present'),
                              ),
                              DropdownMenuItem(
                                value: 'Absent',
                                child: Text('Absent'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              simulateAttendance(event, value);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),


                    ElevatedButton.icon(
                      onPressed: attendanceStatus[eventKey(event)] == 'Present'
                          ? () async {
                        await Navigator.push(
                          context,
                          animatedRoute(
                            EvaluationPage(event: event),
                          ),
                        );

                        if (!mounted) return;

                        setState(() {});
                      }
                          : null,
                      icon: Icon(
                        attendanceStatus[eventKey(event)] == 'Present'
                            ? Icons.star_rounded
                            : Icons.lock_outline_rounded,
                      ),
                      label: Text(
                        attendanceStatus[eventKey(event)] == 'Present'
                            ? 'Evaluate Event'
                            : 'Evaluation Locked',
                      ),
                    ),

                    if (attendanceStatus[eventKey(event)] != 'Present') ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Event evaluation will be available after '
                            'your attendance has been verified.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 11.5,
                        ),
                      ),
                    ],


                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          animatedRoute(
                            StudentQrPassPage(event: event),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_rounded),
                      label: const Text('View QR Pass'),
                    ),

                    const SizedBox(height: 10),



                    const SizedBox(height: 10),

                    OutlinedButton.icon(
                      onPressed: canCancel(event)
                          ? () => cancelRegistration(event)
                          : null,
                      icon: Icon(
                        canCancel(event)
                            ? Icons.cancel_outlined
                            : Icons.lock_outline_rounded,
                      ),
                      label: Text(
                        canCancel(event)
                            ? 'Cancel Registration'
                            : 'Cancellation Unavailable',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        disabledForegroundColor: Colors.grey,
                        side: BorderSide(
                          color: canCancel(event)
                              ? const Color(0xFFF0CACA)
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),

                    if (!canCancel(event)) ...[
                      const SizedBox(height: 8),

                      Text(
                        deadlinePassed(event)
                            ? 'Cancellation deadline has passed.'
                            : attendanceRecorded(event)
                            ? 'Cancellation is unavailable because attendance '
                            'has already been recorded.'
                            : 'Cancellation is currently unavailable.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 11.5,
                        ),
                      ),
                    ],

                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
