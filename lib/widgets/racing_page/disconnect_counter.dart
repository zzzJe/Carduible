class DisconnectCounter {
  DisconnectCounter({
    required this.count,
    required this.onReset,
    required this.onStepin,
    required this.onStepEnd,
  });

  int counter = 0;
  final int count;
  final Function onReset;
  final Function onStepin;
  final Function onStepEnd;

  void stepin() {
    counter++;
    onStepin(counter);
    if (counter == count) {
      onStepEnd();
    }
  }

  void reset() {
    counter = 0;
    onReset(counter);
  }
}
