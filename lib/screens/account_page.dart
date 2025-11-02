import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/account.dart';
import '../theme/app_colors.dart';
import 'settings.dart';
import 'edit_profile_page.dart';

class AccountPage extends StatefulWidget {
  final void Function(bool isDark)? onThemeChanged;
  final void Function(Color color)? onAccentChanged;

  const AccountPage({
    super.key, 
    this.onThemeChanged,
    this.onAccentChanged,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<Account> _accountFuture;

  @override
  void initState() {
    super.initState();
    _accountFuture = Account.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    onThemeChanged: widget.onThemeChanged ?? (_) {},
                    onAccentChanged: widget.onAccentChanged ?? (_) {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Account>(
        future: _accountFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final account = snapshot.data ?? Account();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildProfileImage(account, theme),
                const SizedBox(height: 24),
                Text(
                  account.name,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  account.email,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildStatsCard(account, theme),
                const SizedBox(height: 24),
                _buildEditProfileButton(theme),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileImage(Account account, ThemeData theme) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withOpacity(0.1),
            border: Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          child: account.profileImageUrl.isNotEmpty
              ? ClipOval(
                  child: account.profileImageUrl.startsWith('data:image')
                      ? Image.memory(
                          base64Decode(account.profileImageUrl.split(',')[1]),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person,
                            size: 60,
                          ),
                        )
                      : Image.network(
                          account.profileImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person,
                            size: 60,
                          ),
                        ),
                )
              : const Icon(
                  Icons.person,
                  size: 60,
                ),
        ),
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primary,
          child: IconButton(
            icon: const Icon(
              Icons.camera_alt,
              size: 18,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: Implement image picker
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(Account account, ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              theme,
              'Total Score',
              account.totalScore.toString(),
              Icons.score,
            ),
            const Divider(height: 24),
            _buildStatRow(
              theme,
              'Games Played',
              account.gamesPlayed.toString(),
              Icons.sports_esports,
            ),
            const Divider(height: 24),
            _buildStatRow(
              theme,
              'Average Score',
              account.gamesPlayed > 0
                  ? (account.totalScore / account.gamesPlayed).toStringAsFixed(1)
                  : '0',
              Icons.analytics,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.titleMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: () async {
        final account = await _accountFuture;
        if (!mounted) return;
        
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditProfilePage(account: account),
          ),
        );
        
        if (result == true && mounted) {
          setState(() {
            _accountFuture = Account.load();
          });
        }
      },
      icon: const Icon(Icons.edit),
      label: const Text('Edit Profile'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}