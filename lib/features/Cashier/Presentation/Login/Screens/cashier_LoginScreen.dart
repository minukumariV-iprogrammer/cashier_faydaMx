import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_routers.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../Bloc/login_bloc.dart';
import '../Bloc/login_event.dart';
import '../Bloc/login_state.dart';
import '../enums/cashier_login_status.dart';

class cashierLoginScreen extends StatefulWidget {
  const cashierLoginScreen({super.key});

  @override
  State<cashierLoginScreen> createState() => _cashierLoginScreenState();
}

class _cashierLoginScreenState extends State<cashierLoginScreen> {




  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();





  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) => Scaffold(
    // appBar: AppBar(
    //   leading: BackButton(
    //     color: Colors.black,
    //     onPressed: () => Navigator.pop(context),
    //   ),
    //   title: const Text("Login for Cashier"),
    // ),

    body: SafeArea(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFAEB), Color(0x00FFD417)],
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 40),

                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset('assets/cashierrelated/faydamx.png'),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Welcome to FaydaMX\nCentral',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          if (value.length < 4) {
                            return "username must be longer than or equal to 4 characters";
                          }
                          return null;
                        },

                        onChanged: (value) {
                          context.read<CashierLoginBloc>().add(UsernameChanged(value));
                        },
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          hintText: 'demo453',
                          filled: true,
                          fillColor: const Color(0x00FFD417),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black87),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          context.read<CashierLoginBloc>().add(PasswordChanged(value),);
                        },

                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'demo453',

                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.remove_red_eye_outlined,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),

                          filled: true,
                          fillColor: const Color(0x00FFD417),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.black87),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.2),


                      BlocConsumer<CashierLoginBloc, CashierLoginState>(
                        listener: (context, state) {

                          if (state.status == CashierLoginStatus.success) {
                            ToastUtils.showSuccessToast(
                              message: 'Login successful',
                            );
                            context.go(AppRoutes.cashierDashboard);
                          }

                          if (state.status == CashierLoginStatus.failure &&
                              state.errorMessage != null) {
                            ToastUtils.showErrorToast(
                              message: state.errorMessage!,
                            );
                          }

                          // if (state.status == CashierLoginStatus.failure &&
                          //     state.errorMessage != null) {
                          //   ToastUtils.showErrorToast(message: state.errorMessage);
                          // }
                          //
                          // if (state.status == CashierLoginStatus.success) {
                          //   ToastUtils.showSuccessToast(message: 'Login successful');
                          //   context.go(AppRoutes.cashierDashboard);
                          // }

                        },


                        builder: (context, state) => SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1C252E),
                              ),
                              // onPressed: state.isSubmissionAllowed &&
                              //     state.status != CashierLoginStatus.loading
                              //     ? () {
                              //   if (_formKey.currentState!.validate()) {
                              //     context.read<CashierLoginBloc>().add(
                              //       LoginButtonPressed(),
                              //     );
                              //   }
                              // }
                              //     : null,

                              onPressed: state.isSubmissionAllowed && state.status != CashierLoginStatus.loading
                                  ? () {context.read<CashierLoginBloc>().add(LoginButtonPressed());}
                                  : null,
                              child: state.status == CashierLoginStatus.loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Sign In'),
                            ),
                          ),
                      ),



                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
