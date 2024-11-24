
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../main_screen.dart';
import '../shared/custom_page_route.dart';
import '../shared/dialog.dart';
import 'auth_manager.dart';
import 'signup_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});
  static String routeName='signin_screen';

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  
  final GlobalKey<FormState> _formloginKey = GlobalKey();
   final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _emailController = TextEditingController();
  ValueNotifier<bool> is_obscurepassword= ValueNotifier<bool>(true);
  final _isSubmitting = ValueNotifier<bool>(false);
  Future<void> _submit() async {
    if (!_formloginKey.currentState!.validate()) {
      return;
    }
    _formloginKey.currentState!.save();
    _isSubmitting.value = true;
    try {
      await context.read<AuthManager>().login(
            _authData['email']!,
            _authData['password']!,
      );
       Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (error) {
      if (mounted){
        showErrorDialog(context, 'Đăng nhập không thành công');
      }
    }
    _isSubmitting.value = false;
  }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    String email = args?['email'] ?? '';
    _emailController.text=email;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formloginKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Đăng nhập', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                Text('Vui lòng đăng nhập để tiếp tục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),),
                const SizedBox(height: 50,),
                _buildEmailField( _emailController),
                const SizedBox(height: 30,),
                _buildPasswordField(),
                const SizedBox(height: 20,),
                Align(
                  child: TextButton(onPressed: (){}, 
                    child: Text('Quên mật khẩu?',style: TextStyle(color: Colors.redAccent)),
                  ), 
                  alignment: Alignment.topRight,
                ),
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
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Không có tài khoản?'),
                    TextButton(
                      onPressed: (){
                        Navigator.of(context).push(CustomPageRoute(page: SignupScreen(),));
                      }, 
                      child: Text('Đăng ký', style: TextStyle(color: Colors.redAccent),)
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(TextEditingController _emailController) {
    return TextFormField(
      controller: _emailController,
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

  Widget _buildPasswordField() {
    return ValueListenableBuilder<bool>(
      valueListenable: is_obscurepassword,
      builder: (context, value, child) {
        return TextFormField(
          obscureText: value,
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
              suffixIcon: IconButton(
                onPressed: (){ is_obscurepassword.value=!is_obscurepassword.value;}, 
                icon: is_obscurepassword.value ? Icon(FontAwesomeIcons.solidEyeSlash, size: 15,) : Icon(FontAwesomeIcons.solidEye, size: 15,)
              )
          ),
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
        child: Text('Đăng nhập', style: TextStyle(fontSize: 20, color: Colors.white),)
      ),
    ); 
  }
}