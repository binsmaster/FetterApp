import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ExpandableCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool isExpanded;
  final Widget? trailing;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.children,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.isExpanded = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: backgroundColor ?? AppTheme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: TextStyle(
              color: textColor ?? AppTheme.textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: trailing ??
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: AppTheme.primaryColor,
              ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            if (onTap != null) onTap!();
          },
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: children,
        ),
      ),
    );
  }
}
