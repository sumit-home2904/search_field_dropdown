import 'dart:convert';
import 'package:search_field_dropdown/search_field_dropdown.dart';
import 'Model/city_model.dart';
import 'Model/states_model.dart';
import 'Model/country_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class DummyUserModel {
  final int id;
  final String name;
  final String email;
  final String image;

  DummyUserModel({required this.id, required this.name, required this.email, required this.image});

  factory DummyUserModel.fromJson(Map<String, dynamic> json) {
    return DummyUserModel(
      id: json['id'],
      name: "${json['firstName']} ${json['lastName']}",
      email: json['email'],
      image: json['image'],
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) || other is DummyUserModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

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
          backgroundColor: Colors.deepPurple,
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
  List<OverlayPortalController> countryController1 = [];
  final stateController = OverlayPortalController();
  final cityController = OverlayPortalController();
  final itemController = OverlayPortalController();
  final multiCityController = OverlayPortalController();
  final userApiController = OverlayPortalController();

  CountryModel? selectedCountry;
  StatesModel? selectedState;
  CityModel? selectedCity;
  List<CityModel> selectedMultiCities = [];
  List<DummyUserModel> selectedApiUsers = [];

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

  FocusNode focusNodes = FocusNode();

  @override
  void initState() {
    super.initState();
    loadCity();
    loadState();
    loadCountry();

    countryController1 = List.generate(15, (index) => OverlayPortalController());
  }

  final GlobalKey<SearchFieldDropdownState<String>> dropdownKey1 = GlobalKey<SearchFieldDropdownState<String>>();
  final GlobalKey<SearchFieldDropdownState<String>> dropdownKey2 = GlobalKey<SearchFieldDropdownState<String>>();
  final GlobalKey<SearchFieldDropdownState<String>> dropdownKey3 = GlobalKey<SearchFieldDropdownState<String>>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                      enableInteractiveSelection: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: countryController,
                      initialItem: selectedCountry,
                      item: countryList,
                      decoration: SearchFieldDropdownDecoration(
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                        menuDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        fieldDecoration: InputDecoration(
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
                                if (selectedCountry != null) const SizedBox(width: 5),
                                const Icon(
                                  Icons.arrow_drop_down_sharp,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),
                      ), // Close decoration
                      onChanged: (CountryModel? value) {
                        selectedCountry = value;
                        setState(() {});
                      },
                      onSearch: (value) async {
                        return countryList.where((element) {
                          return element.name.toLowerCase().contains(value.toLowerCase());
                        }).toList();
                      },
                      listItemBuilder: (context, item, isSelected) {
                        int index = countryList.indexOf(item);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          margin: EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                          decoration: BoxDecoration(color: isSelected ? Colors.green : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                          child: Text(
                            item.name,
                            style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                          ),
                        );
                      },
                      selectedItemBuilder: (context, item) {
                        return Text(
                          item.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
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
                      decoration: SearchFieldDropdownDecoration(
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                        menuDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blueAccent),
                        ),
                        fieldDecoration: InputDecoration(
                          suffixIcon: IntrinsicWidth(
                            child: Row(
                              children: [
                                if (selectedState != null)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedState = null;
                                        if (selectedCountry == null) {
                                          tempStatesList.clear();
                                        }
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
                      ), // Close decoration
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
                          return element.name.toLowerCase().contains(value.toLowerCase());
                        }).toList();
                      },
                      listItemBuilder: (context, item, isSelected) {
                        // print("isSelected $isSelected");
                        int index = statesList.indexOf(item);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          margin: EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                          decoration: BoxDecoration(color: isSelected ? Colors.green : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                          child: Text(
                            item.name,
                            style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                          ),
                        );
                      },
                      selectedItemBuilder: (context, item) {
                        return Text(
                          item.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
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
                      decoration: SearchFieldDropdownDecoration(
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                        menuDecoration:
                            BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: Colors.blueAccent)),
                        fieldDecoration: InputDecoration(
                          suffixIcon: IntrinsicWidth(
                            child: Row(
                              children: [
                                if (selectedCity != null)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedCity = null;
                                        if (selectedState == null) {
                                          tempCityList.clear();
                                        }
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
                      ), // Close decoration
                      onChanged: (CityModel? value) {
                        setState(() {
                          selectedCity = value;
                        });
                      },
                      onSearch: (value) async {
                        return tempCityList.where((element) {
                          return element.name.toLowerCase().contains(value.toLowerCase());
                        }).toList();
                      },
                      listItemBuilder: (context, item, isSelected) {
                        int index = cityList.indexOf(item);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                          margin: EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                          decoration: BoxDecoration(color: isSelected ? Colors.green : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                          child: Text(
                            item.name,
                            style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                          ),
                        );
                      },
                      selectedItemBuilder: (context, item) {
                        return Text(
                          item.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                        );
                      },
                    ))
                  ],
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Multi-Select Example (Cities)", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                SearchFieldDropdown<CityModel>(
                  isMultiSelect: true,
                  initialItems: selectedMultiCities,
                  controller: multiCityController,
                  item: cityList,
                  decoration: SearchFieldDropdownDecoration(
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    menuDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blueAccent)),
                    focusedItemDecoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2)),
                    unfocusedItemDecoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(2)),
                    itemPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    fieldDecoration: const InputDecoration(
                      hintText: "Select multiple cities",
                      suffixIcon: Icon(Icons.arrow_drop_down_sharp, size: 20),
                    ),
                  ), // Close decoration
                  onItemsChanged: (List<CityModel> values) {
                    setState(() {
                      selectedMultiCities = values;
                    });
                  },
                  onSearch: (value) async {
                    return cityList.where((element) {
                      return element.name.toLowerCase().contains(value.toLowerCase());
                    }).toList();
                  },
                  listItemBuilder: (context, item, isSelected) {
                    int index = cityList.indexOf(item);
                    return Padding(
                      padding: EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                      child: Text(
                        item.name,
                        style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                      ),
                    );
                  },
                  selectedItemBuilder: (context, item) {
                    return Text(
                      item.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    );
                  },
                  selectedItemsBuilder: (context, items) {
                    return items.map((e) => e.name).join(', ');
                  },
                  showSelectedItemsInField: false,
                  multiSelectDisplayBuilder: (context, selectedItems, onRemove) {
                    if (selectedItems.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: selectedItems.map((city) {
                          return Chip(
                            label: Text(city.name, style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => onRemove(city),
                            backgroundColor: Colors.cyan.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Colors.cyan.withValues(alpha: 0.3)),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("API Multi-Select Example (Users)", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                SearchFieldDropdown<DummyUserModel>(
                  isMultiSelect: true,
                  initialItems: selectedApiUsers,
                  controller: userApiController,
                  isApiLoading: false,
                  item: const [], // start empty
                  onTap: () async {
                    // Fetch all users on tap
                    final response = await http.get(Uri.parse('https://dummyjson.com/users?limit=10'));
                    if (response.statusCode == 200) {
                      Map<String, dynamic> data = json.decode(response.body);
                      List users = data['users'];
                      return users.map((e) => DummyUserModel.fromJson(e)).toList();
                    }
                    return [];
                  },
                  onSearch: (value) async {
                    // TRUE SERVER-SIDE SEARCHING: Passing the search value directly to the remote API
                    final response = await http.get(Uri.parse('https://dummyjson.com/users/search?q=$value'));
                    if (response.statusCode == 200) {
                      Map<String, dynamic> data = json.decode(response.body);
                      List users = data['users'];
                      return users.map((e) => DummyUserModel.fromJson(e)).toList();
                    }
                    return [];
                  },
                  onItemsChanged: (List<DummyUserModel> values) {
                    setState(() {
                      selectedApiUsers = values;
                    });
                  },
                  decoration: SearchFieldDropdownDecoration(
                    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                    menuDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.blueAccent)),
                    focusedItemDecoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2)),
                    unfocusedItemDecoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(2)),
                    itemPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
                    fieldDecoration: const InputDecoration(
                      hintText: "Search remote users... (Try 'John')",
                      suffixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                  listItemBuilder: (context, item, isSelected) {
                    return Row(
                      children: [
                        CircleAvatar(radius: 14, backgroundImage: NetworkImage(item.image)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              Text(item.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  selectedItemBuilder: (context, item) {
                    return Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400));
                  },
                  selectedItemsBuilder: (context, items) {
                    return items.map((e) => e.name).join(', ');
                  },
                  showSelectedItemsInField: false,
                  multiSelectDisplayBuilder: (context, selectedItems, onRemove) {
                    if (selectedItems.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: selectedItems.map((user) {
                          return Chip(
                            avatar: CircleAvatar(backgroundImage: NetworkImage(user.image)),
                            label: Text(user.name, style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () => onRemove(user),
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.blue.withValues(alpha: 0.2)),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // Expanded(
                //   child: ListView.builder(
                //     shrinkWrap: true,
                //     itemCount: 10,
                //     itemBuilder: (context, index) {
                //     return InkWell(
                //       onTap: () {
                //         Navigator.push(context, MaterialPageRoute(builder: (context) =>DropDownClass() ,));
                //       },
                //       child: Container(
                //         height: 50,
                //         margin: EdgeInsets.symmetric(vertical: 10),
                //         child: Text("hello"),
                //       )
                //     );
                //   },),
                // ),

                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DropDownClass(),
                              ));
                        },
                        child: SearchFieldDropdown<CountryModel>(
                          // focusNode: focusNode,
                          overlayHeight: 250,
                          enableInteractiveSelection: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          controller: countryController1[index],
                          initialItem: selectedCountry,
                          fieldReadOnly: true,
                          item: countryList,
                          decoration: SearchFieldDropdownDecoration(
                            textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                            menuDecoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blueAccent),
                            ),
                            fieldDecoration: InputDecoration(
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
                                    if (selectedCountry != null) const SizedBox(width: 5),
                                    const Icon(
                                      Icons.arrow_drop_down_sharp,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ),
                          ), // Close decoration
                          onChanged: (CountryModel? value) {},
                          onSearch: (value) async {
                            return countryList.where((element) {
                              return element.name.toLowerCase().contains(value.toLowerCase());
                            }).toList();
                          },
                          listItemBuilder: (context, item, isSelected) {
                            int index = countryList.indexOf(item);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              margin: EdgeInsets.fromLTRB(5, index == 0 ? 7 : 2, 5, 1),
                              decoration: BoxDecoration(color: isSelected ? Colors.green : Colors.transparent, borderRadius: BorderRadius.circular(2)),
                              child: Text(
                                item.name,
                                style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          selectedItemBuilder: (context, item) {
                            return Text(
                              item.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
