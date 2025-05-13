import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({Key? key}) : super(key: key);

  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final Map<String, VlcPlayerController> _controllers = {};
  final Map<String, bool> _hasError = {};
  bool _refreshing = false;
  String? _expandedDocId;


  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initializeController(String docId, String url) {
    final controller = VlcPlayerController.network(
      url,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    controller.addListener(() {
      final hasError = controller.value.hasError;
      if (hasError != _hasError[docId]) {
        setState(() {
          _hasError[docId] = hasError;
        });
      }
    });

    _controllers[docId] = controller;
    _hasError[docId] = false;
  }

  void _retryStream(String docId, String url) {
    _controllers[docId]?.dispose();
    _controllers.remove(docId);
    _hasError.remove(docId);
    setState(() {
      _initializeController(docId, url);
    });
  }

  Widget _buildStreamCard(String name, String url, String docId) {
    if (!_controllers.containsKey(docId)) {
      _initializeController(docId, url);
    }

    final controller = _controllers[docId]!;
    final hasError = _hasError[docId] ?? false;
    final isExpanded = _expandedDocId == docId;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedDocId = isExpanded ? null : docId;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            SizedBox(
              height: isExpanded ? 300 : 200,
              width: double.infinity,
              child: hasError
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Failed to load stream", style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _retryStream(docId, url),
                      icon: const Icon(Icons.refresh),
                      label: const Text("Retry"),
                    )
                  ],
                ),
              )
                  : VlcPlayer(
                controller: controller,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),

            // Overlay title
            Positioned(
              top: 12,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Play / Pause Buttons
            if (isExpanded)
              Positioned(
                bottom: 12,
                right: 16,
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => controller.play(),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => controller.pause(),
                      child: const Icon(Icons.pause, color: Colors.white),
                    ),
                  ],
                ),
              ),

            // Expand arrow icon
            Positioned(
              top: 12,
              right: 12,
              child: AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(Icons.expand_more, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _handleRefresh() async {
    setState(() {
      _refreshing = true;
    });

    // Dispose and clear all existing controllers and error states
    for (var c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _hasError.clear();

    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _refreshing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Streams"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE8F9FF),
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFE8F9FF),
      body: uid == null
          ? const Center(child: Text("Not logged in"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('cameras')
            .orderBy('addedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final cameras = snapshot.data!.docs;

          if (cameras.isEmpty) {
            return const Center(child: Text("No cameras available."));
          }

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: ListView.builder(
              itemCount: cameras.length,
              itemBuilder: (context, index) {
                final camera = cameras[index].data() as Map<String, dynamic>;
                final name = camera['name'] ?? 'Camera';
                final url = camera['url'] ?? '';
                final docId = cameras[index].id;

                return _buildStreamCard(name, url, docId);
              },
            ),
          );
        },
      ),
    );
  }
}
