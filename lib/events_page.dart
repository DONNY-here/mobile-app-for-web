part of 'main.dart';

// ======================================================
// EVENTS PAGE
// ======================================================

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  String searchText = '';

  String selectedScope = 'All Events';
  String selectedDepartment = 'All Departments';

  final List<String> scopeOptions = [
    'All Events',
    'School-Wide',
    'Department-Specific',
  ];

  final List<String> departmentOptions = [
    'All Departments',
    'College of Computer Studies',
    'College of Education',
    'College of Criminal Justice Education',
    'College of Office Administration',
    'College of Arts and Sciences',
  ];

  @override
  Widget build(BuildContext context) {

    final filteredEvents = eventList.where((event) {
      final matchesSearch = event.title
          .toLowerCase()
          .contains(searchText.trim().toLowerCase());

      final matchesScope =
          selectedScope == 'All Events' ||
              event.scope == selectedScope;

      final matchesDepartment =
          selectedDepartment == 'All Departments' ||
              event.department == selectedDepartment;

      return matchesSearch &&
          matchesScope &&
          matchesDepartment;
    }).toList();


    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: borderColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Discover Events',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find activities, workshops, and campus events.',
                  style: TextStyle(color: textGrey, fontSize: 12.5),
                ),
                const SizedBox(height: 14),

                const SizedBox(height: 14),

                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search event by title...',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.tune_rounded, size: 20),
                  ),
                ),

                const SizedBox(height: 14),

// EVENT TYPE FILTER
                DropdownButtonFormField<String>(
                  initialValue: selectedScope,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: scopeOptions.map((scope) {
                    return DropdownMenuItem<String>(
                      value: scope,
                      child: Text(scope),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedScope = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

// DEPARTMENT FILTER
                DropdownButtonFormField<String>(
                  initialValue: selectedDepartment,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Department',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  items: departmentOptions.map((department) {
                    return DropdownMenuItem<String>(
                      value: department,
                      child: Text(
                        department,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                ),

              ],
            ),
          ),
          Expanded(
            child: filteredEvents.isEmpty
                ? const Center(
              child: EmptyState(
                icon: Icons.search_off_rounded,
                title: 'No event found',
                message: 'Try changing your search or event filters.',
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              itemCount: filteredEvents.length,
              separatorBuilder: (_, _) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = filteredEvents[index];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(
                    milliseconds: 280 + (index * 70),
                  ),
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
                  child: ModernEventCard(
                    event: event,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        animatedRoute(
                          EventDetailsPage(event: event),
                        ),
                      );

                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ModernEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const ModernEventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final registered = registeredEvents.contains(event);

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: appGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.event_note_rounded,
                    color: yellow,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (registered) ...[
                            const SizedBox(width: 8),
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      EventMiniInfo(
                        icon: Icons.calendar_today_outlined,
                        text: event.date,
                      ),
                      const SizedBox(height: 4),
                      EventMiniInfo(
                        icon: Icons.schedule_outlined,
                        text: event.time,
                      ),
                      const SizedBox(height: 4),
                      EventMiniInfo(
                        icon: Icons.location_on_outlined,
                        text: event.venue,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: textGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventMiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const EventMiniInfo({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: textGrey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textGrey,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
