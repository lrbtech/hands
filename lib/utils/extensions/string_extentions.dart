const int averageWordsPerMinute = 180;

extension StrExt on String {
  int getWordsCount() {
    return this.split(' ').length;
  }

  int getEstimatedTimeInMin() {
    return (this.getWordsCount() / averageWordsPerMinute).ceil();
  }
}
