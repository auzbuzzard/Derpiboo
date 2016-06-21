# project-derpi
An iOS app project for derpibooru.org written by an amateur programmer.


## What's this?
Just a random project of mine. We all love ponies but it's hard to view pictures of them when we're on our phone. Recently there's been an Android app for Derpibooru, but at least to my knowledge there isn't one for iOS. So here it is.

## What does it do?
It's a Derpibooru client. It communicates with the site using its API and wrap the results in a more iOS friendly experience. 
### Currently it can:
* View the /images results. Basically the homepage of derpibooru
* Search for images. Just type in the search term as you would on the site
* Viewing details of an image.
* view your own profile. If you're "logged in", you can view your own avatar, username and description.
* Logging in. Derpibooru allows injection of your account's API key to fetch results taylored to your account. The most notible effect of this is that the filter you set on the site will be applied. Because it's an API key, not an actual authorization, the user would have to log in via Safari (as an embedded view in the settings menu) to copy their API key from the site. They should also type in their account name to have the profile view working. 
### Planned features
* viewing lists. Especially the default ones
* user's watch list
* Viewing comments
* many bug fixes
* Way in the future
  * wrapping tags in their own clickable button
  * allowing tokens in the search field
  
## But don't these apps get rejected from the stores?
It's seemed so. I know that the latest known Android version for derpibooru is rejected from the Play Store. I haven't submitted this to the App Store yet since, it is not finished, but I hope that it would allow the app to be on the store.
Currently, the app has a "foal safe" feature that prevents anyone who is not logged in (via the more involved approach of copying API) to see anything more than "safe". A hard-coded search is built in to return only images tagged with "safe" if the user is not logged in. It would be hard for users to stumble on suggestive content given that they: must create the account on their own on the site; log into the app; and manually adjust the filter settings on the site itself.
As for copyright issues, I hope the app could exists on the same terms as the site. I would have to look into this, or hopefully someone could advice me on how to solve this issue.
If anything fails, the code is still up here, anyone can download it and build it onto their devices if they have XCode installed.
## But it's buggy
Sorry but I'm just an ameteur coder learning on the fly. In fact, I'd really appreciate it if you could proofread what I've done.
## Information about the app
Currently it only targets iOS9.0 or above, since it uses SFSafariView and StackViews, which are iOS9.0 or above only. I might probably solve this in the future.
It is available for both iPHone and iPad. If the app actually takes flight I might add in tvOS and watchOS support lol just because.
Not sure what else to put here.
