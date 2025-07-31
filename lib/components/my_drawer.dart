import 'package:flutter/material.dart';
import 'package:moonflow/services/auth/auth_services.dart';
import 'package:moonflow/services/auth/login_or_register.dart';
import 'package:moonflow/pages/profile_page.dart';
import 'package:moonflow/themes/themeProvider.dart';
import 'package:moonflow/utilities/app_localizations.dart';
import 'package:moonflow/utilities/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:moonflow/components/user_avatar.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) async {
    final auth = Provider.of<AuthServices>(context, listen: false);
    await auth.signOut();

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginOrRegister()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                child: Center(
                  child: UserAvatar(
                    radius: 40,
                    // fallbackAsset: 'assets/avatar1.png',
                  ),
                ),
              ),

              // Theme toggle
              SwitchListTile(
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  AppLocalizations.translate(
                    context,
                    'dark_mode',
                  ).toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 2),
                ),

                value: isDarkMode,
                onChanged: themeProvider.toggleTheme,
              ),

              // Home
              ListTile(
                leading: Icon(Icons.home, color: colorScheme.onSurface),
                title: Text(
                  AppLocalizations.translate(context, 'home').toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 2),
                ),

                onTap: () => Navigator.pop(context),
              ),

              // Profile
              ListTile(
                leading: Icon(Icons.person, color: colorScheme.onSurface),
                title: Text(
                  AppLocalizations.translate(context, 'profile').toUpperCase(),
                  style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 2),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: Text(
              AppLocalizations.translate(context, 'language').toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 2),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: theme.colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Text("🇩🇪"),
                        title: const Text("Deutsch"),
                        onTap: () {
                          Provider.of<LanguageProvider>(
                            context,
                            listen: false,
                          ).setLocale(const Locale('de'));
                          Navigator.pop(context);
                        },
                      ),
                      ListTile(
                        leading: const Text("🇬🇧"),
                        title: const Text("English"),
                        onTap: () {
                          Provider.of<LanguageProvider>(
                            context,
                            listen: false,
                          ).setLocale(const Locale('en'));
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              AppLocalizations.translate(context, 'logout').toUpperCase(),
              style: theme.textTheme.bodyMedium?.copyWith(
                letterSpacing: 2,
                color: colorScheme.error,
              ),
            ),

            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}
