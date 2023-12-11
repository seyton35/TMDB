import 'package:flutter/material.dart';
import 'package:the_movie_data_base__pet/domain/api_client/api_client.dart';
import 'package:the_movie_data_base__pet/domain/entity/movie_details_credits.dart';
import 'package:the_movie_data_base__pet/library/widgets/inherited/provider.dart';
import 'package:the_movie_data_base__pet/theme/app_colors.dart';
import 'package:the_movie_data_base__pet/ui/navigation/main_navigation.dart';
import 'package:the_movie_data_base__pet/ui/widgets/app/main_app_model.dart';
import 'package:the_movie_data_base__pet/ui/widgets/movie_details/movie_details_model.dart';
import 'package:the_movie_data_base__pet/ui/widgets/paint/round_percent_bar_widget.dart';

class MovieDetailsWidget extends StatefulWidget {
  const MovieDetailsWidget({super.key});

  @override
  State<MovieDetailsWidget> createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<MovieDetailsWidget> {
  @override
  void initState() {
    super.initState();
    final model = NotifierProvider.read<MovieDetailsModel>(context);
    final mainAppModel = InheritedProvider.read<MainAppModel>(context);
    model?.onSessionExpired = () => mainAppModel?.resetSession(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    NotifierProvider.read<MovieDetailsModel>(context)?.setupLocale(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _ScreenTitleWidget()),
      body: ColoredBox(
        color: AppColors.mainDarkBlue,
        child: _BodyWidget(),
      ),
    );
  }
}

class _BodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    if (model == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      children: const [
        _MoviePosterWidget(),
        _MovieDescriptionWidget(),
        _ActorsListWidget()
      ],
    );
  }
}

class _ScreenTitleWidget extends StatelessWidget {
  const _ScreenTitleWidget();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    return Text(model?.movieDetails?.title ?? 'Загрузка...');
  }
}

class _MoviePosterWidget extends StatelessWidget {
  const _MoviePosterWidget();
  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    final posterPath = model?.movieDetails?.posterPath;
    final backdropPath = model?.movieDetails?.backdropPath;
    return AspectRatio(
      aspectRatio: 392.7 / 220.7,
      child: Stack(
        children: [
          backdropPath != null
              ? Image.network(
                  ApiClient.imageUrl(backdropPath),
                )
              : const SizedBox.shrink(),
          Positioned(
            top: 20,
            left: 20,
            bottom: 20,
            child: posterPath != null
                ? Image.network(
                    ApiClient.imageUrl(posterPath),
                  )
                : const SizedBox.shrink(),
          ),
          const Positioned(
            top: 15,
            right: 15,
            child: _FavoriteButton(),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    final isFavorite = model?.isFavorite;
    return IconButton(
      onPressed: () => model?.toggleFavorite(),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 38,
          ),
          isFavorite == true
              ? Positioned(
                  left: 4,
                  top: 4,
                  child: Icon(
                    Icons.favorite,
                    size: 30,
                    color: Colors.yellow[800],
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _MovieDescriptionWidget extends StatelessWidget {
  const _MovieDescriptionWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _MovieTitleWidget(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              _MovieRatingWidget(),
              _MovieCustomDivider(),
              _MovieTrailerButton(),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: const Color(0xff1d0a55),
              border: Border.all(width: 1, color: Colors.black38)),
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: _MovieGenreWidget(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MovieTaglineWidget(),
              SizedBox(height: 10),
              _MovieReviewWidget(),
              SizedBox(height: 30),
              _CrewListWidget()
            ],
          ),
        ),
      ],
    );
  }
}

class _MovieTitleWidget extends StatelessWidget {
  const _MovieTitleWidget();

  @override
  Widget build(BuildContext context) {
    final details =
        NotifierProvider.watch<MovieDetailsModel>(context)?.movieDetails;
    if (details == null) return const SizedBox();
    var year = details.releaseDate?.year.toString();
    year = year != null ? ' ($year)' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: details.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
              ),
            ),
            TextSpan(
              text: year,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovieRatingWidget extends StatelessWidget {
  const _MovieRatingWidget();

  final _descriptionButtonStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    final voteAverage = (model?.movieDetails?.voteAverage ?? 0) * 10;
    return TextButton(
      onPressed: () {},
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: RoundPercentBarWidget(
              percent: voteAverage,
              fillcolor: AppColors.mainDarkBlue,
              fullcolor: const Color(0xff21d07a),
              freecolor: const Color(0xff204529),
              lineWidth: 3,
            ),
          ),
          const SizedBox(width: 10),
          Text('Рейтинг', style: _descriptionButtonStyle)
        ],
      ),
    );
  }
}

class _MovieCustomDivider extends StatelessWidget {
  const _MovieCustomDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: DecoratedBox(
        decoration: BoxDecoration(color: Colors.grey),
        child: SizedBox(
          height: 24,
          width: 1,
        ),
      ),
    );
  }
}

class _MovieTrailerButton extends StatelessWidget {
  const _MovieTrailerButton();
  final _descriptionButtonStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  void _navigateToTrailer(
      BuildContext context, String trailerKey, String title) {
    final arguments = <String, String>{
      "trailerKey": trailerKey,
      "name": title,
    };
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.movieDetailsTrailerWidget,
      arguments: arguments,
    );
  }

  @override
  Widget build(BuildContext context) {
    final details =
        NotifierProvider.watch<MovieDetailsModel>(context)?.movieDetails;
    final videos = details?.videos.results
        .where((video) => video.type == 'Trailer' && video.site == 'YouTube');
    final trailerKey = videos?.isNotEmpty == true ? videos?.first.key : null;
    if (trailerKey == null) return const SizedBox.shrink();
    return TextButton(
      onPressed: () => _navigateToTrailer(
        context,
        trailerKey,
        details?.title ?? '',
      ),
      child: Row(
        children: [
          const Icon(Icons.play_arrow, color: Colors.white),
          const SizedBox(width: 6),
          Text('Воспроизвести трейлер', style: _descriptionButtonStyle),
        ],
      ),
    );
  }
}

class _MovieGenreWidget extends StatelessWidget {
  const _MovieGenreWidget();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    final details = model?.movieDetails;
    if (model == null || details == null) return const SizedBox();

    var texts = <String>[];

    final releaseDate = details.releaseDate;
    if (releaseDate != null) {
      final formatedDate =
          model.stringFromDate(releaseDate).replaceAll('.', '/');
      texts.add(formatedDate);
    }

    final productCountries = details.productionCountries;
    if (productCountries.isNotEmpty) {
      texts.add('(${productCountries.first.iso})');
    }
    final dateAndCountry = ' ${texts.join(' ')} ';
    var filmDurationString = '';

    final runtime = details.runtime;
    if (runtime != null) {
      final strings = <String>[];
      final hours = runtime ~/ 60;
      final minutes = runtime - hours * 60;
      strings.add(hours > 0 ? ' ${hours}h' : '');
      strings.add(minutes > 0 ? ' ${minutes}m' : '');
      filmDurationString = strings.join('');
    }

    final genres = details.genres;
    var genreStrings = <String>[];
    if (genres.isNotEmpty) {
      for (var genre in genres) {
        genreStrings.add(genre.name);
      }
    }
    final genreString = genreStrings.join(', ');

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: ' PG-13 ',
            style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                background: Paint()
                  ..color = Colors.grey
                  ..style = PaintingStyle.stroke
                  ..strokeCap = StrokeCap.round
                  ..strokeWidth = 2.0),
          ),
          TextSpan(text: dateAndCountry),
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.lens_rounded,
              size: 6,
              color: Colors.white,
            ),
          ),
          TextSpan(text: filmDurationString),
          const TextSpan(text: '\n'),
          TextSpan(text: genreString),
        ],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MovieTaglineWidget extends StatelessWidget {
  const _MovieTaglineWidget();

  @override
  Widget build(BuildContext context) {
    return const Text(
      //todo
      'цитата?',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ),
    );
  }
}

class _MovieReviewWidget extends StatelessWidget {
  const _MovieReviewWidget();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    final overview = model?.movieDetails?.overview ?? '';
    return Column(
      children: [
        const Text(
          'Обзор',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          overview,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CrewListWidget extends StatelessWidget {
  const _CrewListWidget();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    var crew = model?.movieDetails?.credits.crew;
    if (crew == null || crew.isEmpty) return const SizedBox.shrink();
    crew = crew.length > 4 ? crew.sublist(0, 4) : crew;
    var crewCuncks = <List<Crew>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewCuncks
          .add(crew.sublist(i, i + 2 < crew.length ? i + 2 : crew.length));
    }
    return Column(
      children: crewCuncks
          .map((chunck) => Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: CrewListRow(crewChunck: chunck),
              ))
          .toList(),
    );
  }
}

class CrewListRow extends StatelessWidget {
  final List<Crew> crewChunck;
  const CrewListRow({super.key, required this.crewChunck});

  @override
  Widget build(BuildContext context) {
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: crewChunck
            .map((member) => _CrewListRowItem(crewMember: member))
            .toList());
  }
}

class _CrewListRowItem extends StatelessWidget {
  final Crew crewMember;
  const _CrewListRowItem({
    required this.crewMember,
  });
  final _personNameStyle = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );
  final _personJobStyle = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            crewMember.name,
            style: _personNameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            crewMember.job,
            style: _personJobStyle,
          ),
        ],
      ),
    );
  }
}

class _ActorsListWidget extends StatelessWidget {
  const _ActorsListWidget();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'В главных ролях',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 20),
            height: 259,
            child: const Scrollbar(
              child: _ActorsListViewWidget(),
            ),
          )
        ],
      ),
    );
  }
}

class _ActorsListViewWidget extends StatelessWidget {
  const _ActorsListViewWidget();

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieDetailsModel>(context);
    var actors = model?.movieDetails?.credits.cast;
    if (actors == null || actors.isEmpty) return const SizedBox.shrink();
    const actorsLimmit = 20;
    actors =
        actors.length > actorsLimmit ? actors.sublist(0, actorsLimmit) : actors;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemExtent: 120,
      itemCount: actors.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 4),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
            border: Border.all(width: 1, color: Colors.grey.shade300),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          clipBehavior: Clip.hardEdge,
          child: _ActorsListWidgetItem(actor: actors![index]),
        ),
      ),
    );
  }
}

class _ActorsListWidgetItem extends StatelessWidget {
  final Actor actor;
  const _ActorsListWidgetItem({
    required this.actor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        actor.profilePath == null
            ? AspectRatio(
                aspectRatio: 104 / 156.2,
                child: Center(
                    child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Icon(
                      actor.gender == 1
                          ? Icons.person_3_outlined
                          : Icons.person_4_outlined,
                      color: Colors.grey[600],
                    ),
                  ),
                )),
              )
            : Image.network(
                ApiClient.imageUrl(actor.profilePath!),
              ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                actor.name,
                maxLines: 2,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                actor.character,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
