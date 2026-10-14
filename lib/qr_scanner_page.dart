part of 'main.dart';

// ======================================================
// ATTENDANCE QR SCANNER
// ======================================================

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final QrVerificationService qrVerificationService = QrVerificationService();

  Event? selectedEvent;

  bool get canScanAttendance =>
      savedUserRole == 'scanner' || savedUserRole == 'admin';

  final MobileScannerController scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );

  bool processingScan = false;
  String? lastMessage;
  bool lastScanSuccessful = false;
  Event? lastScannedEvent;

  // Load currently available registrations into the mock service.
  void loadMockRegistrations() {
    for (final event in registeredEvents) {
      final key = eventKey(event);
      final token = qrTokens[key];
      if (token == null || token.isEmpty) continue;

      qrVerificationService.addTestRegistration(
        token: token,
        eventId: key,
        studentName: savedName,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadMockRegistrations();
  }

  Future<void> _resumeScannerAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    processingScan = false;
    try {
      await scannerController.start();
    } catch (_) {
      // The scanner may already be running. Safe to ignore in this local demo.
    }
  }

  Future<void> _handleQrCode(String rawValue) async {
    if (processingScan || !canScanAttendance) return;
    if (selectedEvent == null) return;

    processingScan = true;

    try {
      await scannerController.stop();
    } catch (_) {
      // Scanner may already be stopped.
    }

    if (!mounted) return;

    final event = selectedEvent!;
    final key = eventKey(event);

    // Step 1: Decode student QR credential.
    final token = decodeStudentEventQr(rawValue);

    if (token == null) {
      setState(() {
        lastScanSuccessful = false;
        lastScannedEvent = null;
        lastMessage = 'Invalid student QR code.';
      });

      await _resumeScannerAfterDelay();
      return;
    }

    try {
      // Step 2: Verify through the mock service.
      final result = await qrVerificationService.verifyQr(
        token: token,
        eventId: key,
        eventTitle: event.title,
      );

      if (!mounted) return;

      final now = DateTime.now();

      // Step 3: Handle the verification response.
      setState(() {
        lastScanSuccessful = result.success;
        lastScannedEvent = result.status == 'invalid' ? null : event;
        lastMessage = result.message;

        if (result.status == 'present') {
          // Local student-side simulation only.
          // Real attendance will come from the API.
          if (registeredEvents.contains(event) && qrTokens[key] == token) {
            attendanceStatus[key] = 'Present';
            attendanceCheckInTime[key] =
                result.checkInTime ?? formatCheckInTime(now);
          }
        }

        // Log verified successes and duplicates.
        if (result.status == 'present' || result.status == 'duplicate') {
          scanHistory.insert(
            0,
            ScanHistory(
              eventTitle: result.eventTitle ?? event.title,
              studentName: result.studentName ?? 'Unknown Student',
              scannerName: demoScannerName,
              status: result.status == 'present' ? 'Present' : 'Duplicate',
              scannedAt: now,
            ),
          );
        }
      });

      refreshNotifications();

      // Step 4: Keep successful scans paused until
      // the officer selects Scan Another QR.
      if (result.status == 'present' || result.status == 'duplicate') {
        return;
      }

      // Resume after invalid QR.
      await _resumeScannerAfterDelay();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        lastScanSuccessful = false;
        lastScannedEvent = null;
        lastMessage = 'Unable to verify QR code. Please try again.';
      });

      debugPrint('QR verification error: $error');

      await _resumeScannerAfterDelay();
    }
  }

  Future<void> _scanAgain() async {
    if (!mounted) return;
    setState(() {
      processingScan = false;
      lastMessage = null;
      lastScannedEvent = null;
      lastScanSuccessful = false;
    });
    try {
      await scannerController.start();
    } catch (_) {}
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!canScanAttendance) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Attendance')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: EmptyState(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Authorized Personnel Only',
              message:
                  'QR attendance scanning is available only '
                  'to authorized event personnel.',
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Attendance')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.admin_panel_settings_rounded,
                  color: navy,
                  size: 30,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Authorized Scanner',
                        style: TextStyle(color: textGrey, fontSize: 12),
                      ),

                      Text(
                        demoScannerName,
                        style: const TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF27834A),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<Event>(
            key: ValueKey(selectedEvent),
            initialValue: selectedEvent,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Select Event to Scan',
              prefixIcon: Icon(Icons.event_available_outlined),
            ),
            hint: const Text('Choose an event'),
            items: eventList.map((event) {
              return DropdownMenuItem<Event>(
                value: event,
                child: Text(event.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (event) {
              if (event == null) return;

              setState(() {
                selectedEvent = event;
                lastMessage = null;
                lastScannedEvent = null;
                lastScanSuccessful = false;
              });
            },
          ),

          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: appGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner_rounded, color: yellow, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Student QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Select an event and scan the QR pass presented by a registered student.',
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
          const SizedBox(height: 18),
          Container(
            height: 360,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: scannerController,
                  onDetect: (capture) {
                    if (selectedEvent == null || processingScan) return;
                    if (capture.barcodes.isEmpty) return;

                    final rawValue = capture.barcodes.first.rawValue;

                    if (rawValue == null || rawValue.isEmpty) return;

                    _handleQrCode(rawValue);
                  },
                ),
                Center(
                  child: Container(
                    width: 235,
                    height: 235,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: yellow, width: 3),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Place the QR inside the frame',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (lastMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lastScanSuccessful
                    ? const Color(0xFFE7F6EC)
                    : const Color(0xFFFCE8E8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: lastScanSuccessful
                      ? const Color(0xFFC6EAD2)
                      : const Color(0xFFF0CACA),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        lastScanSuccessful
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        color: lastScanSuccessful
                            ? const Color(0xFF27834A)
                            : const Color(0xFFC94747),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lastMessage!,
                          style: TextStyle(
                            color: lastScanSuccessful
                                ? const Color(0xFF27834A)
                                : const Color(0xFFC94747),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (lastScannedEvent != null) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      lastScannedEvent!.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Check-in: ${attendanceCheckInTime[eventKey(lastScannedEvent!)] ?? 'Recorded'}',
                      style: const TextStyle(color: textGrey),
                    ),
                  ],
                  if (lastScannedEvent != null) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: _scanAgain,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('Scan Another QR'),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 24),

          sectionTitle('Recent Scan History'),

          const SizedBox(height: 12),

          if (scanHistory.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No attendance scans recorded yet.',
                style: TextStyle(color: textGrey),
              ),
            )
          else
            ...scanHistory.take(10).map((record) {
              final isPresent = record.status == 'Present';

              final time = formatCheckInTime(record.scannedAt);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPresent
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: isPresent ? Colors.green : Colors.orange,
                      size: 28,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.studentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),

                          Text(
                            record.eventTitle,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: 12,
                            ),
                          ),

                          Text(
                            '${record.status} • $time',
                            style: TextStyle(
                              color: isPresent ? Colors.green : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 18),

          const SizedBox(height: 8),

          const Text(
            'DEMO MODE: Attendance and scan history are '
            'temporarily stored on this device. '
            'Official attendance verification will be '
            'handled through the web API.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textGrey, fontSize: 11.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}
