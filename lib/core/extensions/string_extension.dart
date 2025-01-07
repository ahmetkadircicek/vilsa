extension StringToDouble on String? {
  double toDouble() {
    if (this == null || this!.trim().isEmpty) return 0.0;
    String cleanedText = this!.replaceAll(',', '.').trim();
    return double.tryParse(cleanedText) ?? 0.0;
  }
}
