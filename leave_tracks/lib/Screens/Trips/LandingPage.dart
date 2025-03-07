import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load routes');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showNewTripDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        String newTripName = '';
        return CupertinoPopupSurface(
          isSurfacePainted: true,
          child: Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white.withOpacity(0.95),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New Adventure',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  placeholder: 'Trip Name',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200]!.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  onChanged: (value) => newTripName = value,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CupertinoButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CupertinoButton.filled(
                      child: const Text('Start'),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.white.withOpacity(0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              CupertinoSliverNavigationBar(
                largeTitle: const Text(
                  'Tracks',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
                backgroundColor: Colors.white.withOpacity(0.8),
                trailing: CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(CupertinoIcons.add_circled, size: 28),
                  onPressed: _showNewTripDialog,
                ),
                border: null,
              ),
              CupertinoSliverRefreshControl(onRefresh: _fetchAllRoutes),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: _isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(child: CupertinoActivityIndicator(radius: 16)),
                      )
                    : _routePlaces.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : _buildRouteGrid(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.map_fill, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No Adventures Yet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your journey now',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            child: const Text('New Trip'),
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
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildTripCard(_routePlaces[index]),
        childCount: _routePlaces.length,
      ),
    );
  }

  Widget _buildTripCard(Map<String, dynamic> route) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => Tripreview(tripId: route['_id'])),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: const DecorationImage(
                  image: AssetImage('assets/Fun/Trip.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    route['Name_Route'] ?? 'Unnamed Trip',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: const AssetImage('assets/Fun/One.png'),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Serwaa',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
}