import 'package:flutter/material.dart';
import 'dart:math';
import 'package:o3d/o3d.dart';

class ExtraScreen extends StatefulWidget {
  const ExtraScreen({Key? key}) : super(key: key);

  @override
  _ExtraScreenState createState() => _ExtraScreenState();
}

class _ExtraScreenState extends State<ExtraScreen>
    with SingleTickerProviderStateMixin {
  late O3DController o3dController;
  late PageController mainPageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late String selectedObject;
  late String objectName;

  final List<Map<String, String>> objects = [
    {
      'file': 'assets/mjolnir_thors_hammer.glb',
      'name': 'Mjolnir (Thor\'s Hammer)'
    },
    {'file': 'assets/sci_fi_monitor.glb', 'name': 'Sci-Fi Monitor'},
    {'file': 'assets/tesseract_cube.glb', 'name': 'Tesseract Cube'},
    {
      'file': 'assets/tony_stark_iron_man_mark_xliv.glb',
      'name': 'Tony Stark (Iron Man Mark XLIV)'
    },
    {
      'file': 'assets/infinity_gauntlet_textured_no_rig.glb',
      'name': 'Infinity Gauntlet'
    }
  ];

  @override
  void initState() {
    super.initState();
    o3dController = O3DController();
    mainPageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _selectRandomObject();
    _animationController.forward();
  }

  void _selectRandomObject() {
    final random = Random();
    final selected = objects[random.nextInt(objects.length)];
    selectedObject = selected['file']!;
    objectName = selected['name']!;
  }

  @override
  void dispose() {
    mainPageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extra Screen'),
      ),
      body: Stack(
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: O3D(
                  src: selectedObject,
                  controller: o3dController,
                  ar: false,
                  autoPlay: true,
                  autoRotate: false,
                ),
              ),
            ),
          ),
          PageView(
            controller: mainPageController,
            children: [],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Text(
                      objectName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
