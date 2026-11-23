import '../../../../core/l10n/app_strings.dart';

/// Bundled Calm Corner relaxing tracks (asset paths relative to [AssetSource]).
class RelaxingTrack {
  const RelaxingTrack({
    required this.id,
    required this.asset,
    required this.titleOf,
  });

  final String id;
  final String asset;
  final String Function(AppStrings l10n) titleOf;
}

const List<RelaxingTrack> kRelaxingTracks = [
  RelaxingTrack(
    id: 'tree_of_life',
    asset: 'care/calm/music/tree_of_life.m4a',
    titleOf: _treeOfLife,
  ),
  RelaxingTrack(
    id: 'reverse_polarity',
    asset: 'care/calm/music/reverse_polarity.m4a',
    titleOf: _reversePolarity,
  ),
  RelaxingTrack(
    id: 'glass_castle',
    asset: 'care/calm/music/glass_castle.m4a',
    titleOf: _glassCastle,
  ),
  RelaxingTrack(
    id: 'serenity',
    asset: 'care/calm/music/serenity.m4a',
    titleOf: _serenity,
  ),
  RelaxingTrack(
    id: 'aurora_borealis',
    asset: 'care/calm/music/aurora_borealis.m4a',
    titleOf: _auroraBorealis,
  ),
];

String _treeOfLife(AppStrings l10n) => l10n.careTrackTreeOfLife;
String _reversePolarity(AppStrings l10n) => l10n.careTrackReversePolarity;
String _glassCastle(AppStrings l10n) => l10n.careTrackGlassCastle;
String _serenity(AppStrings l10n) => l10n.careTrackSerenity;
String _auroraBorealis(AppStrings l10n) => l10n.careTrackAuroraBorealis;
