typedef FilePickerErrorHandler = Future<void> Function(String message);

typedef FilePickerErrorMessageBuilder = String Function(int maxSize, double actualSize);
