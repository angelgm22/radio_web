import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class SongsSelector extends StatelessWidget {
  final Playing? playing;
  final List<Audio> audios;
  final Function(Audio) onSelected;
  final Function(List<Audio>) onPlaylistSelected;

  SongsSelector(
      {required this.playing,
      required this.audios,
      required this.onSelected,
      required this.onPlaylistSelected});

  Widget _image(Audio item) {
    if (item.metas.image == null) {
      return SizedBox(height: 40, width: 40);
    }

    return item.metas.image?.type == ImageType.network
        ? Image.network(
            item.metas.image!.path,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          )
        : Image.asset(
            item.metas.image!.path,
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          );
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width - 180;
    double _screenWidthS = MediaQuery.of(context).size.width;
    bool fontS = _screenWidthS < 1024.0;
        int minSize = 500;

    bool minS = _screenWidthS <= minSize;

    

    return /* */ SizedBox(
      width: double.infinity,
      height: 85,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: audios.length,
          itemBuilder: (BuildContext ctx, index) {
            final item = audios[index];
            final isPlaying = item.path == playing?.audio.assetAudioPath;
            return Container(
                margin: const EdgeInsets.all(15),
                width: _screenWidth / 3,
                alignment: Alignment.center,
                child: Neumorphic(
                  margin: EdgeInsets.all(4),
                  style: NeumorphicStyle(
                    depth: isPlaying ? -8 : 8,
                    boxShape:
                        NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
                  ),
                  child: ListTile(
                      leading: Material(
                        shape: CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: _image(item),
                      ),
                      title: 
                      minS ?
                      SizedBox()
                      :
                      Text(item.metas.title.toString(),
                          style: TextStyle(
                            color: isPlaying ? Colors.blue : Colors.black,
                          )),
                      onTap: () {
                        // isPlaying?
                        onSelected(item);
                      }),
                ));
          }),
    );
  }
}
