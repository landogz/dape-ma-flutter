import 'app_locale.dart';
import 'translation_catalog.dart';

class AppStrings {
  AppStrings(this.locale);

  final AppLocale locale;

  bool get isTagalog => locale == AppLocale.tl;

  String _t(
    String key,
    String en,
    String tl, [
    Map<String, String> vars = const {},
  ]) {
    var value = TranslationCatalog.value(key, locale) ?? (isTagalog ? tl : en);
    if (vars.isEmpty) {
      return value;
    }
    vars.forEach((name, replacement) {
      value = value
          .replaceAll('{$name}', replacement)
          .replaceAll('\$$name', replacement);
    });
    return value;
  }

  String _countPhrase({
    required int count,
    required String oneKey,
    required String manyKey,
    required String enOne,
    required String enMany,
    required String tlOne,
    required String tlMany,
  }) {
    if (count == 1) {
      return _t(oneKey, enOne, tlOne);
    }
    return _t(manyKey, enMany, tlMany, {'count': count.toString()});
  }

  // Navigation
  String get navHome => _t('navHome', 'Home', 'Tahanan');
  String get navRehab => _t('navRehab', 'Services', 'Serbisyo');
  String get navSaved => _t('navSaved', 'Saved', 'Naka-save');
  String get navDiary => _t('navDiary', 'Journal', 'Journal');
  String get navBible => _t('navBible', 'Kid Listo', 'Kid Listo');
  String get navKidListo => _t('navKidListo', 'Kid Listo', 'Kid Listo');
  String get navAccount => _t('navAccount', 'Profile', 'Profile');

  String get splashAppName => _t('splashAppName', 'DAPE-MA', 'DAPE-MA');
  String get splashFullName => _t('splashFullName', 
        'Drug Abuse Prevention\nEducation Mobile Application',
        'Drug Abuse Prevention\nEducation Mobile Application',
      );
  String get splashFooter => _t('splashFooter', 
        'Dangerous Drugs Board · Office of the President',
        'Dangerous Drugs Board · Office of the President',
      );

  // DDB Services
  String get ddbServicesTitle => _t('ddbServicesTitle', 'DDB Services', 'Mga Serbisyo ng DDB');
  String get ddbServicesSubtitle => _t('ddbServicesSubtitle', 
        'Browse DDB trainings, rehab centers, IEC materials, and contests.',
        'Tingnan ang mga training, rehab center, IEC materials, at contests ng DDB.',
      );
  String get contestsTitle => _t('contestsTitle', 'Contests', 'Mga Contest');
  String get contestsSubtitle => _t('contestsSubtitle', 
        'Browse song, poster, and video contests in one place.',
        'Tingnan ang song, poster, at video contests sa isang lugar.',
      );
  String get contestDetailTitle =>
      _t('contestDetailTitle', 'Contest details', 'Detalye ng contest');
  String get searchContestsHint =>
      _t('searchContestsHint', 'Search contests...', 'Maghanap ng contest...');
  String get noContestsFound =>
      _t('noContestsFound', 'No contests found', 'Walang nahanap na contest');
  String get contestCategoryAll => _t('contestCategoryAll', 'All', 'Lahat');
  String get contestCategorySong => _t('contestCategorySong', 'Song', 'Kanta');
  String get contestCategoryPoster => _t('contestCategoryPoster', 'Poster', 'Poster');
  String get contestCategoryVideo => _t('contestCategoryVideo', 'Video', 'Video');
  String get posterImageUrlLabel =>
      _t('posterImageUrlLabel', 'Poster image URL', 'URL ng poster image');
  String get mediaOrLyricsRequired => _t('mediaOrLyricsRequired', 
        'Provide a media URL or lyrics.',
        'Maglagay ng media URL o lyrics.',
      );
  String get trainingsTitle => _t('trainingsTitle', 'Trainings', 'Mga Training');
  String get trainingsSubtitle => _t('trainingsSubtitle', 
        'Upcoming capacity-building and preventive education programs.',
        'Mga paparating na capacity-building at preventive education programs.',
      );
  String get rehabCentersSubtitle => _t('rehabCentersSubtitle', 
        'Find treatment and rehabilitation facilities near you.',
        'Maghanap ng treatment at rehabilitation facilities.',
      );
  String get songContestTitle =>
      _t('songContestTitle', 'Playlist / Song Contest', 'Playlist / Song Contest');
  String get songContestSubtitle => _t('songContestSubtitle', 
        'Join open contests, submit your entry, and see winners.',
        'Sumali sa open contests, mag-submit ng entry, at tingnan ang mga panalo.',
      );
  String get posterContestTitle =>
      _t('posterContestTitle', 'Poster-Making Contest', 'Poster-Making Contest');
  String get posterContestSubtitle => _t('posterContestSubtitle', 
        'Submit original advocacy posters for DDB review.',
        'Mag-submit ng orihinal na advocacy poster para sa review ng DDB.',
      );
  String get posterContestDetailTitle =>
      _t('posterContestDetailTitle', 'Poster contest details', 'Detalye ng poster contest');
  String get submitPosterEntry =>
      _t('submitPosterEntry', 'Submit your poster', 'I-submit ang iyong poster');
  String get loginToSubmitPoster => _t('loginToSubmitPoster', 
        'Sign in to submit your poster',
        'Mag-sign in para mag-submit ng poster',
      );
  String get videoContestTitle =>
      _t('videoContestTitle', 'Video-Making Contest', 'Video-Making Contest');
  String get videoContestSubtitle => _t('videoContestSubtitle', 
        'Submit original advocacy videos via YouTube or video URL.',
        'Mag-submit ng orihinal na advocacy video via YouTube o video URL.',
      );
  String get videoContestDetailTitle =>
      _t('videoContestDetailTitle', 'Video contest details', 'Detalye ng video contest');
  String get submitVideoEntry =>
      _t('submitVideoEntry', 'Submit your video', 'I-submit ang iyong video');
  String get loginToSubmitVideo => _t('loginToSubmitVideo', 
        'Sign in to submit your video',
        'Mag-sign in para mag-submit ng video',
      );
  String get videoUrlLabel => _t('videoUrlLabel', 'YouTube / video URL', 'YouTube / video URL');
  String get videoUrlHint => _t('videoUrlHint', 
        'Paste a YouTube or public video link',
        'I-paste ang YouTube o public video link',
      );
  String get videoUrlInvalid => _t('videoUrlInvalid', 
        'Enter a valid http(s) URL',
        'Maglagay ng wastong http(s) URL',
      );
  String get publishedVideos =>
      _t('publishedVideos', 'Published videos', 'Mga na-publish na video');
  String get noPublishedVideosYet => _t('noPublishedVideosYet', 
        'No published videos yet. Submit yours for admin review.',
        'Wala pang na-publish na video. Mag-submit para ma-review ng admin.',
      );
  String get videoSubmittedForReview => _t('videoSubmittedForReview', 
        'Video submitted for admin review.',
        'Naipasa ang video para sa review ng admin.',
      );
  String get videoSubmitFailed => _t('videoSubmitFailed', 
        'Unable to submit video. Please try again.',
        'Hindi maipasa ang video. Subukan muli.',
      );
  String get searchVideoContestHint =>
      _t('searchVideoContestHint', 'Search video contests...', 'Maghanap ng video contest...');
  String get noVideoContestFound =>
      _t('noVideoContestFound', 'No video contests found', 'Walang nahanap na video contest');
  String get pasteVideoUrl =>
      _t('pasteVideoUrl', 'Paste video URL', 'I-paste ang video URL');
  String get iecMaterialsTitle =>
      _t('iecMaterialsTitle', 'IEC Materials (Animated)', 'IEC Materials (Animated)');
  String get iecMaterialsSubtitle => _t('iecMaterialsSubtitle', 
        'Browse animated IEC GIFs, images, and advocacy clips.',
        'Tingnan ang animated IEC GIF, larawan, at advocacy clips.',
      );
  String get iecMaterialDetailTitle =>
      _t('iecMaterialDetailTitle', 'IEC material', 'IEC material');
  String get searchIecMaterialsHint =>
      _t('searchIecMaterialsHint', 'Search IEC materials...', 'Maghanap ng IEC materials...');
  String get noIecMaterialsFound =>
      _t('noIecMaterialsFound', 'No IEC materials found', 'Walang nahanap na IEC materials');
  String get allTopics => _t('allTopics', 'All topics', 'Lahat ng topic');
  String get allMediaTypes => _t('allMediaTypes', 'All media', 'Lahat ng media');
  String get aboutIecMaterial =>
      _t('aboutIecMaterial', 'About this material', 'Tungkol sa material na ito');
  String get tapToViewIec => _t('tapToViewIec', 'Tap to view', 'I-tap para tingnan');
  String get creatorNameLabel =>
      _t('creatorNameLabel', 'Creator name', 'Pangalan ng creator');
  String get posterImageLabel =>
      _t('posterImageLabel', 'Poster image', 'Larawan ng poster');
  String get pickPosterImage =>
      _t('pickPosterImage', 'Choose poster from gallery', 'Pumili ng poster mula sa gallery');
  String get orPosterImageUrl =>
      _t('orPosterImageUrl', 'Or paste image URL', 'O i-paste ang image URL');
  String get publishedPosters =>
      _t('publishedPosters', 'Published posters', 'Mga na-publish na poster');
  String get noPublishedPostersYet => _t('noPublishedPostersYet', 
        'No published posters yet. Submit yours for admin review.',
        'Wala pang na-publish na poster. Mag-submit para ma-review ng admin.',
      );
  String get posterSubmittedForReview => _t('posterSubmittedForReview', 
        'Poster submitted for admin review.',
        'Naipasa ang poster para sa review ng admin.',
      );
  String get posterSubmitFailed => _t('posterSubmitFailed', 
        'Unable to submit poster. Please try again.',
        'Hindi maipasa ang poster. Subukan muli.',
      );
  String get searchPosterContestHint =>
      _t('searchPosterContestHint', 'Search poster contests...', 'Maghanap ng poster contest...');
  String get noPosterContestFound =>
      _t('noPosterContestFound', 'No poster contests found', 'Walang nahanap na poster contest');
  String get songContestDetailTitle =>
      _t('songContestDetailTitle', 'Contest details', 'Detalye ng contest');
  String get aboutEntry => _t('aboutEntry', 'About this entry', 'Tungkol sa entry');
  String get themeLabel => _t('themeLabel', 'Theme', 'Tema');
  String get lyricsLabel => _t('lyricsLabel', 'Lyrics', 'Lyrics');
  String get playlistType => _t('playlistType', 'Playlist', 'Playlist');
  String get songWritingType => _t('songWritingType', 'Song writing', 'Pagsulat ng kanta');
  String get allEntryTypes => _t('allEntryTypes', 'All types', 'Lahat ng uri');
  String get searchSongContestHint =>
      _t('searchSongContestHint', 'Search contests...', 'Maghanap ng contest...');
  String get noSongContestFound =>
      _t('noSongContestFound', 'No contests found', 'Walang nahanap na contest');
  String get openOnYoutube => _t('openOnYoutube', 'Open on YouTube', 'Buksan sa YouTube');
  String get openMediaLink => _t('openMediaLink', 'Open media link', 'Buksan ang media link');
  String get acceptingEntries =>
      _t('acceptingEntries', 'Accepting entries', 'Tumanggap ng entries');
  String get contestRules => _t('contestRules', 'Rules', 'Mga patakaran');
  String get yourEntryStatus => _t('yourEntryStatus', 'Your entry', 'Ang iyong entry');
  String get submitContestEntry =>
      _t('submitContestEntry', 'Submit your entry', 'I-submit ang iyong entry');
  String get loginToSubmitEntry => _t('loginToSubmitEntry', 
        'Sign in to submit your entry',
        'Mag-sign in para mag-submit ng entry',
      );
  String get submissionsClosed =>
      _t('submissionsClosed', 'Submissions are closed', 'Sarado na ang pag-submit');
  String get publishedEntries =>
      _t('publishedEntries', 'Published entries', 'Mga na-publish na entry');
  String get noPublishedEntriesYet => _t('noPublishedEntriesYet', 
        'No published entries yet. Submit yours for admin review.',
        'Wala pang na-publish na entry. Mag-submit para ma-review ng admin.',
      );
  String get entrySubmittedForReview => _t('entrySubmittedForReview', 
        'Entry submitted for admin review.',
        'Naipasa ang entry para sa review ng admin.',
      );
  String get entrySubmitFailed => _t('entrySubmitFailed', 
        'Unable to submit entry. Please try again.',
        'Hindi maipasa ang entry. Subukan muli.',
      );
  String get entryTypeLabel => _t('entryTypeLabel', 'Entry type', 'Uri ng entry');
  String get entryTitleLabel => _t('entryTitleLabel', 'Title', 'Pamagat');
  String get artistNameLabel => _t('artistNameLabel', 'Artist / Creator name', 'Pangalan ng artist / creator');
  String get mediaUrlLabel => _t('mediaUrlLabel', 'Media URL', 'Media URL');
  String get regionOptionalLabel => _t('regionOptionalLabel', 'Region (optional)', 'Rehiyon (opsyonal)');
  String get descriptionOptionalLabel =>
      _t('descriptionOptionalLabel', 'Description (optional)', 'Deskripsyon (opsyonal)');
  String get requiredField => _t('requiredField', 'This field is required', 'Kinakailangan ang field na ito');
  String get trainingDetailTitle => _t('trainingDetailTitle', 'Training details', 'Detalye ng training');
  String get aboutTraining => _t('aboutTraining', 'About this training', 'Tungkol sa training');
  String get scheduleLabel => _t('scheduleLabel', 'Schedule', 'Iskedyul');
  String get timeLabel => _t('timeLabel', 'Time', 'Oras');
  String get venueLabel => _t('venueLabel', 'Venue', 'Lugar');
  String get organizerLabel => _t('organizerLabel', 'Organizer', 'Tagapag-organisa');
  String get slotsLabel => _t('slotsLabel', 'Slots', 'Mga slot');
  String get contactLabel => _t('contactLabel', 'Contact', 'Contact');
  String get registerOrLearnMore =>
      _t('registerOrLearnMore', 'Register / Learn more', 'Magparehistro / Alamin pa');
  String get searchTrainingsHint =>
      _t('searchTrainingsHint', 'Search trainings...', 'Maghanap ng training...');
  String get allCategories => _t('allCategories', 'All categories', 'Lahat ng kategorya');
  String get noTrainingsFound =>
      _t('noTrainingsFound', 'No trainings found', 'Walang nahanap na training');

  // Home
  String get welcomeBack => _t('welcomeBack', 'Welcome back,', 'Maligayang pagbabalik,');
  String get welcomeBackExclaim => _t('welcomeBackExclaim', 'Welcome back!', 'Maligayang pagbabalik!');
  String homeHiName(String name) => _t('homeHiName', 'Hi, $name!', 'Kumusta, $name!', {'name': name.toString()});
  String homeGoodMorning(String name) =>
      _t('homeGoodMorning', 'Good morning, $name', 'Magandang umaga, $name', {'name': name.toString()});
  String homeGoodAfternoon(String name) =>
      _t('homeGoodAfternoon', 'Good afternoon, $name', 'Magandang hapon, $name', {'name': name.toString()});
  String homeGoodEvening(String name) =>
      _t('homeGoodEvening', 'Good evening, $name', 'Magandang gabi, $name', {'name': name.toString()});
  String get homeExploreSubtitle => _t('homeExploreSubtitle', 
        'What do you like to explore today?',
        'Ano ang gusto mong tuklasin ngayon?',
      );
  String get homeSearchTopicsHint => _t('homeSearchTopicsHint', 
        'Search topics, services',
        'Maghanap ng topics, serbisyo',
      );
  String get homeWhatsNew => _t('homeWhatsNew', "What's New?", "Ano'ng Bago?");
  String get homeWhatsNewEmpty => _t('homeWhatsNewEmpty', 
        'Check back soon for new courses and events.',
        'Bumalik mamaya para sa mga bagong kursong event.',
      );
  String get homeNewCoursePrefix => _t('homeNewCoursePrefix', 'New course:', 'Bagong kurso:');
  String get homeNewCourseTitle =>
      _t('homeNewCourseTitle', 'Goals, Dreams, and You', 'Goals, Dreams, and You');
  String get homeUpcomingWebinarPrefix =>
      _t('homeUpcomingWebinarPrefix', 'Upcoming webinar:', 'Paparating na webinar:');
  String get homeUpcomingWebinarTitle =>
      _t('homeUpcomingWebinarTitle', 'The Science of Prevention', 'The Science of Prevention');
  String get homeThoughtOfDay => _t('homeThoughtOfDay', 'Thought of the Day', 'Isipin Ngayon');
  String get homeThoughtFallback => _t('homeThoughtFallback', 
        'Small steps every day lead to a better you.',
        'Ang maliliit na hakbang araw-araw ay patungo sa mas magandang ikaw.',
      );
  String get homeFeaturedForYou =>
      _t('homeFeaturedForYou', 'Featured for You', 'Itinatampok Para sa Iyo');
  String get postsPageTitle => _t('postsPageTitle', 'Posts', 'Mga Post');
  String get postsBrowseSubtitle => _t('postsBrowseSubtitle', 
        'Browse featured stories and more from DAPE-MA.',
        'Tingnan ang mga featured stories at iba pa mula sa DAPE-MA.',
      );
  String get homeTaraExplore =>
      _t('homeTaraExplore', 'Tara, #BeTheDAPE!', 'Tara, #BeTheDAPE!');
  String get homeDapeProgress =>
      _t('homeDapeProgress', 'Your DAPE Progress', 'Iyong DAPE Progress');
  String get homeProgressCourses => _t('homeProgressCourses', 'Courses', 'Mga Kurso');
  String get homeProgressLessons => _t('homeProgressLessons', 'Lessons', 'Mga Aralin');
  String get homeProgressStreak => _t('homeProgressStreak', 'Streak', 'Streak');
  String get bidaLearnTitle => _t('bidaLearnTitle', 'DAPE Learn', 'DAPE Learn');
  String get bidaHopeTitle => _t('bidaHopeTitle', 'DAPE Hope', 'DAPE Hope');
  String get bidaCareTitle => _t('bidaCareTitle', 'DAPE Care', 'DAPE Care');
  String get homeExploreLearnDesc =>
      _t('homeExploreLearnDesc', 'Lessons & modules', 'Mga aralin at modules');
  String get homeExploreHopeDesc =>
      _t('homeExploreHopeDesc', 'Peer support', 'Suporta ng kapwa');
  String get homeExploreCareDesc =>
      _t('homeExploreCareDesc', 'Counseling & help', 'Counseling at tulong');
  String get homeContinueLearning =>
      _t('homeContinueLearning', 'Continue Learning', 'Ipagpatuloy ang Pag-aaral');
  String get homeContinueLearningTitle => _t('homeContinueLearningTitle', 
        'Living Drug-Free, Living Strong',
        'Drug-Free at Matatag na Buhay',
      );
  String get homeStartExploring =>
      _t('homeStartExploring', 'Start exploring', 'Magsimulang tumuklas');
  String get startLesson => _t('startLesson', 'Start', 'Simulan');
  String get resumeLesson => _t('resumeLesson', 'Resume', 'Ipagpatuloy');
  String homeLessonProgress(int done, int total) =>
      _t('homeLessonProgress', 'Lesson $done of $total', 'Aralin $done sa $total', {'done': done.toString(), 'total': total.toString()});
  String get homeRecentActivity =>
      _t('homeRecentActivity', 'Recent Activity', 'Kamakailang Aktibidad');
  String get homeActivityEmptyTitle =>
      _t('homeActivityEmptyTitle', 'No activity yet', 'Wala pang aktibidad');
  String get homeActivityEmptyBody => _t('homeActivityEmptyBody', 
        'Read a lesson or article and it will show up here.',
        'Magbasa ng aralin o artikulo at lilitaw ito dito.',
      );
  String get homeMoreForYou => _t('homeMoreForYou', 'More for you', 'Higit pa para sa iyo');
  String homeYouCompleted(String title) =>
      _t('homeYouCompleted', 'You completed $title', 'Natapos mo ang $title', {'title': title.toString()});
  String homeYouRead(String title) =>
      _t('homeYouRead', 'You read $title', 'Binasa mo ang $title', {'title': title.toString()});
  String get homeDiscover => _t('homeDiscover', 'Discover', 'Tuklasin');
  String get homeNoPostsFound =>
      _t('homeNoPostsFound', 'No posts found', 'Walang nahanap na post');
  String get homeNeedToTalk => _t('homeNeedToTalk', 
        'Need to talk to someone?',
        'Kailangan mong may kausapin?',
      );
  String get homeNeedToTalkCta => _t('homeNeedToTalkCta', 'Get support', 'Humingi ng tulong');
  String get askKidListoTooltip =>
      _t('askKidListoTooltip', 'Ask Kid Listo', 'Magtanong kay Kid Listo');
  String get navLearn => _t('navLearn', 'Learn', 'Learn');
  String get navHope => _t('navHope', 'Hope', 'Hope');
  String get navFaq => _t('navFaq', 'FAQ', 'FAQ');

  // Bottom nav Care tab (matches DAPE Care)
  String get navCare => _t('navCare', 'Care', 'Care');
  String get careTitle => _t('careTitle', 'DAPE Care', 'DAPE Care');
  String get careSubtitle =>
      _t('careSubtitle', 'Your well-being matters to us.', 'Mahalaga sa amin ang iyong well-being.');
  String get careSearchHint => _t('careSearchHint', 
        'Search resources, tips, exercises...',
        'Maghanap ng resources, tips, exercises...',
      );
  String get careHowFeeling =>
      _t('careHowFeeling', 'How are you feeling today?', 'Kumusta ang pakiramdam mo ngayon?');
  String get careDailyReflection =>
      _t('careDailyReflection', 'Daily Reflection', 'Daily Reflection');
  String get careDailyReflectionPrompt => _t('careDailyReflectionPrompt', 
        'What are you grateful for in your recovery journey?',
        'Ano ang iyong pinagpapasalamat sa iyong recovery journey?',
      );
  String get careStartWriting => _t('careStartWriting', 'Start Writing', 'Magsulat');
  String get careCheckInNow =>
      _t('careCheckInNow', 'Your feelings matter. Check in now.', 'Mahalaga ang damdamin mo. Mag-check in ngayon.');
  String get careCheckedInToday =>
      _t('careCheckedInToday', 'Thanks for checking in today.', 'Salamat sa pag-check in ngayon.');
  String get careSelectMoodFirst =>
      _t('careSelectMoodFirst', 'Please select how you feel first.', 'Pumili muna kung ano ang pakiramdam mo.');
  String get careMoodSaved =>
      _t('careMoodSaved', 'Mood check-in saved.', 'Nai-save ang mood check-in.');
  String get careMoodSaveFailed =>
      _t('careMoodSaveFailed', 'Could not save mood check-in.', 'Hindi mai-save ang mood check-in.');
  String get careSpeedDial => _t('careSpeedDial', 'Your Toolkit', 'Iyong Toolkit');
  String get careSpeedDialEyebrow => _t('careSpeedDialEyebrow', 'Quick access', 'Mabilisang access');
  String get careSpeedJournal => _t('careSpeedJournal', 'My Journal', 'Aking Journal');
  String get careSpeedJournalBody =>
      _t('careSpeedJournalBody', 'Write freely. This is your safe space.', 'Sumulat nang malaya. Ito ang iyong safe space.');
  String get careSpeedToolkit => _t('careSpeedToolkit', 'Self-Care Toolkit', 'Self-Care Toolkit');
  String get careSpeedToolkitBody =>
      _t('careSpeedToolkitBody', 'Take care of yourself every day.', 'Alagaan ang sarili araw-araw.');
  String get careSpeedSupport => _t('careSpeedSupport', 'Get Support', 'Kumuha ng Suporta');
  String get careSpeedSupportBody =>
      _t('careSpeedSupportBody', 'Find the right help for you.', 'Hanapin ang tamang tulong para sa iyo.');
  String get careCalmCorner => _t('careCalmCorner', 'Calm Corner', 'Calm Corner');
  String get careCalmCornerBody => _t('careCalmCornerBody', 
        'Take a moment for yourself. You deserve it.',
        'Maglaan ng sandali para sa sarili. Deserve mo ito.',
      );
  String get careKidListo => _t('careKidListo', 'Kid Listo', 'Kid Listo');
  String get careKidListoBody => _t('careKidListoBody', 
        'A daily motivational quote for a drug-free youth.',
        'Araw-araw na motivational quote para sa drug-free youth.',
      );
  String get careBreathingExercise =>
      _t('careBreathingExercise', 'Breathing Exercise', 'Breathing Exercise');
  String get careBreathingExerciseBody => _t('careBreathingExerciseBody', 
        'Simple guided breathing exercise to calm your mind',
        'Simpleng guided breathing para pakalmahin ang isip',
      );
  String get careRelaxingAudio => _t('careRelaxingAudio', 'Relaxing Audio', 'Relaxing Audio');
  String get careRelaxingAudioBody => _t('careRelaxingAudioBody', 
        'Listen to soothing sounds to help you relax.',
        'Makinig sa soothing sounds para makapag-relax.',
      );
  String get careGuidedMeditation =>
      _t('careGuidedMeditation', 'Guided Meditation', 'Guided Meditation');
  String get careGuidedMeditationBody => _t('careGuidedMeditationBody', 
        'Follow meditations for focus, calm, and balance.',
        'Sundan ang meditation para sa focus, calm, at balance.',
      );
  String get careVisualizationExercises =>
      _t('careVisualizationExercises', 'Visualization Exercises', 'Visualization Exercises');
  String get careVisualizationExercisesBody => _t('careVisualizationExercisesBody', 
        'Use your imagination to reduce stress.',
        'Gamitin ang imahinasyon para mabawasan ang stress.',
      );
  String get careColorFun => _t('careColorFun', 'Color Fun', 'Color Fun');
  String get careColorFunBody =>
      _t('careColorFunBody', 'Print and color cute worksheets!', 'I-print at kulayan ang worksheets!');
  String get careStretchBreaks => _t('careStretchBreaks', 'Stretch Breaks', 'Stretch Breaks');
  String get careStretchBreaksBody => _t('careStretchBreaksBody', 
        'Do short posture resets to ease tension.',
        'Maikling stretch para mabawasan ang tension.',
      );
  String get careGuidedBreathing =>
      _t('careGuidedBreathing', 'Guided Breathing', 'Guided Breathing');
  String get careStayCalmBreath => _t('careStayCalmBreath', 
        'Stay calm and take a deep breath.',
        'Manatiling kalmado at huminga nang malalim.',
      );
  String get careStayCalmMusic => _t('careStayCalmMusic', 
        'Stay calm and enjoy the music.',
        'Manatiling kalmado at i-enjoy ang musika.',
      );
  String get careListen => _t('careListen', 'Listen.', 'Makinig.');
  String get careEndSession => _t('careEndSession', 'End', 'Tapusin');
  String get carePause => _t('carePause', 'Pause', 'I-pause');
  String get careResume => _t('careResume', 'Resume', 'Ipagpatuloy');
  String get careCalmMind => _t('careCalmMind', 'Calm Mind', 'Calm Mind');
  String get careCalmMindBody => _t('careCalmMindBody', 
        'A short meditation to help you relax, release tension, and feel at peace.',
        'Maikling meditation para makapag-relax, mag-release ng tension, at makaramdam ng kapayapaan.',
      );
  String get careWhatYoullGet => _t('careWhatYoullGet', "What you'll get", 'Makukuha mo');
  String get careBenefitReduceStress =>
      _t('careBenefitReduceStress', 'Reduce stress and anxiety', 'Bawasan ang stress at anxiety');
  String get careBenefitImproveFocus =>
      _t('careBenefitImproveFocus', 'Improve focus and clarity', 'Pagbutihin ang focus at clarity');
  String get careBenefitFeelCalm =>
      _t('careBenefitFeelCalm', 'Feel calm and relaxed', 'Makaramdam ng kalmado at relax');
  String get carePlayMeditation =>
      _t('carePlayMeditation', 'Play Meditation', 'I-play ang Meditation');
  String get carePeacefulPlace => _t('carePeacefulPlace', 'Peaceful Place', 'Peaceful Place');
  String get careVisualizationTitle =>
      _t('careVisualizationTitle', 'Visualization', 'Visualization');
  String get careMeditationTitle => _t('careMeditationTitle', 'Meditation', 'Meditation');
  String get carePeacefulPlaceBody => _t('carePeacefulPlaceBody', 
        'Use your imagination to create a safe and peaceful place in your mind.',
        'Gamitin ang imahinasyon para gumawa ng ligtas at mapayapang lugar sa isip.',
      );
  String get careInThisExercise =>
      _t('careInThisExercise', 'In this exercise, you will', 'Sa exercise na ito, ikaw ay');
  String get careVizImagine =>
      _t('careVizImagine', 'Imagine your safe space', 'Isipin ang iyong safe space');
  String get careVizSenses =>
      _t('careVizSenses', 'Engage your senses', 'Gamitin ang iyong mga pandama');
  String get careVizFeelRelaxed =>
      _t('careVizFeelRelaxed', 'Feel relaxed and refreshed', 'Makaramdam ng relax at refreshed');
  String get carePlayExercise => _t('carePlayExercise', 'Play Exercise', 'I-play ang Exercise');
  String get careColorFunIntro => _t('careColorFunIntro', 
        'Take a creative break. Download and print fun coloring worksheets to relax and express yourself. You can do this with a friend or family member!',
        'Mag-creative break. I-download at i-print ang coloring worksheets para mag-relax. Pwede kasama ang kaibigan o pamilya!',
      );
  String get careColorFilterAll => _t('careColorFilterAll', 'All', 'Lahat');
  String get careColorFilterNature => _t('careColorFilterNature', 'Nature', 'Kalikasan');
  String get careColorFilterPeople => _t('careColorFilterPeople', 'People', 'Tao');
  String get careColorFilterMessages => _t('careColorFilterMessages', 'Messages', 'Mensahe');
  String get careWorksheetDownloaded => _t('careWorksheetDownloaded', 
        'Worksheet ready. Open it to print or color.',
        'Handa na ang worksheet. Buksan para i-print o kulayan.',
      );
  String get careChooseYourBreak =>
      _t('careChooseYourBreak', 'Choose Your Break', 'Piliin ang Break');
  String get careQuickStretch => _t('careQuickStretch', 'Quick Stretch', 'Quick Stretch');
  String get careQuickStretchBody =>
      _t('careQuickStretchBody', 'Perfect for a short break', 'Para sa maikling break');
  String get careDeskStretch => _t('careDeskStretch', 'Desk Stretch', 'Desk Stretch');
  String get careDeskStretchBody =>
      _t('careDeskStretchBody', 'Great for work or study breaks', 'Para sa work o study breaks');
  String get careFullBodyStretch =>
      _t('careFullBodyStretch', 'Full Body Stretch', 'Full Body Stretch');
  String get careFullBodyStretchBody =>
      _t('careFullBodyStretchBody', 'Feel refreshed and recharged', 'Makaramdam ng refreshed');
  String get careMorningEnergizer =>
      _t('careMorningEnergizer', 'Morning Energizer', 'Morning Energizer');
  String get careMorningEnergizerBody =>
      _t('careMorningEnergizerBody', 'Start your day right', 'Simulan nang tama ang araw');
  String get careSetTodaysReminder =>
      _t('careSetTodaysReminder', "Set Today's Reminder", 'I-set ang Reminder Ngayon');
  String get careStretchReminderTitle =>
      _t('careStretchReminderTitle', 'Time for a stretch break!', 'Oras na para mag-stretch!');
  String get careStretchReminderBody => _t('careStretchReminderBody', 
        'Moving your body boosts your mood and energy!',
        'Ang paggalaw ay nagpapalakas ng mood at energy!',
      );
  String get careStretchSessionHint => _t('careStretchSessionHint', 
        'Follow along at your own pace. Stop if anything hurts.',
        'Sundan sa sariling bilis. Huminto kung may sakit.',
      );
  String get careStartStretch => _t('careStartStretch', 'Start Stretch', 'Simulan ang Stretch');
  String get careSessionComplete =>
      _t('careSessionComplete', 'Nice work. Take a slow breath.', 'Magaling. Huminga nang dahan-dahan.');
  String get careCalmInfoTitle => _t('careCalmInfoTitle', 'About this activity', 'Tungkol dito');
  String get careCalmInfoBody => _t('careCalmInfoBody', 
        'These tools support wellbeing. They are not a substitute for professional care.',
        'Para sa wellbeing ang mga tool na ito. Hindi kapalit ng propesyonal na tulong.',
      );
  String get careStartBreathing =>
      _t('careStartBreathing', 'Start breathing', 'Magsimulang huminga');
  String get careStopBreathing => _t('careStopBreathing', 'Stop', 'Itigil');
  String get careBreatheIn => _t('careBreatheIn', 'Breathe In', 'Huminga');
  String get careBreatheOut => _t('careBreatheOut', 'Breathe Out', 'Ihininga');
  String get careBreatheHold => _t('careBreatheHold', 'Hold', 'Pigilin');
  String get careBreatheReady =>
      _t('careBreatheReady', 'Ready when you are', 'Handa ka na ba?');
  String get careToolkitTitle =>
      _t('careToolkitTitle', 'Self-care Toolkit', 'Self-care Toolkit');
  String get careToolkitHero => _t('careToolkitHero', 
        'Tools to help you understand how you feel, build healthy habits, and know when to reach out.',
        'Mga tool para unawain ang damdamin, bumuo ng healthy habits, at malaman kung kailan humingi ng tulong.',
      );
  String get careStressCheck => _t('careStressCheck', 'Stress Check', 'Stress Check');
  String get careStressCheckBody =>
      _t('careStressCheckBody', 'Understand your stress level', 'Unawain ang antas ng stress mo');
  String get careAnxietyCheck => _t('careAnxietyCheck', 'Anxiety Check', 'Anxiety Check');
  String get careAnxietyCheckBody =>
      _t('careAnxietyCheckBody', 'Check symptoms of anxiety', 'Suriin ang sintomas ng anxiety');
  String get careSleepQuality => _t('careSleepQuality', 'Sleep Quality', 'Kalidad ng Tulog');
  String get careSleepQualityBody =>
      _t('careSleepQualityBody', 'Evaluate your sleep habits', 'Suriin ang iyong tulog');
  String get careMoodTracker => _t('careMoodTracker', 'Mood Tracker', 'Mood Tracker');
  String get careMoodTrackerBody =>
      _t('careMoodTrackerBody', 'Track your mood over time', 'Subaybayan ang iyong mood');
  String get careToolkitDisclaimer => _t('careToolkitDisclaimer', 
        'Stress, anxiety, mood, and sleep checks are tools for self-reflection, not medical diagnosis.',
        'Ang stress, anxiety, mood, at sleep checks ay para sa self-reflection, hindi medikal na diagnosis.',
      );
  String get careBitsTitle => _t('careBitsTitle', 'Care Bits', 'Care Bits');
  String get careBitsSwipeHint =>
      _t('careBitsSwipeHint', 'Swipe right for more', 'I-swipe pakanan para sa iba');
  String get careRemember => _t('careRemember', 'Remember', 'Tandaan');
  String get careRememberHonest =>
      _t('careRememberHonest', 'Answer honestly', 'Sumagot nang tapat');
  String get careRememberNoWrong =>
      _t('careRememberNoWrong', 'No right or wrong responses', 'Walang tama o mali');
  String careQuestionProgress(int current, int total) =>
      _t('careQuestionProgress', '$current of $total questions', '$current sa $total na tanong', {'current': current.toString(), 'total': total.toString()});
  String get careNoToolkitQuestions => _t('careNoToolkitQuestions', 
        'No questions available yet. Please check back soon.',
        'Wala pang tanong. Balikan mamaya.',
      );
  String get careStressIntro => _t('careStressIntro', 
        'Stress is a universal human experience. Recognizing how you feel is the first step toward helping yourself.',
        'Universal ang stress. Ang pagkilala sa pakiramdam mo ang unang hakbang para tulungan ang sarili.',
      );
  String get careAnxietyIntro => _t('careAnxietyIntro', 
        'Anxiety is a common human experience. Recognizing your worry and tension is the first step toward managing it.',
        'Karaniwan ang anxiety. Ang pagkilala sa worry at tension ang unang hakbang para harapin ito.',
      );
  String get careAnxietyPrompt => _t('careAnxietyPrompt', 
        'Over the last two weeks, how often have you been bothered by the following problems?',
        'Sa nakaraang dalawang linggo, gaano kadalas kang nababagabag ng mga sumusunod?',
      );
  String get careSleepIntro => _t('careSleepIntro', 
        'Sleep is essential for health and learning. Recognizing your sleep patterns is the first step toward improving rest.',
        'Mahalaga ang tulog para sa kalusugan at pag-aaral. Ang pagkilala sa pattern ng tulog ang unang hakbang para mapabuti ito.',
      );
  String get careCheckStart =>
      _t('careCheckStart', 'Start assessment', 'Simulan ang assessment');
  String get careCheckNext => _t('careCheckNext', 'Next', 'Susunod');
  String get careCheckBack => _t('careCheckBack', 'Back', 'Bumalik');
  String get careCheckSubmit =>
      _t('careCheckSubmit', 'See my result', 'Tingnan ang result');
  String get careCheckMinutes =>
      _t('careCheckMinutes', 'About 1–2 minutes', 'Mga 1–2 minuto');
  String get careCheckResultTitle =>
      _t('careCheckResultTitle', 'Result', 'Resulta');
  String get careStressResultTitle =>
      _t('careStressResultTitle', 'Stress Check Result', 'Resulta ng Stress Check');
  String get careYourStressLevel =>
      _t('careYourStressLevel', 'Your Stress Level', 'Antas ng Stress Mo');
  String get careYourAnxietyLevel =>
      _t('careYourAnxietyLevel', 'Your Anxiety Level', 'Antas ng Anxiety Mo');
  String get careYourSleepQuality =>
      _t('careYourSleepQuality', 'Your Sleep Quality', 'Kalidad ng Tulog Mo');
  String get careBandStressLow =>
      _t('careBandStressLow', 'Low to Moderate', 'Mababa hanggang Katamtaman');
  String get careBandStressHigh =>
      _t('careBandStressHigh', 'Moderate to High', 'Katamtaman hanggang Mataas');
  String get careBandAnxietyLow =>
      _t('careBandAnxietyLow', 'Minimal to Low', 'Minimal hanggang Mababa');
  String get careBandAnxietyHigh =>
      _t('careBandAnxietyHigh', 'Moderate to Severe', 'Katamtaman hanggang Matindi');
  String get careBandSleepLow => _t('careBandSleepLow', 'Good', 'Maganda');
  String get careBandSleepHigh =>
      _t('careBandSleepHigh', 'Needs Improvement', 'Kailangan pang pagbutihin');
  String get careStressLowHeadline =>
      _t('careStressLowHeadline', "You're managing stress well!", 'Naaasikaso mo nang maayos ang stress!');
  String get careStressLowBody => _t('careStressLowBody', 
        "Everyone feels stressed sometimes. You're handling things well, but small self-care steps can help you stay balanced.",
        'Normal ang stress. Hinahawakan mo ito nang maayos, at makakatulong ang maliit na self-care para manatiling balanced.',
      );
  String get careStressHighHeadline => _t('careStressHighHeadline', 
        'Your stress may be affecting your well-being.',
        'Maaaring naaapektuhan ng stress ang well-being mo.',
      );
  String get careStressHighBody => _t('careStressHighBody', 
        "You're experiencing more stress than is ideal. It is important to take action and build healthier coping strategies.",
        'Mas mataas sa ideal ang stress mo. Mahalagang gumawa ng hakbang at magtayo ng mas healthy na paraan ng pagcope.',
      );
  String get careAnxietyLowHeadline => _t('careAnxietyLowHeadline', 
        "You may feel worried at times, but you're managing.",
        'May pag-aalala paminsan-minsan, pero nahahawakan mo.',
      );
  String get careAnxietyLowBody => _t('careAnxietyLowBody', 
        'Keep using the Calm Corner tools to maintain balance and prevent worries from building up.',
        'Ituloy ang Calm Corner para mapanatili ang balance at maiwasang magtumpok ang pag-aalala.',
      );
  String get careAnxietyHighHeadline => _t('careAnxietyHighHeadline', 
        'Your anxiety level may be affecting your well-being.',
        'Maaaring naaapektuhan ng anxiety ang well-being mo.',
      );
  String get careAnxietyHighBody => _t('careAnxietyHighBody', 
        'Try relaxation activities daily, journal your feelings, and use guided meditation to ease tension. Consider professional help if worries feel overwhelming.',
        'Subukan ang relaxation araw-araw, mag-journal, at gumamit ng guided meditation. Humingi ng propesyonal na tulong kung sobrang bigat ng pag-aalala.',
      );
  String get careSleepLowHeadline => _t('careSleepLowHeadline', 
        "You're getting enough quality sleep.",
        'Sapat at maganda ang tulog mo.',
      );
  String get careSleepLowBody => _t('careSleepLowBody', 
        'You have a consistent sleep routine and good sleep quality. Small improvements can make a big difference!',
        'Consistent ang routine at maganda ang tulog mo. Malaki ang epekto ng maliliit na pagbabago.',
      );
  String get careSleepHighHeadline => _t('careSleepHighHeadline', 
        'Your sleep quality be better.',
        'Pwede pang pagbutihin ang tulog mo.',
      );
  String get careSleepHighBody => _t('careSleepHighBody', 
        'You may not be getting enough restful sleep. Poor sleep can affect your mood, focus, and energy levels. Need help? Feel free to reach out.',
        'Maaaring kulang ang restful sleep mo. Nakakaapekto ito sa mood, focus, at energy. Kung kailangan mo ng tulong, mag-reach out.',
      );
  String get careCheckDisclaimer => _t('careCheckDisclaimer', 
        'This test is for self-reflection only and does not replace professional evaluation.',
        'Para sa self-reflection lamang ang test na ito at hindi kapalit ng propesyonal na ebalwasyon.',
      );
  String get careGoToCalmCorner =>
      _t('careGoToCalmCorner', 'Go to Calm Corner', 'Pumunta sa Calm Corner');
  String get careBackToToolkit =>
      _t('careBackToToolkit', 'Back to Self-Care Toolkit', 'Bumalik sa Self-care Toolkit');
  String get careRetakeAssessment =>
      _t('careRetakeAssessment', 'Retake Assessment', 'Ulitin ang Assessment');
  String get careCheckSaveFailed => _t('careCheckSaveFailed', 
        'Could not save this check. Please try again.',
        'Hindi nai-save ang check. Subukan ulit.',
      );
  String get careBackToCalmCorner =>
      _t('careBackToCalmCorner', 'Back to Calm Corner', 'Bumalik sa Calm Corner');
  String get careCalmStudentIntro => _t('careCalmStudentIntro', 
        'Need a 2-minute reset? Use these tools before a quiz, after class, or anytime your mind feels busy.',
        'Kailangan ng 2-minutong pahinga? Gamitin bago ang quiz, pagkatapos ng klase, o kapag magulo ang isip.',
      );
  String get careGreatJob => _t('careGreatJob', 'Great job!', 'Magaling!');
  String get careWellDone => _t('careWellDone', 'Well done!', 'Mahusay!');
  String get careBreathingDoneBody => _t('careBreathingDoneBody', 
        'You finished your breathing break.',
        'Tapos na ang breathing break mo.',
      );
  String get careAudioDoneBody => _t('careAudioDoneBody', 
        "You finished today's calm break.",
        'Tapos na ang calm break mo ngayon.',
      );
  String get careNoticeBody => _t('careNoticeBody', 
        'Notice how your body feels: lighter, calmer, more focused.',
        'Pansinin ang katawan: mas magaan, mas kalmado, mas focused.',
      );
  String get careWhyBreathing =>
      _t('careWhyBreathing', 'Why Breathing Helps', 'Bakit nakakatulong ang paghinga');
  String get careWhyBreathingBody => _t('careWhyBreathingBody', 
        'Slow breathing helps lower stress, steady your focus, and calm your body — useful before exams or presentations.',
        'Ang mabagal na paghinga ay nagpapababa ng stress at tumutulong mag-focus — lalo na bago ang exam o recitation.',
      );
  String get careHowToUse => _t('careHowToUse', 'How to Use', 'Paano gamitin');
  String get careHowBreathingBody => _t('careHowBreathingBody', 
        'Press play. Follow the circle: breathe in as it grows, hold, then breathe out as it shrinks. Four rounds is enough.',
        'I-play. Huminga papasok habang lumalaki ang circle, pigilin, tapos huminga palabas habang lumiliit. Apat na round ay sapat.',
      );
  String get careQuickTip => _t('careQuickTip', 'Quick Tip', 'Quick Tip');
  String get careBreathingTip => _t('careBreathingTip', 
        'Try this at your desk. No one needs to notice — just four quiet breaths.',
        'Pwede sa desk. Hindi kailangang mapansin ng iba — apat na tahimik na hinga.',
      );
  String get careWhyMusic => _t('careWhyMusic', 'Why Music Helps', 'Bakit nakakatulong ang musika');
  String get careWhyMusicBody => _t('careWhyMusicBody', 
        'A short, steady sound can take your mind off racing thoughts and give you a quiet minute between classes.',
        'Ang tahimik at steady na tunog ay nakakatulong kalmahin ang isip sa pagitan ng klase.',
      );
  String get careHowMusicBody => _t('careHowMusicBody', 
        'Press play, use earphones if you can, and breathe slowly. You can pause anytime.',
        'I-play, gumamit ng earphones kung maaari, at huminga nang dahan-dahan. Pwede i-pause anytime.',
      );
  String get careMusicTip => _t('careMusicTip', 
        'Keep the volume low. This is a break, not a playlist.',
        'Ibaba ang volume. Pahinga ito, hindi playlist.',
      );
  String get careWhyMeditation =>
      _t('careWhyMeditation', 'Why This Helps', 'Bakit nakakatulong ito');
  String get careWhyMeditationBody => _t('careWhyMeditationBody', 
        'A short pause helps clear your mind, reduce stress, and return to class with more focus.',
        'Ang maikling pause ay nakakatulong linawin ang isip at bumalik sa klase nang mas focused.',
      );
  String get careHowMeditationBody => _t('careHowMeditationBody', 
        'Press play, sit comfortably, and follow the words on the screen. You can pause anytime.',
        'I-play, umupo nang komportable, at sundan ang mga salita sa screen. Pwede i-pause anytime.',
      );
  String get careMeditationTip => _t('careMeditationTip', 
        'If a thought about homework appears, notice it and let it pass. That is normal.',
        'Kung may naiisip na assignment, pansinin at hayaan itong dumaan. Normal iyon.',
      );
  String get careWhyVisualizationBody => _t('careWhyVisualizationBody', 
        'Picturing a safe place can calm your body when you feel pressure from school, friends, or home.',
        'Ang pag-isip ng ligtas na lugar ay nakakakalma kapag may pressure sa school, kaibigan, o bahay.',
      );
  String get careHowVisualizationBody => _t('careHowVisualizationBody', 
        'Press play, close your eyes if you like, and follow the guided imagery. Pause anytime.',
        'I-play, ipikit ang mata kung gusto mo, at sundan ang guided imagery. Pwede i-pause anytime.',
      );
  String get careVisualizationTip => _t('careVisualizationTip', 
        'Pick a real place you know — your room, a court, the sea, or a quiet hallway.',
        'Pumili ng tunay na lugar na kilala mo — kwarto, court, dagat, o tahimik na hallway.',
      );
  String get careColorOnScreen =>
      _t('careColorOnScreen', 'Color on screen', 'Kulayan sa screen');
  String get careColorClear => _t('careColorClear', 'Clear', 'Burahin');
  String get careStretchHold =>
      _t('careStretchHold', 'Hold this stretch', 'Hawakan ang stretch');
  String get careMedStep1 => _t('careMedStep1', 
        'Sit comfortably. Rest your hands. Let your shoulders drop.',
        'Umupo nang komportable. Ihiga ang kamay. Ibaba ang balikat.',
      );
  String get careMedStep2 => _t('careMedStep2', 
        'Notice your breath. You do not need to change it yet.',
        'Pansinin ang hinga. Hindi pa kailangang baguhin.',
      );
  String get careMedStep3 => _t('careMedStep3', 
        'If a thought about school appears, name it, then return to your breath.',
        'Kung may naiisip na school, pangalanan, tapos bumalik sa hinga.',
      );
  String get careMedStep4 => _t('careMedStep4', 
        'Take one slower breath. When you are ready, open your eyes.',
        'Kumuha ng mas mabagal na hinga. Kapag handa ka na, imulat ang mata.',
      );
  String get careVizStep1 => _t('careVizStep1', 
        'Picture a place that feels safe — your room, a court, the sea, or a quiet hallway.',
        'Isipin ang lugar na ligtas para sa iyo — kwarto, court, dagat, o hallway.',
      );
  String get careVizStep2 => _t('careVizStep2', 
        'Notice colors, sounds, and temperature. Make the scene feel real.',
        'Pansinin ang kulay, tunog, at temperatura. Gawing totoo ang eksena.',
      );
  String get careVizStep3 => _t('careVizStep3', 
        'Imagine your body relaxing in that place. Unclench your jaw and hands.',
        'Isipin na nagre-relax ang katawan mo doon. Bitawan ang panga at kamay.',
      );
  String get careVizStep4 => _t('careVizStep4', 
        'Take that calm with you. You can return here anytime you need a pause.',
        'Dalhin ang kalmado. Pwede kang bumalik dito anytime kailangan mo ng pause.',
      );
  String get careStretchNeck => _t('careStretchNeck', 
        'Gently tilt your right ear toward your shoulder. Keep breathing.',
        'Dahan-dahang i-tilt ang kanang tenga patungo sa balikat. Patuloy na huminga.',
      );
  String get careStretchShoulders => _t('careStretchShoulders', 
        'Roll both shoulders back slowly, then let them drop.',
        'I-roll pabalik ang dalawang balikat, tapos ibaba.',
      );
  String get careStretchReach => _t('careStretchReach', 
        'Reach both arms up, then fold forward over your desk or lap.',
        'Itaas ang dalawang braso, tapos yumuko pasulong sa desk o kandungan.',
      );
  String get careDoneColoring =>
      _t('careDoneColoring', 'Done coloring', 'Tapos na magkulay');
  String get careInputTimeHint => _t('careInputTimeHint', 'Input the time.', 'Ilagay ang oras.');
  String get careScaleAlmostNever => _t('careScaleAlmostNever', 'Almost Never', 'Halos hindi');
  String get careScaleFairlyOften => _t('careScaleFairlyOften', 'Fairly Often', 'Medyo madalas');
  String get careScaleVeryOften => _t('careScaleVeryOften', 'Very Often', 'Napakadalas');
  String get careMoodOverview => _t('careMoodOverview', 'Mood Overview', 'Mood Overview');
  String get careThisMonth => _t('careThisMonth', 'This Month', 'Buwan na ito');
  String get careCheckInTodayCta =>
      _t('careCheckInTodayCta', 'Check In Today!', 'Mag-check in ngayon!');
  String get careMoodInsightSteady => _t('careMoodInsightSteady', 
        'Your mood has been steady and generally okay. Keep up your healthy habits!',
        'Stable at okay ang mood mo. Ituloy ang healthy habits!',
      );
  String get careMoodInsightLow => _t('careMoodInsightLow', 
        'Some tougher days showed up this month. Be gentle with yourself — support is available.',
        'May mabibigat na araw ngayong buwan. Maging mahinahon sa sarili — may available na support.',
      );
  String get careMoodInsightGreat => _t('careMoodInsightGreat', 
        'You have had many good days this month. Keep nurturing what helps you feel well.',
        'Maraming magagandang araw ngayong buwan. Ituloy ang nakakatulong sa’yo.',
      );
  String get careMoodVeryBad => _t('careMoodVeryBad', 'Very Bad', 'Sobrang hirap');
  String get careMoodBad => _t('careMoodBad', 'Bad', 'Mahirap');
  String get careMoodOkay => _t('careMoodOkay', 'Okay', 'Okay');
  String get careGetSupportTitle => _t('careGetSupportTitle', 'Get Support', 'Kumuha ng Suporta');
  String get careGetSupportHero1 =>
      _t('careGetSupportHero1', 'You do not have to go through it alone.', 'Hindi mo kailangang mag-isa.');
  String get careGetSupportHero2 => _t('careGetSupportHero2', 
        'If worries feel overwhelming, health professionals can provide care.',
        'Kung sobrang bigat ng alalahanin, may mga propesyonal na makakatulong.',
      );
  String get careHotlines => _t('careHotlines', '24/7 Hotlines', '24/7 Hotlines');
  String get careHotlinesBody =>
      _t('careHotlinesBody', 'Access immediate support any time', 'Tumawag para sa agarang tulong');
  String get careHotlinesSubtitle =>
      _t('careHotlinesSubtitle', 'Help is available anytime, anywhere.', 'May tulong anumang oras, saan man.');
  String get careCounseling => _t('careCounseling', 'Counseling', 'Counseling');
  String get careCounselingBody =>
      _t('careCounselingBody', 'Talk to a trained professional', 'Makipag-usap sa trained professional');
  String get careCrisis => _t('careCrisis', 'Crisis Support', 'Crisis Support');
  String get careCrisisBody =>
      _t('careCrisisBody', 'Get help in an emergency', 'Kumuha ng tulong sa emergency');
  String get careCrisisSubtitle => _t('careCrisisSubtitle', 
        'If you or someone you know is in crisis, please reach out for help.',
        'Kung ikaw o may kilala kang nasa crisis, humingi ng tulong.',
      );
  String get careCrisisUnsure =>
      _t('careCrisisUnsure', 'Unsure? These might help.', 'Hindi sigurado? Maaaring makatulong ito.');
  String get careGoToHotlines =>
      _t('careGoToHotlines', 'Go to 24/7 Hotlines', 'Pumunta sa 24/7 Hotlines');
  String get careSupportFooter => _t('careSupportFooter', 
        'You are not alone. Everyone faces challenges; reaching out is a sign of strength.',
        'Hindi ka nag-iisa. Ang paghingi ng tulong ay senyales ng lakas.',
      );
  String get careBrowseRehabServices =>
      _t('careBrowseRehabServices', 'Browse rehab & services', 'Tingnan ang rehab at serbisyo');
  String get careAnswerAll =>
      _t('careAnswerAll', 'Please answer all questions.', 'Sagutin ang lahat ng tanong.');
  String get careSaveCheck => _t('careSaveCheck', 'Save check-in', 'I-save ang check-in');
  String careCheckSaved(int score) =>
      _t('careCheckSaved', 'Saved. Your score: $score', 'Nai-save. Score mo: $score', {'score': score.toString()});
  String get careScaleNever => _t('careScaleNever', 'Never', 'Hindi kailanman');
  String get careScaleRarely => _t('careScaleRarely', 'Rarely', 'Bihira');
  String get careScaleSometimes => _t('careScaleSometimes', 'Sometimes', 'Minsan');
  String get careScaleOften => _t('careScaleOften', 'Often', 'Madalas');
  String get careScaleAlways => _t('careScaleAlways', 'Always', 'Palagi');
  String get careQStress1 =>
      _t('careQStress1', 'I feel overwhelmed by daily tasks.', 'Nalulula ako sa pang-araw-araw na gawain.');
  String get careQStress2 =>
      _t('careQStress2', 'I have trouble relaxing.', 'Hirap akong magpahinga.');
  String get careQStress3 =>
      _t('careQStress3', 'I feel tense or on edge.', 'Pakiramdam ko ay tense o balisa.');
  String get careQAnxiety1 =>
      _t('careQAnxiety1', 'I worry a lot about many things.', 'Marami akong inaalala.');
  String get careQAnxiety2 =>
      _t('careQAnxiety2', 'I feel nervous or restless.', 'Nababalisa o hindi mapakali.');
  String get careQAnxiety3 =>
      _t('careQAnxiety3', 'I avoid situations that make me anxious.', 'Iniiwasan ko ang sitwasyong nagpapabalisa.');
  String get careQSleep1 =>
      _t('careQSleep1', 'I get enough restful sleep.', 'Sapat at mapayapa ang tulog ko.');
  String get careQSleep2 =>
      _t('careQSleep2', 'I fall asleep easily.', 'Madali akong makatulog.');
  String get careQSleep3 =>
      _t('careQSleep3', 'I wake up feeling refreshed.', 'Gising akong refreshed.');
  String get careMoodHistory => _t('careMoodHistory', 'Mood history', 'Kasaysayan ng mood');
  String get careNoMoodHistory =>
      _t('careNoMoodHistory', 'No check-ins yet. Log how you feel above.', 'Wala pang check-in. Mag-log muna sa itaas.');
  String get careScore => _t('careScore', 'Score', 'Score');
  String get loginJourneySubtitle => _t('loginJourneySubtitle', 
        'Sign in to continue your DAPE-MA journey!',
        'Mag-sign in para ituloy ang iyong DAPE-MA journey!',
      );
  String get enterEmailHint =>
      _t('enterEmailHint', 'Enter your email', 'Ilagay ang iyong email');
  String get enterPasswordHint =>
      _t('enterPasswordHint', 'Enter your password', 'Ilagay ang iyong password');
  String get orDivider => _t('orDivider', 'or', 'o');
  String get socialLoginComingSoon =>
      _t('socialLoginComingSoon', 'Social login coming soon', 'Social login, malapit na');
  String get enterVerificationCode =>
      _t('enterVerificationCode', 'Enter Verification Code', 'Ilagay ang Verification Code');
  String verificationCodeSentTo(String destination) => _t('verificationCodeSentTo', 
        "We've sent a six-digit code to $destination.",
        'Nagpadala kami ng anim na digit na code sa $destination.',
        {'destination': destination.toString()});
  String get verifyCode => _t('verifyCode', 'Verify Code', 'I-verify ang Code');
  String get didntReceiveCode =>
      _t('didntReceiveCode', "Didn't receive a code?", 'Hindi nakatanggap ng code?');
  String resendIn(String time) => _t('resendIn', 'Resend in $time', 'Mag-resend sa $time', {'time': time.toString()});
  String get resendCode => _t('resendCode', 'Resend', 'Mag-resend');
  String get verificationPreviewNote => _t('verificationPreviewNote', 
        'Open your email, then enter the 6-digit code to finish signing in.',
        'Buksan ang email, tapos ilagay ang 6-digit na code para tapusin ang pag-sign in.',
      );
  String get loginCodeInvalid => _t('loginCodeInvalid', 
        'That code does not match. Check your email and try again.',
        'Hindi tumugma ang code. Tingnan ang email at subukan muli.',
      );
  String get verificationSuccessful =>
      _t('verificationSuccessful', 'Verification Successful!', 'Matagumpay ang Verification!');
  String get verificationSuccessfulBody => _t('verificationSuccessfulBody', 
        'Your account has been verified successfully. You are all set!',
        'Matagumpay na na-verify ang iyong account. Handang-handa ka na!',
      );
  String get guest => _t('guest', 'Guest', 'Bisita');
  String get searchHint =>
      _t('searchHint', 'Search information, rehab, news...', 'Maghanap ng impormasyon, rehab, balita...');

  // Categories
  String get categoryAll => _t('categoryAll', 'All', 'Lahat');
  String get categoryDrugEffects => _t('categoryDrugEffects', 'Drug Effects', 'Epekto ng Droga');
  String get categoryRehabilitation => _t('categoryRehabilitation', 'Rehabilitation', 'Rehabilitasyon');
  String get categoryPrevention => _t('categoryPrevention', 'Prevention', 'Pag-iwas');
  String get categoryIec => _t('categoryIec', 
        'Information, Education, and Communication (IEC)',
        'Impormasyon, Edukasyon, at Komunikasyon (IEC)',
      );
  String get categoryNews => _t('categoryNews', 'News', 'Balita');
  String get categoryLegal => _t('categoryLegal', 'Laws & Policies', 'Batas at Patakaran');

  String categoryLabel(String slug) {
    return switch (slug) {
      'all' => categoryAll,
      'drug-effects' => categoryDrugEffects,
      'rehabilitation' => categoryRehabilitation,
      'prevention' => categoryPrevention,
      'iec' => categoryIec,
      'news' => categoryNews,
      'legal' => categoryLegal,
      _ => slug,
    };
  }

  // Post engagement
  String get like => _t('like', 'Like', 'Like');
  String get comment => _t('comment', 'Comment', 'Komento');
  String likesCount(int count) => _countPhrase(
        count: count,
        oneKey: 'likesCountOne',
        manyKey: 'likesCount',
        enOne: '1 like',
        enMany: '{count} likes',
        tlOne: '1 like',
        tlMany: '{count} likes',
      );
  String commentsCount(int count) => _countPhrase(
        count: count,
        oneKey: 'commentsCountOne',
        manyKey: 'commentsCount',
        enOne: '1 comment',
        enMany: '{count} comments',
        tlOne: '1 komento',
        tlMany: '{count} mga komento',
      );
  String get savedToBookmarks => _t('savedToBookmarks', 'Saved to bookmarks', 'Nai-save sa mga bookmark');
  String get removedFromBookmarks =>
      _t('removedFromBookmarks', 'Removed from bookmarks', 'Tinanggal sa mga bookmark');
  String get bookmarkUpdateFailed =>
      _t('bookmarkUpdateFailed', 'Could not update bookmark. Try again.', 'Hindi ma-update ang bookmark. Subukan muli.');

  // Account / Profile
  String get accountTitle => _t('accountTitle', 'Account', 'Account');
  String get myProfileTitle => _t('myProfileTitle', 'My Profile', 'Aking Profile');
  String get myStats => _t('myStats', 'My Stats', 'Aking Stats');
  String get lessonsCompleted => _t('lessonsCompleted', 'Lessons', 'Aralin');
  String get articlesRead => _t('articlesRead', 'Articles', 'Artikulo');
  String get eventsJoined => _t('eventsJoined', 'Events', 'Events');
  String get dayStreak => _t('dayStreak', 'Streak', 'Streak');
  String get myBadges => _t('myBadges', 'My Badges', 'Aking Mga Badge');
  String get seeAll => _t('seeAll', 'See all', 'Tingnan lahat');
  String badgesUnlockedProgress(int earned, int total) => _t('badgesUnlockedProgress', 
        '$earned/$total unlocked',
        '$earned/$total nakuha',
        {'earned': earned.toString(), 'total': total.toString()});
  String get badgesPhase2Subtitle =>
      _t('badgesPhase2Subtitle', 'Coming in Phase 2', 'Darating sa Phase 2');
  String get badgesPhase2Body => _t('badgesPhase2Body', 
        'Badges are locked for now and will be available in Phase 2.',
        'Naka-lock ang badges sa ngayon at available sa Phase 2.',
      );
  String get badgeHealthyDecision =>
      _t('badgeHealthyDecision', 'Healthy Decision Maker', 'Healthy Decision Maker');
  String get badgeEmpoweredPeer => _t('badgeEmpoweredPeer', 'Empowered Peer', 'Empowered Peer');
  String get badgeStressBuster => _t('badgeStressBuster', 'Stress Buster', 'Stress Buster');
  String get quickLinks => _t('quickLinks', 'Quick Links', 'Mga Shortcut');
  String get speedDial => quickLinks;
  String get savedArticles => _t('savedArticles', 'Saved Articles', 'Mga Naka-save');
  String get myCertificates => _t('myCertificates', 'My Certificates', 'Aking Mga Sertipiko');
  String get myGains => _t('myGains', 'My Gains', 'Aking Mga Gain');
  String get featureUnavailableNow => _t('featureUnavailableNow', 
        'This feature is unavailable right now.',
        'Hindi available ang feature na ito sa ngayon.',
      );
  String get gotIt => _t('gotIt', 'Got it', 'OK');
  String get dapeSettings => _t('dapeSettings', 'DAPE-MA Settings', 'Mga Setting ng DAPE-MA');
  String get championBadge => _t('championBadge', 'DAPE Champion', 'DAPE Champion');
  String get badgeEarned => _t('badgeEarned', 'Earned', 'Nakuha');
  String get badgeLocked => _t('badgeLocked', 'Locked', 'Naka-lock');
  String get badgeHowToEarn => _t('badgeHowToEarn', 'How to earn', 'Paano makuha');
  String get earnMoreBadgesFooter => _t('earnMoreBadgesFooter', 
        'Earn more badges by continuing your DAPE-MA journey!',
        'Kumita ng mas maraming badge sa iyong DAPE-MA journey!',
      );
  String get certificateOfCompletion =>
      _t('certificateOfCompletion', 'Certificate of Completion', 'Certificate of Completion');
  String get completedOn => _t('completedOn', 'Completed on', 'Natapos noong');
  String get certificatePresentedTo =>
      _t('certificatePresentedTo', 'This certifies that', 'Pinatutunayan nito na si');
  String get certificateForCompleting =>
      _t('certificateForCompleting', 'has successfully completed', 'ay matagumpay na nakatapos ng');
  String get earnedBadgesSection => _t('earnedBadgesSection', 'Earned Badges', 'Mga Nakuha na Badge');
  String get lockedBadgesSection => _t('lockedBadgesSection', 'Locked Badges', 'Mga Naka-lock na Badge');
  String get contestEntriesSection =>
      _t('contestEntriesSection', 'Contest Entries', 'Mga Contest Entry');
  String get levelBeginner => _t('levelBeginner', 'Beginner', 'Beginner');
  String get levelExplorer => _t('levelExplorer', 'Explorer', 'Explorer');
  String get levelChampion => _t('levelChampion', 'Champion', 'Champion');
  String levelLabel(int level) => _t('levelLabel', 'Level $level', 'Level $level', {'level': level.toString()});
  String xpLabel(int xp) => _t('xpLabel', '$xp XP', '$xp XP', {'xp': xp.toString()});
  String xpToNextLevel(int xp) =>
      _t('xpToNextLevel', '$xp XP to next level', '$xp XP papunta sa next level', {'xp': xp.toString()});
  String minReadLabel(int minutes) => _t('minReadLabel', 
        '$minutes min read',
        '$minutes min read',
        {'minutes': minutes.toString()});
  String get featuredBadge => _t('featuredBadge', 'Featured', 'Featured');
  String featuredPostSlide(int current, int total) => _t(
        'featuredPostSlide',
        'Featured post $current of $total',
        'Featured na post $current sa $total',
        {'current': current.toString(), 'total': total.toString()},
      );
  String get sharePost => _t('sharePost', 'Share', 'I-share');
  String get linkCopied => _t('linkCopied', 'Copied to clipboard', 'Nakopya sa clipboard');
  String get profileCompleteLabel =>
      _t('profileCompleteLabel', 'Profile complete', 'Kumpleto ang profile');
  String profilePercentComplete(int percent) =>
      _t('profilePercentComplete', '$percent% complete', '$percent% kumpleto', {'percent': percent.toString()});
  String get profileFinishSetup =>
      _t('profileFinishSetup', 'Finish setup', 'Tapusin ang setup');
  String get profileSetupBeforeKidListo => _t('profileSetupBeforeKidListo', 
        'Add a photo to finish your profile. Kid Listo is next.',
        'Magdagdag ng litrato para makumpleto ang profile. Si Kid Listo ang susunod.',
      );
  String get learnerStatus => _t('learnerStatus', 'Learner', 'Learner');
  String get streakCalendarHint => _t('streakCalendarHint', 
        'Keep journaling to grow your streak.',
        'Mag-journal araw-araw para tumaas ang streak.',
      );
  String get noCertificatesYet =>
      _t('noCertificatesYet', 'No certificates yet', 'Wala pang sertipiko');
  String get noCertificatesBody => _t('noCertificatesBody', 
        'Win a contest to earn certificates here.',
        'Manalo sa contest para makakuha ng sertipiko.',
      );
  String get noGainsYet => _t('noGainsYet', 'No gains yet', 'Wala pang gains');
  String get noGainsBody => _t('noGainsBody', 
        'Submit contest entries to track your gains.',
        'Mag-submit ng contest entries para makita ang iyong gains.',
      );
  String get noActivityYet => _t('noActivityYet', 'Nothing here yet', 'Wala pa rito');
  String get noLessonsBody => _t('noLessonsBody', 
        'Open prevention and recovery lessons to track progress.',
        'Magbasa ng prevention at recovery lessons para masubaybayan ang progreso.',
      );
  String get noArticlesBody => _t('noArticlesBody', 
        'Read posts in the app to build your reading history.',
        'Magbasa ng posts sa app para mabuo ang reading history.',
      );
  String get noEventsBody => _t('noEventsBody', 
        'Join trainings or submit contest entries to track events.',
        'Sumali sa trainings o mag-submit ng contest entries.',
      );
  String get comingSoon =>
      _t('comingSoon', 'Coming soon', 'Malapit na');
  String get comingSoonBody => _t('comingSoonBody', 
        'This feature will be available in a future update.',
        'Available ang feature na ito sa susunod na update.',
      );
  String get guestProfileHint => _t('guestProfileHint', 
        'Sign in to track your progress and unlock profile features.',
        'Mag-sign in para masubaybayan ang progreso at ma-unlock ang profile.',
      );
  String get settingsTitle => _t('settingsTitle', 'Settings', 'Mga Setting');
  String get settingsSubtitle => _t('settingsSubtitle', 
        'Manage your account, preferences, and privacy.',
        'Pamahalaan ang account, preferences, at privacy.',
      );
  String get languageTitle => _t('languageTitle', 'Language', 'Wika');
  String get languageSubtitle =>
      _t('languageSubtitle', 'Choose your preferred app language', 'Piliin ang wika ng app');
  String get signedInHint =>
      _t('signedInHint', 'Save bookmarks and submit reviews', 'Mag-save ng bookmark at magbigay ng review');
  String get youAreSignedIn => _t('youAreSignedIn', 'You are signed in', 'Naka-sign in ka');
  String get editProfile => _t('editProfile', 'Edit Profile', 'I-edit ang Profile');
  String get editProfileSubtitle =>
      _t('editProfileSubtitle', 'Update your personal information', 'I-update ang iyong personal na impormasyon');
  String get notificationsMenu => _t('notificationsMenu', 'Notifications', 'Mga Notification');
  String get notificationsMenuSubtitle => _t('notificationsMenuSubtitle', 
        'Manage your notification preferences',
        'Pamahalaan ang mga preference sa notification',
      );
  String get privacyPolicy => _t('privacyPolicy', 'Privacy Policy', 'Patakaran sa Privacy');
  String get privacyPolicySubtitle =>
      _t('privacyPolicySubtitle', 'Learn how we protect your data', 'Alamin kung paano namin pinoprotektahan ang data');
  String get termsOfUse => _t('termsOfUse', 'Terms of Use', 'Mga Tuntunin ng Paggamit');
  String get termsOfUseSubtitle =>
      _t('termsOfUseSubtitle', 'Read the terms and conditions', 'Basahin ang mga tuntunin at kundisyon');
  String get accessibility => _t('accessibility', 'Accessibility', 'Accessibility');
  String get accessibilitySubtitle =>
      _t('accessibilitySubtitle', 'Explore options for ease of access', 'Tuklasin ang mga opsyon para sa madaling paggamit');
  String get aboutApp => _t('aboutApp', 'About DAPE-MA', 'Tungkol sa DAPE-MA');
  String get aboutAppSubtitle =>
      _t('aboutAppSubtitle', 'App version and more', 'Bersyon ng app at iba pa');
  String get changePassword => _t('changePassword', 'Change password', 'Palitan ang password');
  String get logOut => _t('logOut', 'Log Out', 'Mag-log out');
  String get logOutSubtitle =>
      _t('logOutSubtitle', 'Sign out of your account', 'Mag-sign out sa iyong account');
  String get logoutConfirmTitle =>
      _t('logoutConfirmTitle', 'Log Out of DAPE-MA?', 'Mag-log out sa DAPE-MA?');
  String get logoutConfirmBody => _t('logoutConfirmBody', 
        'You will need to log in again to access your account.',
        'Kailangan mong mag-log in muli para ma-access ang account.',
      );
  String get memberSince => _t('memberSince', 'Member since', 'Miyembro mula');
  String get fullNameLabel => _t('fullNameLabel', 'Full Name', 'Buong Pangalan');
  String get emailAddressLabel => _t('emailAddressLabel', 'Email Address', 'Email Address');
  String get aboutMeLabel => _t('aboutMeLabel', 'About Me', 'Tungkol sa Akin');
  String get aboutMeHint =>
      _t('aboutMeHint', 'Tell others a little about yourself', 'Magbahagi ng kaunti tungkol sa iyong sarili');
  String aboutMeLimitHint(int max) => _t('aboutMeLimitHint', 
        'Up to $max characters so it stays short on your profile.',
        'Hanggang $max na character para hindi masyadong mahaba sa profile.',
        {'max': max.toString()},
      );
  String get interestsLabel => _t('interestsLabel', 'Interests', 'Mga Interes');
  String get interestsHint =>
      _t('interestsHint', 'Select your interests', 'Piliin ang iyong mga interes');
  String get interestsPickerHint => _t('interestsPickerHint', 
        'You can select more than one. Add Other if yours is not listed.',
        'Puwedeng pumili ng higit sa isa. Magdagdag ng Other kung wala sa listahan.',
      );
  String get interestsOther => _t('interestsOther', 'Other', 'Iba pa');
  String get interestsOtherHint =>
      _t('interestsOtherHint', 'Describe your interest', 'Ilarawan ang iyong interes');
  String get interestsOtherPlaceholder =>
      _t('interestsOtherPlaceholder', 'e.g. Sports, Music, Art', 'hal. Sports, Music, Art');
  String get interestsOtherRequired => _t('interestsOtherRequired', 
        'Please type your custom interest.',
        'Ilagay ang iyong custom interest.',
      );
  String get notificationSettingsTitle =>
      _t('notificationSettingsTitle', 'Notification Settings', 'Mga Setting ng Notification');
  String get allowNotifications =>
      _t('allowNotifications', 'Allow Notifications', 'Payagan ang Mga Notification');
  String get allowNotificationsBody => _t('allowNotificationsBody', 
        'Get updates and reminders from your DAPE-MA application.',
        'Makatanggap ng updates at paalala mula sa DAPE-MA.',
      );
  String get notificationTypes =>
      _t('notificationTypes', 'NOTIFICATION TYPES', 'MGA URI NG NOTIFICATION');
  String get notifyArticles =>
      _t('notifyArticles', 'New articles and lessons', 'Mga bagong artikulo at aralin');
  String get notifyArticlesBody =>
      _t('notifyArticlesBody', 'When new resources are published', 'Kapag may bagong nilathalang resources');
  String get notifyAchievements => _t('notifyAchievements', 'Achievements', 'Mga Achievement');
  String get notifyAchievementsBody =>
      _t('notifyAchievementsBody', 'Badges, completed lessons, goals', 'Mga badge, natapos na aralin, goals');
  String get notifyEvents =>
      _t('notifyEvents', 'Events and seminars', 'Mga event at seminar');
  String get notifyEventsBody =>
      _t('notifyEventsBody', 'Upcoming events and reminders', 'Mga paparating na event at paalala');
  String get notifyUpdates =>
      _t('notifyUpdates', 'Application updates', 'Mga update ng application');
  String get notifyUpdatesBody =>
      _t('notifyUpdatesBody', "When it's time for you to do an update", 'Kapag oras nang mag-update');
  String get quietHours =>
      _t('quietHours', 'QUIET HOURS (optional)', 'QUIET HOURS (opsyonal)');
  String get quietHoursLabel =>
      _t('quietHoursLabel', "Don't send between", 'Huwag magpadala sa pagitan ng');
  String get quietHoursRange => _t('quietHoursRange', '10:00 PM - 7:00 AM', '10:00 PM - 7:00 AM');
  String get changeAnytime =>
      _t('changeAnytime', 'You can change these anytime.', 'Maaari mong baguhin ang mga ito anumang oras.');
  String get notificationsTitle => _t('notificationsTitle', 'Notifications', 'Mga Notification');
  String get notificationsToday => _t('notificationsToday', 'Today', 'Ngayon');
  String get notificationsEarlier => _t('notificationsEarlier', 'Earlier', 'Mas Maaga');
  String get markAllRead => _t('markAllRead', 'Mark all as read', 'Markahan lahat bilang nabasa');
  String get notificationsLoadFailed =>
      _t('notificationsLoadFailed', 'Failed to load notifications.', 'Hindi ma-load ang mga notification.');
  String get notificationsMarkAllFailed =>
      _t('notificationsMarkAllFailed', 'Could not mark all as read.', 'Hindi ma-markahan ang lahat bilang nabasa.');
  String get notificationsOpenFailed =>
      _t('notificationsOpenFailed', 'Could not open this notification.', 'Hindi mabuksan ang notification na ito.');
  String get notificationsEmptyTitle =>
      _t('notificationsEmptyTitle', 'No notifications yet', 'Wala pang notification');
  String get notificationsEmptyBody => _t('notificationsEmptyBody', 
        'Replies, likes, lessons, and new posts will appear here.',
        'Ang mga reply, like, aralin, at bagong post ay lilitaw dito.',
      );
  String get notifTypeNewLesson =>
      _t('notifTypeNewLesson', 'New lesson published', 'May bagong aralin');
  String get notifTypeCompletedLesson =>
      _t('notifTypeCompletedLesson', 'Completed a lesson', 'Natapos ang isang aralin');
  String get notifTypeSeminar =>
      _t('notifTypeSeminar', 'Seminar invitation', 'Imbitasyon sa seminar');
  String get notifTypeGoals => _t('notifTypeGoals', 'Goals progress', 'Progreso ng goals');
  String get notifTypeBadges => _t('notifTypeBadges', 'Badges unlocked', 'May bagong badge');
  String get notifTypeReply => _t('notifTypeReply', 'New reply', 'May bagong reply');
  String get notifTypeComment => _t('notifTypeComment', 'New comment', 'May bagong komento');
  String get notifTypeLiked => _t('notifTypeLiked', 'Post liked', 'May nag-like sa post');
  String get notifTypeAdminPush =>
      _t('notifTypeAdminPush', 'Announcement', 'Anunsyo');
  String get notifTypeGeneral => _t('notifTypeGeneral', 'Notification', 'Notification');
  String get privacyIntro => _t('privacyIntro', 
        'Your privacy matters to us. Read our Privacy Policy to learn how we protect your information.',
        'Mahalaga sa amin ang iyong privacy. Basahin ang aming Patakaran sa Privacy.',
      );
  String get privacyBody => _t('privacyBody', 
        'DAPE-MA may collect account details, learning activity, bookmarks, device information, and feedback you submit so we can deliver content, improve services, and support your recovery journey.\n\nWe use this information to personalize your experience, send relevant updates, and keep the platform secure. We do not sell your personal data.\n\nYou may request access, correction, or deletion of your information, and you may withdraw consent where applicable. Educational content is intended for guidance and should be used with appropriate professional or parental support when needed.\n\nFor privacy concerns, contact info@ddb.gov.ph.',
        'Maaaring mangolekta ang DAPE-MA ng detalye ng account, aktibidad sa pag-aaral, bookmark, impormasyon ng device, at feedback upang makapaghatid ng nilalaman at mapabuti ang serbisyo.\n\nGinagamit namin ang impormasyong ito para sa mas angkop na karanasan, mga update, at seguridad. Hindi namin ibinebenta ang iyong personal na data.\n\nMaaari kang humiling ng access, pagwawasto, o pagbura ng iyong impormasyon. Para sa mga concern sa privacy, makipag-ugnayan sa info@ddb.gov.ph.',
      );
  String get termsIntro => _t('termsIntro', 'Be informed.', 'Maging may kaalaman.');
  String get termsSubtitle => _t('termsSubtitle', 
        'Read the terms and conditions for using the DAPE-MA application.',
        'Basahin ang mga tuntunin at kundisyon sa paggamit ng DAPE-MA.',
      );
  String get termsBody => _t('termsBody', 
        'By using DAPE-MA, you agree to use the app responsibly and lawfully. Do not misuse content, attempt unauthorized access, copy or modify the application, or submit harmful or false information.\n\nContent is provided for information and education. It does not replace professional medical, legal, or counseling advice.\n\nWe may update these Terms of Use from time to time. Continued use of the app after updates means you accept the revised terms.\n\nFor questions or concerns regarding these Terms of Use, please contact us at info@ddb.gov.ph.',
        'Sa paggamit ng DAPE-MA, sumasang-ayon kang gamitin ang app nang responsable at ayon sa batas. Huwag abusuhin ang nilalaman o subukang mag-access nang walang pahintulot.\n\nAng nilalaman ay para sa impormasyon at edukasyon. Hindi ito kapalit ng propesyonal na payo.\n\nMaaaring i-update ang mga Tuntunin. Ang patuloy na paggamit ay nangangahulugang tinatanggap mo ang mga pagbabago.\n\nPara sa katanungan, makipag-ugnayan sa info@ddb.gov.ph.',
      );
  String get privacyNotice => _t('privacyNotice', 'Privacy Notice', 'Abiso sa Privacy');
  String get privacyNoticeSubtitle => _t('privacyNoticeSubtitle', 
        'Agreement for access to classified and sensitive information',
        'Kasunduan para sa access sa classified at sensitibong impormasyon',
      );
  String get privacyNoticeIntro => _t('privacyNoticeIntro', 
        'Please read the herein stated Agreement carefully and evidence your acceptance of its terms by clicking on the Agree button below:',
        'Pakibasa nang mabuti ang Kasunduang nakasaad dito at patunayan ang iyong pagtanggap sa mga tuntunin nito sa pamamagitan ng pag-click sa pindutang Agree sa ibaba:',
      );
  String get privacyNoticeBody => _t('privacyNoticeBody', 
        'I hereby accept the obligations contained in this Agreement in consideration of my being granted access to classified and/or sensitive information under the Drug Abuse Prevention and Education Mobile Application (DAPE-MA). As used in this Agreement, classified information is referred to confidential information, including oral communications.\n\nI understand and accept that by being granted access to classified information to the herein referred online system, the confidence and trust are placed in me by the Dangerous Drugs Board.\n\nI understand that the DDB is the responsible agency in collecting all information submitted to the DAPE-MA by end-users.\n\nI am fully aware that the data collection is for analysis and monitoring of reports and that the information gathered shall be used as basis for the development and improvement of policies and drug abuse prevention programs.\n\nI acknowledge that the information generated from the DAPE-MA may be shared to other authorized organizations, partner agencies, local government units and other stakeholders for research, policy formulation and program development.\n\nI agree that DDB shall immediately be notified if there are errors or discrepancies in the data being reported.\n\nWhen notifying the DDB for possible security breaches, I shall include the following:\n• Name and User ID\n• Name of Agency/Organization/Facility\n• Contact details\n• Date and time of unauthorized access\n• Description of security breach or fraud\n• Description of error that has occurred.\n\nI have been informed that unauthorized disclosure, unauthorized retention, or negligent handling of classified information by me could cause damage or irreparable injury to the Board and/or Government of the Philippines or could be used to advantage by other nation or people.\n\nI hereby agree that I shall not divulge classified information to anyone unless:\n\n• Officially verified that the recipient has been properly authorized by the Dangerous Drugs Board or by the government of the Philippines to receive it;\n• I have been given prior written notice of authorization from the Dangerous Drugs Board responsible for the classified information, or granting me clearance that such disclosure is permitted;\n• I have confirmed from an authorized official that the information is unclassified before I may disclose it.\n\nI am obligated to comply with laws and regulations that prohibit the unauthorized disclosure of classified information.\n\nBy my (i) use and/or continued use of this Website, or (ii) access and use of the service provided through this Website, I signify my agreement to indemnify and to keep the DDB, its directors, employees fully and effectively indemnified against all actions, liabilities, costs, claims, losses, damages, proceedings and/or expenses (including all legal costs on an indemnity basis) without prejudice to the filing of any criminal case for violation of any statute or law.\n\nViolation of any of the provisions of this agreement shall constitute breach and shall terminate this agreement immediately without need of notice, without prejudice to criminal prosecution for violation of RA 10173 otherwise known as the “Data Privacy Act of 2012,” as well as other pertinent laws.\n\nUnless and until I am released in writing that all conditions and obligations imposed upon me by this Agreement applies during the time I am granted access to classified information and at all times thereafter.\n\nPlease accept to continue',
        'Tinatanggap ko ang mga obligasyong nakapaloob sa Kasunduang ito bilang kapalit ng pagkakaloob sa akin ng access sa classified at/o sensitibong impormasyon sa ilalim ng Drug Abuse Prevention and Education Mobile Application (DAPE-MA). Sa Kasunduang ito, ang classified information ay tumutukoy sa kumpidensyal na impormasyon, kabilang ang mga oral na komunikasyon.\n\nNauunawaan at tinatanggap ko na sa pagkakaloob sa akin ng access sa classified information sa nabanggit na online system, inilalagak sa akin ng Dangerous Drugs Board ang kanilang tiwala.\n\nNauunawaan ko na ang DDB ang ahensyang responsable sa pagkolekta ng lahat ng impormasyong isinusumite sa DAPE-MA ng mga end-user.\n\nBatid ko na ang pagkolekta ng datos ay para sa pagsusuri at pagsubaybay ng mga ulat, at gagamitin ang nakalap na impormasyon bilang batayan sa pagpapaunlad at pagpapabuti ng mga polisiya at programa sa pag-iwas sa pag-abuso sa droga.\n\nKinikilala ko na ang impormasyong nalilikha mula sa DAPE-MA ay maaaring ibahagi sa iba pang awtorisadong organisasyon, kasosyong ahensya, local government units, at iba pang stakeholder para sa pananaliksik, pagbuo ng polisiya, at pagpapaunlad ng programa.\n\nSumasang-ayon ako na agad na aabisuhan ang DDB kung may mga mali o hindi pagkakatugma sa datos na nire-report.\n\nKapag aabisuhan ang DDB ukol sa posibleng security breach, isasama ko ang mga sumusunod:\n• Pangalan at User ID\n• Pangalan ng Ahensya/Organisasyon/Pasilidad\n• Detalye ng pakikipag-ugnayan\n• Petsa at oras ng hindi awtorisadong pag-access\n• Paglalarawan ng security breach o panloloko\n• Paglalarawan ng naganap na error.\n\nNaipaalam sa akin na ang hindi awtorisadong pagbunyag, hindi awtorisadong pagtatago, o pabayaang paghawak ko sa classified information ay maaaring magdulot ng pinsala o hindi na mababawi na injury sa Board at/o sa Pamahalaan ng Pilipinas, o magamit nang pabor ng ibang bansa o tao.\n\nSumasang-ayon ako na hindi ko ibubunyag ang classified information kaninuman maliban kung:\n\n• Opisyal na napatunayan na ang tatanggap ay wastong pinahintulutan ng Dangerous Drugs Board o ng pamahalaan ng Pilipinas na tumanggap nito;\n• Binigyan ako ng paunang nakasulat na paunawa ng awtorisasyon mula sa Dangerous Drugs Board na responsable sa classified information, o ng clearance na pinahihintulutan ang naturang pagbunyag;\n• Nakumpirma ko mula sa awtorisadong opisyal na unclassified ang impormasyon bago ko ito maibunyag.\n\nObligado akong sumunod sa mga batas at regulasyong nagbabawal sa hindi awtorisadong pagbunyag ng classified information.\n\nSa aking (i) paggamit at/o patuloy na paggamit ng Website na ito, o (ii) access at paggamit ng serbisyong ibinibigay sa pamamagitan ng Website na ito, ipinapahayag ko ang aking pagsang-ayon na indemnify at panatilihing fully at effectively indemnified ang DDB, ang mga direktor, at empleyado nito laban sa lahat ng aksyon, pananagutan, gastos, claim, pagkawala, pinsala, proceedings, at/o gastusin (kabilang ang lahat ng legal na gastos on an indemnity basis), nang hindi isinasakripisyo ang paghahain ng anumang criminal case para sa paglabag sa anumang batas.\n\nAng paglabag sa alinmang probisyon ng kasunduang ito ay ituturing na breach at agad na magwawakas ang kasunduang ito nang hindi na kailangan ng paunawa, nang hindi isinasakripisyo ang criminal prosecution para sa paglabag sa RA 10173 na kilala rin bilang “Data Privacy Act of 2012,” at iba pang naaangkop na batas.\n\nHangga’t hindi ako pinalalaya sa pamamagitan ng sulat, ang lahat ng kundisyon at obligasyong ipinapataw sa akin ng Kasunduang ito ay nalalapat habang ako ay pinagkalooban ng access sa classified information at sa lahat ng panahon pagkatapos nito.\n\nPakitanggap upang magpatuloy',
      );
  String get consentAgreePrefix => _t('consentAgreePrefix', 
        'I have read and agree to the ',
        'Nabasa ko at sumasang-ayon ako sa ',
      );
  String get consentAcceptPrefix => _t('consentAcceptPrefix', 
        'I have read and accept the ',
        'Nabasa ko at tinatanggap ko ang ',
      );
  String get consentRequired => _t('consentRequired', 
        'Please accept the Terms of Use, Privacy Policy, and Privacy Notice to continue.',
        'Pakitanggap ang Mga Tuntunin ng Paggamit, Patakaran sa Privacy, at Abiso sa Privacy upang magpatuloy.',
      );
  String get accessibilityIntro => _t('accessibilityIntro', 
        'We are here to make learning inclusive for everyone.',
        'Nandito kami para gawing inklusibo ang pag-aaral para sa lahat.',
      );
  String get textSize => _t('textSize', 'Text Size', 'Laki ng Teksto');
  String get textSizeBody =>
      _t('textSizeBody', 'Adjust the size of text', 'Ayusin ang laki ng teksto');
  String get darkMode => _t('darkMode', 'Dark Mode', 'Dark Mode');
  String get darkModeBody =>
      _t('darkModeBody', 'Reduce eye strain in low light', 'Bawasan ang strain ng mata sa madilim');
  String get reduceMotion => _t('reduceMotion', 'Reduce Motion', 'Bawasan ang Motion');
  String get reduceMotionBody =>
      _t('reduceMotionBody', 'Minimize animation and motion effects', 'Bawasan ang animation at motion effects');
  String get highContrast => _t('highContrast', 'High Contrast', 'High Contrast');
  String get highContrastBody =>
      _t('highContrastBody', 'Increase contrast for better visibility', 'Dagdagan ang contrast para mas madaling makita');
  String get readAloud => _t('readAloud', 'Read Articles Aloud', 'Basahin nang Malakas');
  String get readAloudBody =>
      _t('readAloudBody', 'Listen to articles and lessons', 'Makinig sa mga artikulo at aralin');
  String get listenToArticle => _t('listenToArticle', 'Listen', 'Makinig');
  String get stopListening => _t('stopListening', 'Stop', 'Ihinto');
  String get captions => _t('captions', 'Captions', 'Mga Caption');
  String get captionsBody =>
      _t('captionsBody', 'Enable captions for videos', 'I-enable ang captions para sa video');
  String get accessibilityFooter => _t('accessibilityFooter', 
        'Accessibility is about inclusion. These settings help make DAPE-MA comfortable, easy to use, and supportive for everyone.',
        'Ang accessibility ay tungkol sa inklusyon. Tinutulungan ng mga setting na ito na gawing komportable at madaling gamitin ang DAPE-MA.',
      );
  String get aboutTagline => _t('aboutTagline', 
        'Dangerous Drugs Board Advocacy and Prevention Education Mobile App',
        'Dangerous Drugs Board Advocacy and Prevention Education Mobile App',
      );
  String get versionLabel => _t('versionLabel', 'Version', 'Bersyon');
  String get buildLabel => _t('buildLabel', 'Build', 'Build');
  String get developersLabel => _t('developersLabel', 'Developers', 'Mga Developer');
  String get contactUsLabel => _t('contactUsLabel', 'Contact Us', 'Makipag-ugnayan');
  String get aboutCopyright =>
      _t('aboutCopyright', '2026. DAPE-MA. All rights reserved.', '2026. DAPE-MA. All rights reserved.');
  String get welcomeTitle => _t('welcomeTitle', 'Welcome to DAPE-MA', 'Maligayang pagdating sa DAPE-MA');
  String get welcomeBody => _t('welcomeBody', 
        'Sign in or create an account to save bookmarks and submit reviews.',
        'Mag-sign in o gumawa ng account para mag-save ng bookmark at mag-review.',
      );
  String get login => _t('login', 'Login', 'Mag-login');
  String get register => _t('register', 'Register', 'Magrehistro');
  String get forgotPassword => _t('forgotPassword', 'Forgot password?', 'Nakalimutan ang password?');
  String get profileUpdated => _t('profileUpdated', 'Profile updated', 'Na-update ang profile');
  String get nameRequired => _t('nameRequired', 'Name is required', 'Kailangan ang pangalan');
  String get updateFailed =>
      _t('updateFailed', 'Update failed. Please try again.', 'Hindi na-update. Subukan muli.');
  String get changePhoto => _t('changePhoto', 'Change photo', 'Palitan ang larawan');
  String get profilePhotoTitle =>
      _t('profilePhotoTitle', 'Profile photo', 'Larawan ng profile');
  String get removePhoto => _t('removePhoto', 'Remove photo', 'Alisin ang larawan');
  String get photoRemoved => _t('photoRemoved', 'Photo removed', 'Naalis ang larawan');
  String get name => _t('name', 'Name', 'Pangalan');
  String get save => _t('save', 'Save', 'I-save');
  String get currentPasswordRequired =>
      _t('currentPasswordRequired', 'Current password is required', 'Kailangan ang kasalukuyang password');
  String get passwordMinLength =>
      _t('passwordMinLength', 'New password must be at least 6 characters', 'Ang bagong password ay dapat 6 character');
  String get passwordsDoNotMatch =>
      _t('passwordsDoNotMatch', 'New passwords do not match', 'Hindi magkatugma ang mga bagong password');
  String get passwordUpdated =>
      _t('passwordUpdated', 'Password updated successfully', 'Matagumpay na na-update ang password');
  String get passwordUpdateFailed => _t('passwordUpdateFailed', 
        'Failed to update password. Check current password.',
        'Hindi na-update ang password. Suriin ang kasalukuyang password.',
      );
  String get currentPassword => _t('currentPassword', 'Current password', 'Kasalukuyang password');
  String get newPassword => _t('newPassword', 'New password', 'Bagong password');
  String get confirmNewPassword => _t('confirmNewPassword', 'Confirm new password', 'Kumpirmahin ang bagong password');
  String get updatePassword => _t('updatePassword', 'Update password', 'I-update ang password');

  // Auth
  String get signIn => _t('signIn', 'Sign in', 'Mag-sign in');
  String get email => _t('email', 'Email', 'Email');
  String get password => _t('password', 'Password', 'Password');
  String get emailRequired => _t('emailRequired', 'Email is required', 'Kailangan ang email');
  String get emailInvalid => _t(
        'emailInvalid',
        'Enter a valid email address, like name@example.com',
        'Maglagay ng wastong email, tulad ng name@example.com',
      );
  String get emailTaken => _t(
        'emailTaken',
        'This email is already registered. Sign in or use another email.',
        'Nakarehistro na ang email na ito. Mag-sign in o gumamit ng iba.',
      );
  String get emailCheckFailed => _t(
        'emailCheckFailed',
        'Could not verify that email. Check your connection and try again.',
        'Hindi ma-verify ang email. Tingnan ang connection at subukan muli.',
      );
  String get passwordRequired => _t('passwordRequired', 'Password is required', 'Kailangan ang password');
  String get loginFailed =>
      _t('loginFailed', 'Login failed. Please check your credentials.', 'Hindi matagumpay ang login. Suriin ang credentials.');
  String get noAccount => _t('noAccount', "Don't have an account? ", 'Wala pang account? ');
  String get fullName => _t('fullName', 'Full name', 'Buong pangalan');
  String get confirmPassword => _t('confirmPassword', 'Confirm password', 'Kumpirmahin ang password');
  String get createAccount => _t('createAccount', 'Create account', 'Gumawa ng account');
  String get continueLabel => _t('continueLabel', 'Continue', 'Magpatuloy');
  String get alreadyHaveAccount => _t('alreadyHaveAccount', 'Already have an account? ', 'May account na? ');

  // Registration onboarding (mockup-aligned, DAPE-MA branding)
  String get regGetStartedTitle => _t('regGetStartedTitle', 'Get Started', 'Magsimula');
  String get regGetStartedSubtitle => _t('regGetStartedSubtitle', 
        'Create an account to start your DAPE-MA journey!',
        'Gumawa ng account para simulan ang iyong DAPE-MA journey!',
      );
  String get regContinueGoogle =>
      _t('regContinueGoogle', 'Continue with Google', 'Magpatuloy gamit ang Google');
  String get regContinueFacebook =>
      _t('regContinueFacebook', 'Continue with Facebook', 'Magpatuloy gamit ang Facebook');
  String get regContinueApple =>
      _t('regContinueApple', 'Continue with Apple', 'Magpatuloy gamit ang Apple');
  String get regNicknameTitlePrefix => _t('regNicknameTitlePrefix', 'What should we call ', 'Ano ang itatawag namin sa ');
  String get regNicknameTitleHighlight => _t('regNicknameTitleHighlight', 'you', 'iyo');
  String get regNicknameTitleSuffix => _t('regNicknameTitleSuffix', '?', '?');
  String get regNicknameSubtitle => _t('regNicknameSubtitle', 
        'We’ll use this to personalize your experience.',
        'Gagamitin namin ito para i-personalize ang iyong karanasan.',
      );
  String get regNicknameHint => _t('regNicknameHint', 'Type your nickname', 'I-type ang iyong palayaw');
  String get regNicknameHelper =>
      _t('regNicknameHelper', 'You can change this anytime.', 'Maaari mong baguhin ito anytime.');
  String get regNicknameRequired =>
      _t('regNicknameRequired', 'Please enter a nickname.', 'Maglagay ng palayaw.');
  String get regOptionalLabel => _t('regOptionalLabel', 'OPTIONAL', 'OPSYONAL');
  String get regPronounsTitle =>
      _t('regPronounsTitle', 'What are your pronouns?', 'Ano ang iyong mga panghalip?');
  String get regPronounsSubtitle => _t('regPronounsSubtitle', 
        'This helps us create a respectful and inclusive experience.',
        'Nakakatulong ito para sa magalang at inklusibong karanasan.',
      );
  String regPronounLabel(String key) => switch (key) {
        'she_her' => _t('regPronoun_she_her', 'She/Her', 'She/Her'),
        'he_him' => _t('regPronoun_he_him', 'He/Him', 'He/Him'),
        'they_them' => _t('regPronoun_they_them', 'They/Them', 'They/Them'),
        'ze_hir' => _t('regPronoun_ze_hir', 'Ze/Hir', 'Ze/Hir'),
        'prefer_not' => _t('regPronoun_prefer_not', 'Prefer not to say', 'Ayaw sabihin'),
        'others' => _t('regPronoun_others', 'Others', 'Iba pa'),
        _ => key,
      };
  String get regBirthdayTitle =>
      _t('regBirthdayTitle', "When's your birthday?", 'Kailan ang iyong kaarawan?');
  String get regBirthdaySubtitle => _t('regBirthdaySubtitle', 
        'We use your age to recommend appropriate content and programs.',
        'Ginagamit ang edad para magrekomenda ng angkop na content at programa.',
      );
  String get regBirthdayHint => _t('regBirthdayHint', 'MM / DD / YYYY', 'MM / DD / YYYY');
  String get regBirthdayRequired =>
      _t('regBirthdayRequired', 'Please select your birthday.', 'Piliin ang iyong kaarawan.');
  String get regPersonaTitle =>
      _t('regPersonaTitle', 'Which best describes you?', 'Alin ang pinakakatugma sa iyo?');
  String get regPersonaSubtitle => _t('regPersonaSubtitle', 
        'Select all that apply. This helps us tailor the DAPE-MA app to your needs.',
        'Pumili ng lahat ng naaangkop. Nakakatulong ito para iangkop ang DAPE-MA app sa iyong pangangailangan.',
      );
  String get regPersonaRequired =>
      _t('regPersonaRequired', 'Please select at least one option.', 'Pumili ng kahit isang opsyon.');
  String regPersonaLabel(String key) => switch (key) {
        'student' => _t('regPersona_student', 'Student', 'Estudyante'),
        'parent' => _t('regPersona_parent', 'Parent', 'Magulang'),
        'teacher' => _t('regPersona_teacher', 'Teacher', 'Guro'),
        'youth_leader' => _t('regPersona_youth_leader', 'Youth Leader', 'Youth Leader'),
        'health_worker' => _t('regPersona_health_worker', 'Health Worker', 'Health Worker'),
        'concerned_citizen' =>
          _t('regPersona_concerned_citizen', 'Concerned Citizen', 'Concerned Citizen'),
        _ => key,
      };
  String get regInterestsTitle =>
      _t('regInterestsTitle', 'What matters most to you?', 'Ano ang pinakamahalaga sa iyo?');
  String get regInterestsSubtitle => _t('regInterestsSubtitle', 
        'Choose among these interests. We’ll personalize your feed.',
        'Pumili mula sa mga interes na ito. Ipa-personalize namin ang iyong feed.',
      );
  String get regInterestsRequired =>
      _t('regInterestsRequired', 'Select at least one interest.', 'Pumili ng kahit isang interes.');
  String regInterestLabel(String key) => switch (key) {
        'knowledge' => _t('regInterest_knowledge', 'Knowledge', 'Kaalaman'),
        'community' => _t('regInterest_community', 'Community', 'Komunidad'),
        'wellness' => _t('regInterest_wellness', 'Wellness', 'Wellness'),
        'stories' => _t('regInterest_stories', 'Stories', 'Mga Kwento'),
        'support' => _t('regInterest_support', 'Support', 'Suporta'),
        'events' => _t('regInterest_events', 'Events', 'Mga Event'),
        'opportunities' => _t('regInterest_opportunities', 'Opportunities', 'Mga Oportunidad'),
        'advocacy' => _t('regInterest_advocacy', 'Advocacy', 'Advocacy'),
        _ => key,
      };
  String regInterestBody(String key) => switch (key) {
        'knowledge' => _t(
              'regInterestBody_knowledge',
              'Learn about drugs, life skills, and making informed decisions.',
              'Matuto tungkol sa drugs, life skills, at matalinong desisyon.',
            ),
        'community' => _t(
              'regInterestBody_community',
              'Connect, share, and support one another!',
              'Makipag-ugnayan, magbahagi, at suportahan ang isa’t isa!',
            ),
        'wellness' => _t(
              'regInterestBody_wellness',
              'Take care of your well-being and mental health.',
              'Alagaan ang iyong well-being at mental health.',
            ),
        'stories' => _t(
              'regInterestBody_stories',
              'Read inspiring stories and inspire others with yours.',
              'Magbasa ng inspirasyon at magbahagi ng iyong kwento.',
            ),
        'support' => _t(
              'regInterestBody_support',
              'Find help and resources when you or someone needs it.',
              'Maghanap ng tulong at resources kung kailangan.',
            ),
        'events' => _t(
              'regInterestBody_events',
              'Join events and activities in your community.',
              'Sumali sa mga event at aktibidad sa komunidad.',
            ),
        'opportunities' => _t(
              'regInterestBody_opportunities',
              'Explore scholarships and career opportunities.',
              'Tuklasin ang scholarships at career opportunities.',
            ),
        'advocacy' => _t(
              'regInterestBody_advocacy',
              'Be a voice for change through your own ways.',
              'Maging boses ng pagbabago sa iyong sariling paraan.',
            ),
        _ => '',
      };
  String get regSuccessTitlePrefix =>
      _t('regSuccessTitlePrefix', "You’re all set to ", 'Handa ka na sa ');
  String get regSuccessTitleHighlight => _t('regSuccessTitleHighlight', 'DAPE-MA', 'DAPE-MA');
  String get regSuccessTitleSuffix =>
      _t('regSuccessTitleSuffix', ' best you can be!', ' nang buong-buo!');
  String get regFeatureLearnTitle => _t('regFeatureLearnTitle', 'DAPE Learn', 'DAPE Learn');
  String get regFeatureLearnBody =>
      _t('regFeatureLearnBody', 'Discover knowledge and build skills!', 'Matuto at magpaunlad ng skills!');
  String get regFeatureHopeTitle => _t('regFeatureHopeTitle', 'DAPE Hope', 'DAPE Hope');
  String get regFeatureHopeBody => _t('regFeatureHopeBody', 
        'Connect with others and aspire together!',
        'Makipag-ugnayan at maghangad nang sama-sama!',
      );
  String get regFeatureCareTitle => _t('regFeatureCareTitle', 'DAPE Care', 'DAPE Care');
  String get regFeatureCareBody => _t('regFeatureCareBody', 
        'Take care of your mind and well-being!',
        'Alagaan ang isip at well-being mo!',
      );
  String get regSuccessReady => _t('regSuccessReady', 
        'Your personalized experience is ready!',
        'Handa na ang iyong personalized na karanasan!',
      );
  String get regSuccessCtaLearn => _t('regSuccessCtaLearn', 'Learn', 'Learn');
  String get regSuccessCtaMid => _t('regSuccessCtaMid', ', ', ', ');
  String get regSuccessCtaHope => _t('regSuccessCtaHope', 'hope', 'hope');
  String get regSuccessCtaAnd => _t('regSuccessCtaAnd', ', and ', ', at ');
  String get regSuccessCtaCare => _t('regSuccessCtaCare', 'care', 'care');
  String get regSuccessCtaEnd => _t('regSuccessCtaEnd', ' now!', ' ngayon!');
  String get regOnboardingFailed => _t('regOnboardingFailed', 
        'Could not save your preferences. Please try again.',
        'Hindi ma-save ang iyong preferences. Subukan muli.',
      );
  String get resetPassword => _t('resetPassword', 'Reset password', 'I-reset ang password');
  String get sendResetLink => _t('sendResetLink', 'Send reset code', 'Ipadala ang reset code');
  String get resetInstructions => _t('resetInstructions', 
        'Enter your email. We will send a 6-digit code — check that inbox before you can set a new password.',
        'Ilagay ang email. Magpapadala kami ng 6-digit na code — tingnan muna ang inbox bago magtakda ng bagong password.',
      );
  String get resetSuccess => _t('resetSuccess', 
        'Check your email for a 6-digit code, then continue here.',
        'Tingnan ang email para sa 6-digit na code, tapos magpatuloy dito.',
      );
  String get resetCodeInvalid => _t('resetCodeInvalid', 
        'That code does not match. Check your email and try again.',
        'Hindi tumugma ang code. Tingnan ang email at subukan muli.',
      );
  String get checkEmailTitle =>
      _t('checkEmailTitle', 'Check your email', 'Tingnan ang iyong email');
  String get resetFailed =>
      _t('resetFailed', 'Unable to send reset link. Please try again.', 'Hindi maipadala ang reset link. Subukan muli.');
  String get resetPasswordSubtitle => _t('resetPasswordSubtitle', 
        'Enter a new password for your account.',
        'Maglagay ng bagong password para sa iyong account.',
      );
  String get newPasswordHint => _t('newPasswordHint', 'New password', 'Bagong password');
  String get confirmPasswordHint =>
      _t('confirmPasswordHint', 'Confirm new password', 'Kumpirmahin ang bagong password');
  String get passwordMinEight => _t('passwordMinEight', 
        'Password must be at least 8 characters',
        'Ang password ay dapat hindi bababa sa 8 character',
      );
  String get saveNewPassword =>
      _t('saveNewPassword', 'Save new password', 'I-save ang bagong password');
  String get passwordResetSuccess => _t('passwordResetSuccess', 
        'Password has been reset. You can sign in now.',
        'Na-reset na ang password. Maaari ka nang mag-sign in.',
      );
  String get passwordResetFailed => _t('passwordResetFailed', 
        'Unable to reset password. The link may have expired.',
        'Hindi ma-reset ang password. Maaaring expired na ang link.',
      );
  String get backToLogin => _t('backToLogin', 'Back to Login', 'Bumalik sa Login');
  String get authAgreePrefix => _t('authAgreePrefix', 
        'By continuing, you agree to our ',
        'Sa pagpapatuloy, sumasang-ayon ka sa aming ',
      );
  String get authAgreeAnd => _t('authAgreeAnd', ' and ', ' at ');

  // Bookmarks
  String get bookmarksTitle => _t('bookmarksTitle', 'Bookmarks', 'Mga Bookmark');
  String bookmarksCountLabel(int count) => _t('bookmarksCountLabel', 
        '$count saved',
        '$count naka-save',
        {'count': count.toString()});
  String get searchBookmarksHint =>
      _t('searchBookmarksHint', 'Search bookmarks...', 'Maghanap sa bookmarks...');
  String get noBookmarksYet =>
      _t('noBookmarksYet', 'No saved posts yet', 'Wala pang naka-save na post');
  String get noBookmarksBody => _t('noBookmarksBody', 
        'Tap the bookmark icon on any post to save it here for later.',
        'Pindutin ang bookmark icon sa post para i-save dito.',
      );
  String get noSearchResults => _t('noSearchResults', 'No matches found', 'Walang nahanap');
  String get noSearchResultsBody => _t('noSearchResultsBody', 
        'Try a different title or category.',
        'Subukan ang ibang pamagat o category.',
      );
  String activityItemsCount(int count) => _countPhrase(
        count: count,
        oneKey: 'activityItemsCountOne',
        manyKey: 'activityItemsCount',
        enOne: '1 item',
        enMany: '{count} items',
        tlOne: '1 item',
        tlMany: '{count} mga item',
      );

  // Rehab
  String get rehabCentersTitle => _t('rehabCentersTitle', 'Rehab Centers', 'Mga Rehab Center');
  String get allRegions => _t('allRegions', 'All regions', 'Lahat ng rehiyon');
  String get searchRehabHint => _t('searchRehabHint', 'Search rehab centers...', 'Maghanap ng rehab center...');

  // Reviews
  String get rateAndReview => _t('rateAndReview', 'Rate & Review', 'Mag-rate at Mag-review');
  String get updateYourRating => _t('updateYourRating', 'Update your rating', 'I-update ang iyong rating');
  String get noRatingsYet => _t('noRatingsYet', 'No ratings yet', 'Wala pang rating');
  String ratingsCount(int count) => _countPhrase(
        count: count,
        oneKey: 'ratingsCountOne',
        manyKey: 'ratingsCount',
        enOne: '1 rating',
        enMany: '{count} ratings',
        tlOne: '1 rating',
        tlMany: '{count} mga rating',
      );
  String get ratingSubmitted => _t('ratingSubmitted', 'Rating submitted', 'Naipasa ang rating');
  String get submitRating => _t('submitRating', 'Submit rating', 'Ipasa ang rating');
  String get chooseRating =>
      _t('chooseRating', 'Tap a star to choose your rating.', 'Pindutin ang bituin para pumili ng rating.');
  String get commentOptional => _t('commentOptional', 'Comment (optional)', 'Komento (opsyonal)');

  // Comments
  String get writeComment => _t('writeComment', 'Write a comment...', 'Sumulat ng komento...');
  String get commentEmojiTab => _t('commentEmojiTab', 'Emoji', 'Emoji');
  String get commentStickersTab => _t('commentStickersTab', 'Stickers', 'Mga Sticker');
  String get reply => _t('reply', 'Reply', 'Tumugon');
  String get replyingTo => _t('replyingTo', 'Replying to', 'Tumutugon kay');
  String get edit => _t('edit', 'Edit', 'I-edit');
  String get deleteAction => _t('deleteAction', 'Delete', 'Burahin');

  String loginRequired(String action) => _t('loginRequired', 
        'Please log in to $action.',
        'Mag-log in muna para $action.',
        {'action': action.toString()});

  // Registration
  String get registrationFailed =>
      _t('registrationFailed', 'Registration failed. Please check your details.', 'Hindi matagumpay ang pagrehistro. Suriin ang mga detalye.');
  String get passwordMinSix =>
      _t('passwordMinSix', 'Password must be at least 8 characters', 'Ang password ay dapat hindi bababa sa 8 character');

  // Bookmarks extras
  String get bookmarkRemoveFailed =>
      _t('bookmarkRemoveFailed', 'Could not remove bookmark. Try again.', 'Hindi matanggal ang bookmark. Subukan muli.');

  // Rehab extras
  String get searchRehabByHint =>
      _t('searchRehabByHint', 'Search by name, address, or province', 'Maghanap ayon sa pangalan, address, o lalawigan');
  String get noRehabFound => _t('noRehabFound', 'No rehab centers found', 'Walang nahanap na rehab center');
  String get tryDifferentSearch =>
      _t('tryDifferentSearch', 'Try a different region or search', 'Subukan ang ibang rehiyon o paghahanap');
  String get checkBackLater =>
      _t('checkBackLater', 'Check back later for listings', 'Bumalik muli mamaya para sa mga listahan');
  String get regionLabel => _t('regionLabel', 'Region', 'Rehiyon');

  // Post detail
  String get commentPosted => _t('commentPosted', 'Comment posted', 'Naipost ang komento');
  String get replyPosted => _t('replyPosted', 'Reply posted', 'Naipost ang tugon');
  String get commentDeleted => _t('commentDeleted', 'Comment deleted', 'Nabura ang komento');
  String get commentUpdated => _t('commentUpdated', 'Comment updated', 'Na-update ang komento');
  String ratingAverageSummary(double average, int count) =>
      '${average.toStringAsFixed(1)} · ${ratingsCount(count)}';
  String get deleteCommentTitle => _t('deleteCommentTitle', 'Delete comment?', 'Burahin ang komento?');
  String get deleteCommentBody =>
      _t('deleteCommentBody', 'This comment will be removed permanently.', 'Permanenteng mabubura ang komentong ito.');
  String get cancel => _t('cancel', 'Cancel', 'Kanselahin');
  String get commentsTitle => _t('commentsTitle', 'Comments', 'Mga Komento');
  String get commentsDisabledTitle =>
      _t('commentsDisabledTitle', 'Comments are turned off', 'Naka-off ang mga komento');
  String get commentsDisabledBody => _t('commentsDisabledBody', 
        'The author has disabled comments on this post.',
        'Naka-disable ang mga komento sa post na ito.',
      );
  String get loadPreviousComments =>
      _t('loadPreviousComments', 'Load previous comments...', 'I-load ang mga naunang komento...');
  String get retry => _t('retry', 'Retry', 'Subukan muli');
  String get noCommentsYet =>
      _t('noCommentsYet', 'No comments yet. Be the first to comment.', 'Wala pang komento. Ikaw ang unang magkomento.');
  String get noCommentsEmptyTitle =>
      _t('noCommentsEmptyTitle', 'No comments yet', 'Wala pang komento');
  String get noCommentsEmptyBody => _t('noCommentsEmptyBody', 
        'Be the first to share your thoughts.',
        'Ikaw ang unang magbahagi ng iyong saloobin.',
      );
  String get tapStarsToRate =>
      _t('tapStarsToRate', 'Tap a star to rate', 'Mag-tap ng bituin para mag-rate');
  String get writeReply => _t('writeReply', 'Write a reply...', 'Sumulat ng tugon...');
  String youRatedStars(int rating) => rating == 1
      ? _t('youRatedStarOne', 'You rated this 1 star', 'Ni-rate mo ito ng 1 bituin')
      : _t(
          'youRatedStars',
          'You rated this {rating} stars',
          'Ni-rate mo ito ng {rating} bituin',
          {'rating': rating.toString()},
      );

  // Review sheet
  String get rateThisContent => _t('rateThisContent', 'Rate this content', 'I-rate ang nilalamang ito');

  // Comment edit
  String get editComment => _t('editComment', 'Edit comment', 'I-edit ang komento');
  String get commentCannotBeEmpty =>
      _t('commentCannotBeEmpty', 'Comment cannot be empty', 'Hindi maaaring walang laman ang komento');
  String get updateCommentHint =>
      _t('updateCommentHint', 'Update your comment...', 'I-update ang iyong komento...');
  String get commentCaptionOptional =>
      _t('commentCaptionOptional', 'Add a caption (optional)', 'Magdagdag ng caption (opsyonal)');
  String get commentChangeSticker =>
      _t('commentChangeSticker', 'Change sticker', 'Palitan ang sticker');
  String get saveChanges => _t('saveChanges', 'Save changes', 'I-save ang mga pagbabago');
  String get commentUpdateFailed =>
      _t('commentUpdateFailed', 'Could not update comment. Try again.', 'Hindi ma-update ang komento. Subukan muli.');

  // Errors (engagement)
  String get serverUpdateRequired => _t('serverUpdateRequired', 
        'Likes and comments need the latest server update. Deploy Laravel and run php artisan migrate.',
        'Kailangan ng pinakabagong server update ang likes at komento.',
      );
  String get ownCommentsOnly =>
      _t('ownCommentsOnly', 'You can only manage your own comments.', 'Maaari mo lang pamahalaan ang sarili mong komento.');
  String get noInternet =>
      _t('noInternet', 'No internet connection. Check your network and try again.',
          'Walang internet. Suriin ang network at subukan muli.');
  String get underMaintenanceTitle =>
      _t('underMaintenanceTitle', 'We’ll be right back', 'Babalik kami agad');
  String get underMaintenanceBadge =>
      _t('underMaintenanceBadge', 'Connection issue', 'May problema sa koneksyon');
  String get underMaintenanceMessage => _t('underMaintenanceMessage', 
        'We’re having trouble connecting right now. Please check back in a few minutes.',
        'Hindi kami makakonekta sa ngayon. Subukan ulit sa ilang minuto.',
      );
  String underMaintenanceLastChecked(String time) => _t('underMaintenanceLastChecked', 
        'Last checked $time',
        'Huling tiningnan $time',
        {'time': time.toString()});
  String get underMaintenanceStillUnavailable => _t('underMaintenanceStillUnavailable', 
        'Still unavailable. Try again shortly.',
        'Hindi pa available. Subukan ulit saglit.',
      );
  String get underMaintenanceChecking =>
      _t('underMaintenanceChecking', 'Checking…', 'Tinitingnan…');
  String get contactSupport =>
      _t('contactSupport', 'Contact support', 'Makipag-ugnayan sa support');
  String actionFailed(String action) =>
      _t('actionFailed', 'Could not $action. Try again.', 'Hindi ma-$action. Subukan muli.', {'action': action.toString()});

  String get justNow => _t('justNow', 'Just now', 'Ngayon lang');

  String authorPost(String name) => _t('authorPost', "$name's Post", 'Post ni $name', {'name': name.toString()});

  // Kid Listo Says (motivational quotes)
  String get dailyVerseTitle => _t('dailyVerseTitle', 'Kid Listo Says', 'Kid Listo Says');
  String get kidListoSaysTitle => _t('kidListoSaysTitle', 'Kid Listo Says', 'Kid Listo Says');
  String get kidListoLogo => _t('kidListoLogo', 'Kid Listo', 'Kid Listo');
  String get kidListoMotivationalTagline => _t('kidListoMotivationalTagline', 
        'A daily motivational quote for a drug-free youth',
        'Araw-araw na motivational quote para sa drug-free youth',
      );
  String get kidListoMotivationalBadge =>
      _t('kidListoMotivationalBadge', 'Motivational Quote', 'Motivational Quote');
  String get anotherKidListoQuote =>
      _t('anotherKidListoQuote', 'Another Kid Listo Quote', 'Ibang Quote ni Kid Listo');
  String get kidListoQuoteFallback => _t('kidListoQuoteFallback', 
        'Choose courage over comfort. A drug-free life starts with one brave decision today.',
        'Piliin ang tapang kaysa ginhawa. Nagsisimula ang drug-free life sa isang matapang na desisyon ngayon.',
      );
  String get todaysScripture => _t('todaysScripture', "Today's quote", 'Quote ngayon');
  String kidListoDayLabel(int day, int total) => _t('kidListoDayLabel', 
        'Day $day of $total',
        'Araw $day sa $total',
        {'day': day.toString(), 'total': total.toString()});
  String get skip => _t('skip', 'Skip', 'Laktawan');
  String get close => _t('close', 'Close', 'Isara');
  String get done => _t('done', 'Done', 'Tapos');
  String get continueToApp => _t('continueToApp', 'Continue to DAPE-MA', 'Magpatuloy sa DAPE-MA');
  String get openBible => _t('openBible', 'Open Kid Listo', 'Buksan ang Kid Listo');
  String get openKidListoBible =>
      _t('openKidListoBible', 'Open Kid Listo', 'Buksan ang Kid Listo');
  String get dailyVerseFallback => _t('dailyVerseFallback', 
        'Choose courage over comfort. A drug-free life starts with one brave decision today.',
        'Piliin ang tapang kaysa ginhawa. Nagsisimula ang drug-free life sa isang matapang na desisyon ngayon.',
      );
  String get dailyVerseReferenceFallback => _t('dailyVerseReferenceFallback', 'Kid Listo', 'Kid Listo');

  // Unused legacy screens — not part of the admin mobile-label catalog.
  String get bibleTitle => isTagalog ? 'Kid Listo Says' : 'Kid Listo Says';
  String get searchBibleBooks =>
      isTagalog ? 'Maghanap ng aklat...' : 'Search books...';
  String get oldTestament => isTagalog ? 'Lumang Tipan' : 'Old Testament';
  String get newTestament => isTagalog ? 'Bagong Tipan' : 'New Testament';
  String get noBibleBooksFound =>
      isTagalog ? 'Walang nahanap na aklat' : 'No books found';
  String get bibleLoadFailed => isTagalog
      ? 'Hindi ma-load ang talata. Subukan muli.'
      : 'Could not load passage. Try again.';
  String get bibleLanguageNote => isTagalog
      ? 'Sinusunod ng Kid Listo quotes ang wika ng app (English o Tagalog).'
      : 'Kid Listo quotes follow your app language (English or Tagalog).';
  String chaptersLabel(int count) =>
      isTagalog ? '$count kabanata' : '$count chapters';

  // Journal (API/code still use diary-*)
  String get diaryTitle => _t('diaryTitle', 'My Journal', 'Aking Journal');
  String get writeToday => _t('writeToday', 'Start Writing', 'Magsimulang sumulat');
  String get diaryLoginRequired => _t('diaryLoginRequired', 
        'Sign in to keep your private daily journal.',
        'Mag-sign in para sa iyong pribadong journal.',
      );
  String get diaryEmpty => _t('diaryEmpty', 
        'No journal entries yet. Start writing to begin.',
        'Wala pang journal entry. Magsimulang sumulat para magsimula.',
      );
  String get diaryEditorTitle => _t('diaryEditorTitle', 'Journal entry', 'Journal entry');
  String get diaryTitleHint => _t('diaryTitleHint', 'Title (optional)', 'Pamagat (opsyonal)');
  String get diaryBodyHint =>
      _t('diaryBodyHint', 'What happened today?', 'Ano ang nangyari ngayon?');
  String get diaryBodyRequired => _t('diaryBodyRequired', 
        'Add at least one reflection field before saving.',
        'Magdagdag muna ng kahit isang refleksiyon bago i-save.',
      );
  String get diarySaved => _t('diarySaved', 'Journal entry saved', 'Nai-save ang journal entry');
  String get diarySaveFailed =>
      _t('diarySaveFailed', 'Could not save journal entry.', 'Hindi mai-save ang journal entry.');
  String get deleteDiaryTitle =>
      _t('deleteDiaryTitle', 'Delete journal entry?', 'Burahin ang journal entry?');
  String get deleteDiaryBody =>
      _t('deleteDiaryBody', 'This entry will be removed permanently.', 'Permanenteng mabubura ang entry na ito.');
  String get diaryDeleteFailed =>
      _t('diaryDeleteFailed', 'Could not delete journal entry.', 'Hindi mabura ang journal entry.');
  String get diaryDeleted =>
      _t('diaryDeleted', 'Journal entry deleted', 'Nabura ang journal entry');

  String get journalYourEntries => _t('journalYourEntries', 'Your Entries', 'Mga Entry Mo');
  String get journalFilterTitle =>
      _t('journalFilterTitle', 'Filter entries', 'I-filter ang entries');
  String get journalFilterAll => _t('journalFilterAll', 'All', 'Lahat');
  String get journalFilterToday => _t('journalFilterToday', 'Today', 'Ngayon');
  String get journalFilterThisWeek =>
      _t('journalFilterThisWeek', 'This week', 'Linggong ito');
  String get journalFilterThisMonth =>
      _t('journalFilterThisMonth', 'This month', 'Buwan na ito');
  String get journalFilterClear => _t('journalFilterClear', 'Clear', 'I-clear');
  String get journalFilterReset => _t('journalFilterReset', 'Reset', 'I-reset');
  String get journalFilterApply => _t('journalFilterApply', 'Apply', 'I-apply');
  String get journalFilterSearchHint => _t(
        'journalFilterSearchHint',
        'Search notes or gratitude…',
        'Maghanap sa notes o pasasalamat…',
      );
  String get journalFilterEmpty => _t(
        'journalFilterEmpty',
        'No entries match these filters.',
        'Walang entry na tumutugma sa filter.',
      );
  String get journalDailyReflection =>
      _t('journalDailyReflection', 'Daily Reflection', 'Araw-araw na Refleksiyon');
  String get journalNoWrittenNotes =>
      _t('journalNoWrittenNotes', '(No written notes)', '(Walang nakasulat na notes)');
  String journalWritingThroughSky(String sky) => _t('journalWritingThroughSky', 
        "Writing through today's $sky",
        'Sumusulat sa $sky ngayon',
        {'sky': sky.toString()});
  String journalStepOf(int current, int total) =>
      _t('journalStepOf', '$current OF $total', '$current SA $total', {'current': current.toString(), 'total': total.toString()});
  String get journalNext => _t('journalNext', 'Next', 'Susunod');
  String get journalSaveEntry => _t('journalSaveEntry', 'Save Entry', 'I-save ang Entry');
  String get journalSkyTitle =>
      _t('journalSkyTitle', "What's your sky today?", 'Ano ang langit mo ngayon?');
  String get journalSkySubtitle => _t('journalSkySubtitle', 
        'Pick the color that matches your inner world. Light tones are brighter moods; dark tones are heavier ones.',
        'Piliin ang kulay na tumutugma sa iyong loob. Ang maliwanag na tono ay mas magaan na damdamin; ang madilim ay mas mabigat.',
      );
  String get journalFeelingsTitle =>
      _t('journalFeelingsTitle', 'What are you feeling?', 'Ano ang nararamdaman mo?');
  String get journalFeelingsSubtitle => _t('journalFeelingsSubtitle', 
        'Select all that apply — or add your own.',
        'Piliin ang lahat na angkop — o magdagdag ng sarili.',
      );
  String get journalAddYourOwn =>
      _t('journalAddYourOwn', 'Add your own', 'Idagdag ang sa iyo');
  String get journalCustomFeelingHint => _t(
        'journalCustomFeelingHint',
        'Long-press a custom feeling to remove it.',
        'Pindutin nang matagal ang custom feeling para alisin.',
      );
  String get journalRemoveCustomFeelingTitle => _t(
        'journalRemoveCustomFeelingTitle',
        'Remove feeling?',
        'Alisin ang feeling?',
      );
  String journalRemoveCustomFeelingBody(String feeling) => _t(
        'journalRemoveCustomFeelingBody',
        'Remove “$feeling” from your saved feelings?',
        'Alisin ang “$feeling” sa iyong listahan?',
        {'feeling': feeling},
      );
  String get journalRemoveFeeling =>
      _t('journalRemoveFeeling', 'Remove', 'Alisin');
  String get journalImpactTitle =>
      _t('journalImpactTitle', 'What shaped your day?', 'Ano ang humubog sa araw mo?');
  String get journalImpactSubtitle => _t('journalImpactSubtitle', 
        'Choose the area that mattered most today.',
        'Piliin ang bahagi na pinakamahalaga ngayon.',
      );
  String get journalNotesTitle =>
      _t('journalNotesTitle', 'Anything else to note?', 'May iba pa bang nais isulat?');
  String get journalNotesSubtitle => _t('journalNotesSubtitle', 
        'Optional free notes — write as much or as little as you need.',
        'Opsyonal na notes — magkano man ang isulat mo.',
      );
  String get journalGratitudeLabel =>
      _t('journalGratitudeLabel', 'Gratitude (optional)', 'Pasasalamat (opsyonal)');
  String get journalGratitudeHint => _t('journalGratitudeHint', 
        "Today I'm grateful for…",
        'Ngayong araw, nagpapasalamat ako sa…',
      );
  String journalGratitudeHintNamed(String name) => _t('journalGratitudeHintNamed', 
        "$name, what are you grateful for today?",
        '$name, ano ang pinapasalamatan mo ngayon?',
        {'name': name.toString()});
  String get journalSummaryTitle =>
      _t('journalSummaryTitle', 'Your reflection so far', 'Ang iyong refleksiyon sa ngayon');
  String get journalSummarySky => _t('journalSummarySky', 'Sky', 'Langit');
  String get journalSummaryFeelings => _t('journalSummaryFeelings', 'Feelings', 'Damdamin');
  String get journalSummaryImpact => _t('journalSummaryImpact', 'Impact', 'Epekto');
  String get journalSummaryEmpty => _t('journalSummaryEmpty', 'Not set', 'Walang napili');
  String get journalNotesShort => _t('journalNotesShort', 'Notes', 'Tala');
  String get journalPhotoLabel =>
      _t('journalPhotoLabel', 'Add a photo (optional)', 'Magdagdag ng larawan (opsyonal)');
  String get journalPhotoHint => _t('journalPhotoHint', 
        'Take a photo or choose from your library. We’ll optimize it before upload.',
        'Kumuha ng litrato o pumili mula sa gallery. Io-optimize bago i-upload.',
      );
  String get journalPhotoAdd => _t('journalPhotoAdd', 'Add photo', 'Magdagdag ng larawan');
  String get journalPhotoChange => _t('journalPhotoChange', 'Change photo', 'Palitan ang larawan');
  String get journalPhotoRemove => _t('journalPhotoRemove', 'Remove', 'Alisin');
  String get journalPhotoSourceTitle =>
      _t('journalPhotoSourceTitle', 'Add a journal photo', 'Magdagdag ng larawan sa journal');
  String get journalPhotoCamera => _t('journalPhotoCamera', 'Take photo', 'Kumuha ng litrato');
  String get journalPhotoGallery =>
      _t('journalPhotoGallery', 'Choose from library', 'Pumili mula sa gallery');
  String get journalPhotoFailed => _t('journalPhotoFailed', 
        'Could not prepare that photo. Please try another.',
        'Hindi ma-prepare ang larawan. Subukan ang iba.',
      );

  // DAPE Hope
  String get hopeTitle => _t('hopeTitle', 'DAPE Hope', 'DAPE Hope');
  String get hopeTagline => _t('hopeTagline', 
        'Together for a drug-free and hopeful future.',
        'Sama-sama para sa drug-free at may pag-asang kinabukasan.',
      );
  String get hopeSearchHint => _t('hopeSearchHint', 
        'Search communities, events, and campaigns!',
        'Maghanap ng communities, events, at campaigns!',
      );
  String get hopeMovementTitle =>
      _t('hopeMovementTitle', 'Be part of the movement!', 'Maging bahagi ng kilusan!');
  String get hopeFeaturedTitle => _t('hopeFeaturedTitle', 'Featured', 'Tampok');
  String get hopeSpeedDialTitle => _t('hopeSpeedDialTitle', 'Quick Access', 'Mabilisang Access');
  String get hopeEventsTile =>
      _t('hopeEventsTile', 'Events & Seminars', 'Events at Seminars');
  String get hopeEventsTileBody => _t('hopeEventsTileBody', 
        'Discover official events',
        'Tuklasin ang opisyal na events',
      );
  String get hopeDirectoryTile =>
      _t('hopeDirectoryTile', 'Official Directory', 'Opisyal na Directory');
  String get hopeDirectoryTileBody => _t('hopeDirectoryTileBody', 
        'Check recognized offices',
        'Tingnan ang kinikilalang opisina',
      );
  String get hopeContestsTile => _t('hopeContestsTile', 'Contests', 'Mga Contest');
  String get hopeContestsTileBody => _t('hopeContestsTileBody', 
        'Join creative contests',
        'Sumali sa creative contests',
      );
  String get hopeIecTile => _t('hopeIecTile', 'IEC Materials', 'IEC Materials');
  String get hopeIecTileBody => _t('hopeIecTileBody', 
        'Browse prevention materials',
        'Tingnan ang prevention materials',
      );
  String get hopeRehabTile => _t('hopeRehabTile', 'Rehab Centers', 'Rehab Centers');
  String get hopeRehabTileBody => _t('hopeRehabTileBody', 
        'Find rehab facilities',
        'Hanapin ang rehab facilities',
      );
  String get hopeLearnPhase2 => _t('hopeLearnPhase2', 
        'DAPE Learn is coming in Phase 2.',
        'Darating ang DAPE Learn sa Phase 2.',
      );
  String get hopeDirectoryTitle => _t('hopeDirectoryTitle', 'Directory', 'Directory');
  String get hopeDirectorySearchHint => _t('hopeDirectorySearchHint', 
        'Search institution/organization',
        'Maghanap ng institution/organization',
      );
  String get hopeDirectoryAll => _t('hopeDirectoryAll', 'All', 'Lahat');
  String get hopeDirectoryGov => _t('hopeDirectoryGov', "Gov't", 'Gobyerno');
  String get hopeDirectoryNgo => _t('hopeDirectoryNgo', 'NGOs', 'NGOs');
  String get hopeDirectorySchools => _t('hopeDirectorySchools', 'Schools', 'Mga Paaralan');
  String get hopeDirectoryEmpty => _t('hopeDirectoryEmpty', 
        'No organizations found.',
        'Walang nahanap na organisasyon.',
      );
  String get hopeEventsTitle => _t('hopeEventsTitle', 'Events', 'Events');
  String get hopeEventsSearchHint => _t('hopeEventsSearchHint', 
        'Search programs/events/webinars',
        'Maghanap ng programs/events/webinars',
      );
  String get hopeEventsAll => _t('hopeEventsAll', 'All', 'Lahat');
  String get hopeEventsYouth => _t('hopeEventsYouth', 'Youth', 'Kabataan');
  String get hopeEventsParents => _t('hopeEventsParents', 'Parents', 'Mga Magulang');
  String get hopeEventsCommunity => _t('hopeEventsCommunity', 'Community', 'Komunidad');
  String get hopeEventsEmpty =>
      _t('hopeEventsEmpty', 'No events found.', 'Walang nahanap na event.');
  String get hopeEventsRegister => _t('hopeEventsRegister', 'Register', 'Magparehistro');
  String get hopeEventsRegisterNow =>
      _t('hopeEventsRegisterNow', 'Register Now', 'Magparehistro Ngayon');
  String hopeEventsSlotsLeft(int n) =>
      _t('hopeEventsSlotsLeft', '$n slots left', '$n slots ang natitira', {'n': n.toString()});
  String get hopeEventAbout => _t('hopeEventAbout', 'About', 'Tungkol');
  String get hopeEventDetails => _t('hopeEventDetails', 'Details', 'Detalye');
  String get hopeEventSpeakers => _t('hopeEventSpeakers', 'Speakers', 'Mga Speaker');
  String get hopeEventFaqs => _t('hopeEventFaqs', 'FAQs', 'FAQs');
  String get hopeEventAboutHeading =>
      _t('hopeEventAboutHeading', 'About the event', 'Tungkol sa event');
  String get hopeEventForYouHeading =>
      _t('hopeEventForYouHeading', 'This is for you if you want to:', 'Para sa iyo kung gusto mong:');
  String get hopeEventWhoCanJoin =>
      _t('hopeEventWhoCanJoin', 'Who can join?', 'Sino ang pwede sumali?');
  String get hopeEventHighlights => _t('hopeEventHighlights', 'Highlights', 'Mga Highlight');
  String get hopeEventUpcoming => _t('hopeEventUpcoming', 'Upcoming', 'Paparating');
}
