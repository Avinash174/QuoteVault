import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/views/settings_view.dart';
import '../../../auth/presentation/views/login_view.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/auth_provider.dart';
import '../../../../data/models/user_stats.dart';
import '../../../library/presentation/providers/collection_viewmodel.dart';
import '../../../library/presentation/providers/library_viewmodel.dart';
import '../providers/stats_provider.dart';
import '../../../home/presentation/providers/bottom_nav_provider.dart';
import 'edit_profile_view.dart';
import 'edit_goal_view.dart';
import '../../../../core/utils/snackbar_utils.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (authState.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    final stats =
        ref.watch(userStatsNotifierProvider).value ?? const UserStats();
    final favorites = ref.watch(libraryViewModelProvider);
    final collections = ref.watch(collectionViewModelProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.library_books, color: AppColors.accent, size: 24),
            const SizedBox(width: 8),
            Text(
              'ThoughtVault',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsView()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    favorites.length.toString(),
                    'SAVED',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    collections.when(
                      data: (data) => data.length.toString(),
                      loading: () => '-',
                      error: (_, __) => '0',
                    ),
                    'COLLECTIONS',
                    isAccent: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    stats.streak.toString(),
                    'STREAK',
                    isAccent: true,
                    accentColor: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildDailyGoalCard(context, stats),
            const SizedBox(height: 30),
            _buildSectionHeader(
              context,
              'My Collections',
              showSeeAll: true,
              onSeeAll: () {
                // Switch to Library Tab (Index 2)
                ref.read(bottomNavNotifierProvider.notifier).setIndex(2);
              },
            ),
            const SizedBox(height: 16),
            if (collections.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (collections.valueOrNull == null ||
                collections.value!.isEmpty)
              Center(
                child: Text(
                  'No collections yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildCollectionCard(
                      context,
                      collections.value![0].name,
                      '${collections.value![0].quotes.length} quotes',
                      Icons.folder,
                      Colors.indigoAccent,
                    ),
                  ),
                  if (collections.value!.length > 1) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildCollectionCard(
                        context,
                        collections.value![1].name,
                        '${collections.value![1].quotes.length} quotes',
                        Icons.folder,
                        Colors.pinkAccent,
                      ),
                    ),
                  ] else if (collections.value!.length == 1)
                    const Expanded(child: SizedBox()),
                ],
              ),
            const SizedBox(height: 30),
            _buildSectionHeader(context, 'Recently Saved'),
            const SizedBox(height: 16),
            if (favorites.isEmpty)
              Center(
                child: Text(
                  'No saved quotes yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else
              ...favorites
                  .take(2)
                  .map(
                    (quote) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildQuoteCard(
                        context,
                        quote.text,
                        quote.author,
                        AppColors.accent,
                      ),
                    ),
                  ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (user == null) {
      return Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: isDark
                ? AppColors.card
                : Colors.black.withValues(alpha: 0.05),
            child: const Icon(Icons.person, size: 50, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            'Guest User',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Sign In / Create Account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final displayName = user.displayName ?? 'ThoughtVault User';
    final email = user.email ?? '';
    final photoUrl = user.photoURL;
    final initials = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : email.isNotEmpty
        ? email.substring(0, 1).toUpperCase()
        : '?';

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileView()),
            );
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.pinkAccent.withValues(alpha: 0.5),
                      AppColors.accent.withValues(alpha: 0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(email, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            await AuthService().signOut();
            if (context.mounted) {
              SnackbarUtils.showSuccess(
                context,
                'Signed Out',
                'Successfully signed out',
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.card
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  'SIGN OUT',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label, {
    bool isAccent = false,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.accent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // width: 100, // Removed hardcoded width for responsiveness
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: isAccent
                  ? color
                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, UserStats stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigoAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bar_chart, color: Colors.indigoAccent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Reading Goal',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      "TODAY'S PROGRESS",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: stats.quotesReadToday.toString(),
                      style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' / ${stats.dailyGoal}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (stats.quotesReadToday / stats.dailyGoal).clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.grey[800] : Colors.black12,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stats.quotesReadToday >= stats.dailyGoal
                      ? 'Goal achieved! You are on fire.'
                      : 'Great work! Just ${stats.dailyGoal - stats.quotesReadToday} more to go.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditGoalView(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Edit Goal',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF1E1E1E) : Colors.white,
            color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 0.7,
                  minHeight: 4,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                count,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    String text,
    String author,
    Color accent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E1E1E)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$text"',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(width: 20, height: 2, color: accent),
              const SizedBox(width: 8),
              Text(
                author,
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool showSeeAll = false,
    VoidCallback? onSeeAll,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (showSeeAll)
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All >',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
