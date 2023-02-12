import 'package:flutter/material.dart';
import 'package:flutter_webtoon/models/webtoon_detail_model.dart';
import 'package:flutter_webtoon/models/webtoon_episode_model.dart';
import 'package:flutter_webtoon/services/api_service.dart';
import 'package:flutter_webtoon/widgets/episode_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen(
      {Key? key, required this.title, required this.thumb, required this.id})
      : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final Future<WebtoonDetailModel> webtoon;
  late final Future<List<WebtoonEpisodeModel>> episodes;
  late final SharedPreferences prefs;
  bool isLiked = false;

  Future initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    final likedTonns = prefs.getStringList("likedToons");
    if (likedTonns != null) {
      if (likedTonns.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await prefs.setStringList("likedToons", []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodes(widget.id);
    initPrefs();
  }

  onHeartTap() async {
    final likedTonns = prefs.getStringList("likedToons");
    if (likedTonns != null) {
      if (isLiked) {
        likedTonns.remove(widget.id);
      } else {
        likedTonns.add(widget.id);
      }
      await prefs.setStringList('likedToons', likedTonns);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon: isLiked
                ? const Icon(
                    Icons.favorite,
                  )
                : const Icon(
                    Icons.favorite_outline,
                  ),
          ),
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: widget.id,
                    child: Container(
                      width: 200,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 15,
                              offset: const Offset(10, 10),
                              color: Colors.black.withOpacity(0.3)),
                        ],
                      ),
                      child: Image.network(widget.thumb),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              FutureBuilder(
                future: webtoon,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          snapshot.data!.about,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Text('${snapshot.data!.genre} / ${snapshot.data!.age}')
                      ],
                    );
                  }
                  return const Text('........');
                },
              ),
              const SizedBox(
                height: 25,
              ),
              FutureBuilder(
                future: episodes,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        for (var episode in snapshot.data!)
                          Episode(
                            episode: episode,
                            webtoonId: widget.id,
                          ),
                      ],
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
