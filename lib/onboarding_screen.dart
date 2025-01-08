import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLanguage = 'English';
  String _selectedCountry = 'USA';
  String _selectedCity = 'New York';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', _selectedLanguage);
    await prefs.setString('selectedCountry', _selectedCountry);
    await prefs.setString('selectedCity', _selectedCity);
    await prefs.setBool('isFirstLaunch', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD7D1BE),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildWelcomeTab(),
                _buildLanguageTab(),
                _buildLocationTab(),
              ],
            ),
          ),
          _buildPageIndicator(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await _savePreferences();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Get Started'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                width: 60,
              ),
              _buildStylistRow('assets/master1.png', 'Find', true, 70),
            ],
          ),
          SizedBox(height: 20),
          _buildStylistRow('assets/master2.png', 'Stylists', false, 50),
          SizedBox(height: 20),
          _buildStylistRow('assets/master3.png', 'Near You', true, 60),
        ],
      ),
    );
  }

  Widget _buildStylistRow(
      String imagePath, String text, bool isImageFirst, double avatarRadius) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isImageFirst)
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage: AssetImage(imagePath),
          ),
        if (isImageFirst) SizedBox(width: 20),
        Text(
          text,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (!isImageFirst) SizedBox(width: 20),
        if (!isImageFirst)
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage: AssetImage(imagePath),
          ),
      ],
    );
  }

  Widget _buildLanguageTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language,
            size: 100,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'Choose your language',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 20),
          _buildDropdown(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedLanguage = newValue;
                });
              }
            },
            items: <String>['English', 'Spanish', 'French'],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: 100,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            'Select your Country and city',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'and Turn on Location to show stylists in your city',
            style: TextStyle(fontSize: 18, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          _buildDropdown(
            value: _selectedCountry,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCountry = newValue;
                });
              }
            },
            items: <String>['USA', 'Canada', 'UK'],
          ),
          SizedBox(height: 20),
          _buildDropdown(
            value: _selectedCity,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCity = newValue;
                });
              }
            },
            items: <String>['New York', 'Los Angeles', 'London'],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required ValueChanged<String?> onChanged,
    required List<String> items,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(color: Colors.black),
              ),
            );
          }).toList(),
          dropdownColor: Colors.white,
          style: TextStyle(color: Colors.black),
          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) => _buildIndicator(index)),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return Container(
          width: _tabController.index == index ? 40 : 10,
          height: 4,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
