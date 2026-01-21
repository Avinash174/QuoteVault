import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/quote_model.dart';
import '../widgets/quote_card.dart';

class QuoteDetailView extends StatelessWidget {
  final Quote quote;
  final String heroTag;

  const QuoteDetailView({
    super.key,
    required this.quote,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: isDark ? Colors.white : AppColors.textPrimaryLight,
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              child: QuoteCard(quote: quote),
            ),
          ),
        ),
      ),
    );
  }
}
