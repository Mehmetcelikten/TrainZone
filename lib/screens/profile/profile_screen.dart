import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String? userName;
  String? gender;
  String? height;
  String? profileImageUrl;
  File? _imageFile;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadThemePreference();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
      gender = prefs.getString('gender');
      height = prefs.getString('height');
      profileImageUrl = prefs.getString('profileImageUrl');
    });
  }

  Future<void> _saveProfileDataFromResponse(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', data['userId']);
    await prefs.setString('authToken', data['authToken']);
    await prefs.setString('userName', data['userName']);
    await prefs.setString('gender', data['gender']);
    await prefs.setString('height', data['height']);
    setState(() {
      userName = data['userName'];
      gender = data['gender'];
      height = data['height'];
    });
  }

  Future<String?> uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'deqntg1ta';
    const uploadPreset = 'fitness_app_upload';
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = json.decode(responseData);
      return data['secure_url'];
    } else {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
        final uploadedUrl = await uploadImageToCloudinary(_imageFile!);
        if (uploadedUrl != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('profileImageUrl', uploadedUrl);
          setState(() {
            profileImageUrl = uploadedUrl;
          });
          _showAlert('Başarılı', 'Fotoğraf yüklendi ve güncellendi.');
        } else {
          _showAlert('Hata', 'Yükleme başarısız.');
        }
      }
    } else {
      _showAlert('İzin Gerekli', 'Fotoğraf seçmek için izin vermelisin.');
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(color: Colors.redAccent)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _showProfileForm() {
    final nameController = TextEditingController();
    final heightController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedGender = gender ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.person_add,
                size: 40,
                color: _isDarkMode ? Colors.redAccent : Colors.blue,
              ),
              const SizedBox(height: 8),
              Text(
                'Profil Oluştur',
                style: TextStyle(
                  color: _isDarkMode ? Colors.redAccent : Colors.blue,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Kullanıcı Adı',
                          labelStyle: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700]),
                          hintText: 'En az 3 karakter',
                          hintStyle: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white54
                                  : Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.person,
                            color: _isDarkMode ? Colors.redAccent : Colors.blue,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _isDarkMode
                                    ? Colors.redAccent
                                    : Colors.blue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor:
                              _isDarkMode ? Colors.grey[900] : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Parola',
                          labelStyle: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700]),
                          hintText: 'En az 4 karakter',
                          hintStyle: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white54
                                  : Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: _isDarkMode ? Colors.redAccent : Colors.blue,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _isDarkMode
                                    ? Colors.redAccent
                                    : Colors.blue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor:
                              _isDarkMode ? Colors.grey[900] : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: heightController,
                        style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Boy (cm)',
                          labelStyle: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[700]),
                          hintText: '110-230 cm arası',
                          hintStyle: TextStyle(
                              color: _isDarkMode
                                  ? Colors.white54
                                  : Colors.grey[600]),
                          prefixIcon: Icon(
                            Icons.height,
                            color: _isDarkMode ? Colors.redAccent : Colors.blue,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _isDarkMode
                                    ? Colors.grey[700]!
                                    : Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: _isDarkMode
                                    ? Colors.redAccent
                                    : Colors.blue),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor:
                              _isDarkMode ? Colors.grey[900] : Colors.white,
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _isDarkMode ? Colors.grey[900] : Colors.white,
                          border: Border.all(
                              color: _isDarkMode
                                  ? Colors.grey[700]!
                                  : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value:
                              selectedGender.isNotEmpty ? selectedGender : null,
                          dropdownColor: _isDarkMode
                              ? const Color(0xFF2A2A2A)
                              : Colors.white,
                          hint: Text(
                            'Cinsiyet Seçin',
                            style: TextStyle(
                                color: _isDarkMode
                                    ? Colors.white54
                                    : Colors.grey[600]),
                          ),
                          style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: _isDarkMode ? Colors.redAccent : Colors.blue,
                          ),
                          items: ['Erkek', 'Kadın'].map((val) {
                            return DropdownMenuItem(
                              value: val,
                              child: Row(
                                children: [
                                  Icon(
                                    val == 'Erkek' ? Icons.male : Icons.female,
                                    color: _isDarkMode
                                        ? Colors.redAccent
                                        : Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(val),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => selectedGender = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white54 : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final password = passwordController.text.trim();
                final boy = heightController.text.trim();
                final boyInt = int.tryParse(boy);

                if (name.length < 3) {
                  _showAlert('Hata', 'Kullanıcı adı en az 3 harf olmalı.');
                } else if (password.length < 4) {
                  _showAlert('Hata', 'Parola en az 4 karakter olmalı.');
                } else if (boyInt == null || boyInt < 110 || boyInt > 230) {
                  _showAlert('Hata', 'Boy 110-230 cm arası olmalı.');
                } else if (selectedGender.isEmpty) {
                  _showAlert('Hata', 'Cinsiyet seçilmelidir.');
                } else {
                  try {
                    final response = await AuthService.registerUser(
                      userName: name,
                      height: boyInt,
                      password: password,
                      gender: selectedGender,
                    );
                    await _saveProfileDataFromResponse(response);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, '/home_screen');
                    }
                  } catch (e) {
                    _showAlert('Hata', e.toString());
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDarkMode ? Colors.redAccent : Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _profileInfo(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDarkMode
              ? const [Colors.red, Colors.redAccent]
              : const [Colors.blue, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (_isDarkMode ? Colors.red : Colors.blue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor:
            _isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[100],
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: profileImageUrl != null
                                    ? NetworkImage(profileImageUrl!)
                                    : null,
                                backgroundColor: _isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                child: profileImageUrl == null
                                    ? Icon(Icons.add_a_photo,
                                        color: _isDarkMode
                                            ? Colors.white54
                                            : Colors.grey.shade600)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: _isDarkMode ? Colors.red : Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (userName != null)
                        Center(
                          child: Text(
                            userName!,
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (height != null || gender != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (height != null)
                              _profileInfo('Boy', '$height cm'),
                            if (gender != null)
                              _profileInfo('Cinsiyet', gender!),
                          ],
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showProfileForm,
                        icon: const Icon(Icons.edit),
                        label: const Text('Profili Oluştur / Düzenle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isDarkMode ? Colors.red : Colors.blue,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Tema',
                            style: TextStyle(
                              color: _isDarkMode ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (_isDarkMode) {
                                _toggleTheme();
                              }
                            },
                            icon: const Icon(Icons.light_mode),
                            label: const Text('Aydınlık'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isDarkMode ? Colors.amber : Colors.grey[300],
                              foregroundColor:
                                  _isDarkMode ? Colors.black : Colors.grey[600],
                              minimumSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (!_isDarkMode) {
                                _toggleTheme();
                              }
                            },
                            icon: const Icon(Icons.dark_mode),
                            label: const Text('Karanlık'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isDarkMode
                                  ? Colors.grey[300]
                                  : Colors.indigo,
                              foregroundColor:
                                  _isDarkMode ? Colors.grey[600] : Colors.white,
                              minimumSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthService.logoutUser();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      foregroundColor:
                          _isDarkMode ? Colors.white : Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Çıkış Yap'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
