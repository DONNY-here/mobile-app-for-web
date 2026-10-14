part of 'main.dart';

// ======================================================
// EVENT EVALUATION
// ======================================================

class EvaluationPage extends StatefulWidget {
  final Event event;

  const EvaluationPage({
    super.key,
    required this.event,
  });

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  int rating = 0;
  final commentController = TextEditingController();


  bool get canEvaluate {
    final key = eventKey(widget.event);

    final isRegistered =
    registeredEvents.contains(widget.event);

    final isPresent =
        attendanceStatus[key] == 'Present';

    return isRegistered && isPresent;
  }


  @override
  void initState() {
    super.initState();
    rating = eventRatings[eventKey(widget.event)] ?? 0;
    commentController.text = eventComments[eventKey(widget.event)] ?? '';
  }


  void submitEvaluation() {
    // Check registration and attendance.
    if (!canEvaluate) {
      showMessage(
        context,
        'You must have verified attendance '
            'before submitting an evaluation.',
      );
      return;
    }

    if (rating < 1 || rating > 5) {
      showMessage(
        context,
        'Please select a rating from 1 to 5.',
      );
      return;
    }

    final key = eventKey(widget.event);

    // Save evaluation in temporary local data.
    eventRatings[key] = rating;
    eventComments[key] = commentController.text.trim();

    showMessage(
      context,
      'Evaluation submitted successfully!',
    );

    Navigator.pop(context, true);
  }


  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Evaluation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: appGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: yellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.event.date} • ${widget.event.venue}',
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  const Text(
                    'How was the event?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap a star to rate your experience.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textGrey),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      final selected = star <= rating;

                      return GestureDetector(
                        onTap: canEvaluate
                            ? () {
                          setState(() {
                            rating = star;
                          });
                        }
                            : null,
                        child: AnimatedScale(
                          scale: selected ? 1.1 : 1,
                          duration: const Duration(milliseconds: 170),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              selected
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              size: 42,
                              color: yellow,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      key: ValueKey(rating),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: lightNavy,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rating == 0
                            ? 'No rating selected'
                            : '$rating out of 5',
                        style: const TextStyle(
                          color: navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            sectionTitle('Comment / Suggestion'),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              readOnly: !canEvaluate,
              maxLines: 5,
              maxLength: 300,
              decoration: const InputDecoration(
                hintText: 'Write your feedback here...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 90),
                  child: Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
            ),
            const SizedBox(height: 16),


            if (!canEvaluate) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You must be registered and have verified '
                            'attendance before evaluating this event.',
                        style: TextStyle(
                          fontSize: 12,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],


            ElevatedButton.icon(
              onPressed: canEvaluate ? submitEvaluation : null,
              icon: Icon(
                canEvaluate
                    ? Icons.send_rounded
                    : Icons.lock_outline_rounded,
              ),
              label: Text(
                canEvaluate
                    ? 'Submit Evaluation'
                    : 'Evaluation Locked',
              ),
            ),

          ],
        ),
      ),
    );
  }
}
