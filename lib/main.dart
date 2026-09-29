import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dropdown/smart_dropdown.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Dropdown Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  dynamic countryResponse;
  dynamic selectedCountry;

  bool isLoading = true;
  String? errorMessage;

  // Use your token locally.
  // Do not commit real tokens to GitHub/pub.dev.
  final String token = 'YOUR_TOKEN_HERE';

  // Static dropdown data for testing.
  final List<DropdownOption<int>> countries = const [
    DropdownOption(
      value: 1,
      label: 'India',
    ),
    DropdownOption(
      value: 2,
      label: 'USA',
    ),
    DropdownOption(
      value: 3,
      label: 'UK',
    ),
  ];

  @override
  void initState() {
    super.initState();

    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await getCountries();

      if (!mounted) return;

      setState(() {
        countryResponse = response;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<dynamic> getCountries() async {
    final url = Uri.parse(
      'https://cardio-staging.konectar.io/apis/v1/country_helpers/countries_list',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    debugPrint('Status code: ${response.statusCode}');
    debugPrint('Response: ${response.body}');

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to load countries. '
      'Status code: ${response.statusCode}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Dropdown'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadCountries,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (countryResponse == null) {
      return const Center(
        child: Text('No country data'),
      );
    }

    return SmartDropdown(
      // -----------------------------------------
      // OPTION 1: Static data
      // -----------------------------------------
      //
      // source: StaticDropdownSource(
      //   options: countries,
      // ),

      // -----------------------------------------
      // OPTION 2: API response
      // -----------------------------------------
      source: ResponseDropdownSource(
        response: countryResponse,

        // API response:
        //
        // {
        //   "status": 1200,
        //   "data": [
        //     {
        //       "id": "1",
        //       "value": "Afghanistan"
        //     }
        //   ]
        // }
        //
        // Extract the actual dropdown list.
        itemsParser: (response) {
          return response['data'];
        },

        // Keep the original API value type.
        //
        // If API returns int -> int
        // If API returns String -> String
        // If API returns bool -> bool
        valueParser: (item) {
          return item['id'];
        },

        // Label is displayed as text.
        labelParser: (item) {
          return item['value'].toString();
        },
      ),

      isMultiSelect: false,

      selectedValues: selectedCountry == null
          ? []
          : [selectedCountry],

      hint: 'Select Country',

      onChanged: (values) {
        debugPrint('Selected values: $values');

        setState(() {
          selectedCountry =
              values.isEmpty ? null : values.first;
        });
      },
    );
  }
}