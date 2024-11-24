import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../auth/auth_manager.dart';
import '../main_screen.dart';
import '../shared/custom_page_route.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);
  static String routeName = 'update_profile_screen';

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late Future<User> _fetchUser;
  final GlobalKey<FormState> _formKey = GlobalKey();
  final Map<String, dynamic> _authData = {
    'name': '',
    'email': '',
    'address': '',
    'phone': '',
    'city': null,
    'district': '',
  };
  final _isSubmitting = ValueNotifier<bool>(false);

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final List<String> _city = ['Thành phố Cần Thơ', 'Thành phố Hồ Chí Minh',];
  final Map<String, List<String>> _districts = {
    'Thành phố Cần Thơ': ['Quận Ninh Kiều', 'Quận Bình Thủy', 'Quận Cái Răng'],
    'Thành phố Hồ Chí Minh': ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6', 'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12', 'Quận Bình Tân'],
  };
  String? _selectedDistrict;
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    _isSubmitting.value = true;
    try {
      await context.read<AuthManager>().updateUserInfo(_authData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thành công!')),
      );
      await Future.delayed(const Duration(seconds: 3));
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop();
      Navigator.of(context).push(CustomPageRoute(page: MainScreen(), arguments: {'index':3}));
      // Navigator.of(context).popAndPushNamed(MainScreen.routeName, arguments: {'index':3});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật thất bại: $error')),
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(width: 1, color: Colors.red),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUser = context.read<AuthManager>().getUserInfo();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        leading: IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Chỉnh sửa thông tin'),
        centerTitle: true,
      ),
      body: FutureBuilder<User>(
        future: _fetchUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            _nameController.text = user.name;
            _emailController.text = user.email;
            _phoneController.text = user.phone!;
            _addressController.text = user.address!;
            _authData['city']= user.city;
            _authData['district']= user.district;
            _selectedDistrict = user.district;
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child:  Image.network(
                                snapshot.data!.imageUrl,
                                fit: BoxFit.cover,
                              )
                        ),
                      ),
                      const SizedBox(height: 50),
                      // Form fields
                      _buildTextField(_nameController, 'Họ và tên',
                          FontAwesomeIcons.user, TextInputType.name),
                      const SizedBox(height: 10),
                      _buildTextField(_emailController, 'Email',
                          FontAwesomeIcons.envelope, TextInputType.emailAddress),
                      const SizedBox(height: 10),
                      _buildTextField(_phoneController, 'Điện thoại',
                          FontAwesomeIcons.phone, TextInputType.phone),
                      const SizedBox(height: 10),
                      _buildCityField(),
                      const SizedBox(height: 20,),
                      _buildDistrictField(), 
                      const SizedBox(height: 20,),
                      _buildTextField(_addressController, 'Địa chỉ',
                          Icons.location_pin, TextInputType.streetAddress),
                      const SizedBox(height: 10),
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
            );
          } else {
            return const Center(child: Text('Không có dữ liệu người dùng.'));
          }
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, TextInputType keyboardType) {
    return TextFormField(
      maxLength: 30,
      readOnly: label=='Email' ? true : false,
      controller: controller,
      decoration: _inputDecoration(label, icon),
      keyboardType: keyboardType,
      validator: (value) {
         if (label == 'Họ và tên') {
          if (value!.isEmpty) {
            return 'Vui lòng nhập họ tên';
          } else if (value.length < 8) {
            return 'Họ tên quá ngắn';
          }
        } 
        if (label == 'Email') {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập email';
          } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Email không hợp lệ!';
          }
        } 
        if (label == 'Điện thoại') {
          if (value!.isEmpty){
            return 'Vui lòng nhập số điện thoại';
          } else if (!RegExp(r'^(0|\+84)[35789]\d{8}$').hasMatch(value!)) {
          return 'Số điện thoại không hợp lệ';
          }
        }
        if (label == 'Địa chỉ') {
          if (value!.isEmpty ){
            return 'Vui lòng nhập địa chỉ';
          }
          else if (value.length < 10){
            return 'Địa chỉ quá ngắn!';
          }
        }
        return null;
      },
      onSaved: (value)  {
        String key='';
        if (label == 'Họ và tên'){
          key = 'name';
        } else if (label == 'Điện thoại'){
          key='phone';
        } else if (label == 'Địa chỉ'){
          key='address';
        } else if (label == 'Email'){
          key='email';
        }
        _authData[key] = value!;
      }
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
      value:  _authData['city'],
      items: _city.map((gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _authData['city'] = value!;
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
      items: _districts[_authData['city']]?.map((district) {
        return DropdownMenuItem<String>(
          value: district,
          child: Text(district),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDistrict = value; 
          _authData['district'] = value!;// Cập nhật quận đã chọn
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
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: TextButton(
        onPressed: _submit,
        style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
        child: const Text(
          'Cập nhật thông tin',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
