import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_dropdown/smart_dropdown.dart';

void main() {
  test('ResponseDropdownSource converts API response correctly', () async {
    final response = {
      'status': 1200,
      'data': [
        {
          'id': '1',
          'value': 'Afghanistan',
        },
        {
          'id': '2',
          'value': 'Albania',
        },
      ],
    };

    final source = ResponseDropdownSource(
      response: response,
      itemsParser: (response) {
        return response['data'];
      },
      valueParser: (item) {
        return item['id'];
      },
      labelParser: (item) {
        return item['value'].toString();
      },
    );

    final options = await source.load();

    expect(options.length, 2);

    expect(options[0].value, '1');
    expect(options[0].label, 'Afghanistan');

    expect(options[1].value, '2');
    expect(options[1].label, 'Albania');
  });
}