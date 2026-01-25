import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../data/models/quote_model.dart';

class QuoteGeneratorView extends StatefulWidget {
  final Quote quote;

  const QuoteGeneratorView({super.key, required this.quote});

  @override
  State<QuoteGeneratorView> createState() => _QuoteGeneratorViewState();
}

class _QuoteGeneratorViewState extends State<QuoteGeneratorView> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String _selectedTheme = 'Midnight';

  final Map<String, List<Color>> _themes = {
    'Midnight': [AppColors.midnightStart, AppColors.midnightEnd],
    'Royal': [AppColors.royalStart, AppColors.royalEnd],
    'Sunset': [AppColors.sunsetStart, AppColors.sunsetEnd],
    'Custom': [Colors.grey.shade800, Colors.black],
  };

  @override
  void initState() {
    super.initState();
    _recordRead();
  }

  void _recordRead() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().incrementQuotesRead(user.uid);
    }
  }

  void _shareImage() async {
    AdService().showRewardedAd(
      onAdDismissed: () {
        // ad failed or dismissed
      },
      onUserEarnedReward: () async {
        try {
          final Uint8List? image = await _screenshotController.capture();
          if (image != null) {
            final directory = await getApplicationDocumentsDirectory();
            final imagePath = await File(
              '${directory.path}/quote_card.png',
            ).create();
            await imagePath.writeAsBytes(image);

            // Share the file
            await Share.shareXFiles([
              XFile(imagePath.path),
            ], text: 'Check out this quote from ThoughtVault!');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error generating image: $e')),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Widget Preview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          width: 300,
                          constraints: const BoxConstraints(minHeight: 400),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _themes[_selectedTheme]!,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _themes[_selectedTheme]![0].withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Top Icons
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      Icons.format_quote,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    Icon(
                                      Icons.wifi,
                                      size: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Centered Quote Content
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'QUOTE OF THE DAY',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 10,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '"${widget.quote.text}"',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Text(
                                          "— ${widget.quote.author}",
                                          style: TextStyle(
                                            color: Colors.white.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.format_quote,
                                                size: 12,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "ThoughtVault",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Bottom Decorative Elements
                              Positioned(
                                bottom: 20,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    4,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Controls
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _shareImage,
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Save Appearance / Share'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'LAST SYNCED: JUST NOW',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: _themes.keys.map((theme) {
                              final isSelected = _selectedTheme == theme;
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTheme = theme),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: _themes[theme]!,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: isSelected
                                              ? Border.all(
                                                  color: AppColors.accent,
                                                  width: 2,
                                                )
                                              : Border.all(
                                                  color: Theme.of(context)
                                                      .dividerColor
                                                      .withValues(alpha: 0.1),
                                                ),
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        theme[0].toUpperCase() +
                                            theme.substring(1),
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppColors.accent
                                              : Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color,
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Footer Tip
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Theme settings are synced instantly via Firebase and will apply to your widget automatically.",
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
