import 'package:flutter/material.dart';
import '../models/complaint_model.dart';
import '../utils/extensions.dart';
import '../utils/app_theme.dart';

class ComplaintCard extends StatelessWidget {
  final ComplaintModel complaint;
  const ComplaintCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  complaint.category.displayName,
                  style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12),
                ),
                Chip(
                  label: Text(complaint.status.displayName, style: const TextStyle(color: Colors.white, fontSize: 12)),
                  backgroundColor: complaint.status.color,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              complaint.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.secondaryTextColor),
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppTheme.secondaryTextColor),
                const SizedBox(width: 4),
                Text(complaint.createdAt.formatDate(), style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
                const Spacer(),
                if (complaint.evidencePath != null) ...[
                  const Icon(Icons.attachment, size: 14, color: AppTheme.secondaryTextColor),
                  const SizedBox(width: 4),
                  const Text('Ada Lampiran', style: TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}