import 'package:flutter/material.dart';
import 'package:todo_app/Home/settings.dart';
import 'package:todo_app/Service/local_status.dart';
import 'package:todo_app/Service/pojectService.dart';
import '../Models/auth_model.dart';
import '../Service/authservice.dart';
import '../auth/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AppUser? _user;
  bool _isLoading = true;
  String? _error;
  int projectCount = 0;
  int notComplete = 0;

  final AuthService _authService = AuthService();
  final projectService = ProjectService();

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        _authService.getUserData(),
        projectService.getProjectCompletedCount(),
        projectService.getProjectNotCompleteCount(),
      ]);
      setState(() {
        _user = results[0] as AppUser?;
        projectCount = results[1] as int;
        notComplete = results[2] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ grab theme colors once here
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ removed hardcoded Colors.white
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
            icon: const Icon(Icons.settings),  // ✅ color from iconTheme
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: textTheme.bodyLarge))
          : _buildBody(colorScheme, textTheme, isDark),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, TextTheme textTheme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Avatar ───────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Colors.purple, Colors.blue]),
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: colorScheme.surface,  // ✅ theme aware
              child: Icon(Icons.person, size: 60, color: colorScheme.primary),
            ),
          ),

          const SizedBox(height: 16),

          // ── Name ─────────────────────────────────────────
          Text(
            _user?.name ?? 'Unknown',
            style: textTheme.titleLarge?.copyWith(fontSize: 22), // ✅ theme aware
          ),

          const SizedBox(height: 30),

          // ── Stat Cards ───────────────────────────────────
          Row(
            children: [
              _buildStatCard(
                colors: [Colors.pink, Colors.purple],
                title: "Completed",
                value: projectCount.toString(),
                icon: Icons.check_circle,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                colors: [Colors.orange, Colors.red],
                title: "Pending",
                value: notComplete.toString(),
                icon: Icons.pending,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── User Details ─────────────────────────────────
          Align(
            alignment: Alignment.topLeft,
            child: Text("User Details", style: textTheme.titleLarge),
          ),

          const SizedBox(height: 10),

          // ✅ Card uses theme cardColor automatically
          Card(
            child: Column(
              children: [
                _buildInfoTile(
                  icon: Icons.person,
                  title: "Name",
                  value: _user?.name ?? '—',
                  colorScheme: colorScheme,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.email,
                  title: "Email",
                  value: _user?.email ?? '—',
                  colorScheme: colorScheme,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  icon: Icons.calendar_today,
                  title: "Member Since",
                  value: _user?.createdAt != null
                      ? '${_user!.createdAt.day}/${_user!.createdAt.month}/${_user!.createdAt.year}'
                      : '—',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ moved inside class so it has access to colorScheme
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primary.withOpacity(0.1), // ✅ theme aware
        child: Icon(icon, color: colorScheme.primary),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.5)),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface, // ✅ theme aware
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required List<Color> colors,
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}