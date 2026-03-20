import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routers.dart';
import '../../../../di/injection.dart';
import '../../../../core/network/token_service.dart';



class cashierSplashScreen extends StatefulWidget {
  const cashierSplashScreen({super.key});



  @override
  State<cashierSplashScreen> createState() => _cashierSplashScreenState();
}



class _cashierSplashScreenState extends State<cashierSplashScreen> {



  int _remainingSeconds = 2;
  Timer? _timer;




  @override
  void initState() {
    super.initState();
    _navigate();
    _startTimer();

  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }




  Future<void> _navigate() async {
    final token = await sl<TokenService>().getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (!mounted) return;

    if (isLoggedIn) {
      context.go(AppRoutes.cashierDashboard);
    } else {
      context.go(AppRoutes.cashierLoginScreen);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        _navigate();
      } else {
        if (mounted) setState(() => _remainingSeconds--);
      }
    });
  }






  @override
  Widget build(BuildContext context) => Scaffold(

      // appBar: AppBar(
      //   leading: BackButton(
      //     color: Colors.black,
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: const Text("Splash Screen for Cashier"),
      // ),
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text("Splash Screen for Cashier"),
    ),


    body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFAEB),
                Color(0x00FFD417),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),


              Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/cashierrelated/faydamx.png',
                ),
              ),



              const SizedBox(height: 20),



              const Text(
                'FaydaMX Central',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 70),


              SizedBox(
                width: 300,
                height: 300,
                child: Image.asset(
                  'assets/cashierrelated/cashierSplash.png',
                  fit: BoxFit.contain,
                ),
              ),


              const SizedBox(height: 30),


              // GestureDetector(
              //   onTap: () {
              //     context.push(CashierRoutes.cashierLoginScreen);
              //   },
              //   child: Text("on tap for login screen"),),


              Text(
                'Redirecting in $_remainingSeconds s',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),

              const Spacer(),


            ],
          ),
        ),
      ),
    );
}
