import 'package:flutter/material.dart';

import '../models/dropdown_option.dart';
import '../sources/dropdown_source.dart';

class SmartDropdown<T> extends StatefulWidget {
  final DropdownSource<T> source;

  final List<T> selectedValues;
  final bool isMultiSelect;

  final ValueChanged<List<T>>? onChanged;

  final String hint;

  const SmartDropdown({
    super.key,
    required this.source,
    this.selectedValues = const [],
    this.isMultiSelect = false,
    this.onChanged,
    this.hint = 'Select',
  });

  @override
  State<SmartDropdown<T>> createState() =>
      _SmartDropdownState<T>();
}

class _SmartDropdownState<T>
    extends State<SmartDropdown<T>> {

  List<DropdownOption<T>> options = [];

  late List<T> selectedValues;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    selectedValues =
        List<T>.from(widget.selectedValues);

    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final result = await widget.source.load();

    if (!mounted) return;

    setState(() {
      options = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const CircularProgressIndicator();
    }

    if (widget.isMultiSelect) {
      return _buildMultiSelect();
    }

    return _buildSingleSelect();
  }

Widget _buildSingleSelect() {
  final T? selectedValue =
      selectedValues.isEmpty
          ? null
          : selectedValues.first;

  return DropdownButtonFormField<T>(
    initialValue: selectedValue,
    isExpanded: true,
    hint: Text(widget.hint),
    items: options.map((option) {
      return DropdownMenuItem<T>(
        value: option.value,
        child: Text(
          option.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }).toList(),
    onChanged: (value) {
      if (value == null) {
        selectedValues = [];
        widget.onChanged?.call([]);
      } else {
        selectedValues = [value];
        widget.onChanged?.call([value]);
      }
    },
  );
}
 Widget _buildMultiSelect() {
    return InkWell(
      onTap: _openMultiSelect,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.hint,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedValues.isEmpty
              ? 'Select'
              : _selectedLabels(),
        ),
      ),
    );
  }

  String _selectedLabels() {
    return selectedValues.map((value) {
      final option = options.firstWhere(
        (option) => option.value == value,
      );

      return option.label;
    }).join(', ');
  }

  Future<void> _openMultiSelect() async {
    final tempValues =
        List<T>.from(selectedValues);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(widget.hint),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: options.map((option) {
                    final selected =
                        tempValues.contains(option.value);

                    return CheckboxListTile(
                      value: selected,
                      title: Text(option.label),
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            tempValues.add(option.value);
                          } else {
                            tempValues.remove(option.value);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedValues = tempValues;
                    });

                    widget.onChanged?.call(selectedValues);

                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}