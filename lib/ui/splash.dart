import 'package:flutter/material.dart';
import 'home.dart';
import 'style/theme.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temaEscuro = AppTheme.modo.value == ThemeMode.light ? false : true;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            // ANIMAÇÃO DO ÍCONE
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset('./assets/icone.png', width: 200),
              ),
            ),

            SizedBox(
              width: 200,
              child: SwitchListTile(
                title: const Text("Tema escuro"),
                value: temaEscuro,
                onChanged: (value) {
                  setState(() {
                    AppTheme.modo.value = value
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  });
                },
              ),
            ),

            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Home()),
              ),
              child: const Text("Iniciar"),
            ),
          ],
        ),
      ),
    );
  }
}
