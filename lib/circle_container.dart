import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomContainer extends StatelessWidget {
  final String text;
  final Widget targetPage;
  final String imageNetwork;
  final double widthFraction;
  final double heightFraction;

  const CustomContainer({
    Key? key,
    required this.text,
    required this.targetPage,
    required this.imageNetwork,
    required this.widthFraction,
    required this.heightFraction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * widthFraction * 0.7,
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * heightFraction * 0.8,
            width: MediaQuery.of(context).size.width * widthFraction * 0.7,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => targetPage,
                  ),
                );
              },
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 3.0)),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // ✅ Makes the container circular
                      color: Color(0xFFe0f2f1),
                    ),
                    height: MediaQuery.of(context).size.height * heightFraction * 0.5,
                    width: MediaQuery.of(context).size.height * heightFraction * 0.5, // ✅ Make width same as height for perfect circle
                    child: ClipOval( // ✅ Ensures the image is clipped into a circle
                      child: Image.network(
                        imageNetwork,
                        fit: BoxFit.cover, // ✅ Ensures image covers the circular area
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/default.jpg', // Fallback image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Text(
                      text,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Group {
  final String groupName;
  final String targetPage;
  final String imageAsset;

  Group({
    required this.groupName,
    required this.targetPage,
    required this.imageAsset,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      groupName: json['group_name'],
      targetPage: json['target_page'],
      imageAsset: json['image_asset'],
    );
  }
}

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late Future<List<Group>> groupsFuture;

  @override
  void initState() {
    super.initState();
    groupsFuture = fetchGroups();
  }

  Future<List<Group>> fetchGroups() async {
    final response = await http
        .get(Uri.parse('https://hbnappdatas.pythonanywhere.com/groups_api'));

    if (response.statusCode == 200) {
      print(response.body);
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Group.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load groups');
    }
  }

  Widget getTargetPage(String pageName) {
    switch (pageName) {
      case 'Delicous':
        return Placeholder(); // Replace with your actual page widget
      case 'Beverages':
        return Placeholder(); // Replace with your actual page widget
      default:
        return Placeholder(); // Default fallback page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Groups')),
      body: FutureBuilder<List<Group>>(
        future: groupsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<Group> groups = snapshot.data!;
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                Group group = groups[index];
                return CustomContainer(
                  text: group.groupName,
                  targetPage: getTargetPage(group.targetPage),
                  imageNetwork: group.imageAsset,
                  widthFraction: 0.8, // Example width fraction
                  heightFraction: 0.6, // Example height fraction
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
