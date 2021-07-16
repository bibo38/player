import 'package:app/constants/images.dart';
import 'package:app/mixins/stream_subscriber.dart';
import 'package:app/models/playlist.dart';
import 'package:app/models/song.dart';
import 'package:app/providers/playlist_provider.dart';
import 'package:app/ui/screens/playlist_details.dart';
import 'package:app/utils/preferences.dart' as preferences;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistRow extends StatefulWidget {
  final Playlist playlist;

  final VoidCallback? onTap;

  const PlaylistRow({Key? key, required this.playlist, this.onTap})
      : super(key: key);

  _PlaylistRowState createState() => _PlaylistRowState();
}

class _PlaylistRowState extends State<PlaylistRow> with StreamSubscriber {
  late final PlaylistProvider playlistProvider;
  late Playlist _playlist;

  @override
  initState() {
    super.initState();
    playlistProvider = context.read();
    setState(() => _playlist = widget.playlist);

    subscribe(
      playlistProvider.playlistPopulatedStream.listen((playlist) {
        if (playlist.id == _playlist.id) {
          setState(() => _playlist = playlist);
        }
      }),
    );
  }

  @override
  dispose() {
    unsubscribeAll();
    super.dispose();
  }

  Widget playlistThumbnail() {
    late String? thumbnailUrl;

    if (!_playlist.isEmpty) {
      Song songWithCustomImage = _playlist.songs.firstWhere((song) {
        return song.hasCustomImage;
      }, orElse: () => _playlist.songs[0]);

      thumbnailUrl = songWithCustomImage.imageUrl;
    } else {
      thumbnailUrl = preferences.defaultImageUrl;
    }

    return _playlist.populated
        ? ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              placeholder: (_, __) => defaultImage,
              errorWidget: (_, __, ___) => defaultImage,
              imageUrl: thumbnailUrl ?? preferences.defaultImageUrl,
            ),
          )
        : Icon(
            CupertinoIcons.music_note_list,
            color: Colors.white54,
          );
  }

  void _defaultOnTap() => gotoDetailsScreen(context, playlist: _playlist);

  @override
  Widget build(BuildContext context) {
    String subtitle =
        _playlist.isSmart ? 'Smart playlist' : 'Standard playlist';

    if (_playlist.populated) {
      subtitle += _playlist.isEmpty
          ? ' • Empty'
          : ' • ${_playlist.songs.length} song' +
              (_playlist.songs.length == 1 ? '' : 's');
    }

    return InkWell(
      onTap: widget.onTap ?? _defaultOnTap,
      child: ListTile(
        shape: Border(bottom: Divider.createBorderSide(context)),
        leading: playlistThumbnail(),
        title: Text(_playlist.name, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
      ),
    );
  }
}
