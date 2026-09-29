import '../models/dropdown_option.dart';

abstract class DropdownSource<T> {
  Future<List<DropdownOption<T>>> load();
}