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
  String get navDiary => _t('Diary', 'Talaarawan');
  String get navBible => _t('Bible', 'Bibliya');
  String get navAccount => _t('Account', 'Account');

  // DDB Services
  String get ddbServicesTitle => _t('DDB Services', 'Mga Serbisyo ng DDB');
  String get ddbServicesSubtitle => _t(
        'Browse DDB trainings, rehab centers, and song contest entries.',
        'Tingnan ang mga training, rehab center, at song contest ng DDB.',
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

  // Account
  String get accountTitle => _t('Account', 'Account');
  String get languageTitle => _t('Language', 'Wika');
  String get languageSubtitle =>
      _t('Choose your preferred app language', 'Piliin ang wika ng app');
  String get signedInHint =>
      _t('Save bookmarks and submit reviews', 'Mag-save ng bookmark at magbigay ng review');
  String get youAreSignedIn => _t('You are signed in', 'Naka-sign in ka');
  String get editProfile => _t('Edit profile', 'I-edit ang profile');
  String get changePassword => _t('Change password', 'Palitan ang password');
  String get logOut => _t('Log out', 'Mag-log out');
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
  String get alreadyHaveAccount => _t('Already have an account? ', 'May account na? ');
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

  // Bookmarks
  String get bookmarksTitle => _t('Bookmarks', 'Mga Bookmark');

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
      _t('Password must be at least 6 characters', 'Ang password ay dapat hindi bababa sa 6 character');

  // Bookmarks extras
  String get bookmarkRemoveFailed =>
      _t('Could not remove bookmark. Try again.', 'Hindi matanggal ang bookmark. Subukan muli.');
  String get noBookmarksYet => _t('No saved posts yet', 'Wala pang naka-save na post');

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
  String get loadPreviousComments =>
      _t('Load previous comments...', 'I-load ang mga naunang komento...');
  String get retry => _t('Retry', 'Subukan muli');
  String get noCommentsYet =>
      _t('No comments yet. Be the first to comment.', 'Wala pang komento. Ikaw ang unang magkomento.');
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

  // Daily verse
  String get dailyVerseTitle => _t('Verse of the Day', 'Talatang Araw-araw');
  String get skip => _t('Skip', 'Laktawan');
  String get continueToApp => _t('Continue to app', 'Magpatuloy sa app');
  String get openBible => _t('Open Bible', 'Buksan ang Bibliya');
  String get dailyVerseFallback => _t(
        'Trust in the Lord with all your heart.',
        'Manalig ka sa Panginoon ng buong puso mo.',
      );
  String get dailyVerseReferenceFallback => _t('Proverbs 3:5', 'Kawikaan 3:5');

  // Bible
  String get bibleTitle => _t('Holy Bible', 'Banal na Bibliya');
  String get searchBibleBooks => _t('Search books...', 'Maghanap ng aklat...');
  String get oldTestament => _t('Old Testament', 'Lumang Tipan');
  String get newTestament => _t('New Testament', 'Bagong Tipan');
  String get noBibleBooksFound => _t('No books found', 'Walang nahanap na aklat');
  String get bibleLoadFailed =>
      _t('Could not load passage. Try again.', 'Hindi ma-load ang talata. Subukan muli.');
  String get bibleLanguageNote => _t(
        'Bible text follows your app language (English or Tagalog).',
        'Sinusunod ng Bibliya ang wika ng app (English o Tagalog).',
      );
  String chaptersLabel(int count) => _t(
        '$count chapters',
        '$count kabanata',
      );

  // Diary
  String get diaryTitle => _t('My Diary', 'Aking Talaarawan');
  String get writeToday => _t("Write today's note", 'Sumulat ngayong araw');
  String get diaryLoginRequired => _t(
        'Sign in to keep your private daily journal.',
        'Mag-sign in para sa iyong pribadong talaarawan.',
      );
  String get diaryEmpty => _t(
        'No diary entries yet. Tap Write today to begin.',
        'Wala pang tala. Pindutin ang Sumulat ngayong araw para magsimula.',
      );
  String get diaryEditorTitle => _t('Diary entry', 'Tala sa talaarawan');
  String get diaryTitleHint => _t('Title (optional)', 'Pamagat (opsyonal)');
  String get diaryBodyHint =>
      _t('What happened today?', 'Ano ang nangyari ngayon?');
  String get diaryBodyRequired =>
      _t('Please write something in your diary.', 'Magsulat muna sa iyong talaarawan.');
  String get diarySaved => _t('Diary entry saved', 'Nai-save ang tala');
  String get diarySaveFailed =>
      _t('Could not save diary entry.', 'Hindi mai-save ang tala.');
  String get deleteDiaryTitle => _t('Delete diary entry?', 'Burahin ang tala?');
  String get deleteDiaryBody =>
      _t('This entry will be removed permanently.', 'Permanenteng mabubura ang talang ito.');
  String get diaryDeleteFailed =>
      _t('Could not delete diary entry.', 'Hindi mabura ang tala.');
}
