import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:html' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_keys.dart';

class MusicService {
  final String clientId = ApiKeys.spotifyClientId;
  final String clientSecret = ApiKeys.spotifyClientSecret;
  final String redirectUri = 'aura-assistant://callback';

  Future<String> getAccessToken() async {
    print('\n=== MusicService: Starting Authentication ===');
    print('Client ID: ${clientId.substring(0, 5)}...');
    print('Redirect URI: $redirectUri');

    try {
      if (kIsWeb) {
        print('Web platform detected, implementing implicit grant flow...');
        final webUrl = 'https://accounts.spotify.com/authorize?'
            'client_id=$clientId'
            '&response_type=token'
            '&redirect_uri=$redirectUri'
            '&scope=user-read-private%20user-read-email%20user-modify-playback-state%20'
            'streaming%20user-read-playback-state%20app-remote-control';
        
        // Create a listener for the redirect
        final completer = Completer<String>();
        
        // Handle the redirect and token extraction
        html.window.onMessage.listen((event) {
          if (event.data.toString().contains('access_token=')) {
            final token = Uri.parse(event.data).fragment
                .split('&')
                .firstWhere((e) => e.startsWith('access_token='))
                .split('=')[1];
            completer.complete(token);
          }
        });

        // Launch the auth window
        if (await canLaunch(webUrl)) {
          await launch(webUrl);
          final token = await completer.future;
          print('Access token received from web flow');
          return token;
        } else {
          throw Exception('Could not launch Spotify authentication');
        }
      } else {
        // Native platform authentication flow
        print('Native platform detected, using flutter_web_auth...');
        final authUrl = 'https://accounts.spotify.com/authorize?'
            'client_id=$clientId'
            '&response_type=code'
            '&redirect_uri=$redirectUri'
            '&scope=user-read-private%20user-read-email%20user-modify-playback-state%20'
            'streaming%20user-read-playback-state%20app-remote-control';

        final result = await FlutterWebAuth.authenticate(
          url: authUrl,
          callbackUrlScheme: 'aura-assistant',
        );
        
        final code = Uri.parse(result).queryParameters['code']!;
        print('Authorization code received');

        final tokenResponse = await http.post(
          Uri.parse('https://accounts.spotify.com/api/token'),
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': redirectUri,
            'client_id': clientId,
            'client_secret': clientSecret,
          },
        );

        if (tokenResponse.statusCode == 200) {
          final tokenData = json.decode(tokenResponse.body);
          return tokenData['access_token'];
        } else {
          throw Exception('Failed to get access token: ${tokenResponse.body}');
        }
      }
    } catch (e, stackTrace) {
      print('Error in getAccessToken: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> getActiveDeviceId(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/player/devices'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final devices = data['devices'] as List;
      if (devices.isNotEmpty) {
        // Prefer active device, otherwise take the first one
        final activeDevice = devices.firstWhere(
          (device) => device['is_active'] == true,
          orElse: () => devices.first,
        );
        return activeDevice['id'];
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    print('Fetching user profile'); // Debugging statement
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to fetch user profile: ${response.body}'); // Debugging statement
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<Map<String, dynamic>> getUserPlaylists(String accessToken) async {
    print('Fetching user playlists'); // Debugging statement
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to fetch user playlists: ${response.body}'); // Debugging statement
      throw Exception('Failed to fetch user playlists');
    }
  }

  Future<void> playTrack(String accessToken, String trackId) async {
    print('\n=== MusicService: Playing Track ===');
    print('Track ID: $trackId');

    try {
      // First, get active device ID
      final deviceId = await getActiveDeviceId(accessToken);
      print('Active device ID: $deviceId');

      // Launch Spotify app/web player
      final spotifyUri = 'spotify:track:$trackId';
      final webUrl = 'https://open.spotify.com/track/$trackId';
      
      if (!kIsWeb && await canLaunch(spotifyUri)) {
        await launch(spotifyUri, forceSafariVC: false);
        await Future.delayed(const Duration(seconds: 2)); // Wait for app to open
      } else {
        await launch(webUrl);
        await Future.delayed(const Duration(seconds: 2)); // Wait for web player
      }

      // Send play command to Spotify API
      final endpoint = deviceId != null 
          ? 'https://api.spotify.com/v1/me/player/play?device_id=$deviceId'
          : 'https://api.spotify.com/v1/me/player/play';

      final response = await http.put(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'uris': ['spotify:track:$trackId'],
          'position_ms': 0,
        }),
      );

      if (response.statusCode == 204 || response.statusCode == 202) {
        print('Play command sent successfully');
      } else {
        print('Play command failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to start playback');
      }
    } catch (e, stackTrace) {
      print('Error in playTrack: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String> searchTrack(String accessToken, String trackName) async {
    print('Searching for track: $trackName');
    final encodedQuery = Uri.encodeComponent(trackName);
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$encodedQuery&type=track&limit=1'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['tracks']['items'].isEmpty) {
        throw Exception('No tracks found');
      }
      final trackId = data['tracks']['items'][0]['id'];
      print('Track ID found: $trackId');
      return trackId;
    } else {
      print('Failed to search track: ${response.body}');
      throw Exception('Failed to search track');
    }
  }

  // Add other Spotify API methods here
}