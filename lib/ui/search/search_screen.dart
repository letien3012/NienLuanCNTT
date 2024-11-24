import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/place.dart';
import '../place/room_detail_screen.dart';
import '../place/room_manager.dart';
import '../widgets/place_list.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search';
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = "";
  List<Place> filteredPlaces = [];
  String? selectedCity;
  List<String> selectedDistrict= [];
  String? selectedRoomType;
  List<dynamic> selectedRoomFeature = [];
  String? selectedRentPrice;
  double selectedMinPrice=0;
  double selectedMaxPrice=0;
  int? selectedRoomQuantity = null;
  @override
  void initState() {
    super.initState();
    final placeManager = Provider.of<RoomManager>(context, listen: false);
    placeManager.loadPlaces(false).then((_) {
      setState(() {
        filteredPlaces = placeManager.places ?? [];
      });
    });
  }
   String formatPrice(double price) {
    if (price >= 1000000) {
      return NumberFormat().format(price / 1000000) + ' triệu';
    } else if (price >= 1000) {
      return NumberFormat().format(price / 1000) + ' nghìn';
    } else {
      return NumberFormat().format(price);
    }
  }
  void updateSearch(String query) {
    setState(() {
        searchQuery = query;
        final places = Provider.of<RoomManager>(context, listen: false).places ?? [];
        filteredPlaces = places.where((place) {
        final nameMatch = place.title.toLowerCase().contains(query.toLowerCase());
        final addressMatch = place.address.toLowerCase().contains(query.toLowerCase());
        final priceMatch = formatPrice(place.price ?? 0).toString().toLowerCase().contains(query.toLowerCase());
        return nameMatch || addressMatch || priceMatch;
      }).toList();
    });
  }

  Future<void> _refreshPlaces() async {
    final placeManager = Provider.of<RoomManager>(context, listen: false);
    await placeManager.loadPlaces(false);
    setState(() {
      filteredPlaces = placeManager.places ?? [];
    });
  }

  void applyFilters() {
    final placeManager = Provider.of<RoomManager>(context, listen: false);
    List<Place> places = placeManager.places ?? [];
    final filtered = places.where((place) {
      if (selectedRoomQuantity!= null){
         if (selectedRoomQuantity! > place.quantity!) return false;
      }
      if (place.quantity == 0) return false;
      if (selectedRoomType != null && place.type != selectedRoomType) return false;
      if (selectedRoomFeature.isNotEmpty && selectedRoomType== 'Phòng trọ') {
        if (!selectedRoomFeature.contains(place.hasLoft)) return false;
      }
      if (selectedRoomFeature.isNotEmpty && selectedRoomType== 'Minihouse') {
        if (!selectedRoomFeature.contains(place.roomCount)) return false;
      }
      if (selectedCity != null && place.city != selectedCity) return false;

      if (selectedDistrict.isNotEmpty) {
        if (!selectedDistrict.contains(place.district)) return false;
      }
      if (selectedRentPrice != null) {
        if (selectedMinPrice != 0 && selectedMaxPrice!= 0){
          if (place.price! > selectedMaxPrice) return false;
          if (place.price! <selectedMinPrice) return false;
        }
      }
      return true;
    }).toList();
    setState(() {
      filteredPlaces = filtered;
    });
  }

  void showAddressFilterModal(BuildContext context) {
    Map<String, List<String>> cityDistricts = {
      "Thành phố Cần Thơ": ["Quận Ninh Kiều", "Quận Bình Thủy", "Quận Cái Răng"],
      "Thành phố Hồ Chí Minh": ['Quận 1','Quận 2','Quận 3','Quận 4','Quận 5','Quận 6','Quận 7','Quận 8','Quận 9','Quận 10','Quận 11','Quận 12','Quận Bình Tân']
    };
    List<String> districts = selectedCity != null ? cityDistricts[selectedCity!] ?? [] : [];
    showModalBottomSheet(context: context,isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Chọn thành phố", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 16),
                  const Text("Thành phố",style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: cityDistricts.keys.map((city) {
                      return FilterChipWidget(
                        label: city,
                        onSelected: (selected) {
                          setState(() {
                            selectedCity = selected ? city : selectedCity;
                            districts = selected ? cityDistricts[city]! : [];
                            selectedDistrict = [];
                          });
                        },
                        isSelected: selectedCity == city,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (selectedCity != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Quận",style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: districts.map((district) {
                            return FilterChipWidget(
                              label: district,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedDistrict.add(district);
                                  } else {
                                    selectedDistrict.remove(district);
                                  }
                                });
                              },
                              isSelected: selectedDistrict.contains(district),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedCity = null;
                            selectedDistrict = [];
                          });
                          applyFilters();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text("Xóa bộ lọc",style: TextStyle(color: Colors.redAccent, fontSize: 16),),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          "Áp dụng",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showPriceFilterModal(BuildContext context) {
    Map<String, List<int>> priceRanges = {
      "Dưới 1 triệu": [500000, 1000000],
      "1-3 triệu": [1000000, 3000000],
      "3-4 triệu": [3000000, 4000000],
      "4-5 triệu": [4000000, 5000000],
      "5-7 triệu": [5000000, 7000000],
      "7-10 triệu": [7000000, 10000000],
      "10-20 triệu": [10000000, 20000000],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Giá thuê",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: priceRanges.keys.map((priceRange) {
                      return FilterChipWidget(
                        label: priceRange,
                        isSelected: selectedRentPrice == priceRange,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedRentPrice = selected ? priceRange : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedRentPrice = null;
                            selectedMinPrice = 0;
                            selectedMaxPrice = 0;
                            applyFilters();
                            Navigator.of(context).pop();
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          "Xóa bộ lọc",
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedRentPrice != null) {
                            List<int> range = priceRanges[selectedRentPrice]!;
                            selectedMinPrice = range[0].toDouble();
                            selectedMaxPrice = range[1].toDouble();
                            applyFilters();
                          }
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          "Áp dụng",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showTypeFilterModal(BuildContext context) {
    Map<String, List<dynamic>> rooms = {
      "Phòng trọ": [{"label": "Có gác", "value": true},{"label": "Không gác", "value": false}],
      "Minihouse": [{"label": "1 phòng ngủ", "value": 1},{"label": "2 phòng ngủ", "value": 2},{"label": "3 phòng ngủ", "value": 3},{"label": "4 phòng ngủ", "value": 4},{"label": "5 phòng ngủ", "value": 5}]
    };

    List<dynamic> roomFeature = selectedRoomType != null ? rooms[selectedRoomType!] ?? [] : [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Chọn loại phòng",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Loại phòng",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: rooms.keys.map((room) {
                      return FilterChipWidget(
                        label: room,
                        onSelected: (selected) {
                          setState(() {
                            selectedRoomType = selected ? room : selectedRoomType;
                            roomFeature = selected ? rooms[room]! : [];
                            selectedRoomFeature = [];
                          });
                        },
                        isSelected: selectedRoomType == room,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (selectedRoomType != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Đặc điểm",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: roomFeature.map((feature) {
                            return FilterChipWidget(
                              label: feature["label"],
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedRoomFeature.add(feature["value"]);
                                  } else {
                                    selectedRoomFeature.remove(feature["value"]);
                                  }
                                });
                              },
                              isSelected: selectedRoomFeature.contains(feature["value"]),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            selectedRoomType = null;
                            selectedRoomFeature = [];
                          });
                          applyFilters();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          "Xóa bộ lọc",
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          "Áp dụng",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void showQuantityFilterModal(BuildContext context) {
  TextEditingController quantityController = TextEditingController(); 

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nhập số lượng phòng trống",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // TextField to input room quantity
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số lượng phòng',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        quantityController.clear(); // Clear the input field
                        setState(() {
                          selectedRoomQuantity = null; // Reset quantity filter
                          applyFilters(); // Apply the cleared filter
                          Navigator.of(context).pop();
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Xóa bộ lọc",
                        style: TextStyle(color: Colors.redAccent, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String input = quantityController.text;
                        if (input.isNotEmpty && int.tryParse(input) != null) {
                          selectedRoomQuantity = int.parse(input);
                          applyFilters(); 
                        }
                        Navigator.pop(context); // Close the modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Áp dụng",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    },
  );
}

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: const Text('Tìm kiếm',style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold),),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPlaces,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  onChanged: updateSearch,
                  decoration: InputDecoration(
                    hintText: 'Nhập tên hoặc địa chỉ muốn tìm',
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
              ),  
              SingleChildScrollView(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                scrollDirection: Axis.horizontal,
                physics: AlwaysScrollableScrollPhysics(),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        showAddressFilterModal(context); // Gọi modal
                      },
                      child: Row(children: [
                        Text('Địa chỉ', style: TextStyle(color: Colors.black),),
                        Icon(Icons.arrow_drop_down_sharp)
                      ],),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        showPriceFilterModal(context); 
                      },
                      child: Row(children: [
                        Text('Giá', style: TextStyle(color: Colors.black),),
                        Icon(Icons.arrow_drop_down_sharp)
                      ],),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        showTypeFilterModal(context);
                      },
                      child: Row(children: [
                        Text('Loại phòng', style: TextStyle(color: Colors.black),),
                        Icon(Icons.arrow_drop_down_sharp)
                      ],),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        showQuantityFilterModal(context);
                      },
                      child: Row(children: [
                        Text('Số lượng phòng trống', style: TextStyle(color: Colors.black),),
                        Icon(Icons.arrow_drop_down_sharp)
                      ],),
                    ),
                  ],
                ),
              ) ,           
              filteredPlaces.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredPlaces.length,
                        itemBuilder: (BuildContext context, int index) {
                          final place = filteredPlaces[index];
                          return PlaceList(
                            imageUrl: place.imageUrls[0],
                            address: place.address,
                            title: place.title,
                            price: place.price!,
                            ontap: () {
                              Navigator.of(context).pushNamed(RoomDetailScreen.routeName, arguments: {'placeId': place.id});
                            },
                          );
                        },
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                      ),
                    )
                  : const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Không tìm thấy địa điểm, vui lòng nhập lại',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterChipWidget extends StatelessWidget {
  final String label;
  final Function(bool)? onSelected;
  final bool? isSelected;

  const FilterChipWidget({
    Key? key,
    required this.label,
    this.onSelected,
    this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected! ? Colors.white : Colors.black,
      ),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.redAccent,
      selected: isSelected!,
      onSelected: (bool selected) {
        if (onSelected != null) {
          onSelected!(selected); 
        }
      },
    );
  }
}

// class FilterChipWidget extends StatefulWidget {
//   final String label;
//   final Function(bool)? onSelected; 
//   final isSelected;
//   const FilterChipWidget({Key? key, required this.label, this.onSelected, this.isSelected}) : super(key: key);

//   @override
//   _FilterChipWidgetState createState() => _FilterChipWidgetState();
// }

// class _FilterChipWidgetState extends State<FilterChipWidget> {
//   bool isSelected = false;

//   @override
//   Widget build(BuildContext context) {
//     return FilterChip(
//       label: Text(widget.label),
//       labelStyle: TextStyle(
//         color: isSelected ? Colors.white : Colors.black,
//       ),
//       backgroundColor: Colors.grey[200],
//       selectedColor: Colors.redAccent,
//       selected: isSelected,
//       onSelected: (bool selected) {
//         setState(() {
//           isSelected = selected; // Cập nhật trạng thái isSelected
//         });
//         if (widget.onSelected != null) {
//           widget.onSelected!(selected); // Gọi hàm onSelected nếu không null
//         }
//       },
//     );
//   }
// }
