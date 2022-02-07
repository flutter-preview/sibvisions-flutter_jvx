class Gaps {
  /// The vertical gap of a layout
  final int verticalGap;

  /// The horizontal gap of a layout
  final int horizontalGap;

  Gaps({required this.horizontalGap, required this.verticalGap});

  /// Returns Gaps instance, if provided List is null the gaps will be set to 0.
  static Gaps createFromList({required List<String>? gapsList}) {
    Gaps gaps;
    if (gapsList == null) {
      gaps = Gaps(horizontalGap: 0, verticalGap: 0);
    } else {
      gaps = Gaps(horizontalGap: int.parse(gapsList[0]), verticalGap: int.parse(gapsList[1]));
    }
    return gaps;
  }
}