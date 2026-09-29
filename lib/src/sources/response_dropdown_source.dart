import 'package:flutter_smart_dropdown/smart_dropdown.dart';

class ResponseDropdownSource<T> extends DropdownSource<T> {
  final dynamic response;
  final T Function(dynamic item) valueParser;
  final String Function(dynamic item) labelParser;
  final List<dynamic> Function(dynamic response)? itemsParser;

  ResponseDropdownSource({
    required this.response,
    required this.valueParser,
    required this.labelParser,
    this.itemsParser,
  });

  @override
  Future<List<DropdownOption<T>>> load() async {
    final List<dynamic> items =
        itemsParser != null
            ? itemsParser!(response)
            : response is List
                ? response
                : [];

    return items.map((item) {
      return DropdownOption<T>(
        value: valueParser(item),
        label: labelParser(item),
      );
    }).toList();
  }
}