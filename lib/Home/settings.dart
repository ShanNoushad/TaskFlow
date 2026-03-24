import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Service/local_status.dart';
import '../auth/login.dart';
import '../provider/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String version = "";
  final localStorage = LocalStorageService();

  @override
  void initState() {
    super.initState();
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Are You Sure That You Want to Logout"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                localStorage.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: themeProvider.isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                ),
              ),
            ),

            const Divider(),

            Card(
              elevation: 2,
              child: GestureDetector(
                onTap: () {
                  showAlertDialog();
                },
                child: ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log Out"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
