import 'package:flutter/material.dart';

class SingleDashboardRoute extends StatelessWidget {
  final String id;
  final String previewFile;
  final String userProfile;
  final String userName;
  final String nameTrip;
  final VoidCallback onDetailPressed;
  final VoidCallback onEditPressed;
  final VoidCallback onReRoutePressed;

  const SingleDashboardRoute({
    super.key,
    required this.id,
    required this.previewFile,
    required this.userProfile,
    required this.userName,
    required this.nameTrip,
    required this.onDetailPressed,
    required this.onEditPressed,
    required this.onReRoutePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          // Trip preview image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              previewFile,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          // Content overlay
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameTrip,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(userProfile),
                      radius: 12,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton('Detail', onDetailPressed),
                    _buildButton('Edit', onEditPressed),
                    _buildButton('ReRoute', onReRoutePressed),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
