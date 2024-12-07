import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:leave_tracks/Widgets/SingleDashboardRoute.dart';
//there is hope
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);


// where is the man

//hope is on the way
//bold solution 
  @override
  State<Dashboard> createState() => _DashboardState();
}
//ghosts are real
class _DashboardState extends State<Dashboard> {
  static const String baseUrl = 'https://leave-tracks-backend.vercel.app';
  bool _isLoading = true;
  List<Map<String, dynamic>> _routePlaces = [];

  @override
  void initState() {
    super.initState();
    fetchAllRoutes();
  }

  Future<void> fetchAllRoutes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('$baseUrl/allRoutes'));
      if (response.statusCode == 200) {
        setState(() {
          _routePlaces =
              List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        print("There is a big error in the backend");
        setState(() {
          _routePlaces = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
        _routePlaces = [];
      });
      throw "There is some big error: $e";
    }
  }

  Future<void> updateRouteName(String id, String newName) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateRoute/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'Name_Route': newName}),
      );
      if (response.statusCode == 200) {
        // Update successful, refresh the routes
        await fetchAllRoutes();
        
      } else {
        print("Error updating route: ${response.body}");
      }
    } catch (e) {
      print("Error updating route: $e");
    }
  }
 

  void _showEditModal(BuildContext context, Map<String, dynamic> route) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditRouteModal(
          routeName: route['Name_Route'] ?? '',
          onSave: (newName) async {
            Navigator.of(context).pop(); // Close the modal
            await updateRouteName(route['_id'].toString(), newName);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Route Dashboard",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _routePlaces.length,
              itemBuilder: (context, index) {
                final singleRoute = _routePlaces[index];
                return GestureDetector(
                  onTap: () {
                    // Handle tap if needed
                  },
                  child: SingleDashboardRoute(
                    id: singleRoute['id']?.toString() ?? '',
                    previewFile: 'assets/Fun/Trip.png',
                    userProfile: "assets/Fun/One.png",
                    userName:
                        singleRoute['userName']?.toString() ?? 'Unknown User',
                    nameTrip:
                        singleRoute['Name_Route']?.toString() ?? 'Unnamed Trip',
                    onDetailPressed: () {
                      print("Detail pressed for ${singleRoute['Name_Route']}");
                    },
                    onEditPressed: () {
                      _showEditModal(context, singleRoute);
                    },
                    onReRoutePressed: () {
                      print("ReRoute pressed for ${singleRoute['Name_Route']}");
                    Navigator.pushNamed(
                        context,
                        '/route',
                        arguments: {
                          'tripName': singleRoute['Name_Route'],
                          'routeId': singleRoute['_id'],
                        },
                      );

                    },
                  ),
                );
              },
            ),
    );
  }
}

class EditRouteModal extends StatefulWidget {
  final String routeName;
  final Function(String) onSave;

  const EditRouteModal({
    Key? key,
    required this.routeName,
    required this.onSave,
  }) : super(key: key);

  @override
  _EditRouteModalState createState() => _EditRouteModalState();
}

class _EditRouteModalState extends State<EditRouteModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.routeName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Route Name'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Route Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: Text('Save'),
          onPressed: () {
            widget.onSave(_controller.text);
          },
        ),
      ],
    );
  }
}
