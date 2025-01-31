import 'dart:convert';
import 'package:search_field_dropdown/search_field_dropdown.dart';

import 'Model/CityModel.dart';
import 'Model/StatesModel.dart';
import 'Model/CountryModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FormFiled DropDown Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          primary: Colors.deepPurple,
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const DropDownClass(),
    );
  }
}

class DropDownClass extends StatefulWidget {
  const DropDownClass({super.key});

  @override
  State<DropDownClass> createState() => _DropDownClassState();
}

class _DropDownClassState extends State<DropDownClass> {
  final countryController = OverlayPortalController();
  final stateController = OverlayPortalController();
  final cityController = OverlayPortalController();
  final itemController = OverlayPortalController();

  CountryModel? selectedCountry;
  StatesModel? selectedState;
  CityModel? selectedCity;

  List<StatesModel> tempStatesList = [];
  List<CountryModel> countryList = [];
  List<StatesModel> statesList = [];
  List<CityModel> tempCityList = [];
  List<CityModel> cityList = [];

  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();

  Future<void> loadCity() async {
    cityList = [];

    var data = await rootBundle.loadString("assets/JsonFiles/City.json");
    var cityData = json.decode(data);
    List list = cityData['city'].cast<Map<String, dynamic>>();
    cityList.addAll(list.map((e) => CityModel.fromJson(e)).toList());
    setState(() {});
  }

  Future<void> loadState() async {
    statesList = [];
    var data = await rootBundle.loadString("assets/JsonFiles/State.json");
    var stateData = json.decode(data);
    List list = stateData['states'].cast<Map<String, dynamic>>();
    statesList.addAll(list.map((e) => StatesModel.fromJson(e)).toList());
    setState(() {});
  }

  Future<void> loadCountry() async {
    countryList = [];
    var data = await rootBundle.loadString("assets/JsonFiles/Country.json");
    var countryData = json.decode(data);
    List list = countryData['countries'].cast<Map<String, dynamic>>();
    countryList.addAll(list.map((e) => CountryModel.fromJson(e)).toList());
    setState(() {});
  }

  bool isHidde = false;

  @override
  void initState() {
    super.initState();
    loadCity();
    loadState();
    loadCountry();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FormFiled DropDown Example",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: CallbackShortcuts(
        bindings: {
          LogicalKeySet(LogicalKeyboardKey.tab): () async {
            if (focusNode.hasFocus) {
              focusNode2.requestFocus();
              stateController.show();
              countryController.hide();
              cityController.hide();
            } else if (focusNode2.hasFocus) {
              focusNode3.requestFocus();
              stateController.hide();
              countryController.hide();
              cityController.show();
            } else if (focusNode3.hasFocus) {
              focusNode.requestFocus();
              stateController.hide();
              cityController.hide();
              countryController.show();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [

                  Expanded(
                      child: SearchFieldDropdown<CountryModel>(
                    focusNode: focusNode,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: countryController,
                    initialItem: selectedCountry,
                    item: countryList,
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400),
                    menuDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blueAccent),
                      boxShadow:  [
                        BoxShadow(
                          color: Colors.blue.shade100,
                          blurRadius: 4,
                          spreadRadius: 5,
                          offset: const Offset(0, 0)
                        )
                      ]
                    ),
                    filedDecoration: InputDecoration(
                      suffixIcon: IntrinsicWidth(
                        child: Row(
                          children: [
                            if (selectedCountry != null)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    isHidde = false;
                                    tempCityList = [];
                                    tempStatesList = [];
                                    // print(tempStatesList.length);
                                    selectedCity = null;
                                    selectedState = null;
                                    selectedCountry = null;
                                    loadCountry();
                                  });
                                },
                                child: const Icon(
                                  Icons.clear,
                                  size: 20,
                                ),
                              ),
                            if (selectedCountry != null)
                              const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_drop_down_sharp,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    onChanged: (CountryModel? value) {
                      setState(() {
                        isHidde = true;
                        selectedCountry = value;
                        selectedCity = null;
                        selectedState = null;
                        tempStatesList = [];
                        tempCityList = [];
                        tempStatesList = statesList.where((element) {
                          return "${element.countryId}" ==
                              "${selectedCountry?.id}";
                        }).toList();
                      });
                    },
                    onSearch: (value) async {
                      return countryList.where((element) {
                        return element.name
                            .toLowerCase()
                            .contains(value.toLowerCase());
                      }).toList();
                    },
                    listItemBuilder: (context, item, isSelected) {
                      int index = countryList.indexOf(item);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        margin:
                            EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                        decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(
                          item.name,
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                    selectedItemBuilder: (context, item) {
                      return Text(
                        item.name,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      );
                    },
                  )),
                  const SizedBox(width: 15),


                  Expanded(
                      child: SearchFieldDropdown<StatesModel>(
                    focusNode: focusNode2,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: stateController,
                    initialItem: selectedState,
                    item: tempStatesList,
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400),
                    menuDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueAccent),
                      boxShadow: []
                    ),
                    filedDecoration: InputDecoration(
                      suffixIcon: IntrinsicWidth(
                        child: Row(
                          children: [
                            if (selectedState != null)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedState = null;
                                    if (selectedCountry == null)
                                      tempStatesList.clear();
                                  });
                                },
                                child: const Icon(
                                  Icons.clear,
                                  size: 20,
                                ),
                              ),
                            if (selectedState != null) const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_drop_down_sharp,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    onChanged: (StatesModel? value) {
                      setState(() {
                        tempCityList = [];
                        selectedCity = null;
                        selectedState = value;

                        tempCityList = cityList.where((element) {
                          return "${element.stateId}" == "${selectedState?.id}";
                        }).toList();
                      });
                    },
                    onSearch: (value) async {
                      return statesList.where((element) {
                        return element.name
                            .toLowerCase()
                            .contains(value.toLowerCase());
                      }).toList();
                    },
                    listItemBuilder: (context, item, isSelected) {
                      // print("isSelected $isSelected");
                      int index = statesList.indexOf(item);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        margin:
                            EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                        decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(
                          item.name,
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                        selectedItemBuilder: (context, item) {
                          return Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          );
                        },
                  )),

                  const SizedBox(width: 15),

                  Expanded(
                      child: SearchFieldDropdown<CityModel>(
                    focusNode: focusNode3,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: cityController,
                    readOnly: tempCityList.isEmpty,
                    initialItem: selectedCity,
                    item: tempCityList,
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400),
                    menuDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blueAccent)),
                    filedDecoration: InputDecoration(
                      suffixIcon: IntrinsicWidth(
                        child: Row(
                          children: [
                            if (selectedCity != null)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedCity = null;
                                    if (selectedState == null)
                                      tempCityList.clear();
                                  });
                                },
                                child: const Icon(
                                  Icons.clear,
                                  size: 20,
                                ),
                              ),
                            if (selectedCity != null) const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_drop_down_sharp,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    onChanged: (CityModel? value) {
                      setState(() {
                        selectedCity = value;
                      });
                    },
                    onSearch: (value) async {
                      return tempCityList.where((element) {
                        return element.name
                            .toLowerCase()
                            .contains(value.toLowerCase());
                      }).toList();
                    },
                    listItemBuilder: (context, item, isSelected) {
                      int index = cityList.indexOf(item);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 5),
                        margin:
                            EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                        decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(2)),
                        child: Text(
                          item.name,
                          style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                      );
                    },
                        selectedItemBuilder: (context, item) {
                          return Text(
                            item.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          );
                        },
                  ))
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}
