class DateTimeHelper {
  String formatLastEdited(DateTime? lastEdited) {
    if (lastEdited == null) return "Edited Just Now";
    final now = DateTime.now();
  final difference = now.difference(lastEdited);

  if (difference.inDays > 0) {
    return 'Edited ${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  } else if (difference.inHours > 0) {
    return 'Edited ${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  } else if (difference.inMinutes > 0) {
    return 'Edited ${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
  } else {
    return 'Edited just now';
  }
  }
}
