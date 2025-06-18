import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;

class Accueil extends StatefulWidget {
  @override
  _AccueilState createState() => _AccueilState();
}

class _AccueilState extends State<Accueil> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _allSongs = [];
  List<Map<String, dynamic>> _filteredSongs = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isLoading = false;
  bool _isPlaying = false;
  String _currentPlayingUrl = '';
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  // Popular artists for quick selection
  final List<String> _popularArtists = [
    'Eminem',
    'Blackpink',
    'Dua Lipa',
    'The Weeknd',
    'Billie Eilish',
  ];

  // Define our theme colors
  final Color primaryColor = Color(0xFF00BCD4); // Turquoise blue
  final Color secondaryColor = Color(0xFF4CAF50); // Green
  final Color backgroundColor = Color(0xFFE0F7FA); // Light turquoise

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
    );

    // Initial fetch with animation delay for better UX
    Future.delayed(Duration(milliseconds: 300), () {
      fetchSongs('eminem');
    });
  }

  Future<void> fetchSongs(String query) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse("https://api.deezer.com/search?q=$query");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> tracks = data['data'];

      _allSongs =
          tracks.map<Map<String, dynamic>>((song) {
            return {
              'id': song['id'].toString(),
              'title': song['title'],
              'artist': song['artist']['name'],
              'url': song['preview'],
              'albumCover': song['album']['cover_medium'],
              'duration': song['duration'],
            };
          }).toList();

      setState(() {
        _filteredSongs = _allSongs;
        _isLoading = false;
      });
    } else {
      print("Erreur API Deezer");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSongs(String query) {
    setState(() {
      _isLoading = true;
    });
    fetchSongs(query);
  }

  void _togglePlayPause(String url) async {
    if (_currentPlayingUrl == url && _isPlaying) {
      await _audioPlayer.pause();
      _animationController.reverse();
      setState(() {
        _isPlaying = false;
      });
    } else if (_currentPlayingUrl == url && !_isPlaying) {
      await _audioPlayer.resume();
      _animationController.forward();
      setState(() {
        _isPlaying = true;
      });
    } else {
      // New song
      if (_isPlaying) {
        _animationController.reverse();
      }

      setState(() {
        _currentPlayingUrl = url;
        _isPlaying = true;
      });

      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          '🎵 Music Explorer',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: primaryColor,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Column(
        children: [
          // Search bar with animation
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onSubmitted: _filterSongs,
              decoration: InputDecoration(
                hintText: 'Rechercher une chanson ou un artiste...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: primaryColor),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
            ),
          ),

          // Artist quick selection
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _popularArtists.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _searchController.text = _popularArtists[index];
                    fetchSongs(_popularArtists[index]);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _popularArtists[index],
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Songs list with animations
          _isLoading
              ? Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              )
              : Expanded(
                child:
                    _filteredSongs.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.music_off,
                                size: 80,
                                color: primaryColor.withOpacity(0.5),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Aucune chanson trouvée.',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        )
                        : ListView.builder(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredSongs.length,
                          itemBuilder: (context, index) {
                            final song = _filteredSongs[index];
                            final isCurrentlyPlaying =
                                _currentPlayingUrl == song['url'];

                            // Create staggered animation for list items
                            return AnimatedOpacity(
                              duration: Duration(milliseconds: 500),
                              opacity: 1.0,
                              curve: Curves.easeInOut,
                              child: TweenAnimationBuilder(
                                tween: Tween<double>(begin: 1.0, end: 0.0),
                                duration: Duration(
                                  milliseconds: 500 + (index * 50),
                                ),
                                builder: (context, double value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, value * 50),
                                    child: child,
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            isCurrentlyPlaying
                                                ? primaryColor.withOpacity(0.4)
                                                : Colors.grey.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        song['albumCover'] ??
                                            'https://via.placeholder.com/60',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: primaryColor.withOpacity(
                                              0.2,
                                            ),
                                            child: Icon(
                                              Icons.music_note,
                                              color: primaryColor,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    title: Text(
                                      song['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      song['artist'] ?? '',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    trailing: GestureDetector(
                                      onTap:
                                          () => _togglePlayPause(song['url']),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors:
                                                isCurrentlyPlaying && _isPlaying
                                                    ? [
                                                      secondaryColor,
                                                      primaryColor,
                                                    ]
                                                    : [
                                                      primaryColor,
                                                      primaryColor.withOpacity(
                                                        0.7,
                                                      ),
                                                    ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: Duration(
                                              milliseconds: 300,
                                            ),
                                            transitionBuilder: (
                                              Widget child,
                                              Animation<double> animation,
                                            ) {
                                              return RotationTransition(
                                                turns: animation,
                                                child: ScaleTransition(
                                                  scale: animation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child:
                                                isCurrentlyPlaying && _isPlaying
                                                    ? Icon(
                                                      Icons.pause,
                                                      key: ValueKey('pause'),
                                                      color: Colors.white,
                                                    )
                                                    : Icon(
                                                      Icons.play_arrow,
                                                      key: ValueKey('play'),
                                                      color: Colors.white,
                                                    ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
        ],
      ),
      // Now playing indicator at the bottom
      bottomNavigationBar:
          _isPlaying
              ? AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.5),
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 2 * math.pi,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(Icons.music_note, color: primaryColor),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'En cours de lecture...',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.stop, color: Colors.white),
                      onPressed: () async {
                        await _audioPlayer.stop();
                        _animationController.reverse();
                        setState(() {
                          _isPlaying = false;
                          _currentPlayingUrl = '';
                        });
                      },
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              )
              : SizedBox(height: 0),
    );
  }
}
