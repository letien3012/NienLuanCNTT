import 'dart:io';
import 'package:NienLuan/ui/place/room_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../../models/place.dart';
import '../shared/custom_page_route.dart';
import '../shared/dialog.dart';
import 'room_manager.dart';

class EditRoomScreen extends StatefulWidget {
  const EditRoomScreen({super.key});
  static String routeName='edit_place';

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, dynamic> _placeData = {
    'id': '',
    'title': '',
    'address': '',
    'city': null,
    'district': '',
    'type': '',
    'roomCount': 0,
    'hasLoft': '',
    'description': '',
    'price': 0.0,
    'area': null,
    'images': <File>[], 
    'quantiy': 0
  };
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _areaController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  var _isSubmitting = ValueNotifier<bool>(false);
  late Place place;
  final List<String> _city = ['Thành phố Cần Thơ', 'Thành phố Hồ Chí Minh',];
  final Map<String, List<String>> _districts = {
    'Thành phố Cần Thơ': ['Quận Ninh Kiều', 'Quận Bình Thủy', 'Quận Cái Răng'],
    'Thành phố Hồ Chí Minh': ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6', 'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12', 'Quận Bình Tân'],
  };
  String? _selectedDistrict;
  final List<String> _roomTypes = ['Phòng trọ', 'Minihouse']; 
  String? _selectedRoomType; 
  int? _selectedRoomCount; 
  bool? _hasLoft;
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _isSubmitting.value = true;
    try {
      FocusScope.of(context).unfocus();
      await context.read<RoomManager>().updatePlace(_placeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );
      
      await Future.delayed(const Duration(seconds: 2));
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).push(CustomPageRoute(page: RoomDetailScreen(), arguments:{'placeId': _placeData['id']} ));
      // Navigator.of(context).popAndPushNamed(UserPlaceDetail.routeName, 
      // arguments: {
      //   'placeId': _placeData['id']
      // });
    } catch (error) {
      print(error);
      if (mounted){
        showErrorDialog(context, 'Cập nhật không thành công');
      }
    }
    _isSubmitting.value = false;
  }
  Future<void> _pickImages() async {
    final imagePicker = ImagePicker();
    try {
      final List<XFile>? imageFiles = await imagePicker.pickMultiImage();
      if (imageFiles == null || imageFiles.isEmpty) {
        return; 
      }

      setState(() {
        _placeData['images'].addAll(imageFiles.map((image) => File(image.path)).toList());
      });
    } catch (error) {
      if (mounted) {
        showErrorDialog(context, 'Something went wrong.');
      }
    }
  }
  void _removeImage(int index) {
  setState(() {
      _placeData['images'].removeAt(index); // Xóa hình ảnh ở chỉ số index
    });
  }
  Future<List<File?>> downloadFiles(List<String> urls) async {
    List<File?> downloadedFiles = [];

    for (String url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = Uri.parse(url).pathSegments.last;
          final filePath = '${directory.path}/$fileName';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          downloadedFiles.add(file);
        } else {
          print('Failed to download file: ${response.statusCode}');
          downloadedFiles.add(null);
        }
      } catch (e) {
        print('Error: $e');
        downloadedFiles.add(null);
      }
    }

    return downloadedFiles;
  }
  Future<void> convertUrlsToFiles(List<String> urls) async {
    final downloadedFiles = await downloadFiles(urls);
    setState(() {
      _placeData['images'] = downloadedFiles.where((file) => file != null).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    
    // Lấy dữ liệu từ route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        place = args['place'] ?? Place(title: '', address: '', imageUrls: [], description: '');
        _nameController.text = place.title;
        _addressController.text = place.address;
        _descriptionController.text = place.description ?? '';
        _priceController.text = place.price.toString();
        _areaController.text = place.area.toString();
        _quantityController.text = place.quantity.toString();
        _placeData['id'] = place.id;
        _placeData['title'] = place.title;
        _placeData['address'] = place.address;
        _placeData['description'] = place.description;
        _placeData['price'] = place.price;
        _placeData['city']= place.city;
        _placeData['district']= place.district;
        _selectedDistrict = place.district;
        _placeData['type']= place.type;
        _selectedRoomType = place.type;
        _placeData['hasLoft']= place.hasLoft;
        _hasLoft = place.hasLoft;
        _placeData['roomCount'] = place.roomCount;
        _selectedRoomCount = place.roomCount;
        _placeData['area']= place.area;
        _placeData['quantity']= place.quantity;
        
        // Chuyển đổi URL thành file hình ảnh
        if (place.imageUrls.isNotEmpty) {
          await convertUrlsToFiles(place.imageUrls);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    // Place place = args?['place'] ?? Place(title: '', address: '', imageUrls: [], description: '');
    // _nameController.text = place.title;
    // _addressController.text = place.address;
    // _descriptionController.text = place.description != null ? place.description! : '';
    // _priceController.text = place.price.toString();
    // _placeData['id'] = place.id;
    // _placeData['title'] =place.title;
    // _placeData['address'] =place.address;
    // _placeData['description'] =place.description;
    // _placeData['price'] =place.price;
   
    // _placeData['images'] = place.imageUrls.map((url) => File(url)).toList();
    // print(_placeData['images']);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        leading: IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Cập nhật thông tin trọ'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 350,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.redAccent),
                        ),
                        child: _placeData['images'].isEmpty
                            ? SizedBox(
                                width: 100,
                                height: 50,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.image),
                                  label: Text('Chọn hình ảnh'),
                                  onPressed: _pickImages, // Gọi hàm chọn hình ảnh
                                ),
                              )
                            : Stack(
                                children: [
                                  GridView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: _placeData['images'].length+1,
                                    itemBuilder: (context, index) {
                                      if (index < _placeData['images'].length)
                                      return Stack(
                                        children: [
                                          Image.file (
                                            // width: 350,              
                                            _placeData['images'][index],
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: IconButton(
                                              icon: Icon(Icons.cancel, size: 30,),
                                              onPressed: () => _removeImage(index)
                                            )
                                          )
                                        ],
                                      );
                                      else {
                                        return SizedBox(
                                          width: 100,
                                          height: 50,
                                          child: TextButton.icon(
                                            icon: const Icon(Icons.image),
                                            label: Text('Thêm hình ảnh'),
                                            onPressed: _pickImages, // Gọi hàm chọn hình ảnh
                                          ),
                                        );
                                      }
                                    }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1,),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                _buildNameField(),
                const SizedBox(height: 20,),
                _buildCityField(),
                const SizedBox(height: 20,),
                _buildDistrictField(), 
                const SizedBox(height: 20,),
                _buildAddressField(),
                 const SizedBox(height: 20,),
                _buildRoomTypeField(), // Thêm dropdown loại phòng
                const SizedBox(height: 20,),
                if (_selectedRoomType == 'Minihouse') _buildRoomCountField(), // Dropdown số phòng
                if (_selectedRoomType == 'Phòng trọ') _buildLoftField(), // Dropdown có gác
                const SizedBox(height: 20,),
                _buildDescriptionField(),
                const SizedBox(height: 20,),
                _buildAreaField(),               
                const SizedBox(height: 20),
                _buildQuantityField(),
                const SizedBox(height: 20),
                _buildPriceField(),
                const SizedBox(height: 20,),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSubmitting,
                  builder: (context, isSubmitting, child) {
                    if (isSubmitting) {
                      return const CircularProgressIndicator();
                    }
                    return _buildSubmitButton();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
          label: const Text('Tên trọ'), 
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.length == 0){
          return 'Vui lòng tên địa điểm';
        }
        else if (value.length < 6) {
          return 'Tên quá ngắn';
        }
        return null;
      },
      onSaved: (value) {
        _placeData['title'] = value!;
      },
    );
  }
  Widget _buildCityField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: const Text('Thành phố'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      value:  _placeData['city'],
      items: _city.map((city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _placeData['city'] = value!;
          _selectedDistrict = null; // Reset quận đã chọn
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn thành phố';
        }
        return null;
      },
    );
  }
  Widget _buildDistrictField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: const Text('Quận'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      value: _selectedDistrict,
      items: _districts[_placeData['city']]?.map((district) {
        return DropdownMenuItem<String>(
          value: district,
          child: Text(district),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDistrict = value; 
          _placeData['district'] = value;// Cập nhật quận đã chọn
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn quận';
        }
        return null;
      },
    );
  }
  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
          label: const Text('Địa chỉ'), 
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.length == 0){
          return 'Vui lòng nhập địa chỉ';
        } else if (value.length < 10) {
          return 'Địa chỉ quá ngắn';
        }
        return null;
      },
      onSaved: (value) {
        _placeData['address'] = value!;
      },
    );
  }
  Widget _buildRoomTypeField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: const Text('Loại phòng'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      value: _selectedRoomType,
      items: _roomTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(type),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoomType = value; // Cập nhật loại phòng đã chọn
          _placeData['type'] = value; // Lưu vào _placeData
          _selectedRoomCount = null; // Reset số phòng
          _hasLoft = null; // Reset có gác
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn loại phòng';
        }
        return null;
      },
    );
  }
  Widget _buildRoomCountField() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        label: const Text('Số phòng'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      value: _selectedRoomCount,
      items: List.generate(5, (index) => index + 1).map((count) {
        return DropdownMenuItem<int>(
          value: count,
          child: Text('$count phòng'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRoomCount = value; // Cập nhật số phòng đã chọn
          _placeData['roomCount'] = value; // Lưu vào _placeData
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn số phòng';
        }
        return null;
      },
    );
  }

  Widget _buildLoftField() {
    return DropdownButtonFormField<bool>(
      decoration: InputDecoration(
        label: const Text('Có gác không?'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      value: _hasLoft,
      items: [
        DropdownMenuItem<bool>(
          value: true,
          child: Text('Có'),
        ),
        DropdownMenuItem<bool>(
          value: false,
          child: Text('Không'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _hasLoft = value; // Cập nhật trạng thái có gác
          _placeData['hasLoft'] = value; // Lưu vào _placeData
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn có gác hay không';
        }
        return null;
      },
    );
  }
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      decoration: InputDecoration(
          label: const Text('Mô tả quy định'), 
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
      ),
      validator: (value) {
        if (value == null || value.length == 0){
          return 'Vui lòng nhập mô tả';
        }
        else if (value.length < 20) {
          return 'Mô tả ít nhắn 20 ký tự';
        }
        return null;
      },
      onSaved: (value) {
        _placeData['description'] = value!;
      },
    );
  }
  Widget _buildAreaField() {
    return TextFormField(
      controller: _areaController,
      keyboardType: TextInputType.numberWithOptions(),
      decoration: InputDecoration(
        label: const Text('Diện tích (m²)'), 
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập diện tích';
        }
        if (double.tryParse(value) == null) {
          return 'Vui lòng nhập giá trị hợp lệ';
        }
        if (double.parse(value) <= 0) {
          return 'Diện tích phải lớn hơn 0';
        }
        if (double.parse(value) >= 1000) {
          return 'Bán đất ha dì bự dữ ạ';
        }
        return null;
      },
      onSaved: (value) {
        _placeData['area'] = double.parse(value!);
      },
    );
  }
  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: TextInputType.numberWithOptions(),
      decoration: InputDecoration(
        label: const Text('Số lượng phòng'), 
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 1, color: Colors.red),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số lượng phòng';
        }
        if (double.tryParse(value) == null) {
          return 'Vui lòng nhập giá trị hợp lệ';
        }
        if (double.parse(value) <= 0) {
          return 'Số lượng phải lớn hơn 0';
        }
        if (double.parse(value) >= 30) {
          return 'Nhà trọ hay tổ kiến';
        }
        return null;
      },
      onSaved: (value) {
        _placeData['quantity'] = int.parse(value!);
      },
    );
  }
  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      keyboardType: TextInputType.numberWithOptions(),
      decoration: InputDecoration(
          label: const Text('Giá (vnđ)'), 
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(width: 1,color: Colors.red),            
          ),
      ),
      validator: (value) {
        if (value == null || value.length == 0){
          return 'Vui lòng nhập giá';
        }
        if (double.tryParse(value) == null){
          return 'Vui lòng nhập số tiền hợp lệ';
        }
        if (double.parse(value) <= 0){
          return 'Vui lòng điền số lớn hơn 0';
        }
        return null;
      },
      onSaved: (value) {
        _placeData['price'] = double.parse(value!);
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: _submit, 
        style: TextButton.styleFrom(
          backgroundColor: Colors.redAccent
        ),
        child: Text('Cập nhật', style: TextStyle(fontSize: 20, color: Colors.white),)
      ),
    ); 
  }

}