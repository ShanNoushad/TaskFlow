import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'date_selector.dart';

class TodayTask extends StatefulWidget {
  const TodayTask({super.key});

  @override
  State<TodayTask> createState() => _TodayTaskState();
}

class _TodayTaskState extends State<TodayTask> {
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Stream<QuerySnapshot> _buildStream(String userId) {
    final date = _dateOnly(selectedDate);
    return FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("projects")
        .orderBy("startDate")
        .where("startDate",
        isLessThanOrEqualTo: Timestamp.fromDate(
          DateTime(date.year, date.month, date.day, 23, 59, 59),
        ))
        .snapshots();
  }

  bool _isInRange(Map<String, dynamic> data) {
    final date = _dateOnly(selectedDate);
    final startTs = data["startDate"] as Timestamp?;
    final endTs = data["endDate"] as Timestamp?;
    if (startTs == null || endTs == null) return false;
    final start = _dateOnly(startTs.toDate());
    final end = _dateOnly(endTs.toDate());
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    // ✅ grab once, pass down
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ removed hardcoded Color(0xFFF6F7FB)
      appBar: AppBar(
        title: Text(
          "Today's Tasks",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          // ✅ removed hardcoded color: Colors.black
        ),
        centerTitle: true,
        // ✅ removed hardcoded BackButton color and icon color
        leading: const BackButton(),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: Column(
        children: [
          DateSelector(
            selectedDate: selectedDate,
            onDateSelected: (date) => setState(() => selectedDate = date),
          ),
          const SizedBox(height: 14),

          // ── Filter Buttons ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: BuildButton(
                    text: "All",
                    isSelected: selectedIndex == 0,
                    onTap: () => setState(() => selectedIndex = 0),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BuildButton(
                    text: "To Do",
                    isSelected: selectedIndex == 1,
                    onTap: () => setState(() => selectedIndex = 1),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BuildButton(
                    text: "Wish",
                    isSelected: selectedIndex == 2,
                    onTap: () => setState(() => selectedIndex = 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Task List ──────────────────────────────────
          Expanded(
            child: userId == null
                ? const Center(child: Text("Not logged in"))
                : StreamBuilder<QuerySnapshot>(
              stream: _buildStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}"));
                }

                final allDocs = snapshot.data?.docs ?? [];
                final filtered = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (!_isInRange(data)) return false;
                  if (selectedIndex == 1 &&
                      data["type"] != "todo") return false;
                  if (selectedIndex == 2 &&
                      data["type"] != "wish") return false;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 60,
                          // ✅ uses primary instead of hardcoded deepPurple
                          color: colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No tasks for this date",
                          style: GoogleFonts.poppins(
                            // ✅ theme aware
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final data = filtered[index].data()
                    as Map<String, dynamic>;
                    final startTs =
                    data["startDate"] as Timestamp?;
                    final endTs = data["endDate"] as Timestamp?;
                    final timeRange =
                    (startTs != null && endTs != null)
                        ? "${_formatDate(startTs.toDate())} → ${_formatDate(endTs.toDate())}"
                        : "";

                    return TaskCard(
                      category: data["group"] ?? "",
                      title: data["title"] ?? "",
                      time: timeRange,
                      type: data["type"] ?? "todo",
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
}

// ── Filter Button ──────────────────────────────────────────────────

class BuildButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const BuildButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        // ✅ uses colorScheme instead of hardcoded deepPurple
        backgroundColor: isSelected
            ? colorScheme.primary
            : colorScheme.primary.withOpacity(0.1),
        foregroundColor: isSelected
            ? colorScheme.onPrimary
            : colorScheme.primary,
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── Task Card ──────────────────────────────────────────────────────

class TaskCard extends StatelessWidget {
  final String category;
  final String title;
  final String time;
  final String type;

  const TaskCard({
    super.key,
    required this.category,
    required this.title,
    required this.time,
    required this.type,
  });

  Color _getColor(ColorScheme colorScheme) {
    // ✅ uses colorScheme instead of hardcoded blue/purple
    return type == "todo" ? colorScheme.primary : colorScheme.secondary;
  }

  String getLabel() {
    return type == "todo" ? "To Do" : "Wish";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _getColor(colorScheme);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ uses cardColor from theme instead of hardcoded Colors.white
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // ✅ subtle shadow that works in both modes
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 12,
              // ✅ theme aware
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              // ✅ theme aware
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  // ✅ theme aware
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getLabel(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}