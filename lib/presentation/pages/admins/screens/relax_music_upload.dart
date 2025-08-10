import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mindcare/presentation/pages/relax_musics/bloc/music/music_bloc.dart';
import 'package:provider/provider.dart';

class RelaxMusicUploadScreen extends StatefulWidget {
  const RelaxMusicUploadScreen({Key? key}) : super(key: key);

  @override
  State<RelaxMusicUploadScreen> createState() => _RelaxMusicUploadScreenState();
}

class _RelaxMusicUploadScreenState extends State<RelaxMusicUploadScreen> with SingleTickerProviderStateMixin {
  List<PlatformFile> _selectedFiles = [];
  List<UploadProgress> _uploadProgress = [];
  List<StorageFile> _uploadedSongs = [];
  bool _isUploading = false;
  bool _isLoadingSongs = true;
  String _statusMessage = '';
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUploadedSongs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUploadedSongs() async {
    setState(() => _isLoadingSongs = true);
    
    try {
      final ListResult result = await FirebaseStorage.instance.ref('musics').listAll();
      List<StorageFile> songs = [];
      
      for (Reference ref in result.items) {
        final metadata = await ref.getMetadata();
        songs.add(StorageFile(
          name: ref.name,
          fullPath: ref.fullPath,
          size: metadata.size ?? 0,
          timeCreated: metadata.timeCreated ?? DateTime.now(),
          downloadUrl: await ref.getDownloadURL(),
        ));
      }
      
      // Sort by upload time (newest first)
      songs.sort((a, b) => b.timeCreated.compareTo(a.timeCreated));
      
      setState(() {
        _uploadedSongs = songs;
        _isLoadingSongs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSongs = false;
        _statusMessage = 'Error loading songs: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Management'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.cloud_upload),
              text: 'Upload New',
            ),
            Tab(
              icon: const Icon(Icons.library_music),
              text: 'Available Songs (${_uploadedSongs.length})',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUploadedSongs,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadTab(),
          _buildSongsLibraryTab(),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File Selection Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Music Files',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Supported formats: MP3, WAV, FLAC, M4A, AAC',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickFiles,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Select Files'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: (_selectedFiles.isEmpty || _isUploading) ? null : _clearFiles,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selected Files List
          if (_selectedFiles.isNotEmpty) ...[
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Files (${_selectedFiles.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _selectedFiles.length,
                          itemBuilder: (context, index) {
                            final file = _selectedFiles[index];
                            final progress = index < _uploadProgress.length ? _uploadProgress[index] : null;
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.music_note, color: Colors.teal),
                                title: Text(
                                  file.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_formatFileSize(file.size)),
                                    if (progress != null) ...[
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: progress.progress,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                                      ),
                                    ],
                                  ],
                                ),
                                trailing: progress != null && progress.isComplete
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : progress != null && progress.hasError
                                        ? const Icon(Icons.error, color: Colors.red)
                                        : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Upload Button
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _uploadFiles,
              icon: _isUploading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isUploading ? 'Uploading...' : 'Upload Files'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ] else ...[
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'No files selected',
                      style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Select Files" to choose music files',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Status Message
          if (_statusMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: _statusMessage.contains('Error') 
                  ? Colors.red.shade50 
                  : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('Error') 
                        ? Colors.red.shade800 
                        : Colors.green.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSongsLibraryTab() {
    if (_isLoadingSongs) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading uploaded songs...'),
          ],
        ),
      );
    }

    if (_uploadedSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No songs uploaded yet',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your first song in the Upload tab',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.teal),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Storage Information',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total songs: ${_uploadedSongs.length}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'Total size: ${_getTotalSize()}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _uploadedSongs.length,
              itemBuilder: (context, index) {
                final song = _uploadedSongs[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Icon(Icons.music_note, color: Colors.teal),
                    ),
                    title: Text(
                      _formatMusicName(song.name),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Size: ${_formatFileSize(song.size)}'),
                        Text(
                          'Uploaded: ${_formatDate(song.timeCreated)}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'delete') {
                          _confirmDeleteSong(song);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _showSongDetails(song),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSongDetails(StorageFile song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_formatMusicName(song.name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Original Name:', song.name),
            _buildDetailRow('File Size:', _formatFileSize(song.size)),
            _buildDetailRow('Upload Date:', _formatDate(song.timeCreated)),
            _buildDetailRow('Storage Path:', song.fullPath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSong(StorageFile song) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Song'),
        content: Text('Are you sure you want to delete "${_formatMusicName(song.name)}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSong(song);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSong(StorageFile song) async {
    try {
      await FirebaseStorage.instance.ref(song.fullPath).delete();
      await _loadUploadedSongs();
      
      // Refresh music bloc
      if (mounted) {
        await context.read<MusicBloc>().loadMusicsFromFirebase();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${_formatMusicName(song.name)}"'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting song: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles = result.files;
          _uploadProgress.clear();
          _statusMessage = '${result.files.length} file(s) selected';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error selecting files: ${e.toString()}';
      });
    }
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles.clear();
      _uploadProgress.clear();
      _statusMessage = '';
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty || _isUploading) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = _selectedFiles.map((f) => UploadProgress()).toList();
      _statusMessage = 'Starting upload...';
    });

    int successCount = 0;
    int errorCount = 0;

    for (int i = 0; i < _selectedFiles.length; i++) {
      final file = _selectedFiles[i];
      
      try {
        if (file.path != null) {
          await _uploadSingleFile(File(file.path!), file.name, i);
          successCount++;
          setState(() {
            _uploadProgress[i].isComplete = true;
          });
        }
      } catch (e) {
        errorCount++;
        setState(() {
          _uploadProgress[i].hasError = true;
        });
        print('Error uploading ${file.name}: $e');
      }
    }

    setState(() {
      _isUploading = false;
      _statusMessage = 'Upload complete: $successCount successful, $errorCount failed';
    });

    // Refresh music list and uploaded songs
    if (mounted && successCount > 0) {
      try {
        await context.read<MusicBloc>().loadMusicsFromFirebase();
        await _loadUploadedSongs();
        setState(() {
          _statusMessage += '\nMusic library updated successfully!';
        });
      } catch (e) {
        print('Error refreshing music list: $e');
      }
    }

    // Show completion dialog
    if (mounted) {
      _showCompletionDialog(successCount, errorCount);
    }
  }

  Future<void> _uploadSingleFile(File file, String fileName, int index) async {
    final storageRef = FirebaseStorage.instance.ref().child('musics/$fileName');
    final uploadTask = storageRef.putFile(file);
    
    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      if (mounted) {
        setState(() {
          _uploadProgress[index].progress = progress;
        });
      }
    });

    await uploadTask;
  }

  void _showCompletionDialog(int successCount, int errorCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              errorCount == 0 ? Icons.check_circle : Icons.warning,
              color: errorCount == 0 ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            const Text('Upload Complete'),
          ],
        ),
        content: Text(
          'Successfully uploaded $successCount file(s).\n'
          '${errorCount > 0 ? 'Failed to upload $errorCount file(s).' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (successCount > 0) {
                _clearFiles();
                _tabController.animateTo(1); // Switch to library tab
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatMusicName(String name) {
    final formattedName = name.replaceAll('_', ' ').replaceAll('-', ' ').replaceAll('.mp3', '');
    return formattedName
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getTotalSize() {
    final totalBytes = _uploadedSongs.fold<int>(0, (sum, song) => sum + song.size);
    return _formatFileSize(totalBytes);
  }
}

class UploadProgress {
  double progress = 0.0;
  bool isComplete = false;
  bool hasError = false;
}

class StorageFile {
  final String name;
  final String fullPath;
  final int size;
  final DateTime timeCreated;
  final String downloadUrl;

  StorageFile({
    required this.name,
    required this.fullPath,
    required this.size,
    required this.timeCreated,
    required this.downloadUrl,
  });
}