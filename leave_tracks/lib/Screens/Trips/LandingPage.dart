import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:leave_tracks/Screens/Trips/TripReview.dart';
import 'package:leave_tracks/Widgets/SingleSavedRoute.dart';
import 'RealTimeTrackingMap.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const String baseUrl = 'https://leave-tracks-backend.vercel.app';
  bool _isLoading = false;
  List<Map<String, dynamic>> _routePlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchAllRoutes();
  }

  Future<void> _fetchAllRoutes() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(Uri.parse('$baseUrl/allRoutes'));
      
      if (response.statusCode == 200) {
        setState(() {
          _routePlaces = List<Map<String, dynamic>>.from(json.decode(response.body));
          _isLoading = false;
        });
      } else {
        setState(() {
          _routePlaces = [];
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load routes');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _routePlaces = [];
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showNewTripDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        String newTripName = '';
        return CupertinoAlertDialog(
          title: const Text('New Adventure', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CupertinoTextField(
              placeholder: 'Enter trip name',
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              onChanged: (value) => newTripName = value,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: false,
              child: const Text('Cancel', style: TextStyle(color: CupertinoColors.systemGrey)),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Start Trip', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                if (newTripName.isNotEmpty) {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => RealTimeTrackingMap(tripName: newTripName),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground,
        border: null,
        middle: const Text(
          'Tracks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add, size: 24),
          onPressed: _showNewTripDialog,
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.sidebar_left, size: 24),
          onPressed: () => _showSidebar(context),
        ),
      ),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: _fetchAllRoutes,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: _isLoading
                ? const SliverFillRemaining(
                    child: Center(
                      child: CupertinoActivityIndicator(radius: 14),
                    ),
                  )
                : _routePlaces.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : _buildRouteGrid(),
          ),
        ],
      ),
    );
  }

  void _showSidebar(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              color: CupertinoColors.systemBlue.withOpacity(0.1),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: CupertinoColors.systemBlue.withOpacity(0.2),
                      child: Icon(
                        CupertinoIcons.person_fill,
                        color: CupertinoColors.systemBlue,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tracks',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Adventure Awaits',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ..._sidebarItems.map((item) => _buildSidebarItem(
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    route: item['route'] as String,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: CupertinoColors.systemBlue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: CupertinoColors.label,
              ),
            ),
            const Spacer(),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 16,
              color: CupertinoColors.systemGrey3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.map,
            size: 80,
            color: CupertinoColors.systemGrey3,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Adventures Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to start a new adventure',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            child: const Text('Create New Trip'),
            onPressed: _showNewTripDialog,
          ),
        ],
      ),
    );
  }

  SliverGrid _buildRouteGrid() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final route = _routePlaces[index];
          return _buildTripCard(route);
        },
        childCount: _routePlaces.length,
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> route) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => Tripreview(tripId: route['_id']),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey6,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip thumbnail
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                image: const DecorationImage(
                  image: AssetImage('assets/Fun/Trip.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route['Name_Route']?.toString() ?? 'Unnamed Trip',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/Fun/One.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Serwaa',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<Map<String, dynamic>> _sidebarItems = [
    {'title': 'Home', 'icon': CupertinoIcons.home, 'route': '/Home'},
    {'title': 'My Routes', 'icon': CupertinoIcons.map, 'route': '/MyRoute'},
    {'title': 'Settings', 'icon': CupertinoIcons.settings, 'route': '/Settings'},
    {'title': 'AI Assistant', 'icon': CupertinoIcons.wand_stars, 'route': '/AIshine'},
    {'title': 'Media', 'icon': CupertinoIcons.photo_camera, 'route': '/TestVideo'},
    {'title': 'Log Out', 'icon': CupertinoIcons.square_arrow_left, 'route': '/LogOut'},
  ];
}