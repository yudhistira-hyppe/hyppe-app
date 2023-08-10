class ProgressUploadArgument {
  final double count;
  final double total;
  final bool isCompressing;

  ProgressUploadArgument({
    required this.count,
    required this.total,
    this.isCompressing = false,
  });
}
