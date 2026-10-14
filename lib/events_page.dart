part of 'main.dart';

// ======================================================
// TMC EVENTEASE - ENHANCED EVENTS PAGE
// ======================================================

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';
  String selectedScope = 'All Events';
  String selectedDepartment = 'All Departments';

  bool showFilters = true;

  static const Color darkBlue = Color(0xFF0D3062);
  static const Color mediumBlue = Color(0xFF194E91);
  static const Color softBlue = Color(0xFFEAF2FB);
  static const Color softYellow = Color(0xFFFFF3CF);

  // ====================================================
  // FILTER OPTIONS
  // ====================================================

  final List<String> scopeOptions = const [
    'All Events',
    'School-Wide',
    'Department-Specific',
  ];

  List<String> get departmentOptions {
    final departments =
        eventList
            .where(
              (event) => event.scope.toLowerCase() == 'department-specific',
            )
            .map((event) => event.department.trim())
            .where(
              (department) =>
                  department.isNotEmpty && department != 'All Departments',
            )
            .toSet()
            .toList()
          ..sort();

    return ['All Departments', ...departments];
  }

  // ====================================================
  // SEARCH AND FILTER EVENTS
  // ====================================================

  List<Event> get filteredEvents {
    return eventList.where((event) {
      final matchesSearch = event.title.toLowerCase().contains(
        searchText.toLowerCase(),
      );

      final matchesScope =
          selectedScope == 'All Events' || event.scope == selectedScope;

      final matchesDepartment =
          selectedDepartment == 'All Departments' ||
          event.department == selectedDepartment;

      return matchesSearch && matchesScope && matchesDepartment;
    }).toList();
  }

  void clearFilters() {
    searchController.clear();

    setState(() {
      searchText = '';
      selectedScope = 'All Events';
      selectedDepartment = 'All Departments';
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ====================================================
  // PAGE HEADER
  // ====================================================

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkBlue, mediumBlue, darkBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),

      child: Stack(
        children: [
          // Decorative blue circle
          Positioned(
            right: -80,
            top: -75,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.035),
              ),
            ),
          ),

          // Decorative yellow accent
          Positioned(
            right: -55,
            bottom: -70,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: yellow,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.event_note_rounded,
                        color: yellow,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                          children: [
                            TextSpan(
                              text: 'TMC ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'EventEase',
                              style: TextStyle(color: yellow),
                            ),
                          ],
                        ),
                      ),
                    ),

                    IconButton(
                      tooltip: 'Announcements',
                      onPressed: () {
                        Navigator.push(
                          context,
                          animatedRoute(const AnnouncementsPage()),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                const Text(
                  'Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // SEARCH FIELD
  // ====================================================

  Widget buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: TextField(
        controller: searchController,

        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },

        decoration: InputDecoration(
          hintText: 'Search event by title...',
          hintStyle: const TextStyle(color: textGrey, fontSize: 14),

          prefixIcon: const Icon(
            Icons.search_rounded,
            color: textGrey,
            size: 25,
          ),

          suffixIcon: IconButton(
            tooltip: 'Show or hide filters',
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
            icon: Icon(
              Icons.tune_rounded,
              color: showFilters ? navy : textGrey,
            ),
          ),

          filled: true,
          fillColor: Colors.white,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 18,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: const BorderSide(color: Colors.transparent),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: const BorderSide(color: navy, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ====================================================
  // EVENT TYPE FILTER
  // ====================================================

  Widget buildScopeFilter() {
    return DropdownButtonFormField<String>(
      key: ValueKey('scope-$selectedScope'),
      initialValue: selectedScope,
      isExpanded: true,

      decoration: InputDecoration(
        labelText: 'Event Type',
        prefixIcon: const Icon(
          Icons.category_outlined,
          color: textGrey,
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 15),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: borderColor),
        ),
      ),

      items: scopeOptions.map((scope) {
        return DropdownMenuItem<String>(
          value: scope,
          child: Text(
            scope,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12,
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedScope = value;
        });
      },
    );
  }

  // ====================================================
  // DEPARTMENT FILTER
  // ====================================================

  Widget buildDepartmentFilter() {
    return DropdownButtonFormField<String>(
      key: ValueKey('department-$selectedDepartment'),
      initialValue: selectedDepartment,
      isExpanded: true,

      decoration: InputDecoration(
        labelText: 'Department',
        prefixIcon: const Icon(
          Icons.account_balance_outlined,
          color: textGrey,
          size: 20,
        ),

        filled: true,
        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 15),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(17)),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: borderColor),
        ),
      ),

      items: departmentOptions.map((department) {
        return DropdownMenuItem<String>(
          value: department,
          child: Text(
            department,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),

      onChanged: (value) {
        if (value == null) return;

        setState(() {
          selectedDepartment = value;
        });
      },
    );
  }

  // ====================================================
  // FILTER SECTION
  // ====================================================

  Widget buildFilters() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Side-by-side when there is enough space.
        if (constraints.maxWidth >= 350) {
          return Row(
            children: [
              Expanded(child: buildScopeFilter()),

              const SizedBox(width: 10),

              Expanded(child: buildDepartmentFilter()),
            ],
          );
        }

        // Stacked filters on smaller screens.
        return Column(
          children: [
            buildScopeFilter(),
            const SizedBox(height: 11),
            buildDepartmentFilter(),
          ],
        );
      },
    );
  }

  // ====================================================
  // EVENT ICON
  // ====================================================

  IconData eventIcon(Event event) {
    final title = event.title.toLowerCase();

    if (title.contains('esport') || title.contains('gaming')) {
      return Icons.sports_esports_rounded;
    }

    if (title.contains('web') ||
        title.contains('programming') ||
        title.contains('coding')) {
      return Icons.code_rounded;
    }

    if (title.contains('leadership')) {
      return Icons.groups_rounded;
    }

    if (title.contains('sports')) {
      return Icons.emoji_events_rounded;
    }

    return Icons.event_note_rounded;
  }

  // ====================================================
  // EVENT INFORMATION ROW
  // ====================================================

  Widget eventInfo({required IconData icon, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),

      child: Row(
        children: [
          Icon(icon, size: 15, color: textGrey),

          const SizedBox(width: 7),

          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: textGrey),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // ENHANCED EVENT CARD
  // ====================================================

  Widget buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: navy.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(23),

        child: InkWell(
          borderRadius: BorderRadius.circular(23),

          onTap: () {
            Navigator.push(
              context,
              animatedRoute(EventDetailsPage(event: event)),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(13),

            child: Row(
              children: [
                // ====================================
                // EVENT ICON TILE
                // ====================================
                Container(
                  width: 82,
                  height: 105,
                  clipBehavior: Clip.antiAlias,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [darkBlue, mediumBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(19),
                  ),

                  child: Stack(
                    children: [
                      Positioned(
                        left: -25,
                        bottom: -38,
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: yellow,
                          ),
                        ),
                      ),

                      Center(
                        child: Icon(eventIcon(event), color: yellow, size: 37),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 13),

                // ====================================
                // EVENT DETAILS
                // ====================================
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

                      const SizedBox(height: 8),

                      eventInfo(
                        icon: Icons.calendar_today_outlined,
                        value: event.date,
                      ),

                      eventInfo(
                        icon: Icons.access_time_rounded,
                        value: event.time,
                      ),

                      eventInfo(
                        icon: Icons.location_on_outlined,
                        value: event.venue,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // ====================================
                // ARROW INDICATOR
                // ====================================
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: softYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: navy,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================
  // EMPTY RESULTS
  // ====================================================

  Widget buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 38),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),

      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: softBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_busy_outlined, color: navy, size: 43),
          ),

          const SizedBox(height: 15),

          const Text(
            'No Events Found',
            style: TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Try adjusting your search or '
            'selecting different filters.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textGrey, fontSize: 13, height: 1.5),
          ),

          const SizedBox(height: 13),

          TextButton.icon(
            onPressed: clearFilters,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // MAIN EVENTS PAGE UI
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final events = filteredEvents;

    return Scaffold(
      backgroundColor: lightBg,

      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [
            // ==========================================
            // BLUE HEADER
            // ==========================================
            buildHeader(),

            // ==========================================
            // DISCOVER EVENTS INTRO
            // ==========================================
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 25, 19, 16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Discover Events',
                    style: TextStyle(
                      color: textDark,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Find activities, workshops, '
                    'and campus events.',
                    style: TextStyle(fontSize: 13, color: textGrey),
                  ),

                  const SizedBox(height: 22),

                  // ==================================
                  // SEARCH FIELD
                  // ==================================
                  buildSearchField(),

                  // ==================================
                  // FILTERS
                  // ==================================
                  if (showFilters) ...[
                    const SizedBox(height: 15),
                    buildFilters(),
                  ],
                ],
              ),
            ),

            // ==========================================
            // EVENT RESULTS
            // ==========================================
            Container(
              padding: const EdgeInsets.fromLTRB(19, 21, 19, 28),

              decoration: const BoxDecoration(
                color: lightBg,
                border: Border(top: BorderSide(color: borderColor)),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),

                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_available_rounded,
                          color: navy,
                          size: 20,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          '${events.length} '
                          '${events.length == 1 ? 'Event' : 'Events'} Found',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (events.isEmpty)
                    buildEmptyState()
                  else
                    ...events.map((event) => buildEventCard(event)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
