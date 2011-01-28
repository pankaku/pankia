
// [Device]
#define kPNHTTPRequestCommandDeviceTransfer				@"/device/transfer"
#define kPNHttpRequestCommandDeviceRegisterPushToken	@"/device/register_push_token"
// [Learderboard]
#define kPNHTTPRequestCommandLeaderboardScores			@"/leaderboard/scores"
#define kPNHTTPRequestCommandLeaderboardRank			@"/leaderboard/ranks"
#define kPNHTTPRequestCommandLeaderboardPost			@"/leaderboard/post"
#define kPNHTTPRequestCommandLeaderboardIncrement		@"/leaderboard/increment"
#define kPNHTTPRequestCommandLeaderboardLatests			@"/leaderboard/latests"
// [Room]
#define kPNHTTPRequestCommandRoomShow					@"/room/show"
#define kPNHTTPRequestCommandRoomFind					@"/room/find"
#define kPNHTTPRequestCommandRoomFindRandom				@"/room/find"
#define kPNHTTPRequestCommandRoomCreate					@"/room/create"
#define kPNHTTPRequestCommandRoomDelete					@"/room/delete"
#define kPNHTTPRequestCommandRoomSay					@"/room/say"
#define kPNHTTPRequestCommandRoomMembers				@"/room/memberships"
#define kPNHTTPRequestCommandRoomJoin					@"/room/join"
#define kPNHTTPRequestCommandRoomLeave					@"/room/leave"
#define kPNHTTPRequestCommandRoomRemove					@"/room/remove"
#define kPNHTTPRequestCommandRoomLock					@"/room/lock"
#define kPNHTTPRequestCommandRoomUnlock					@"/room/unlock"

// [Purchase]
#define kPNHTTPRequestCommandPurchaseRegister			@"/purchase/register"
#define kPNHTTPRequestCommandPurchaseHistory			@"/purchase/history"

// [Introspection]
#define kPNHTTPRequestCommandIntrospectionReport		@"/introspection/report"

// [Session]
#define kPNHTTPRequestCommandSessionCreate				@"/session/create"
#define kPNHTTPRequestCommandSessionCreateByPassword		@"/session/create_by_password"
#define kPNHTTPRequestCommandSessionCreateByTwitter		@"/session/create_by_twitter"
#define kPNHTTPRequestCommandSessionCreateByFacebook	@"/session/create_by_facebook"
#define kPNHTTPRequestCommandSessionCreateByExternalID	@"/session/create_by_external_id"
#define kPNHTTPRequestCommandSessionVerify				@"/session/verify"
#define kPNHTTPRequestCommandSessionDelete				@"/session/delete"

// [Splash]
#define kPNHTTPRequestCommandSplashAck					@"/splash/ack"
#define kPNHTTPRequestCommandSplashPing					@"/splash/ping"

// [Subscription]
#define kPNHTTPRequestCommandSubscriptionShow			@"/subscription/delete"
#define kPNHTTPRequestCommandSubscriptionAdd			@"/subscription/add"
#define kPNHTTPRequestCommandSubscriptionRemove			@"/subscription/remove"
#define kPNHTTPRequestCommandSubscriptionSet			@"/subscription/set"
// [Subscription command]
#define kPNHTTPSubscriptionTopicCommandUser				@"/user/"
#define kPNHTTPSubscriptionTopicCommandRoom				@"/room/"
#define kPNHTTPSubscriptionTopicCommandMembership		@"/membership/"
#define kPNHTTPSubscriptionTopicCommandFriendship		@"/friendship/"
// [User]
#define kPNHTTPRequestCommandUserShow					@"/user/show"
#define kPNHTTPRequestCommandUserFind					@"/user/find"
#define kPNHTTPRequestCommandUserSecure					@"/user/secure"
#define kPNHTTPRequestCommandUserUpdate					@"/user/update"
#define kPNHTTPRequestCommandUserPush					@"/user/push"
#define kPNHTTPRequestCommandUserFollow					@"/user/follow"
#define kPNHTTPRequestCommandUserUnfollow				@"/user/unfollow"
#define kPNHTTPRequestCommandUserFollowers				@"/user/followers"
#define kPNHTTPRequestCommandUserFollowees				@"/user/followees"
#define kPNHTTPRequestCommandUserBlock					@"/user/block"
#define kPNHTTPRequestCommandUserUnblock				@"/user/unblock"
// [Game]
#define kPNHTTPRequestCommandGameAchievement            @"/game/achievements"
#define kPNHTTPRequestCommandGameCategories				@"/game/categories"
#define kPNHTTPRequestCommandGameGrades					@"/game/grades"
#define kPNHTTPRequestCommandGameGradesStatus			@"/game/grade_status"
#define kPNHTTPRequestCommandGameItems					@"/game/items"
#define kPNHTTPRequestCommandGameLeaderboads			@"/game/leaderboards"
#define kPNHTTPRequestCommandGameVersions				@"/game/versions"
#define kPNHTTPRequestCommandGameLobbies				@"/game/lobbies"
#define kPNHTTPRequestCommandGameMerchandises			@"/game/merchandises"
#define kPNHTTPRequestCommandGameShow					@"/game/show"
#define kPNHTTPRequestCommandGameRevision				@"/game/revision"

// [Item]
#define kPNHTTPRequestCommandItemOwnerships				@"/item/ownerships"
#define kPNHTTPRequestCommandItemAcquire				@"/item/acquire"
#define kPNHTTPRequestCommandItemConsume				@"/item/consume"


// [Achievement]
#define kPNHTTPRequestCommandAchievementUnlock			@"/achievement/unlock"
#define kPNHTTPRequestCommandAchievementUnlocks			@"/achievement/unlocks"
#define kPNHTTPRequestCommandAchievementUnlocked		@"/achievement/unlocked"
// [Invitation]
#define kPNHTTPRequestCommandInvitationShow				@"/invitation/show"
#define kPNHTTPRequestCommandInvitationPost				@"/invitation/post"
#define kPNHTTPRequestCommandInvitationDelete			@"/invitation/delete"
#define kPNHTTPRequestCommandInvitationRooms			@"/invitation/rooms" 

// [Twitter]
#define kPNHTTPRequestCommandMatchStart					@"/match/start"
#define kPNHTTPRequestCommandMatchFinish				@"/match/finish"
#define kPNHTTPRequestCommandMatchFind					@"/match/find"


// [Twitter]
#define kPNHTTPRequestCommandTwitterLink				@"/twitter/link"
#define kPNHTTPRequestCommandTwitterUnlink				@"/twitter/unlink"
#define kPNHTTPRequestCommandTwitterPostTweet			@"/twitter/say"
#define kPNHTTPRequestCommandTwitterVerify				@"/twitter/verify"
#define kPNHTTPRequestCommandTwitterImport				@"/twitter/import_graph"

// [Facebook]
#define kPNHTTPRequestCommandFacebookLink				@"/facebook/link"
#define kPNHTTPRequestCommandFacebookUnlink				@"/facebook/unlink"
#define kPNHTTPRequestCommandFacebookFriends			@"/facebook/friends"
#define kPNHTTPRequestCommandFacebookImport				@"/facebook/import_graph"
#define kPNHTTPRequestCommandFacebookVerify				@"/facebook/verify"