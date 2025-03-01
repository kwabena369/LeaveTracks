// lib/models/route_model.dart
class RouteModel {
  final String id;
  final String name;
  final String userProfile;
  final String userName;
  final List<PathCoordinate> pathCoordinates;
  final List<Memory> memories;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final int dislikes;
  final int views;
  final bool isPublic;
  final List<String> authorizedViewers;

  RouteModel({
    required this.id,
    required this.name,
    required this.userProfile,
    required this.userName,
    required this.pathCoordinates,
    required this.memories,
    required this.createdAt,
    required this.updatedAt,
    this.likes = 0,
    this.dislikes = 0,
    this.views = 0,
    this.isPublic = true,
    this.authorizedViewers = const [],
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['_id'] ?? '',
      name: json['Name_Route'] ?? 'Unnamed Trip',
      userProfile: json['userProfile'] ?? '/cat.png',
      userName: json['userName'] ?? 'Unknown',
      pathCoordinates: (json['Path_Cordinate'] as List?)
          ?.map((coord) => PathCoordinate.fromJson(coord))
          .toList() ?? [],
      memories: (json['MemoriesTrip'] as List?)
          ?.map((memory) => Memory.fromJson(memory))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      views: json['views'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      authorizedViewers: (json['authorizedViewers'] as List?)
          ?.map((viewer) => viewer.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Name_Route': name,
      'userProfile': userProfile,
      'userName': userName,
      'Path_Cordinate': pathCoordinates.map((coord) => coord.toJson()).toList(),
      'MemoriesTrip': memories.map((memory) => memory.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likes': likes,
      'dislikes': dislikes,
      'views': views,
      'isPublic': isPublic,
      'authorizedViewers': authorizedViewers,
    };
  }
}

class PathCoordinate {
  final double latitude;
  final double longitude;

  PathCoordinate({
    required this.latitude,
    required this.longitude,
  });

  factory PathCoordinate.fromJson(Map<String, dynamic> json) {
    return PathCoordinate(
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class Memory {
  final String imageContent;
  final Location location;

  Memory({
    required this.imageContent,
    required this.location,
  });

  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      imageContent: json['ImageContent'] ?? '',
      location: Location.fromJson(json['Location'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ImageContent': imageContent,
      'Location': location.toJson(),
    };
  }
}

class Location {
  final double lat;
  final double long;

  Location({
    required this.lat,
    required this.long,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0).toDouble(),
      long: (json['long'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'long': long,
    };
  }
}