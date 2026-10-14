
part of 'main.dart';

class StudentQrPassPage extends StatelessWidget {
  final Event event;

  const StudentQrPassPage({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final key = eventKey(event);
    final registered = registeredEvents.contains(event);
    final token = qrTokens[key];

    // Never create a new token just by opening the page.
    if (!registered || token == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Student QR Pass'),
        ),
        body: const Center(
          child: Text(
            'No active QR pass is available '
                'for this event.',
          ),
        ),
      );
    }

    final qrData = '$studentQrPrefix$token';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student QR Pass'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: Container(
            constraints:
            const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(24),
              border:
              Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.school_rounded,
                  color: navy,
                  size: 40,
                ),

                const SizedBox(height: 10),

                const Text(
                  'TMC EVENTEASE',
                  style: TextStyle(
                    color: navy,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const Text(
                  'STUDENT EVENT PASS',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 22),

                Container(
                  padding: const EdgeInsets.all(15),
                  color: Colors.white,
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 230,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Present this QR code to '
                      'authorized event personnel.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 24),

                const Divider(),

                _info('Student', savedName),
                _info('Department', savedDepartment),
                _info('Course', savedCourse),
                _info('Year Level', savedYear),
                _info('Event', event.title),
                _info('Date', event.date),

                const SizedBox(height: 12),

                const Chip(
                  label: Text('Registration Confirmed'),
                  backgroundColor: Color(0xFFE7F6EC),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 12,
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
}
