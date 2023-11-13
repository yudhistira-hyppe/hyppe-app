class LayerModel {
  late String name;
  late String icon;
  late double previousValue;
  late double value;
  late double defaultValue;
  late double min;
  late double max;

  LayerModel({
    required this.name,
    required this.icon,
    this.value = 0,
    this.previousValue = 0,
    this.defaultValue = 0,
    this.min = -100,
    this.max = 100,
  });
}
