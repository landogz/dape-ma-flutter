import 'app_locale.dart';

class AppStrings {
  AppStrings(this.locale);

  final AppLocale locale;

  bool get isTagalog => locale == AppLocale.tl;

  String _t(String en, String tl) => isTagalog ? tl : en;

  // Navigation
  String get navHome => _t('Home', 'Tahanan');
  String get navRehab => _t('Services', 'Serbisyo');
  String get navSaved => _t('Saved', 'Naka-save');
  String get navDiary => _t('Journal', 'Journal');
  String get navBible => _t('Kid Listo', 'Kid Listo');
  String get navKidListo => _t('Kid Listo', 'Kid Listo');
  String get navAccount => _t('Profile', 'Profile');

  // DDB Services
  String get ddbServicesTitle => _t('DDB Services', 'Mga Serbisyo ng DDB');
  String get ddbServicesSubtitle => _t(
        'Browse DDB trainings, rehab centers, IEC materials, and contests.',
        'Tingnan ang mga training, rehab center, IEC materials, at contests ng DDB.',
      );
  String get contestsTitle => _t('Contests', 'Mga Contest');
  String get contestsSubtitle => _t(
        'Browse song, poster, and video contests in one place.',
        'Tingnan ang song, poster, at video contests sa isang lugar.',
      );
  String get contestDetailTitle =>
      _t('Contest details', 'Detalye ng contest');
  String get searchContestsHint =>
      _t('Search contests...', 'Maghanap ng contest...');
  String get noContestsFound =>
      _t('No contests found', 'Walang nahanap na contest');
  String get contestCategoryAll => _t('All', 'Lahat');
  String get contestCategorySong => _t('Song', 'Kanta');
  String get contestCategoryPoster => _t('Poster', 'Poster');
  String get contestCategoryVideo => _t('Video', 'Video');
  String get posterImageUrlLabel =>
      _t('Poster image URL', 'URL ng poster image');
  String get mediaOrLyricsRequired => _t(
        'Provide a media URL or lyrics.',
        'Maglagay ng media URL o lyrics.',
      );
  String get trainingsTitle => _t('Trainings', 'Mga Training');
  String get trainingsSubtitle => _t(
        'Upcoming capacity-building and preventive education programs.',
        'Mga paparating na capacity-building at preventive education programs.',
      );
  String get rehabCentersSubtitle => _t(
        'Find treatment and rehabilitation facilities near you.',
        'Maghanap ng treatment at rehabilitation facilities.',
      );
  String get songContestTitle =>
      _t('Playlist / Song Contest', 'Playlist / Song Contest');
  String get songContestSubtitle => _t(
        'Join open contests, submit your entry, and see winners.',
        'Sumali sa open contests, mag-submit ng entry, at tingnan ang mga panalo.',
      );
  String get posterContestTitle =>
      _t('Poster-Making Contest', 'Poster-Making Contest');
  String get posterContestSubtitle => _t(
        'Submit original advocacy posters for DDB review.',
        'Mag-submit ng orihinal na advocacy poster para sa review ng DDB.',
      );
  String get posterContestDetailTitle =>
      _t('Poster contest details', 'Detalye ng poster contest');
  String get submitPosterEntry =>
      _t('Submit your poster', 'I-submit ang iyong poster');
  String get loginToSubmitPoster => _t(
        'Sign in to submit your poster',
        'Mag-sign in para mag-submit ng poster',
      );
  String get videoContestTitle =>
      _t('Video-Making Contest', 'Video-Making Contest');
  String get videoContestSubtitle => _t(
        'Submit original advocacy videos via YouTube or video URL.',
        'Mag-submit ng orihinal na advocacy video via YouTube o video URL.',
      );
  String get videoContestDetailTitle =>
      _t('Video contest details', 'Detalye ng video contest');
  String get submitVideoEntry =>
      _t('Submit your video', 'I-submit ang iyong video');
  String get loginToSubmitVideo => _t(
        'Sign in to submit your video',
        'Mag-sign in para mag-submit ng video',
      );
  String get videoUrlLabel => _t('YouTube / video URL', 'YouTube / video URL');
  String get videoUrlHint => _t(
        'Paste a YouTube or public video link',
        'I-paste ang YouTube o public video link',
      );
  String get videoUrlInvalid => _t(
        'Enter a valid http(s) URL',
        'Maglagay ng wastong http(s) URL',
      );
  String get publishedVideos =>
      _t('Published videos', 'Mga na-publish na video');
  String get noPublishedVideosYet => _t(
        'No published videos yet. Submit yours for admin review.',
        'Wala pang na-publish na video. Mag-submit para ma-review ng admin.',
      );
  String get videoSubmittedForReview => _t(
        'Video submitted for admin review.',
        'Naipasa ang video para sa review ng admin.',
      );
  String get videoSubmitFailed => _t(
        'Unable to submit video. Please try again.',
        'Hindi maipasa ang video. Subukan muli.',
      );
  String get searchVideoContestHint =>
      _t('Search video contests...', 'Maghanap ng video contest...');
  String get noVideoContestFound =>
      _t('No video contests found', 'Walang nahanap na video contest');
  String get pasteVideoUrl =>
      _t('Paste video URL', 'I-paste ang video URL');
  String get iecMaterialsTitle =>
      _t('IEC Materials (Animated)', 'IEC Materials (Animated)');
  String get iecMaterialsSubtitle => _t(
        'Browse animated IEC GIFs, images, and advocacy clips.',
        'Tingnan ang animated IEC GIF, larawan, at advocacy clips.',
      );
  String get iecMaterialDetailTitle =>
      _t('IEC material', 'IEC material');
  String get searchIecMaterialsHint =>
      _t('Search IEC materials...', 'Maghanap ng IEC materials...');
  String get noIecMaterialsFound =>
      _t('No IEC materials found', 'Walang nahanap na IEC materials');
  String get allTopics => _t('All topics', 'Lahat ng topic');
  String get allMediaTypes => _t('All media', 'Lahat ng media');
  String get aboutIecMaterial =>
      _t('About this material', 'Tungkol sa material na ito');
  String get tapToViewIec => _t('Tap to view', 'I-tap para tingnan');
  String get creatorNameLabel =>
      _t('Creator name', 'Pangalan ng creator');
  String get posterImageLabel =>
      _t('Poster image', 'Larawan ng poster');
  String get pickPosterImage =>
      _t('Choose poster from gallery', 'Pumili ng poster mula sa gallery');
  String get orPosterImageUrl =>
      _t('Or paste image URL', 'O i-paste ang image URL');
  String get publishedPosters =>
      _t('Published posters', 'Mga na-publish na poster');
  String get noPublishedPostersYet => _t(
        'No published posters yet. Submit yours for admin review.',
        'Wala pang na-publish na poster. Mag-submit para ma-review ng admin.',
      );
  String get posterSubmittedForReview => _t(
        'Poster submitted for admin review.',
        'Naipasa ang poster para sa review ng admin.',
      );
  String get posterSubmitFailed => _t(
        'Unable to submit poster. Please try again.',
        'Hindi maipasa ang poster. Subukan muli.',
      );
  String get searchPosterContestHint =>
      _t('Search poster contests...', 'Maghanap ng poster contest...');
  String get noPosterContestFound =>
      _t('No poster contests found', 'Walang nahanap na poster contest');
  String get songContestDetailTitle =>
      _t('Contest details', 'Detalye ng contest');
  String get aboutEntry => _t('About this entry', 'Tungkol sa entry');
  String get themeLabel => _t('Theme', 'Tema');
  String get lyricsLabel => _t('Lyrics', 'Lyrics');
  String get playlistType => _t('Playlist', 'Playlist');
  String get songWritingType => _t('Song writing', 'Pagsulat ng kanta');
  String get allEntryTypes => _t('All types', 'Lahat ng uri');
  String get searchSongContestHint =>
      _t('Search contests...', 'Maghanap ng contest...');
  String get noSongContestFound =>
      _t('No contests found', 'Walang nahanap na contest');
  String get openOnYoutube => _t('Open on YouTube', 'Buksan sa YouTube');
  String get openMediaLink => _t('Open media link', 'Buksan ang media link');
  String get acceptingEntries =>
      _t('Accepting entries', 'Tumanggap ng entries');
  String get contestRules => _t('Rules', 'Mga patakaran');
  String get yourEntryStatus => _t('Your entry', 'Ang iyong entry');
  String get submitContestEntry =>
      _t('Submit your entry', 'I-submit ang iyong entry');
  String get loginToSubmitEntry => _t(
        'Sign in to submit your entry',
        'Mag-sign in para mag-submit ng entry',
      );
  String get submissionsClosed =>
      _t('Submissions are closed', 'Sarado na ang pag-submit');
  String get publishedEntries =>
      _t('Published entries', 'Mga na-publish na entry');
  String get noPublishedEntriesYet => _t(
        'No published entries yet. Submit yours for admin review.',
        'Wala pang na-publish na entry. Mag-submit para ma-review ng admin.',
      );
  String get entrySubmittedForReview => _t(
        'Entry submitted for admin review.',
        'Naipasa ang entry para sa review ng admin.',
      );
  String get entrySubmitFailed => _t(
        'Unable to submit entry. Please try again.',
        'Hindi maipasa ang entry. Subukan muli.',
      );
  String get entryTypeLabel => _t('Entry type', 'Uri ng entry');
  String get entryTitleLabel => _t('Title', 'Pamagat');
  String get artistNameLabel => _t('Artist / Creator name', 'Pangalan ng artist / creator');
  String get mediaUrlLabel => _t('Media URL', 'Media URL');
  String get regionOptionalLabel => _t('Region (optional)', 'Rehiyon (opsyonal)');
  String get descriptionOptionalLabel =>
      _t('Description (optional)', 'Deskripsyon (opsyonal)');
  String get requiredField => _t('This field is required', 'Kinakailangan ang field na ito');
  String get trainingDetailTitle => _t('Training details', 'Detalye ng training');
  String get aboutTraining => _t('About this training', 'Tungkol sa training');
  String get scheduleLabel => _t('Schedule', 'Iskedyul');
  String get timeLabel => _t('Time', 'Oras');
  String get venueLabel => _t('Venue', 'Lugar');
  String get organizerLabel => _t('Organizer', 'Tagapag-organisa');
  String get slotsLabel => _t('Slots', 'Mga slot');
  String get contactLabel => _t('Contact', 'Contact');
  String get registerOrLearnMore =>
      _t('Register / Learn more', 'Magparehistro / Alamin pa');
  String get searchTrainingsHint =>
      _t('Search trainings...', 'Maghanap ng training...');
  String get allCategories => _t('All categories', 'Lahat ng kategorya');
  String get noTrainingsFound =>
      _t('No trainings found', 'Walang nahanap na training');

  // Home
  String get welcomeBack => _t('Welcome back,', 'Maligayang pagbabalik,');
  String get welcomeBackExclaim => _t('Welcome back!', 'Maligayang pagbabalik!');
  String homeHiName(String name) => _t('Hi, $name!', 'Kumusta, $name!');
  String homeGoodMorning(String name) =>
      _t('Good morning, $name', 'Magandang umaga, $name');
  String homeGoodAfternoon(String name) =>
      _t('Good afternoon, $name', 'Magandang hapon, $name');
  String homeGoodEvening(String name) =>
      _t('Good evening, $name', 'Magandang gabi, $name');
  String get homeExploreSubtitle => _t(
        'What do you like to explore today?',
        'Ano ang gusto mong tuklasin ngayon?',
      );
  String get homeSearchTopicsHint => _t(
        'Search topics, services',
        'Maghanap ng topics, serbisyo',
      );
  String get homeWhatsNew => _t("What's New?", "Ano'ng Bago?");
  String get homeWhatsNewEmpty => _t(
        'Check back soon for new courses and events.',
        'Bumalik mamaya para sa mga bagong kursong event.',
      );
  String get homeNewCoursePrefix => _t('New course:', 'Bagong kurso:');
  String get homeNewCourseTitle =>
      _t('Goals, Dreams, and You', 'Goals, Dreams, and You');
  String get homeUpcomingWebinarPrefix =>
      _t('Upcoming webinar:', 'Paparating na webinar:');
  String get homeUpcomingWebinarTitle =>
      _t('The Science of Prevention', 'The Science of Prevention');
  String get homeThoughtOfDay => _t('Thought of the Day', 'Isipin Ngayon');
  String get homeThoughtFallback => _t(
        'Small steps every day lead to a better you.',
        'Ang maliliit na hakbang araw-araw ay patungo sa mas magandang ikaw.',
      );
  String get homeFeaturedForYou =>
      _t('Featured for You', 'Itinatampok Para sa Iyo');
  String get postsPageTitle => _t('Posts', 'Mga Post');
  String get postsBrowseSubtitle => _t(
        'Browse featured stories and more from DAPE-MA.',
        'Tingnan ang mga featured stories at iba pa mula sa DAPE-MA.',
      );
  String get homeTaraExplore =>
      _t('Tara, #BeTheBIDA!', 'Tara, #BeTheBIDA!');
  String get homeDapeProgress =>
      _t('Your DAPE Progress', 'Iyong DAPE Progress');
  String get homeProgressCourses => _t('Courses', 'Mga Kurso');
  String get homeProgressLessons => _t('Lessons', 'Mga Aralin');
  String get homeProgressStreak => _t('Streak', 'Streak');
  String get bidaLearnTitle => _t('BIDA Learn', 'BIDA Learn');
  String get bidaHopeTitle => _t('BIDA Hope', 'BIDA Hope');
  String get bidaCareTitle => _t('BIDA Care', 'BIDA Care');
  String get homeExploreLearnDesc =>
      _t('Lessons & modules', 'Mga aralin at modules');
  String get homeExploreHopeDesc =>
      _t('Peer support', 'Suporta ng kapwa');
  String get homeExploreCareDesc =>
      _t('Counseling & help', 'Counseling at tulong');
  String get homeContinueLearning =>
      _t('Continue Learning', 'Ipagpatuloy ang Pag-aaral');
  String get homeContinueLearningTitle => _t(
        'Living Drug-Free, Living Strong',
        'Drug-Free at Matatag na Buhay',
      );
  String get homeStartExploring =>
      _t('Start exploring', 'Magsimulang tumuklas');
  String get startLesson => _t('Start', 'Simulan');
  String get resumeLesson => _t('Resume', 'Ipagpatuloy');
  String homeLessonProgress(int done, int total) =>
      _t('Lesson $done of $total', 'Aralin $done sa $total');
  String get homeRecentActivity =>
      _t('Recent Activity', 'Kamakailang Aktibidad');
  String get homeActivityEmptyTitle =>
      _t('No activity yet', 'Wala pang aktibidad');
  String get homeActivityEmptyBody => _t(
        'Read a lesson or article and it will show up here.',
        'Magbasa ng aralin o artikulo at lilitaw ito dito.',
      );
  String get homeMoreForYou => _t('More for you', 'Higit pa para sa iyo');
  String homeYouCompleted(String title) =>
      _t('You completed $title', 'Natapos mo ang $title');
  String homeYouRead(String title) =>
      _t('You read $title', 'Binasa mo ang $title');
  String get homeDiscover => _t('Discover', 'Tuklasin');
  String get homeNoPostsFound =>
      _t('No posts found', 'Walang nahanap na post');
  String get homeNeedToTalk => _t(
        'Need to talk to someone?',
        'Kailangan mong may kausapin?',
      );
  String get homeNeedToTalkCta => _t('Get support', 'Humingi ng tulong');
  String get askKidListoTooltip =>
      _t('Ask Kid Listo', 'Magtanong kay Kid Listo');
  String get navLearn => _t('Learn', 'Learn');
  String get navHope => _t('Hope', 'Hope');
  String get navFaq => _t('FAQ', 'FAQ');

  // Bottom nav Care tab (matches BIDA Care)
  String get navCare => _t('Care', 'Care');
  String get careTitle => _t('DAPE Care', 'DAPE Care');
  String get careSubtitle =>
      _t('Your well-being matters to us.', 'Mahalaga sa amin ang iyong well-being.');
  String get careSearchHint => _t(
        'Search resources, tips, exercises...',
        'Maghanap ng resources, tips, exercises...',
      );
  String get careHowFeeling =>
      _t('How are you feeling today?', 'Kumusta ang pakiramdam mo ngayon?');
  String get careDailyReflection =>
      _t('Daily Reflection', 'Daily Reflection');
  String get careDailyReflectionPrompt => _t(
        'What are you grateful for in your recovery journey?',
        'Ano ang iyong pinagpapasalamat sa iyong recovery journey?',
      );
  String get careStartWriting => _t('Start Writing', 'Magsulat');
  String get careCheckInNow =>
      _t('Your feelings matter. Check in now.', 'Mahalaga ang damdamin mo. Mag-check in ngayon.');
  String get careCheckedInToday =>
      _t('Thanks for checking in today.', 'Salamat sa pag-check in ngayon.');
  String get careSelectMoodFirst =>
      _t('Please select how you feel first.', 'Pumili muna kung ano ang pakiramdam mo.');
  String get careMoodSaved =>
      _t('Mood check-in saved.', 'Nai-save ang mood check-in.');
  String get careMoodSaveFailed =>
      _t('Could not save mood check-in.', 'Hindi mai-save ang mood check-in.');
  String get careSpeedDial => _t('Your Toolkit', 'Iyong Toolkit');
  String get careSpeedDialEyebrow => _t('Quick access', 'Mabilisang access');
  String get careSpeedJournal => _t('My Journal', 'Aking Journal');
  String get careSpeedJournalBody =>
      _t('Write freely. This is your safe space.', 'Sumulat nang malaya. Ito ang iyong safe space.');
  String get careSpeedToolkit => _t('Self-Care Toolkit', 'Self-Care Toolkit');
  String get careSpeedToolkitBody =>
      _t('Take care of yourself every day.', 'Alagaan ang sarili araw-araw.');
  String get careSpeedSupport => _t('Get Support', 'Kumuha ng Suporta');
  String get careSpeedSupportBody =>
      _t('Find the right help for you.', 'Hanapin ang tamang tulong para sa iyo.');
  String get careCalmCorner => _t('Calm Corner', 'Calm Corner');
  String get careCalmCornerBody => _t(
        'Take a moment for yourself. You deserve it.',
        'Maglaan ng sandali para sa sarili. Deserve mo ito.',
      );
  String get careBreathingExercise =>
      _t('Breathing Exercise', 'Breathing Exercise');
  String get careBreathingExerciseBody => _t(
        'Simple guided breathing exercise to calm your mind',
        'Simpleng guided breathing para pakalmahin ang isip',
      );
  String get careRelaxingAudio => _t('Relaxing Audio', 'Relaxing Audio');
  String get careRelaxingAudioBody => _t(
        'Listen to soothing sounds to help you relax.',
        'Makinig sa soothing sounds para makapag-relax.',
      );
  String get careGuidedMeditation =>
      _t('Guided Meditation', 'Guided Meditation');
  String get careGuidedMeditationBody => _t(
        'Follow meditations for focus, calm, and balance.',
        'Sundan ang meditation para sa focus, calm, at balance.',
      );
  String get careVisualizationExercises =>
      _t('Visualization Exercises', 'Visualization Exercises');
  String get careVisualizationExercisesBody => _t(
        'Use your imagination to reduce stress.',
        'Gamitin ang imahinasyon para mabawasan ang stress.',
      );
  String get careColorFun => _t('Color Fun', 'Color Fun');
  String get careColorFunBody =>
      _t('Print and color cute worksheets!', 'I-print at kulayan ang worksheets!');
  String get careStretchBreaks => _t('Stretch Breaks', 'Stretch Breaks');
  String get careStretchBreaksBody => _t(
        'Do short posture resets to ease tension.',
        'Maikling stretch para mabawasan ang tension.',
      );
  String get careGuidedBreathing =>
      _t('Guided Breathing', 'Guided Breathing');
  String get careStayCalmBreath => _t(
        'Stay calm and take a deep breath.',
        'Manatiling kalmado at huminga nang malalim.',
      );
  String get careStayCalmMusic => _t(
        'Stay calm and enjoy the music.',
        'Manatiling kalmado at i-enjoy ang musika.',
      );
  String get careListen => _t('Listen.', 'Makinig.');
  String get careEndSession => _t('End', 'Tapusin');
  String get carePause => _t('Pause', 'I-pause');
  String get careResume => _t('Resume', 'Ipagpatuloy');
  String get careCalmMind => _t('Calm Mind', 'Calm Mind');
  String get careCalmMindBody => _t(
        'A short meditation to help you relax, release tension, and feel at peace.',
        'Maikling meditation para makapag-relax, mag-release ng tension, at makaramdam ng kapayapaan.',
      );
  String get careWhatYoullGet => _t("What you'll get", 'Makukuha mo');
  String get careBenefitReduceStress =>
      _t('Reduce stress and anxiety', 'Bawasan ang stress at anxiety');
  String get careBenefitImproveFocus =>
      _t('Improve focus and clarity', 'Pagbutihin ang focus at clarity');
  String get careBenefitFeelCalm =>
      _t('Feel calm and relaxed', 'Makaramdam ng kalmado at relax');
  String get carePlayMeditation =>
      _t('Play Meditation', 'I-play ang Meditation');
  String get carePeacefulPlace => _t('Peaceful Place', 'Peaceful Place');
  String get careVisualizationTitle =>
      _t('Visualization', 'Visualization');
  String get careMeditationTitle => _t('Meditation', 'Meditation');
  String get carePeacefulPlaceBody => _t(
        'Use your imagination to create a safe and peaceful place in your mind.',
        'Gamitin ang imahinasyon para gumawa ng ligtas at mapayapang lugar sa isip.',
      );
  String get careInThisExercise =>
      _t('In this exercise, you will', 'Sa exercise na ito, ikaw ay');
  String get careVizImagine =>
      _t('Imagine your safe space', 'Isipin ang iyong safe space');
  String get careVizSenses =>
      _t('Engage your senses', 'Gamitin ang iyong mga pandama');
  String get careVizFeelRelaxed =>
      _t('Feel relaxed and refreshed', 'Makaramdam ng relax at refreshed');
  String get carePlayExercise => _t('Play Exercise', 'I-play ang Exercise');
  String get careColorFunIntro => _t(
        'Take a creative break. Download and print fun coloring worksheets to relax and express yourself. You can do this with a friend or family member!',
        'Mag-creative break. I-download at i-print ang coloring worksheets para mag-relax. Pwede kasama ang kaibigan o pamilya!',
      );
  String get careColorFilterAll => _t('All', 'Lahat');
  String get careColorFilterNature => _t('Nature', 'Kalikasan');
  String get careColorFilterPeople => _t('People', 'Tao');
  String get careColorFilterMessages => _t('Messages', 'Mensahe');
  String get careWorksheetDownloaded => _t(
        'Worksheet ready. Open it to print or color.',
        'Handa na ang worksheet. Buksan para i-print o kulayan.',
      );
  String get careChooseYourBreak =>
      _t('Choose Your Break', 'Piliin ang Break');
  String get careQuickStretch => _t('Quick Stretch', 'Quick Stretch');
  String get careQuickStretchBody =>
      _t('Perfect for a short break', 'Para sa maikling break');
  String get careDeskStretch => _t('Desk Stretch', 'Desk Stretch');
  String get careDeskStretchBody =>
      _t('Great for work or study breaks', 'Para sa work o study breaks');
  String get careFullBodyStretch =>
      _t('Full Body Stretch', 'Full Body Stretch');
  String get careFullBodyStretchBody =>
      _t('Feel refreshed and recharged', 'Makaramdam ng refreshed');
  String get careMorningEnergizer =>
      _t('Morning Energizer', 'Morning Energizer');
  String get careMorningEnergizerBody =>
      _t('Start your day right', 'Simulan nang tama ang araw');
  String get careSetTodaysReminder =>
      _t("Set Today's Reminder", 'I-set ang Reminder Ngayon');
  String get careStretchReminderTitle =>
      _t('Time for a stretch break!', 'Oras na para mag-stretch!');
  String get careStretchReminderBody => _t(
        'Moving your body boosts your mood and energy!',
        'Ang paggalaw ay nagpapalakas ng mood at energy!',
      );
  String get careStretchSessionHint => _t(
        'Follow along at your own pace. Stop if anything hurts.',
        'Sundan sa sariling bilis. Huminto kung may sakit.',
      );
  String get careStartStretch => _t('Start Stretch', 'Simulan ang Stretch');
  String get careSessionComplete =>
      _t('Nice work. Take a slow breath.', 'Magaling. Huminga nang dahan-dahan.');
  String get careCalmInfoTitle => _t('About this activity', 'Tungkol dito');
  String get careCalmInfoBody => _t(
        'These tools support wellbeing. They are not a substitute for professional care.',
        'Para sa wellbeing ang mga tool na ito. Hindi kapalit ng propesyonal na tulong.',
      );
  String get careStartBreathing =>
      _t('Start breathing', 'Magsimulang huminga');
  String get careStopBreathing => _t('Stop', 'Itigil');
  String get careBreatheIn => _t('Breathe In', 'Huminga');
  String get careBreatheOut => _t('Breathe Out', 'Ihininga');
  String get careBreatheHold => _t('Hold', 'Pigilin');
  String get careBreatheReady =>
      _t('Ready when you are', 'Handa ka na ba?');
  String get careToolkitTitle =>
      _t('Self-care Toolkit', 'Self-care Toolkit');
  String get careToolkitHero => _t(
        'Tools to help you understand how you feel, build healthy habits, and know when to reach out.',
        'Mga tool para unawain ang damdamin, bumuo ng healthy habits, at malaman kung kailan humingi ng tulong.',
      );
  String get careStressCheck => _t('Stress Check', 'Stress Check');
  String get careStressCheckBody =>
      _t('Understand your stress level', 'Unawain ang antas ng stress mo');
  String get careAnxietyCheck => _t('Anxiety Check', 'Anxiety Check');
  String get careAnxietyCheckBody =>
      _t('Check symptoms of anxiety', 'Suriin ang sintomas ng anxiety');
  String get careSleepQuality => _t('Sleep Quality', 'Kalidad ng Tulog');
  String get careSleepQualityBody =>
      _t('Evaluate your sleep habits', 'Suriin ang iyong tulog');
  String get careMoodTracker => _t('Mood Tracker', 'Mood Tracker');
  String get careMoodTrackerBody =>
      _t('Track your mood over time', 'Subaybayan ang iyong mood');
  String get careToolkitDisclaimer => _t(
        'Stress, anxiety, mood, and sleep checks are tools for self-reflection, not medical diagnosis.',
        'Ang stress, anxiety, mood, at sleep checks ay para sa self-reflection, hindi medikal na diagnosis.',
      );
  String get careBitsTitle => _t('Care Bits', 'Care Bits');
  String get careBitsSwipeHint =>
      _t('Swipe right for more', 'I-swipe pakanan para sa iba');
  String get careRemember => _t('Remember', 'Tandaan');
  String get careRememberHonest =>
      _t('Answer honestly', 'Sumagot nang tapat');
  String get careRememberNoWrong =>
      _t('No right or wrong responses', 'Walang tama o mali');
  String careQuestionProgress(int current, int total) =>
      _t('$current of $total questions', '$current sa $total na tanong');
  String get careNoToolkitQuestions => _t(
        'No questions available yet. Please check back soon.',
        'Wala pang tanong. Balikan mamaya.',
      );
  String get careStressIntro => _t(
        'Stress is a universal human experience. Recognizing how you feel is the first step toward helping yourself.',
        'Universal ang stress. Ang pagkilala sa pakiramdam mo ang unang hakbang para tulungan ang sarili.',
      );
  String get careAnxietyIntro => _t(
        'Anxiety is a common human experience. Recognizing your worry and tension is the first step toward managing it.',
        'Karaniwan ang anxiety. Ang pagkilala sa worry at tension ang unang hakbang para harapin ito.',
      );
  String get careAnxietyPrompt => _t(
        'Over the last two weeks, how often have you been bothered by the following problems?',
        'Sa nakaraang dalawang linggo, gaano kadalas kang nababagabag ng mga sumusunod?',
      );
  String get careSleepIntro => _t(
        'Sleep is essential for health and learning. Recognizing your sleep patterns is the first step toward improving rest.',
        'Mahalaga ang tulog para sa kalusugan at pag-aaral. Ang pagkilala sa pattern ng tulog ang unang hakbang para mapabuti ito.',
      );
  String get careInputTimeHint => _t('Input the time.', 'Ilagay ang oras.');
  String get careScaleAlmostNever => _t('Almost Never', 'Halos hindi');
  String get careScaleFairlyOften => _t('Fairly Often', 'Medyo madalas');
  String get careScaleVeryOften => _t('Very Often', 'Napakadalas');
  String get careMoodOverview => _t('Mood Overview', 'Mood Overview');
  String get careThisMonth => _t('This Month', 'Buwan na ito');
  String get careCheckInTodayCta =>
      _t('Check In Today!', 'Mag-check in ngayon!');
  String get careMoodInsightSteady => _t(
        'Your mood has been steady and generally okay. Keep up your healthy habits!',
        'Stable at okay ang mood mo. Ituloy ang healthy habits!',
      );
  String get careMoodInsightLow => _t(
        'Some tougher days showed up this month. Be gentle with yourself — support is available.',
        'May mabibigat na araw ngayong buwan. Maging mahinahon sa sarili — may available na support.',
      );
  String get careMoodInsightGreat => _t(
        'You have had many good days this month. Keep nurturing what helps you feel well.',
        'Maraming magagandang araw ngayong buwan. Ituloy ang nakakatulong sa’yo.',
      );
  String get careMoodVeryBad => _t('Very Bad', 'Sobrang hirap');
  String get careMoodBad => _t('Bad', 'Mahirap');
  String get careMoodOkay => _t('Okay', 'Okay');
  String get careGetSupportTitle => _t('Get Support', 'Kumuha ng Suporta');
  String get careGetSupportHero1 =>
      _t('You do not have to go through it alone.', 'Hindi mo kailangang mag-isa.');
  String get careGetSupportHero2 => _t(
        'If worries feel overwhelming, health professionals can provide care.',
        'Kung sobrang bigat ng alalahanin, may mga propesyonal na makakatulong.',
      );
  String get careHotlines => _t('24/7 Hotlines', '24/7 Hotlines');
  String get careHotlinesBody =>
      _t('Access immediate support any time', 'Tumawag para sa agarang tulong');
  String get careHotlinesSubtitle =>
      _t('Help is available anytime, anywhere.', 'May tulong anumang oras, saan man.');
  String get careCounseling => _t('Counseling', 'Counseling');
  String get careCounselingBody =>
      _t('Talk to a trained professional', 'Makipag-usap sa trained professional');
  String get careCrisis => _t('Crisis Support', 'Crisis Support');
  String get careCrisisBody =>
      _t('Get help in an emergency', 'Kumuha ng tulong sa emergency');
  String get careCrisisSubtitle => _t(
        'If you or someone you know is in crisis, please reach out for help.',
        'Kung ikaw o may kilala kang nasa crisis, humingi ng tulong.',
      );
  String get careCrisisUnsure =>
      _t('Unsure? These might help.', 'Hindi sigurado? Maaaring makatulong ito.');
  String get careGoToHotlines =>
      _t('Go to 24/7 Hotlines', 'Pumunta sa 24/7 Hotlines');
  String get careGoToCalmCorner =>
      _t('Go to Calm Corner', 'Pumunta sa Calm Corner');
  String get careSupportFooter => _t(
        'You are not alone. Everyone faces challenges; reaching out is a sign of strength.',
        'Hindi ka nag-iisa. Ang paghingi ng tulong ay senyales ng lakas.',
      );
  String get careBrowseRehabServices =>
      _t('Browse rehab & services', 'Tingnan ang rehab at serbisyo');
  String get careAnswerAll =>
      _t('Please answer all questions.', 'Sagutin ang lahat ng tanong.');
  String get careSaveCheck => _t('Save check-in', 'I-save ang check-in');
  String careCheckSaved(int score) =>
      _t('Saved. Your score: $score', 'Nai-save. Score mo: $score');
  String get careScaleNever => _t('Never', 'Hindi kailanman');
  String get careScaleRarely => _t('Rarely', 'Bihira');
  String get careScaleSometimes => _t('Sometimes', 'Minsan');
  String get careScaleOften => _t('Often', 'Madalas');
  String get careScaleAlways => _t('Always', 'Palagi');
  String get careQStress1 =>
      _t('I feel overwhelmed by daily tasks.', 'Nalulula ako sa pang-araw-araw na gawain.');
  String get careQStress2 =>
      _t('I have trouble relaxing.', 'Hirap akong magpahinga.');
  String get careQStress3 =>
      _t('I feel tense or on edge.', 'Pakiramdam ko ay tense o balisa.');
  String get careQAnxiety1 =>
      _t('I worry a lot about many things.', 'Marami akong inaalala.');
  String get careQAnxiety2 =>
      _t('I feel nervous or restless.', 'Nababalisa o hindi mapakali.');
  String get careQAnxiety3 =>
      _t('I avoid situations that make me anxious.', 'Iniiwasan ko ang sitwasyong nagpapabalisa.');
  String get careQSleep1 =>
      _t('I get enough restful sleep.', 'Sapat at mapayapa ang tulog ko.');
  String get careQSleep2 =>
      _t('I fall asleep easily.', 'Madali akong makatulog.');
  String get careQSleep3 =>
      _t('I wake up feeling refreshed.', 'Gising akong refreshed.');
  String get careMoodHistory => _t('Mood history', 'Kasaysayan ng mood');
  String get careNoMoodHistory =>
      _t('No check-ins yet. Log how you feel above.', 'Wala pang check-in. Mag-log muna sa itaas.');
  String get careScore => _t('Score', 'Score');
  String get loginJourneySubtitle => _t(
        'Sign in to continue your DAPE-MA journey!',
        'Mag-sign in para ituloy ang iyong DAPE-MA journey!',
      );
  String get enterEmailHint =>
      _t('Enter your email', 'Ilagay ang iyong email');
  String get enterPasswordHint =>
      _t('Enter your password', 'Ilagay ang iyong password');
  String get orDivider => _t('or', 'o');
  String get socialLoginComingSoon =>
      _t('Social login coming soon', 'Social login, malapit na');
  String get enterVerificationCode =>
      _t('Enter Verification Code', 'Ilagay ang Verification Code');
  String verificationCodeSentTo(String destination) => _t(
        "We've sent a six-digit code to $destination.",
        'Nagpadala kami ng anim na digit na code sa $destination.',
      );
  String get verifyCode => _t('Verify Code', 'I-verify ang Code');
  String get didntReceiveCode =>
      _t("Didn't receive a code?", 'Hindi nakatanggap ng code?');
  String resendIn(String time) => _t('Resend in $time', 'Mag-resend sa $time');
  String get resendCode => _t('Resend', 'Mag-resend');
  String get verificationPreviewNote => _t(
        'Verification is for preview only and is not required yet.',
        'Preview lang ang verification at hindi pa required.',
      );
  String get verificationSuccessful =>
      _t('Verification Successful!', 'Matagumpay ang Verification!');
  String get verificationSuccessfulBody => _t(
        'Your account has been verified successfully. You are all set!',
        'Matagumpay na na-verify ang iyong account. Handang-handa ka na!',
      );
  String get guest => _t('Guest', 'Bisita');
  String get searchHint =>
      _t('Search information, rehab, news...', 'Maghanap ng impormasyon, rehab, balita...');

  // Categories
  String get categoryAll => _t('All', 'Lahat');
  String get categoryDrugEffects => _t('Drug Effects', 'Epekto ng Droga');
  String get categoryRehabilitation => _t('Rehabilitation', 'Rehabilitasyon');
  String get categoryPrevention => _t('Prevention', 'Pag-iwas');
  String get categoryIec => _t(
        'Information, Education, and Communication (IEC)',
        'Impormasyon, Edukasyon, at Komunikasyon (IEC)',
      );
  String get categoryNews => _t('News', 'Balita');
  String get categoryLegal => _t('Laws & Policies', 'Batas at Patakaran');

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
  String get like => _t('Like', 'Like');
  String get comment => _t('Comment', 'Komento');
  String likesCount(int count) =>
      _t('$count ${count == 1 ? 'like' : 'likes'}', '$count ${count == 1 ? 'like' : 'likes'}');
  String commentsCount(int count) => _t(
        '$count ${count == 1 ? 'comment' : 'comments'}',
        '$count ${count == 1 ? 'komento' : 'mga komento'}',
      );
  String get savedToBookmarks => _t('Saved to bookmarks', 'Nai-save sa mga bookmark');
  String get removedFromBookmarks =>
      _t('Removed from bookmarks', 'Tinanggal sa mga bookmark');
  String get bookmarkUpdateFailed =>
      _t('Could not update bookmark. Try again.', 'Hindi ma-update ang bookmark. Subukan muli.');

  // Account / Profile
  String get accountTitle => _t('Account', 'Account');
  String get myProfileTitle => _t('My Profile', 'Aking Profile');
  String get myStats => _t('My Stats', 'Aking Stats');
  String get lessonsCompleted => _t('Lessons', 'Aralin');
  String get articlesRead => _t('Articles', 'Artikulo');
  String get eventsJoined => _t('Events', 'Events');
  String get dayStreak => _t('Streak', 'Streak');
  String get myBadges => _t('My Badges', 'Aking Mga Badge');
  String get seeAll => _t('See all', 'Tingnan lahat');
  String badgesUnlockedProgress(int earned, int total) => _t(
        '$earned/$total unlocked',
        '$earned/$total nakuha',
      );
  String get badgesPhase2Subtitle =>
      _t('Coming in Phase 2', 'Darating sa Phase 2');
  String get badgesPhase2Body => _t(
        'Badges are locked for now and will be available in Phase 2.',
        'Naka-lock ang badges sa ngayon at available sa Phase 2.',
      );
  String get badgeHealthyDecision =>
      _t('Healthy Decision Maker', 'Healthy Decision Maker');
  String get badgeEmpoweredPeer => _t('Empowered Peer', 'Empowered Peer');
  String get badgeStressBuster => _t('Stress Buster', 'Stress Buster');
  String get quickLinks => _t('Quick Links', 'Mga Shortcut');
  String get speedDial => quickLinks;
  String get savedArticles => _t('Saved Articles', 'Mga Naka-save');
  String get myCertificates => _t('My Certificates', 'Aking Mga Sertipiko');
  String get myGains => _t('My Gains', 'Aking Mga Gain');
  String get featureUnavailableNow => _t(
        'This feature is unavailable right now.',
        'Hindi available ang feature na ito sa ngayon.',
      );
  String get gotIt => _t('Got it', 'OK');
  String get dapeSettings => _t('DAPE-MA Settings', 'Mga Setting ng DAPE-MA');
  String get championBadge => _t('DAPE Champion', 'DAPE Champion');
  String get badgeEarned => _t('Earned', 'Nakuha');
  String get badgeLocked => _t('Locked', 'Naka-lock');
  String get badgeHowToEarn => _t('How to earn', 'Paano makuha');
  String get earnMoreBadgesFooter => _t(
        'Earn more badges by continuing your DAPE-MA journey!',
        'Kumita ng mas maraming badge sa iyong DAPE-MA journey!',
      );
  String get certificateOfCompletion =>
      _t('Certificate of Completion', 'Certificate of Completion');
  String get completedOn => _t('Completed on', 'Natapos noong');
  String get certificatePresentedTo =>
      _t('This certifies that', 'Pinatutunayan nito na si');
  String get certificateForCompleting =>
      _t('has successfully completed', 'ay matagumpay na nakatapos ng');
  String get earnedBadgesSection => _t('Earned Badges', 'Mga Nakuha na Badge');
  String get lockedBadgesSection => _t('Locked Badges', 'Mga Naka-lock na Badge');
  String get contestEntriesSection =>
      _t('Contest Entries', 'Mga Contest Entry');
  String get levelBeginner => _t('Beginner', 'Beginner');
  String get levelExplorer => _t('Explorer', 'Explorer');
  String get levelChampion => _t('Champion', 'Champion');
  String levelLabel(int level) => _t('Level $level', 'Level $level');
  String xpLabel(int xp) => _t('$xp XP', '$xp XP');
  String xpToNextLevel(int xp) =>
      _t('$xp XP to next level', '$xp XP papunta sa next level');
  String minReadLabel(int minutes) => _t(
        '$minutes min read',
        '$minutes min read',
      );
  String get featuredBadge => _t('Featured', 'Featured');
  String get sharePost => _t('Share', 'I-share');
  String get linkCopied => _t('Copied to clipboard', 'Nakopya sa clipboard');
  String get profileCompleteLabel =>
      _t('Profile complete', 'Kumpleto ang profile');
  String profilePercentComplete(int percent) =>
      _t('Profile $percent% complete', 'Profile $percent% kumpleto');
  String get learnerStatus => _t('Learner', 'Learner');
  String get streakCalendarHint => _t(
        'Keep journaling to grow your streak.',
        'Mag-journal araw-araw para tumaas ang streak.',
      );
  String get noCertificatesYet =>
      _t('No certificates yet', 'Wala pang sertipiko');
  String get noCertificatesBody => _t(
        'Win a contest to earn certificates here.',
        'Manalo sa contest para makakuha ng sertipiko.',
      );
  String get noGainsYet => _t('No gains yet', 'Wala pang gains');
  String get noGainsBody => _t(
        'Submit contest entries to track your gains.',
        'Mag-submit ng contest entries para makita ang iyong gains.',
      );
  String get noActivityYet => _t('Nothing here yet', 'Wala pa rito');
  String get noLessonsBody => _t(
        'Open prevention and recovery lessons to track progress.',
        'Magbasa ng prevention at recovery lessons para masubaybayan ang progreso.',
      );
  String get noArticlesBody => _t(
        'Read posts in the app to build your reading history.',
        'Magbasa ng posts sa app para mabuo ang reading history.',
      );
  String get noEventsBody => _t(
        'Join trainings or submit contest entries to track events.',
        'Sumali sa trainings o mag-submit ng contest entries.',
      );
  String get comingSoon =>
      _t('Coming soon', 'Malapit na');
  String get comingSoonBody => _t(
        'This feature will be available in a future update.',
        'Available ang feature na ito sa susunod na update.',
      );
  String get guestProfileHint => _t(
        'Sign in to track your progress and unlock profile features.',
        'Mag-sign in para masubaybayan ang progreso at ma-unlock ang profile.',
      );
  String get settingsTitle => _t('Settings', 'Mga Setting');
  String get settingsSubtitle => _t(
        'Manage your account, preferences, and privacy.',
        'Pamahalaan ang account, preferences, at privacy.',
      );
  String get languageTitle => _t('Language', 'Wika');
  String get languageSubtitle =>
      _t('Choose your preferred app language', 'Piliin ang wika ng app');
  String get signedInHint =>
      _t('Save bookmarks and submit reviews', 'Mag-save ng bookmark at magbigay ng review');
  String get youAreSignedIn => _t('You are signed in', 'Naka-sign in ka');
  String get editProfile => _t('Edit Profile', 'I-edit ang Profile');
  String get editProfileSubtitle =>
      _t('Update your personal information', 'I-update ang iyong personal na impormasyon');
  String get notificationsMenu => _t('Notifications', 'Mga Notification');
  String get notificationsMenuSubtitle => _t(
        'Manage your notification preferences',
        'Pamahalaan ang mga preference sa notification',
      );
  String get privacyPolicy => _t('Privacy Policy', 'Patakaran sa Privacy');
  String get privacyPolicySubtitle =>
      _t('Learn how we protect your data', 'Alamin kung paano namin pinoprotektahan ang data');
  String get termsOfUse => _t('Terms of Use', 'Mga Tuntunin ng Paggamit');
  String get termsOfUseSubtitle =>
      _t('Read the terms and conditions', 'Basahin ang mga tuntunin at kundisyon');
  String get accessibility => _t('Accessibility', 'Accessibility');
  String get accessibilitySubtitle =>
      _t('Explore options for ease of access', 'Tuklasin ang mga opsyon para sa madaling paggamit');
  String get aboutApp => _t('About DAPE-MA', 'Tungkol sa DAPE-MA');
  String get aboutAppSubtitle =>
      _t('App version and more', 'Bersyon ng app at iba pa');
  String get changePassword => _t('Change password', 'Palitan ang password');
  String get logOut => _t('Log Out', 'Mag-log out');
  String get logOutSubtitle =>
      _t('Sign out of your account', 'Mag-sign out sa iyong account');
  String get logoutConfirmTitle =>
      _t('Log Out of DAPE-MA?', 'Mag-log out sa DAPE-MA?');
  String get logoutConfirmBody => _t(
        'You will need to log in again to access your account.',
        'Kailangan mong mag-log in muli para ma-access ang account.',
      );
  String get memberSince => _t('Member since', 'Miyembro mula');
  String get fullNameLabel => _t('Full Name', 'Buong Pangalan');
  String get emailAddressLabel => _t('Email Address', 'Email Address');
  String get aboutMeLabel => _t('About Me', 'Tungkol sa Akin');
  String get aboutMeHint =>
      _t('Tell others a little about yourself', 'Magbahagi ng kaunti tungkol sa iyong sarili');
  String get interestsLabel => _t('Interests', 'Mga Interes');
  String get interestsHint =>
      _t('Select your interests', 'Piliin ang iyong mga interes');
  String get interestsPickerHint => _t(
        'You can select more than one. Add Other if yours is not listed.',
        'Puwedeng pumili ng higit sa isa. Magdagdag ng Other kung wala sa listahan.',
      );
  String get interestsOther => _t('Other', 'Iba pa');
  String get interestsOtherHint =>
      _t('Describe your interest', 'Ilarawan ang iyong interes');
  String get interestsOtherPlaceholder =>
      _t('e.g. Sports, Music, Art', 'hal. Sports, Music, Art');
  String get interestsOtherRequired => _t(
        'Please type your custom interest.',
        'Ilagay ang iyong custom interest.',
      );
  String get notificationSettingsTitle =>
      _t('Notification Settings', 'Mga Setting ng Notification');
  String get allowNotifications =>
      _t('Allow Notifications', 'Payagan ang Mga Notification');
  String get allowNotificationsBody => _t(
        'Get updates and reminders from your DAPE-MA application.',
        'Makatanggap ng updates at paalala mula sa DAPE-MA.',
      );
  String get notificationTypes =>
      _t('NOTIFICATION TYPES', 'MGA URI NG NOTIFICATION');
  String get notifyArticles =>
      _t('New articles and lessons', 'Mga bagong artikulo at aralin');
  String get notifyArticlesBody =>
      _t('When new resources are published', 'Kapag may bagong nilathalang resources');
  String get notifyAchievements => _t('Achievements', 'Mga Achievement');
  String get notifyAchievementsBody =>
      _t('Badges, completed lessons, goals', 'Mga badge, natapos na aralin, goals');
  String get notifyEvents =>
      _t('Events and seminars', 'Mga event at seminar');
  String get notifyEventsBody =>
      _t('Upcoming events and reminders', 'Mga paparating na event at paalala');
  String get notifyUpdates =>
      _t('Application updates', 'Mga update ng application');
  String get notifyUpdatesBody =>
      _t("When it's time for you to do an update", 'Kapag oras nang mag-update');
  String get quietHours =>
      _t('QUIET HOURS (optional)', 'QUIET HOURS (opsyonal)');
  String get quietHoursLabel =>
      _t("Don't send between", 'Huwag magpadala sa pagitan ng');
  String get quietHoursRange => _t('10:00 PM - 7:00 AM', '10:00 PM - 7:00 AM');
  String get changeAnytime =>
      _t('You can change these anytime.', 'Maaari mong baguhin ang mga ito anumang oras.');
  String get notificationsTitle => _t('Notifications', 'Mga Notification');
  String get notificationsToday => _t('Today', 'Ngayon');
  String get notificationsEarlier => _t('Earlier', 'Mas Maaga');
  String get markAllRead => _t('Mark all as read', 'Markahan lahat bilang nabasa');
  String get notificationsLoadFailed =>
      _t('Failed to load notifications.', 'Hindi ma-load ang mga notification.');
  String get notificationsMarkAllFailed =>
      _t('Could not mark all as read.', 'Hindi ma-markahan ang lahat bilang nabasa.');
  String get notificationsOpenFailed =>
      _t('Could not open this notification.', 'Hindi mabuksan ang notification na ito.');
  String get notificationsEmptyTitle =>
      _t('No notifications yet', 'Wala pang notification');
  String get notificationsEmptyBody => _t(
        'Replies, likes, lessons, and new posts will appear here.',
        'Ang mga reply, like, aralin, at bagong post ay lilitaw dito.',
      );
  String get notifTypeNewLesson =>
      _t('New lesson published', 'May bagong aralin');
  String get notifTypeCompletedLesson =>
      _t('Completed a lesson', 'Natapos ang isang aralin');
  String get notifTypeSeminar =>
      _t('Seminar invitation', 'Imbitasyon sa seminar');
  String get notifTypeGoals => _t('Goals progress', 'Progreso ng goals');
  String get notifTypeBadges => _t('Badges unlocked', 'May bagong badge');
  String get notifTypeReply => _t('New reply', 'May bagong reply');
  String get notifTypeComment => _t('New comment', 'May bagong komento');
  String get notifTypeLiked => _t('Post liked', 'May nag-like sa post');
  String get notifTypeAdminPush =>
      _t('Announcement', 'Anunsyo');
  String get notifTypeGeneral => _t('Notification', 'Notification');
  String get privacyIntro => _t(
        'Your privacy matters to us. Read our Privacy Policy to learn how we protect your information.',
        'Mahalaga sa amin ang iyong privacy. Basahin ang aming Patakaran sa Privacy.',
      );
  String get privacyBody => _t(
        'DAPE-MA may collect account details, learning activity, bookmarks, device information, and feedback you submit so we can deliver content, improve services, and support your recovery journey.\n\nWe use this information to personalize your experience, send relevant updates, and keep the platform secure. We do not sell your personal data.\n\nYou may request access, correction, or deletion of your information, and you may withdraw consent where applicable. Educational content is intended for guidance and should be used with appropriate professional or parental support when needed.\n\nFor privacy concerns, contact info@ddb.gov.ph.',
        'Maaaring mangolekta ang DAPE-MA ng detalye ng account, aktibidad sa pag-aaral, bookmark, impormasyon ng device, at feedback upang makapaghatid ng nilalaman at mapabuti ang serbisyo.\n\nGinagamit namin ang impormasyong ito para sa mas angkop na karanasan, mga update, at seguridad. Hindi namin ibinebenta ang iyong personal na data.\n\nMaaari kang humiling ng access, pagwawasto, o pagbura ng iyong impormasyon. Para sa mga concern sa privacy, makipag-ugnayan sa info@ddb.gov.ph.',
      );
  String get termsIntro => _t('Be informed.', 'Maging may kaalaman.');
  String get termsSubtitle => _t(
        'Read the terms and conditions for using the DAPE-MA application.',
        'Basahin ang mga tuntunin at kundisyon sa paggamit ng DAPE-MA.',
      );
  String get termsBody => _t(
        'By using DAPE-MA, you agree to use the app responsibly and lawfully. Do not misuse content, attempt unauthorized access, copy or modify the application, or submit harmful or false information.\n\nContent is provided for information and education. It does not replace professional medical, legal, or counseling advice.\n\nWe may update these Terms of Use from time to time. Continued use of the app after updates means you accept the revised terms.\n\nFor questions or concerns regarding these Terms of Use, please contact us at info@ddb.gov.ph.',
        'Sa paggamit ng DAPE-MA, sumasang-ayon kang gamitin ang app nang responsable at ayon sa batas. Huwag abusuhin ang nilalaman o subukang mag-access nang walang pahintulot.\n\nAng nilalaman ay para sa impormasyon at edukasyon. Hindi ito kapalit ng propesyonal na payo.\n\nMaaaring i-update ang mga Tuntunin. Ang patuloy na paggamit ay nangangahulugang tinatanggap mo ang mga pagbabago.\n\nPara sa katanungan, makipag-ugnayan sa info@ddb.gov.ph.',
      );
  String get accessibilityIntro => _t(
        'We are here to make learning inclusive for everyone.',
        'Nandito kami para gawing inklusibo ang pag-aaral para sa lahat.',
      );
  String get textSize => _t('Text Size', 'Laki ng Teksto');
  String get textSizeBody =>
      _t('Adjust the size of text', 'Ayusin ang laki ng teksto');
  String get darkMode => _t('Dark Mode', 'Dark Mode');
  String get darkModeBody =>
      _t('Reduce eye strain in low light', 'Bawasan ang strain ng mata sa madilim');
  String get reduceMotion => _t('Reduce Motion', 'Bawasan ang Motion');
  String get reduceMotionBody =>
      _t('Minimize animation and motion effects', 'Bawasan ang animation at motion effects');
  String get highContrast => _t('High Contrast', 'High Contrast');
  String get highContrastBody =>
      _t('Increase contrast for better visibility', 'Dagdagan ang contrast para mas madaling makita');
  String get readAloud => _t('Read Articles Aloud', 'Basahin nang Malakas');
  String get readAloudBody =>
      _t('Listen to articles and lessons', 'Makinig sa mga artikulo at aralin');
  String get listenToArticle => _t('Listen', 'Makinig');
  String get stopListening => _t('Stop', 'Ihinto');
  String get captions => _t('Captions', 'Mga Caption');
  String get captionsBody =>
      _t('Enable captions for videos', 'I-enable ang captions para sa video');
  String get accessibilityFooter => _t(
        'Accessibility is about inclusion. These settings help make DAPE-MA comfortable, easy to use, and supportive for everyone.',
        'Ang accessibility ay tungkol sa inklusyon. Tinutulungan ng mga setting na ito na gawing komportable at madaling gamitin ang DAPE-MA.',
      );
  String get aboutTagline => _t(
        'Dangerous Drugs Board Advocacy and Prevention Education Mobile App',
        'Dangerous Drugs Board Advocacy and Prevention Education Mobile App',
      );
  String get versionLabel => _t('Version', 'Bersyon');
  String get buildLabel => _t('Build', 'Build');
  String get developersLabel => _t('Developers', 'Mga Developer');
  String get contactUsLabel => _t('Contact Us', 'Makipag-ugnayan');
  String get aboutCopyright =>
      _t('2026. DAPE-MA. All rights reserved.', '2026. DAPE-MA. All rights reserved.');
  String get welcomeTitle => _t('Welcome to DAPE-MA', 'Maligayang pagdating sa DAPE-MA');
  String get welcomeBody => _t(
        'Sign in or create an account to save bookmarks and submit reviews.',
        'Mag-sign in o gumawa ng account para mag-save ng bookmark at mag-review.',
      );
  String get login => _t('Login', 'Mag-login');
  String get register => _t('Register', 'Magrehistro');
  String get forgotPassword => _t('Forgot password?', 'Nakalimutan ang password?');
  String get profileUpdated => _t('Profile updated', 'Na-update ang profile');
  String get nameRequired => _t('Name is required', 'Kailangan ang pangalan');
  String get updateFailed =>
      _t('Update failed. Please try again.', 'Hindi na-update. Subukan muli.');
  String get changePhoto => _t('Change photo', 'Palitan ang larawan');
  String get name => _t('Name', 'Pangalan');
  String get save => _t('Save', 'I-save');
  String get currentPasswordRequired =>
      _t('Current password is required', 'Kailangan ang kasalukuyang password');
  String get passwordMinLength =>
      _t('New password must be at least 6 characters', 'Ang bagong password ay dapat 6 character');
  String get passwordsDoNotMatch =>
      _t('New passwords do not match', 'Hindi magkatugma ang mga bagong password');
  String get passwordUpdated =>
      _t('Password updated successfully', 'Matagumpay na na-update ang password');
  String get passwordUpdateFailed => _t(
        'Failed to update password. Check current password.',
        'Hindi na-update ang password. Suriin ang kasalukuyang password.',
      );
  String get currentPassword => _t('Current password', 'Kasalukuyang password');
  String get newPassword => _t('New password', 'Bagong password');
  String get confirmNewPassword => _t('Confirm new password', 'Kumpirmahin ang bagong password');
  String get updatePassword => _t('Update password', 'I-update ang password');

  // Auth
  String get signIn => _t('Sign in', 'Mag-sign in');
  String get email => _t('Email', 'Email');
  String get password => _t('Password', 'Password');
  String get emailRequired => _t('Email is required', 'Kailangan ang email');
  String get passwordRequired => _t('Password is required', 'Kailangan ang password');
  String get loginFailed =>
      _t('Login failed. Please check your credentials.', 'Hindi matagumpay ang login. Suriin ang credentials.');
  String get noAccount => _t("Don't have an account? ", 'Wala pang account? ');
  String get fullName => _t('Full name', 'Buong pangalan');
  String get confirmPassword => _t('Confirm password', 'Kumpirmahin ang password');
  String get createAccount => _t('Create account', 'Gumawa ng account');
  String get continueLabel => _t('Continue', 'Magpatuloy');
  String get alreadyHaveAccount => _t('Already have an account? ', 'May account na? ');

  // Registration onboarding (mockup-aligned, DAPE-MA branding)
  String get regGetStartedTitle => _t('Get Started', 'Magsimula');
  String get regGetStartedSubtitle => _t(
        'Create an account to start your DAPE-MA journey!',
        'Gumawa ng account para simulan ang iyong DAPE-MA journey!',
      );
  String get regContinueGoogle =>
      _t('Continue with Google', 'Magpatuloy gamit ang Google');
  String get regContinueFacebook =>
      _t('Continue with Facebook', 'Magpatuloy gamit ang Facebook');
  String get regContinueApple =>
      _t('Continue with Apple', 'Magpatuloy gamit ang Apple');
  String get regNicknameTitlePrefix => _t('What should we call ', 'Ano ang itatawag namin sa ');
  String get regNicknameTitleHighlight => _t('you', 'iyo');
  String get regNicknameTitleSuffix => _t('?', '?');
  String get regNicknameSubtitle => _t(
        'We’ll use this to personalize your experience.',
        'Gagamitin namin ito para i-personalize ang iyong karanasan.',
      );
  String get regNicknameHint => _t('Type your nickname', 'I-type ang iyong palayaw');
  String get regNicknameHelper =>
      _t('You can change this anytime.', 'Maaari mong baguhin ito anytime.');
  String get regNicknameRequired =>
      _t('Please enter a nickname.', 'Maglagay ng palayaw.');
  String get regOptionalLabel => _t('OPTIONAL', 'OPSYONAL');
  String get regPronounsTitle =>
      _t('What are your pronouns?', 'Ano ang iyong mga panghalip?');
  String get regPronounsSubtitle => _t(
        'This helps us create a respectful and inclusive experience.',
        'Nakakatulong ito para sa magalang at inklusibong karanasan.',
      );
  String regPronounLabel(String key) => switch (key) {
        'she_her' => _t('She/Her', 'She/Her'),
        'he_him' => _t('He/Him', 'He/Him'),
        'they_them' => _t('They/Them', 'They/Them'),
        'ze_hir' => _t('Ze/Hir', 'Ze/Hir'),
        'prefer_not' => _t('Prefer not to say', 'Ayaw sabihin'),
        'others' => _t('Others', 'Iba pa'),
        _ => key,
      };
  String get regBirthdayTitle =>
      _t("When's your birthday?", 'Kailan ang iyong kaarawan?');
  String get regBirthdaySubtitle => _t(
        'We use your age to recommend appropriate content and programs.',
        'Ginagamit ang edad para magrekomenda ng angkop na content at programa.',
      );
  String get regBirthdayHint => _t('MM / DD / YYYY', 'MM / DD / YYYY');
  String get regBirthdayRequired =>
      _t('Please select your birthday.', 'Piliin ang iyong kaarawan.');
  String get regPersonaTitle =>
      _t('Which best describes you?', 'Alin ang pinakakatugma sa iyo?');
  String get regPersonaSubtitle => _t(
        'This helps us tailor the DAPE-MA app to your needs.',
        'Nakakatulong ito para iangkop ang DAPE-MA app sa iyong pangangailangan.',
      );
  String get regPersonaRequired =>
      _t('Please select one option.', 'Pumili ng isang opsyon.');
  String regPersonaLabel(String key) => switch (key) {
        'student' => _t('Student', 'Estudyante'),
        'parent' => _t('Parent', 'Magulang'),
        'teacher' => _t('Teacher', 'Guro'),
        'youth_leader' => _t('Youth Leader', 'Youth Leader'),
        'health_worker' => _t('Health Worker', 'Health Worker'),
        'concerned_citizen' => _t('Concerned Citizen', 'Concerned Citizen'),
        _ => key,
      };
  String get regInterestsTitle =>
      _t('What matters most to you?', 'Ano ang pinakamahalaga sa iyo?');
  String get regInterestsSubtitle => _t(
        'Choose among these interests. We’ll personalize your feed.',
        'Pumili mula sa mga interes na ito. Ipa-personalize namin ang iyong feed.',
      );
  String get regInterestsRequired =>
      _t('Select at least one interest.', 'Pumili ng kahit isang interes.');
  String regInterestLabel(String key) => switch (key) {
        'knowledge' => _t('Knowledge', 'Kaalaman'),
        'community' => _t('Community', 'Komunidad'),
        'wellness' => _t('Wellness', 'Wellness'),
        'stories' => _t('Stories', 'Mga Kwento'),
        'support' => _t('Support', 'Suporta'),
        'events' => _t('Events', 'Mga Event'),
        'opportunities' => _t('Opportunities', 'Mga Oportunidad'),
        'advocacy' => _t('Advocacy', 'Advocacy'),
        _ => key,
      };
  String regInterestBody(String key) => switch (key) {
        'knowledge' => _t(
              'Learn about drugs, life skills, and making informed decisions.',
              'Matuto tungkol sa drugs, life skills, at matalinong desisyon.',
            ),
        'community' => _t(
              'Connect, share, and support one another!',
              'Makipag-ugnayan, magbahagi, at suportahan ang isa’t isa!',
            ),
        'wellness' => _t(
              'Take care of your well-being and mental health.',
              'Alagaan ang iyong well-being at mental health.',
            ),
        'stories' => _t(
              'Read inspiring stories and inspire others with yours.',
              'Magbasa ng inspirasyon at magbahagi ng iyong kwento.',
            ),
        'support' => _t(
              'Find help and resources when you or someone needs it.',
              'Maghanap ng tulong at resources kung kailangan.',
            ),
        'events' => _t(
              'Join events and activities in your community.',
              'Sumali sa mga event at aktibidad sa komunidad.',
            ),
        'opportunities' => _t(
              'Explore scholarships and career opportunities.',
              'Tuklasin ang scholarships at career opportunities.',
            ),
        'advocacy' => _t(
              'Be a voice for change through your own ways.',
              'Maging boses ng pagbabago sa iyong sariling paraan.',
            ),
        _ => '',
      };
  String get regSuccessTitlePrefix =>
      _t("You’re all set to ", 'Handa ka na sa ');
  String get regSuccessTitleHighlight => _t('DAPE-MA', 'DAPE-MA');
  String get regSuccessTitleSuffix =>
      _t(' best you can be!', ' nang buong-buo!');
  String get regFeatureLearnTitle => _t('DAPE Learn', 'DAPE Learn');
  String get regFeatureLearnBody =>
      _t('Discover knowledge and build skills!', 'Matuto at magpaunlad ng skills!');
  String get regFeatureHopeTitle => _t('DAPE Hope', 'DAPE Hope');
  String get regFeatureHopeBody => _t(
        'Connect with others and aspire together!',
        'Makipag-ugnayan at maghangad nang sama-sama!',
      );
  String get regFeatureCareTitle => _t('DAPE Care', 'DAPE Care');
  String get regFeatureCareBody => _t(
        'Take care of your mind and well-being!',
        'Alagaan ang isip at well-being mo!',
      );
  String get regSuccessReady => _t(
        'Your personalized experience is ready!',
        'Handa na ang iyong personalized na karanasan!',
      );
  String get regSuccessCtaLearn => _t('Learn', 'Learn');
  String get regSuccessCtaMid => _t(', ', ', ');
  String get regSuccessCtaHope => _t('hope', 'hope');
  String get regSuccessCtaAnd => _t(', and ', ', at ');
  String get regSuccessCtaCare => _t('care', 'care');
  String get regSuccessCtaEnd => _t(' now!', ' ngayon!');
  String get regOnboardingFailed => _t(
        'Could not save your preferences. Please try again.',
        'Hindi ma-save ang iyong preferences. Subukan muli.',
      );
  String get resetPassword => _t('Reset password', 'I-reset ang password');
  String get sendResetLink => _t('Send reset link', 'Ipadala ang reset link');
  String get resetInstructions => _t(
        'Enter your email and we will send password reset instructions.',
        'Ilagay ang email at padadalhan ka namin ng mga tagubilin sa pag-reset ng password.',
      );
  String get resetSuccess => _t(
        'Password reset instructions have been sent to your email.',
        'Naipadala na ang mga tagubilin sa pag-reset ng password sa iyong email.',
      );
  String get resetFailed =>
      _t('Unable to send reset link. Please try again.', 'Hindi maipadala ang reset link. Subukan muli.');
  String get backToLogin => _t('Back to Login', 'Bumalik sa Login');
  String get authAgreePrefix => _t(
        'By continuing, you agree to our ',
        'Sa pagpapatuloy, sumasang-ayon ka sa aming ',
      );
  String get authAgreeAnd => _t(' and ', ' at ');

  // Bookmarks
  String get bookmarksTitle => _t('Bookmarks', 'Mga Bookmark');
  String bookmarksCountLabel(int count) => _t(
        '$count saved',
        '$count naka-save',
      );
  String get searchBookmarksHint =>
      _t('Search bookmarks...', 'Maghanap sa bookmarks...');
  String get noBookmarksYet =>
      _t('No saved posts yet', 'Wala pang naka-save na post');
  String get noBookmarksBody => _t(
        'Tap the bookmark icon on any post to save it here for later.',
        'Pindutin ang bookmark icon sa post para i-save dito.',
      );
  String get noSearchResults => _t('No matches found', 'Walang nahanap');
  String get noSearchResultsBody => _t(
        'Try a different title or category.',
        'Subukan ang ibang pamagat o category.',
      );
  String activityItemsCount(int count) => _t(
        '$count ${count == 1 ? 'item' : 'items'}',
        '$count ${count == 1 ? 'item' : 'mga item'}',
      );

  // Rehab
  String get rehabCentersTitle => _t('Rehab Centers', 'Mga Rehab Center');
  String get allRegions => _t('All regions', 'Lahat ng rehiyon');
  String get searchRehabHint => _t('Search rehab centers...', 'Maghanap ng rehab center...');

  // Reviews
  String get rateAndReview => _t('Rate & Review', 'Mag-rate at Mag-review');
  String get updateYourRating => _t('Update your rating', 'I-update ang iyong rating');
  String get noRatingsYet => _t('No ratings yet', 'Wala pang rating');
  String ratingsCount(int count) => _t(
        '$count ${count == 1 ? 'rating' : 'ratings'}',
        '$count ${count == 1 ? 'rating' : 'mga rating'}',
      );
  String get ratingSubmitted => _t('Rating submitted', 'Naipasa ang rating');
  String get submitRating => _t('Submit rating', 'Ipasa ang rating');
  String get chooseRating =>
      _t('Tap a star to choose your rating.', 'Pindutin ang bituin para pumili ng rating.');
  String get commentOptional => _t('Comment (optional)', 'Komento (opsyonal)');

  // Comments
  String get writeComment => _t('Write a comment...', 'Sumulat ng komento...');
  String get reply => _t('Reply', 'Tumugon');
  String get replyingTo => _t('Replying to', 'Tumutugon kay');
  String get edit => _t('Edit', 'I-edit');
  String get deleteAction => _t('Delete', 'Burahin');

  String loginRequired(String action) => _t(
        'Please log in to $action.',
        'Mag-log in muna para $action.',
      );

  // Registration
  String get registrationFailed =>
      _t('Registration failed. Please check your details.', 'Hindi matagumpay ang pagrehistro. Suriin ang mga detalye.');
  String get passwordMinSix =>
      _t('Password must be at least 8 characters', 'Ang password ay dapat hindi bababa sa 8 character');

  // Bookmarks extras
  String get bookmarkRemoveFailed =>
      _t('Could not remove bookmark. Try again.', 'Hindi matanggal ang bookmark. Subukan muli.');

  // Rehab extras
  String get searchRehabByHint =>
      _t('Search by name, address, or province', 'Maghanap ayon sa pangalan, address, o lalawigan');
  String get noRehabFound => _t('No rehab centers found', 'Walang nahanap na rehab center');
  String get tryDifferentSearch =>
      _t('Try a different region or search', 'Subukan ang ibang rehiyon o paghahanap');
  String get checkBackLater =>
      _t('Check back later for listings', 'Bumalik muli mamaya para sa mga listahan');
  String get regionLabel => _t('Region', 'Rehiyon');

  // Post detail
  String get commentPosted => _t('Comment posted', 'Naipost ang komento');
  String get replyPosted => _t('Reply posted', 'Naipost ang tugon');
  String get commentDeleted => _t('Comment deleted', 'Nabura ang komento');
  String get commentUpdated => _t('Comment updated', 'Na-update ang komento');
  String ratingAverageSummary(double average, int count) =>
      '${average.toStringAsFixed(1)} · ${ratingsCount(count)}';
  String get deleteCommentTitle => _t('Delete comment?', 'Burahin ang komento?');
  String get deleteCommentBody =>
      _t('This comment will be removed permanently.', 'Permanenteng mabubura ang komentong ito.');
  String get cancel => _t('Cancel', 'Kanselahin');
  String get commentsTitle => _t('Comments', 'Mga Komento');
  String get commentsDisabledTitle =>
      _t('Comments are turned off', 'Naka-off ang mga komento');
  String get commentsDisabledBody => _t(
        'The author has disabled comments on this post.',
        'Naka-disable ang mga komento sa post na ito.',
      );
  String get loadPreviousComments =>
      _t('Load previous comments...', 'I-load ang mga naunang komento...');
  String get retry => _t('Retry', 'Subukan muli');
  String get noCommentsYet =>
      _t('No comments yet. Be the first to comment.', 'Wala pang komento. Ikaw ang unang magkomento.');
  String get noCommentsEmptyTitle =>
      _t('No comments yet', 'Wala pang komento');
  String get noCommentsEmptyBody => _t(
        'Be the first to share your thoughts.',
        'Ikaw ang unang magbahagi ng iyong saloobin.',
      );
  String get tapStarsToRate =>
      _t('Tap a star to rate', 'Mag-tap ng bituin para mag-rate');
  String get writeReply => _t('Write a reply...', 'Sumulat ng tugon...');
  String youRatedStars(int rating) => _t(
        'You rated this $rating star${rating == 1 ? '' : 's'}',
        'Ni-rate mo ito ng $rating bituin',
      );

  // Review sheet
  String get rateThisContent => _t('Rate this content', 'I-rate ang nilalamang ito');

  // Comment edit
  String get editComment => _t('Edit comment', 'I-edit ang komento');
  String get commentCannotBeEmpty =>
      _t('Comment cannot be empty', 'Hindi maaaring walang laman ang komento');
  String get updateCommentHint =>
      _t('Update your comment...', 'I-update ang iyong komento...');
  String get saveChanges => _t('Save changes', 'I-save ang mga pagbabago');
  String get commentUpdateFailed =>
      _t('Could not update comment. Try again.', 'Hindi ma-update ang komento. Subukan muli.');

  // Errors (engagement)
  String get serverUpdateRequired => _t(
        'Likes and comments need the latest server update. Deploy Laravel and run php artisan migrate.',
        'Kailangan ng pinakabagong server update ang likes at komento.',
      );
  String get ownCommentsOnly =>
      _t('You can only manage your own comments.', 'Maaari mo lang pamahalaan ang sarili mong komento.');
  String get noInternet =>
      _t('No internet connection. Check your network and try again.',
          'Walang internet. Suriin ang network at subukan muli.');
  String actionFailed(String action) =>
      _t('Could not $action. Try again.', 'Hindi ma-$action. Subukan muli.');

  String get justNow => _t('Just now', 'Ngayon lang');

  String authorPost(String name) => _t("$name's Post", 'Post ni $name');

  // Kid Listo Says (motivational quotes)
  String get dailyVerseTitle => _t('Kid Listo Says', 'Kid Listo Says');
  String get kidListoSaysTitle => _t('Kid Listo Says', 'Kid Listo Says');
  String get kidListoMotivationalTagline => _t(
        'A daily motivational quote for a drug-free youth',
        'Araw-araw na motivational quote para sa drug-free youth',
      );
  String get kidListoMotivationalBadge =>
      _t('Motivational Quote', 'Motivational Quote');
  String get anotherKidListoQuote =>
      _t('Another Kid Listo Quote', 'Ibang Quote ni Kid Listo');
  String get kidListoQuoteFallback => _t(
        'Kid Listo says: Choose courage over comfort. A drug-free life starts with one brave decision today.',
        'Sabi ni Kid Listo: Piliin ang tapang kaysa ginhawa. Nagsisimula ang drug-free life sa isang matapang na desisyon ngayon.',
      );
  String get todaysScripture => _t("Today's quote", 'Quote ngayon');
  String kidListoDayLabel(int day, int total) => _t(
        'Day $day of $total',
        'Araw $day sa $total',
      );
  String get skip => _t('Skip', 'Laktawan');
  String get close => _t('Close', 'Isara');
  String get done => _t('Done', 'Tapos');
  String get continueToApp => _t('Continue to DAPE-MA', 'Magpatuloy sa DAPE-MA');
  String get openBible => _t('Open Kid Listo', 'Buksan ang Kid Listo');
  String get openKidListoBible =>
      _t('Open Kid Listo', 'Buksan ang Kid Listo');
  String get dailyVerseFallback => _t(
        'Kid Listo says: Choose courage over comfort. A drug-free life starts with one brave decision today.',
        'Sabi ni Kid Listo: Piliin ang tapang kaysa ginhawa. Nagsisimula ang drug-free life sa isang matapang na desisyon ngayon.',
      );
  String get dailyVerseReferenceFallback => _t('Kid Listo', 'Kid Listo');

  // Legacy Bible labels kept for unused screens
  String get bibleTitle => _t('Kid Listo Says', 'Kid Listo Says');
  String get searchBibleBooks => _t('Search books...', 'Maghanap ng aklat...');
  String get oldTestament => _t('Old Testament', 'Lumang Tipan');
  String get newTestament => _t('New Testament', 'Bagong Tipan');
  String get noBibleBooksFound => _t('No books found', 'Walang nahanap na aklat');
  String get bibleLoadFailed =>
      _t('Could not load passage. Try again.', 'Hindi ma-load ang talata. Subukan muli.');
  String get bibleLanguageNote => _t(
        'Kid Listo quotes follow your app language (English or Tagalog).',
        'Sinusunod ng Kid Listo quotes ang wika ng app (English o Tagalog).',
      );
  String chaptersLabel(int count) => _t(
        '$count chapters',
        '$count kabanata',
      );

  // Journal (API/code still use diary-*)
  String get diaryTitle => _t('Journal', 'Journal');
  String get writeToday => _t('Start Writing', 'Magsimulang sumulat');
  String get diaryLoginRequired => _t(
        'Sign in to keep your private daily journal.',
        'Mag-sign in para sa iyong pribadong journal.',
      );
  String get diaryEmpty => _t(
        'No journal entries yet. Start writing to begin.',
        'Wala pang journal entry. Magsimulang sumulat para magsimula.',
      );
  String get diaryEditorTitle => _t('Journal entry', 'Journal entry');
  String get diaryTitleHint => _t('Title (optional)', 'Pamagat (opsyonal)');
  String get diaryBodyHint =>
      _t('What happened today?', 'Ano ang nangyari ngayon?');
  String get diaryBodyRequired => _t(
        'Add at least one reflection field before saving.',
        'Magdagdag muna ng kahit isang refleksiyon bago i-save.',
      );
  String get diarySaved => _t('Journal entry saved', 'Nai-save ang journal entry');
  String get diarySaveFailed =>
      _t('Could not save journal entry.', 'Hindi mai-save ang journal entry.');
  String get deleteDiaryTitle =>
      _t('Delete journal entry?', 'Burahin ang journal entry?');
  String get deleteDiaryBody =>
      _t('This entry will be removed permanently.', 'Permanenteng mabubura ang entry na ito.');
  String get diaryDeleteFailed =>
      _t('Could not delete journal entry.', 'Hindi mabura ang journal entry.');

  String get journalYourEntries => _t('Your Entries', 'Mga Entry Mo');
  String get journalDailyReflection =>
      _t('Daily Reflection', 'Araw-araw na Refleksiyon');
  String get journalNoWrittenNotes =>
      _t('(No written notes)', '(Walang nakasulat na notes)');
  String journalWritingThroughSky(String sky) => _t(
        "Writing through today's $sky",
        'Sumusulat sa $sky ngayon',
      );
  String journalStepOf(int current, int total) =>
      _t('$current OF $total', '$current SA $total');
  String get journalNext => _t('Next', 'Susunod');
  String get journalSaveEntry => _t('Save Entry', 'I-save ang Entry');
  String get journalSkyTitle =>
      _t("How's your sky today?", 'Kumusta ang langit mo ngayon?');
  String get journalSkySubtitle => _t(
        'Pick the weather that matches your inner world.',
        'Piliin ang panahon na tumutugma sa iyong loob.',
      );
  String get journalFeelingsTitle =>
      _t('What are you feeling?', 'Ano ang nararamdaman mo?');
  String get journalFeelingsSubtitle => _t(
        'Select all that apply — or add your own.',
        'Piliin ang lahat na angkop — o magdagdag ng sarili.',
      );
  String get journalAddYourOwn =>
      _t('Add your own', 'Idagdag ang sa iyo');
  String get journalImpactTitle =>
      _t('What shaped your day?', 'Ano ang humubog sa araw mo?');
  String get journalImpactSubtitle => _t(
        'Choose the area that mattered most today.',
        'Piliin ang bahagi na pinakamahalaga ngayon.',
      );
  String get journalNotesTitle =>
      _t('Anything else to note?', 'May iba pa bang nais isulat?');
  String get journalNotesSubtitle => _t(
        'Optional free notes — write as much or as little as you need.',
        'Opsyonal na notes — magkano man ang isulat mo.',
      );
  String get journalGratitudeLabel =>
      _t('Gratitude (optional)', 'Pasasalamat (opsyonal)');
  String get journalGratitudeHint => _t(
        "Today I'm grateful for…",
        'Ngayong araw, nagpapasalamat ako sa…',
      );
  String journalGratitudeHintNamed(String name) => _t(
        "$name, what are you grateful for today?",
        '$name, ano ang pinapasalamatan mo ngayon?',
      );
  String get journalSummaryTitle =>
      _t('Your reflection so far', 'Ang iyong refleksiyon sa ngayon');
  String get journalSummarySky => _t('Sky', 'Langit');
  String get journalSummaryFeelings => _t('Feelings', 'Damdamin');
  String get journalSummaryImpact => _t('Impact', 'Epekto');
  String get journalSummaryEmpty => _t('Not set', 'Walang napili');
  String get journalPhotoLabel =>
      _t('Add a photo (optional)', 'Magdagdag ng larawan (opsyonal)');
  String get journalPhotoHint => _t(
        'Take a photo or choose from your library. We’ll optimize it before upload.',
        'Kumuha ng litrato o pumili mula sa gallery. Io-optimize bago i-upload.',
      );
  String get journalPhotoAdd => _t('Add photo', 'Magdagdag ng larawan');
  String get journalPhotoChange => _t('Change photo', 'Palitan ang larawan');
  String get journalPhotoRemove => _t('Remove', 'Alisin');
  String get journalPhotoSourceTitle =>
      _t('Add a journal photo', 'Magdagdag ng larawan sa journal');
  String get journalPhotoCamera => _t('Take photo', 'Kumuha ng litrato');
  String get journalPhotoGallery =>
      _t('Choose from library', 'Pumili mula sa gallery');
  String get journalPhotoFailed => _t(
        'Could not prepare that photo. Please try another.',
        'Hindi ma-prepare ang larawan. Subukan ang iba.',
      );

  // DAPE Hope
  String get hopeTitle => _t('DAPE Hope', 'DAPE Hope');
  String get hopeTagline => _t(
        'Together for a drug-free and hopeful future.',
        'Sama-sama para sa drug-free at may pag-asang kinabukasan.',
      );
  String get hopeSearchHint => _t(
        'Search communities, events, and campaigns!',
        'Maghanap ng communities, events, at campaigns!',
      );
  String get hopeMovementTitle =>
      _t('Be part of the movement!', 'Maging bahagi ng kilusan!');
  String get hopeFeaturedTitle => _t('Featured', 'Tampok');
  String get hopeSpeedDialTitle => _t('Speed Dial', 'Mabilisang Access');
  String get hopeEventsTile =>
      _t('Events & Seminars', 'Events at Seminars');
  String get hopeEventsTileBody => _t(
        'Discover official events and learning sessions!',
        'Tuklasin ang opisyal na events at learning sessions!',
      );
  String get hopeDirectoryTile =>
      _t('Official Directory', 'Opisyal na Directory');
  String get hopeDirectoryTileBody => _t(
        'Check recognized offices and organizations.',
        'Tingnan ang kinikilalang opisina at organisasyon.',
      );
  String get hopeContestsTile => _t('Contests', 'Mga Contest');
  String get hopeContestsTileBody => _t(
        'Join creative contests and show your advocacy.',
        'Sumali sa creative contests at ipakita ang advocacy.',
      );
  String get hopeIecTile => _t('IEC Materials', 'IEC Materials');
  String get hopeIecTileBody => _t(
        'Browse prevention education materials.',
        'Tingnan ang prevention education materials.',
      );
  String get hopeRehabTile => _t('Rehab Centers', 'Rehab Centers');
  String get hopeRehabTileBody => _t(
        'Find treatment and rehab facilities.',
        'Hanapin ang treatment at rehab facilities.',
      );
  String get hopeLearnPhase2 => _t(
        'BIDA Learn is coming in Phase 2.',
        'Darating ang BIDA Learn sa Phase 2.',
      );
  String get hopeDirectoryTitle => _t('Directory', 'Directory');
  String get hopeDirectorySearchHint => _t(
        'Search institution/organization',
        'Maghanap ng institution/organization',
      );
  String get hopeDirectoryAll => _t('All', 'Lahat');
  String get hopeDirectoryGov => _t("Gov't", 'Gobyerno');
  String get hopeDirectoryNgo => _t('NGOs', 'NGOs');
  String get hopeDirectorySchools => _t('Schools', 'Mga Paaralan');
  String get hopeDirectoryEmpty => _t(
        'No organizations found.',
        'Walang nahanap na organisasyon.',
      );
  String get hopeEventsTitle => _t('Events', 'Events');
  String get hopeEventsSearchHint => _t(
        'Search programs/events/webinars',
        'Maghanap ng programs/events/webinars',
      );
  String get hopeEventsAll => _t('All', 'Lahat');
  String get hopeEventsYouth => _t('Youth', 'Kabataan');
  String get hopeEventsParents => _t('Parents', 'Mga Magulang');
  String get hopeEventsCommunity => _t('Community', 'Komunidad');
  String get hopeEventsEmpty =>
      _t('No events found.', 'Walang nahanap na event.');
  String get hopeEventsRegister => _t('Register', 'Magparehistro');
  String get hopeEventsRegisterNow =>
      _t('Register Now', 'Magparehistro Ngayon');
  String hopeEventsSlotsLeft(int n) =>
      _t('$n slots left', '$n slots ang natitira');
  String get hopeEventAbout => _t('About', 'Tungkol');
  String get hopeEventDetails => _t('Details', 'Detalye');
  String get hopeEventSpeakers => _t('Speakers', 'Mga Speaker');
  String get hopeEventFaqs => _t('FAQs', 'FAQs');
  String get hopeEventAboutHeading =>
      _t('About the event', 'Tungkol sa event');
  String get hopeEventForYouHeading =>
      _t('This is for you if you want to:', 'Para sa iyo kung gusto mong:');
  String get hopeEventWhoCanJoin =>
      _t('Who can join?', 'Sino ang pwede sumali?');
  String get hopeEventHighlights => _t('Highlights', 'Mga Highlight');
  String get hopeEventUpcoming => _t('Upcoming', 'Paparating');
}
