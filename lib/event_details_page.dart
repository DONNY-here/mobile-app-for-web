part of 'main.dart';

// ======================================================
// EVENT DETAILS
// ======================================================

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {


  bool get _profileComplete =>
      savedName.trim().isNotEmpty &&
          savedDepartment.trim().isNotEmpty &&
          savedCourse.trim().isNotEmpty &&
          savedYear.trim().isNotEmpty &&
          savedBlock.trim().isNotEmpty;


  bool get _courseEligible =>
      widget.event.allowedCourses.contains(savedCourse);


  bool get _departmentCourseValid {
    final programs =
    TmcDepartments.programs[savedDepartment];

    if (programs == null) return false;

    return programs.contains(savedCourse);
  }

  bool get _departmentEligible {
    // Make sure the student belongs to a valid
    // department and program combination.
    if (!_departmentCourseValid) {
      return false;
    }

    // Events open to multiple departments.
    if (widget.event.scope == 'School-Wide') {
      return true;
    }

    // Department-exclusive events.
    if (widget.event.scope == 'Department-Specific') {
      return widget.event.department == savedDepartment;
    }

    // Reject unrecognized event classifications.
    return false;
  }


  bool get _yearEligible =>
      widget.event.allowedYears.contains(savedYear);

  bool get _blockEligible =>
      widget.event.allowedBlocks.contains(savedBlock);

  bool get _hasAvailableSlot {
    final registered = registeredEvents.contains(widget.event);
    final total = widget.event.currentParticipants + (registered ? 1 : 0);
    return total < widget.event.capacity || registered;
  }



  bool get _eligibleToRegister =>
      _profileComplete &&
          _departmentEligible &&
          _courseEligible &&
          _yearEligible &&
          _blockEligible &&
          _hasAvailableSlot &&
          !_deadlinePassed &&
          widget.event.registrationOpen;



  int get _displayParticipantCount {
    final registered = registeredEvents.contains(widget.event);
    return widget.event.currentParticipants + (registered ? 1 : 0);
  }

  int get _availableSlots =>
      max(0, widget.event.capacity - _displayParticipantCount);

  // Certificate unlocks after attendance and event evaluation.
  bool get _certificateEligible {
    final key = eventKey(widget.event);
    return registeredEvents.contains(widget.event) &&
        attendanceStatus[key] == 'Present' &&
        eventRatings.containsKey(key);
  }


  bool get _deadlinePassed {
    final dateText = widget.event.registrationDeadline
        .replaceAll(',', '')
        .trim();

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

    // Reject invalid calendar dates.
    if (deadline.year != year ||
        deadline.month != month ||
        deadline.day != day) {
      return true;
    }

    // Registration remains open throughout the
    // deadline date in the device's local timezone.
    final closingTime = DateTime(year, month, day + 1);

    return !DateTime.now().isBefore(closingTime);
  }


  Future<void> _openEvaluation() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EvaluationPage(event: widget.event)),
    );
    if (!mounted) return;
    setState(() {}); // Re-check the saved rating after returning.
  }

  void _openCertificate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ECertificateScreen(
          studentName: savedName,
          course: savedCourse,
          yearLevel: savedYear,
          eventTitle: widget.event.title,
          eventDate: widget.event.date,
        ),
      ),
    );
  }

  Future<void> registerEvent() async {
    if (registeredEvents.contains(widget.event)) {
      showMessage(context, 'You are already registered for this event.');
      return;
    }

    if (!_profileComplete) {
      showMessage(
        context,
        'Please complete your profile before registering for an event.',
      );
      return;
    }


    if (!_departmentEligible) {
      showMessage(
        context,
        'Your department or course does not meet '
            'the requirements for this event.',
      );
      return;
    }


    if (!_courseEligible || !_yearEligible || !_blockEligible) {
      showMessage(
        context,
        'Your course, year level, or block is not eligible for this event.',
      );
      return;
    }

    if (!_hasAvailableSlot) {
      showMessage(context, 'Registration is full for this event.');
      return;
    }

    if (!widget.event.registrationOpen) {
      showMessage(context, 'Registration for this event is closed.');
      return;
    }


    if (_deadlinePassed) {
      showMessage(
        context,
        'The registration deadline for this event has passed.',
      );
      return;
    }


    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.verified_user_rounded, color: navy, size: 38),
          title: const Text('Confirm Event Registration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _confirmationLine('Event', widget.event.title),
              _confirmationLine(
                'Student',
                savedName.isEmpty ? 'Not provided' : savedName,
              ),
              _confirmationLine('Department', savedDepartment),
              _confirmationLine('Course', savedCourse),
              _confirmationLine('Year Level', savedYear),
              _confirmationLine('Block', savedBlock),
              const SizedBox(height: 14),
              const Text(
                'By continuing, you confirm that you want to participate in this event.',
                style: TextStyle(color: textGrey, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Confirm Registration'),
            ),
          ],
        );
      },
    );


    if (confirm != true || !mounted) return;

    // Check registration requirements again.
    if (registeredEvents.contains(widget.event)) {
      showMessage(
        context,
        'You are already registered for this event.',
      );
      return;
    }

    if (!_eligibleToRegister) {
      showMessage(
        context,
        'Registration requirements are no longer satisfied.',
      );
      return;
    }

    final key = eventKey(widget.event);

    setState(() {
      registeredEvents.add(widget.event);
      attendanceStatus[key] = 'Not Recorded';
      attendanceCheckInTime.remove(key);

      // Create QR credential for this registration.
      qrTokens[key] = createLocalQrToken();
    });



    showMessage(
      context,
      'Registration confirmed successfully!',
    );
  } // IMPORTANT: Closes registerEvent()

Widget _confirmationLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _participantInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: navy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _verificationRow({
    required String label,
    required String value,
    required bool passed,
  }) {
    final statusColor = passed
        ? const Color(0xFF27834A)
        : const Color(0xFFC94747);
    final background = passed
        ? const Color(0xFFE7F6EC)
        : const Color(0xFFFCE8E8);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: statusColor,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registered = registeredEvents.contains(widget.event);
    final verified = registered || _eligibleToRegister;

    final courseText =
        widget.event.allowedCourses.length == courseOptions.length
        ? 'All Courses'
        : widget.event.allowedCourses.join(', ');

    final yearText = widget.event.allowedYears.length == allYearLevels.length
        ? '1st Year - 4th Year'
        : widget.event.allowedYears.join(', ');

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1),
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                height: 200,
                width: double.infinity,
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
                child: Stack(
                  children: [
                    Positioned(
                      right: -35,
                      top: -45,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    const Center(
                      child: Icon(
                        Icons.event_available_rounded,
                        color: yellow,
                        size: 82,
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          'TMC CAMPUS EVENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              widget.event.title,
              style: const TextStyle(
                color: textDark,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  EventInformation(
                    icon: Icons.category_outlined,
                    label: 'Event Type',
                    text: widget.event.scope,
                  ),

                  const Divider(height: 24),

                  EventInformation(
                    icon: Icons.account_balance_outlined,
                    label: 'Department',
                    text: widget.event.department,
                  ),

                  const Divider(height: 24),

                  EventInformation(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date',
                    text: widget.event.date,
                  ),
                  const Divider(height: 24),
                  EventInformation(
                    icon: Icons.access_time_rounded,
                    label: 'Time',
                    text: widget.event.time,
                  ),
                  const Divider(height: 24),
                  EventInformation(
                    icon: Icons.location_on_rounded,
                    label: 'Venue',
                    text: widget.event.venue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            sectionTitle('About the Event'),
            const SizedBox(height: 10),
            Text(
              widget.event.description,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.55,
                color: textGrey,
              ),
            ),
            const SizedBox(height: 28),

            // --------------------------------------------------
            // WHO CAN JOIN
            // --------------------------------------------------
            sectionTitle('Who Can Join'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _participantInfoRow(
                    icon: Icons.groups_2_outlined,
                    label: 'Eligible Participants',
                    value: widget.event.eligibleParticipants,
                  ),
                  const Divider(height: 16),
                  _participantInfoRow(
                    icon: Icons.school_outlined,
                    label: 'Allowed Courses',
                    value: courseText,
                  ),
                  const Divider(height: 16),
                  _participantInfoRow(
                    icon: Icons.calendar_month_outlined,
                    label: 'Year Level',
                    value: yearText,
                  ),
                  const Divider(height: 16),
                  _participantInfoRow(
                    icon: Icons.people_alt_outlined,
                    label: 'Available Slots',
                    value:
                        '$_availableSlots available out of ${widget.event.capacity} slots',
                  ),
                  const Divider(height: 16),
                  _participantInfoRow(
                    icon: Icons.event_busy_outlined,
                    label: 'Registration Deadline',
                    value: widget.event.registrationDeadline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // --------------------------------------------------
            // VERIFICATION
            // --------------------------------------------------
            sectionTitle('Registration Verification'),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _verificationRow(
                    label: 'Profile Information',
                    value: _profileComplete
                        ? 'Student profile is complete'
                        : 'Complete your profile first',
                    passed: _profileComplete,
                  ),

                  _verificationRow(
                    label: 'Department Eligibility',
                    value: _departmentEligible
                        ? '$savedDepartment is eligible'
                        : 'Your department or program is not eligible',
                    passed: _departmentEligible,
                  ),

                  _verificationRow(
                    label: 'Course Eligibility',
                    value: _courseEligible
                        ? '$savedCourse is allowed'
                        : '${savedCourse.isEmpty ? 'No course selected' : savedCourse} is not allowed',
                    passed: _courseEligible,
                  ),
                  _verificationRow(
                    label: 'Year Level Eligibility',
                    value: _yearEligible
                        ? '$savedYear is allowed'
                        : '${savedYear.isEmpty ? 'No year level selected' : savedYear} is not allowed',
                    passed: _yearEligible,
                  ),
                  _verificationRow(
                    label: 'Registration Availability',
                    value: _hasAvailableSlot
                        ? 'Slots are still available'
                        : 'Registration is already full',
                    passed: _hasAvailableSlot,
                  ),
                  _verificationRow(
                    label: 'Registration Status',
                    value: registered
                        ? 'Registration confirmed'
                        : widget.event.registrationOpen
                        ? 'Registration is open'
                        : 'Registration is closed',
                    passed: registered || widget.event.registrationOpen,
                  ),


                  _verificationRow(
                    label: 'Registration Deadline',
                    value: _deadlinePassed
                        ? 'Registration deadline has passed'
                        : 'Within the registration period',
                    passed: !_deadlinePassed,
                  ),


                  _verificationRow(
                    label: 'Block Eligibility',
                    value: _blockEligible
                        ? '$savedBlock is allowed'
                        : 'Your block is not eligible for this event',
                    passed: _blockEligible,
                  ),




                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: verified
                          ? const Color(0xFFE7F6EC)
                          : const Color(0xFFFCE8E8),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          verified
                              ? Icons.verified_rounded
                              : Icons.gpp_bad_rounded,
                          color: verified
                              ? const Color(0xFF27834A)
                              : const Color(0xFFC94747),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            registered
                                ? 'REGISTRATION CONFIRMED'
                                : verified
                                ? 'ELIGIBLE TO JOIN'
                                : 'NOT ELIGIBLE TO JOIN',
                            style: TextStyle(
                              color: verified
                                  ? const Color(0xFF27834A)
                                  : const Color(0xFFC94747),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --------------------------------------------------
            // REGISTRATION ACTION
            // --------------------------------------------------
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: registered
                  ? Container(
                      key: const ValueKey('registered'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F6EC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFC6EAD2)),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF27834A),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Registration Confirmed',
                                style: TextStyle(
                                  color: Color(0xFF27834A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$savedName • $savedCourse • $savedYear',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton.icon(
                      key: const ValueKey('register'),
                      onPressed: _eligibleToRegister ? registerEvent : null,
                      icon: Icon(
                        _eligibleToRegister
                            ? Icons.how_to_reg_rounded
                            : Icons.block_rounded,
                      ),
                      label: Text(
                        _eligibleToRegister
                            ? 'Confirm Registration'
                            : 'Not Eligible to Register',
                      ),
                    ),
            ),
            if (registered) ...[
              const SizedBox(height: 22),
              sectionTitle('E-Certificate'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _certificateEligible
                          ? 'Your certificate is ready to view.'
                          : 'Your certificate will unlock when your attendance is marked Present and your event evaluation is completed.',
                      style: const TextStyle(color: textGrey, height: 1.4),
                    ),
                    if (attendanceStatus[eventKey(widget.event)] ==
                        'Present') ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _openEvaluation,
                        icon: Icon(
                          eventRatings.containsKey(eventKey(widget.event))
                              ? Icons.edit_note_rounded
                              : Icons.rate_review_outlined,
                        ),
                        label: Text(
                          eventRatings.containsKey(eventKey(widget.event))
                              ? 'Edit Event Evaluation'
                              : 'Complete Event Evaluation',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _certificateEligible ? _openCertificate : null,
                      icon: Icon(
                        _certificateEligible
                            ? Icons.workspace_premium_rounded
                            : Icons.lock_outline_rounded,
                      ),
                      label: Text(
                        _certificateEligible
                            ? 'View E-Certificate'
                            : 'E-Certificate Locked',
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!registered && !_eligibleToRegister) ...[
              const SizedBox(height: 10),
              const Text(
                'Your profile must meet the event requirements before you can register.',
                textAlign: TextAlign.center,
                style: TextStyle(color: textGrey, fontSize: 12, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
