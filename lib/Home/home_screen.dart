import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../Models/todoModel.dart';
import '../Service/pojectService.dart';
import 'add_project.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: _buildFAB(context),
      body: SafeArea(
        child: StreamBuilder<List<ProjectModel>>(
          stream: ProjectService().getProjects(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final projects = snapshot.data ?? [];
            final overallProgress = projects.isEmpty
                ? 0.0
                : projects.map((p) => p.progress).reduce((a, b) => a + b) /
                      projects.length;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── HEADER ──────────────────────────────
                      _buildHeader(
                        user?.displayName ?? "User",
                        overallProgress,
                        projects.length,
                        context,
                      ),
                      const SizedBox(height: 24),

                      // ── IN PROGRESS ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _sectionHeader(
                          "In Progress",
                          projects.length,
                          context,
                        ),
                      ),
                      const SizedBox(height: 14),

                      SizedBox(
                        height: 170,
                        child: projects.isEmpty
                            ? Center(
                                child: Text(
                                  "No projects yet",
                                  style: GoogleFonts.nunito(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(left: 20),
                                itemCount: projects.length,
                                itemBuilder: (_, i) =>
                                    _horizontalCard(projects[i], i, context),
                              ),
                      ),
                      const SizedBox(height: 28),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _sectionHeader(
                          "Task Groups",
                          projects.length,
                          context,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _verticalCard(context, projects[i], i),
                      childCount: projects.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _buildHeader(
    String name,
    double progress,
    int count,
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C6FFF), Color(0xFF5B4FE9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hello, $name 👋",
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your today's tasks\nalmost done!",
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      "View Tasks",
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF6C63FF),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _CircularProgress(progress: progress),
        ],
      ),
    );
  }

  // ─── SECTION HEADER ────────────────────────────────────────────

  Widget _sectionHeader(String title, int count, BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$count",
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ─── HORIZONTAL CARD ───────────────────────────────────────────

  static const List<List<Color>> _cardGradients = [
    [Color(0xFFFFE5D0), Color(0xFFFFCBAA)],
    [Color(0xFFE0F4FF), Color(0xFFC2E9FF)],
    [Color(0xFFE8E0FF), Color(0xFFD4C9FF)],
    [Color(0xFFD0FFE8), Color(0xFFAAF0C8)],
  ];

  static const List<Color> _cardAccents = [
    Color(0xFFFF7043),
    Color(0xFF29B6F6),
    Color(0xFF7C6FFF),
    Color(0xFF26A69A),
  ];

  Widget _horizontalCard(ProjectModel p, int index, BuildContext context) {
    final gradIdx = index % _cardGradients.length;
    final accent = _cardAccents[gradIdx];

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cardGradients[gradIdx],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  p.group,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              Icon(Icons.more_horiz, color: accent, size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            p.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const Spacer(),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: p.progress,
              minHeight: 6,
              backgroundColor: accent.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${(p.progress * 100).toInt()}% complete",
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  // ─── VERTICAL CARD ─────────────────────────────────────────────

  Widget _verticalCard(BuildContext context, ProjectModel p, int index) {
    final completed = p.steps.values.where((s) => s.done).length;
    final total = p.steps.length;
    final accent = _cardAccents[index % _cardAccents.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Card Header ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      p.title[0].toUpperCase(),
                   style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Text(
                        "$total Tasks  •  ${_fmt(p.startDate)} → ${_fmt(p.endDate)}",
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular progress
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: p.progress,
                        strokeWidth: 4,
                        backgroundColor: accent.withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation(accent),
                      ),
                      Text(
                        "${(p.progress * 100).toInt()}%",
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Divider ────────────────────────────────────────
          if (p.steps.isNotEmpty)
            Divider(height: 1, color: Colors.grey.shade100),

          // ── Steps ──────────────────────────────────────────
          if (p.steps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                children: p.steps.entries.map((entry) {
                  final step = entry.value;
                  return _buildStepTile(
                    step: step,
                    accent: accent,
                    onToggle: (val) {
                      if (p.id == null) return;
                      ProjectService().updateStep(
                        projectId: p.id!,
                        stepKey: entry.key,
                        value: val ?? false,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // ─── BEAUTIFUL STEP TILE ───────────────────────────────────────

  Widget _buildStepTile({
    required StepModel step,
    required Color accent,
    required ValueChanged<bool?> onToggle,
  }) {
    return GestureDetector(
      onTap: () => onToggle(!step.done),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: step.done ? accent.withOpacity(0.07) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: step.done ? accent.withOpacity(0.3) : Colors.grey.shade200,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // Custom checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: step.done ? accent : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: step.done ? accent : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: step.done
                    ? [
                        BoxShadow(
                          color: accent.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: step.done
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step.title,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: step.done
                      ? Colors.grey.shade400
                      : const Color(0xFF1A1A2E),
                  decoration: step.done ? TextDecoration.lineThrough : null,
                  decorationColor: Colors.grey.shade400,
                ),
              ),
            ),
            if (step.done)
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: accent.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  // ─── FAB ───────────────────────────────────────────────────────

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF6C63FF),
      elevation: 8,
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddProject()),
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
    );
  }

  String _fmt(DateTime d) => "${d.day}/${d.month}/${d.year}";
}

class _CircularProgress extends StatelessWidget {
  final double progress;

  const _CircularProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(80, 80),
            painter: _RingPainter(progress: progress),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${(progress * 100).toInt()}%",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  const _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
