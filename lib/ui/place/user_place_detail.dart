import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/place.dart';
import '../shared/dialog.dart';
import 'edit_place_screen.dart';
import 'place_manager.dart';
import 'user_place_screen.dart';

class UserPlaceDetail extends StatefulWidget {
  const UserPlaceDetail({super.key});
  static String routeName = 'user_place_detail_screen';

  @override
  State<UserPlaceDetail> createState() => _UserPlaceDetailState();
}

class _UserPlaceDetailState extends State<UserPlaceDetail> {
  late Place place;
  late String placeId;
  bool isLoading = true; // Biến để kiểm tra trạng thái tải

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      placeId = args?['placeId'] ?? '';
      _loadPlace(placeId);
    });
  }

  Future<void> _loadPlace(String placeId) async {
    // place = await context.read<PlaceManager>().getPlace(placeId);
    setState(() {
      isLoading = false; 
    });
  }

  Future<void> _delete() async{
    bool _isDelete = false;
    _isDelete = (await showConfirmDialog(context, "Bạn có chắc muốn xóa '${place.title}'"))!;
    if (_isDelete){
      context.read<PlaceManager>().deletePlace(placeId);
      Navigator.of(context).pop();
      Navigator.of(context).popAndPushNamed(UserPlaceScreen.routeName);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).popAndPushNamed(UserPlaceScreen.routeName);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: const Text('Chi tiết địa điểm', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
                Navigator.of(context).pushNamed(EditPlaceScreen.routeName, arguments: {'place': place});       
            },
            icon: const Icon(FontAwesomeIcons.pen, size: 18)
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: ClipRRect(
                      child: Image.network(
                        place.imageUrls[0],
                        fit: BoxFit.fill,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              child: Text(
                                "đ${place.price?.ceil()}",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              alignment: Alignment.centerLeft,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.title,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on_outlined, color: Colors.lightBlue),
                                    Flexible(
                                      child: Text(
                                        place.address,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.lightBlue),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          child: Text(
                            place.description != null ? place.description! : '',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        const SizedBox(height: 60),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: _delete,
                            style: TextButton.styleFrom(backgroundColor: Colors.blue),
                            child: const Text( 'Xóa địa điểm', style: TextStyle(fontSize: 20, color: Colors.white),)
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}




// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';

// import '../../models/place.dart';
// import '../shared/custom_page_route.dart';
// import '../shared/dialog.dart';
// import 'place_manager.dart';
// import 'user_place_detail.dart';

// class EditPlaceScreen extends StatefulWidget {
//   const EditPlaceScreen({super.key});
//   static String routeName = 'edit_place';

//   @override
//   State<EditPlaceScreen> createState() => _EditPlaceScreenState();
// }

// class _EditPlaceScreenState extends State<EditPlaceScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey();
//   final Map<String, dynamic> _placeData = {
//     'id': '',
//     'title': '',
//     'address': '',
//     'description': '',
//     'price': 0.0,
//     'images': <File>[], // Hình ảnh mới từ thiết bị
//     'existingImages': <String>[], // Hình ảnh cũ từ server
//   };
//   final _nameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _priceController = TextEditingController();
//   var _isSubmitting = ValueNotifier<bool>(false);

//   Future<void> _submit() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }
//     _formKey.currentState!.save();
//     _isSubmitting.value = true;
//     try {
//       FocusScope.of(context).unfocus();
//       await context.read<PlaceManager>().updatePlace(
//             _placeData['id'],
//             _placeData['title']!,
//             _placeData['address']!,
//             _placeData['description']!,
//             _placeData['price']!,
//             _placeData['images']!, // Hình ảnh mới
//             _placeData['existingImages'], // Hình ảnh cũ
//           );
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Cập nhật thành công!')),
//       );

//       await Future.delayed(const Duration(seconds: 2));
//       Navigator.of(context).pop();
//       Navigator.of(context).pop();
//       Navigator.of(context).push(CustomPageRoute(
//         page: const UserPlaceDetail(),
//         arguments: {'placeId': _placeData['id']},
//       ));
//     } catch (error) {
//       if (mounted) {
//         showErrorDialog(context, 'Cập nhật không thành công');
//       }
//     }
//     _isSubmitting.value = false;
//   }

//   Future<void> _pickImages() async {
//     final imagePicker = ImagePicker();
//     try {
//       final List<XFile>? imageFiles = await imagePicker.pickMultiImage();
//       if (imageFiles == null || imageFiles.isEmpty) {
//         return;
//       }

//       setState(() {
//         _placeData['images'].addAll(
//           imageFiles.map((image) => File(image.path)).toList(),
//         );
//       });
//     } catch (error) {
//       if (mounted) {
//         showErrorDialog(context, 'Không thể chọn hình ảnh');
//       }
//     }
//   }

//   void _removeImage(int index, {bool isNew = false}) {
//     setState(() {
//       if (isNew) {
//         _placeData['images'].removeAt(index);
//       } else {
//         _placeData['existingImages'].removeAt(index);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final args =
//         ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
//     Place place = args?['place'] ??
//         Place(title: '', address: '', imageUrls: [], description: '');

//     _nameController.text = place.title;
//     _addressController.text = place.address;
//     _descriptionController.text = place.description ?? '';
//     _priceController.text = place.price.toString();
//     _placeData['id'] = place.id;
//     _placeData['title'] = place.title;
//     _placeData['address'] = place.address;
//     _placeData['description'] = place.description;
//     _placeData['price'] = place.price;
//     _placeData['existingImages'] = place.imageUrls; // Gán hình ảnh từ server

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.lightBlue,
//         leading: IconButton(
//           onPressed: () {
//             FocusScope.of(context).unfocus();
//             Navigator.pop(context);
//           },
//           icon: const Icon(Icons.arrow_back_ios),
//         ),
//         title: const Text('Cập nhật địa điểm'),
//         centerTitle: true,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _buildImageSelector(),
//                 const SizedBox(height: 20),
//                 _buildNameField(),
//                 const SizedBox(height: 20),
//                 _buildAddressField(),
//                 const SizedBox(height: 20),
//                 _buildDescriptionField(),
//                 const SizedBox(height: 20),
//                 _buildPriceField(),
//                 const SizedBox(height: 20),
//                 ValueListenableBuilder<bool>(
//                   valueListenable: _isSubmitting,
//                   builder: (context, isSubmitting, child) {
//                     return isSubmitting
//                         ? const CircularProgressIndicator()
//                         : _buildSubmitButton();
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageSelector() {
//     final existingImages = _placeData['existingImages'];
//     final newImages = _placeData['images'];

//     return Container(
//       height: 300,
//       child: GridView.builder(
//         itemCount: existingImages.length + newImages.length + 1,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           childAspectRatio: 1,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemBuilder: (context, index) {
//           if (index < existingImages.length) {
//             return Stack(
//               children: [
//                 Image.network(
//                   existingImages[index],
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: IconButton(
//                     icon: const Icon(Icons.cancel, size: 30),
//                     onPressed: () => _removeImage(index),
//                   ),
//                 ),
//               ],
//             );
//           }
//           if (index < existingImages.length + newImages.length) {
//             final newIndex = index - existingImages.length;
//             return Stack(
//               children: [
//                 Image.file(
//                   newImages[newIndex],
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//                 Positioned(
//                   top: 0,
//                   right: 0,
//                   child: IconButton(
//                     icon: const Icon(Icons.cancel, size: 30),
//                     onPressed: () => _removeImage(newIndex, isNew: true),
//                   ),
//                 ),
//               ],
//             );
//           }
//           return TextButton.icon(
//             icon: const Icon(Icons.add_a_photo),
//             label: const Text('Thêm ảnh'),
//             onPressed: _pickImages,
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildNameField() {
//     return TextFormField(
//       controller: _nameController,
//       decoration: InputDecoration(
//         label: const Text('Tên địa điểm'),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return 'Vui lòng nhập tên địa điểm';
//         if (value.length < 6) return 'Tên địa điểm quá ngắn';
//         return null;
//       },
//       onSaved: (value) {
//         _placeData['title'] = value!;
//       },
//     );
//   }

//   Widget _buildAddressField() {
//     return TextFormField(
//       controller: _addressController,
//       decoration: InputDecoration(
//         label: const Text('Địa chỉ'),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return 'Vui lòng nhập địa chỉ';
//         if (value.length < 10) return 'Địa chỉ quá ngắn';
//         return null;
//       },
//       onSaved: (value) {
//         _placeData['address'] = value!;
//       },
//     );
//   }

//   Widget _buildDescriptionField() {
//     return TextFormField(
//       controller: _descriptionController,
//       maxLines: 3,
//       decoration: InputDecoration(
//         label: const Text('Mô tả'),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return 'Vui lòng nhập mô tả';
//         if (value.length < 20) return 'Mô tả quá ngắn';
//         return null;
//       },
//       onSaved: (value) {
//         _placeData['description'] = value!;
//       },
//     );
//   }

//   Widget _buildPriceField() {
//     return TextFormField(
//       controller: _priceController,
//       keyboardType: TextInputType.number,
//       decoration: InputDecoration(
//         label: const Text('Giá'),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(width: 1),
//         ),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return 'Vui lòng nhập giá';
//         if (double.tryParse(value) == null) return 'Vui lòng nhập số hợp lệ';
//         if (double.parse(value) <= 0) return 'Giá phải lớn hơn 0';
//         return null;
//       },
//       onSaved: (value) {
//         _placeData['price'] = double.parse(value!);
//       },
//     );
//   }

//   Widget _buildSubmitButton() {
//     return ElevatedButton(
//       onPressed: _submit,
//       child: const Text('Cập nhật địa điểm'),
//     );
//   }
// }

