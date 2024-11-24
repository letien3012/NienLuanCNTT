import 'dart:ffi';

import 'package:NienLuan/ui/auth/auth_manager.dart';
import 'package:NienLuan/ui/auth/signin_screen.dart';
import 'package:NienLuan/ui/shared/custom_page_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../shared/dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  static String routeName = 'signup_screen';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formsignupKey = GlobalKey();
  final Map<String, dynamic> _authData = {
    'name': '',
    'email': '',
    'password': '',
    'gender': null,
    'city': null,
    'district': '',
    'role': null
  };
  final _isSubmitting = ValueNotifier<bool>(false);
  final _passwordController = TextEditingController();
  bool is_obscurepassword = true;
  bool is_obscureconfirmpassword = true;
  final List<String> _city = ['Thành phố Cần Thơ', 'Thành phố Hồ Chí Minh',];
  final Map<String, List<String>> _districts = {
    'Thành phố Cần Thơ': ['Quận Ninh Kiều', 'Quận Bình Thủy', 'Quận Cái Răng'],
    'Thành phố Hồ Chí Minh': ['Quận 1', 'Quận 2', 'Quận 3', 'Quận 4', 'Quận 5', 'Quận 6', 'Quận 7', 'Quận 8', 'Quận 9', 'Quận 10', 'Quận 11', 'Quận 12', 'Quận Bình Tân'],
  };
  String? _selectedDistrict;
  // Các lựa chọn giới tính
  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];
  Future<void> _submit() async {
    if (!_formsignupKey.currentState!.validate()) {
      return;
    }
    _formsignupKey.currentState!.save();
    _isSubmitting.value = true;
    bool emailExists = false;
    try {
      emailExists = await context.read<AuthManager>().isEmailExist(_authData['email']!);
      print(emailExists);
      if (emailExists) {
        showErrorDialog(context, 'Email đã tồn tại');
        _isSubmitting.value = false;
        return;
      }
      await context.read<AuthManager>().signup(_authData);
      Navigator.of(context).popAndPushNamed(SigninScreen.routeName, arguments: {'email': _authData['email']});
    } catch (error) {
      print(error);
      if (mounted) {
        showErrorDialog(context, 'Đăng ký không thành công');
      }
    }
    _isSubmitting.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formsignupKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(    
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tạo tài khoản', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('Đăng ký để bắt đầu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                const SizedBox(height: 50),
                _buildNameField(),
                const SizedBox(height: 10),
                _buildEmailField(),
                const SizedBox(height: 10),
                _buildCityField(),
                const SizedBox(height: 10,),
                _buildDistrictField(), 
                const SizedBox(height: 10),
                _buildPasswordField(),
                const SizedBox(height: 10),
                _buildPasswordConfirmField(),
                const SizedBox(height: 10),
                _buildGenderField(), 
                const SizedBox(height: 20),
                _buildRoleField(), 
                const SizedBox(height: 20),
                ValueListenableBuilder<bool>(
                  valueListenable: _isSubmitting,
                  builder: (context, isSubmitting, child) {
                    if (isSubmitting) {
                      return Center(child: const CircularProgressIndicator());
                    }
                    return _buildSubmitButton();
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Đã có tài khoản?'),
                    TextButton(
                      onPressed: () {                       
                        Navigator.of(context).push(CustomPageRoute(page: SigninScreen(), curve: Curves.decelerate));
                      },
                      child: Text('Đăng nhập', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Các phương thức xây dựng form đã có (không thay đổi)

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
          label: const Text('Họ và tên'), 
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
          return 'Vui lòng nhập họ tên';
        }
        else if (value.length < 8) {
          return 'Họ tên quá ngắn!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['name'] = value!;
      },
    );
  }
  
  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
          label: const Text('Email'), 
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
          return 'Vui lòng nhập emal';
        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Email không hợp lệ!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
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
  Widget _buildPasswordField() {
    return TextFormField(
      obscureText: is_obscurepassword,
      decoration: InputDecoration(
          label: const Text('Mật khẩu'), 
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
          suffixIcon: IconButton(onPressed: () {
            setState(() {
              is_obscurepassword = !is_obscurepassword;
            });
          }, icon: is_obscurepassword ? Icon(FontAwesomeIcons.solidEyeSlash, size: 15,) : Icon(FontAwesomeIcons.solidEye, size: 15,))
      ),
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.length == 0){
          return 'Vui lòng nhập mật khẩu';
        }
        else if (value.length < 8) {
          return 'Mật khẩu quá ngắn!';
        }
        return null;
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  Widget _buildPasswordConfirmField() {
    return TextFormField(
      obscureText: is_obscureconfirmpassword,
      decoration: InputDecoration(
          label: const Text('Nhập lại mật khẩu'), 
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
          suffixIcon: IconButton(onPressed: () {
            setState(() {
              is_obscureconfirmpassword = !is_obscureconfirmpassword;
            });
          }, icon: is_obscureconfirmpassword ? Icon(FontAwesomeIcons.solidEyeSlash, size: 15,) : Icon(FontAwesomeIcons.solidEye, size: 15,))
      ),
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Mật khẩu không khớp!';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        label: const Text('Giới tính'),
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
      value: _authData['gender'],
      items: _genders.map((gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _authData['gender'] = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng chọn giới tính';
        }
        return null;
      },
    );
  }
  Widget _buildRoleField() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        label: const Text('Bạn là?'),
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
      value: _authData['role'],
      items: [
        DropdownMenuItem<int>(
          value: 0,
          child: Text('Người thuê'),
        ),
        DropdownMenuItem<int>(
          value: 1,
          child: Text('Người cho thuê'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _authData['role'] = value!;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Vui lòng chọn vai trò';
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
        child: Text('Đăng ký', style: TextStyle(fontSize: 20, color: Colors.white)),
      ),
    );
  }
}
