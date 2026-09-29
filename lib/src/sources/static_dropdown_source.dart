import '../models/dropdown_option.dart';
import 'dropdown_source.dart';

class StaticDropdownSource<T> extends DropdownSource<T> {
  final List<DropdownOption<T>> options;

  StaticDropdownSource({
    required this.options,
  });

  @override
  Future<List<DropdownOption<T>>> load() async {
    return options;
  }
}