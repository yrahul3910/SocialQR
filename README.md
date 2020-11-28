# SocialQR

## What is it?

SocialQR (the current name) is an app designed to help people grow their social networks by displaying nearby people who also have the app installed. A chat lobby is present where everyone can chat in a common room, but users have the option of adding friends for private messaging. Alternatively, a QR code can be scanned as a method of consent for friend requests. These chats are only short-lived, i.e., they only work so long as you are in close proximity; however, the friend list is persistent. This design allows for a serverless, privacy-first architecture. Because the friend list will include the friend's phone number and possibly other contact information, the goal is for users to continue their conversations via iMessage (which is installed on most iPhones).

## Flow

At the top level, the view rendered is the `TabView`, which displays the tabs at the bottom of the screen. The `TabView` itself is embedded inside a `ZStack`, which allows for the toast notification functionality to work. The list of friends is stored on disk, and is initialized to an empty list if it does not exist. Each screen is in its own view, as described below.

`RequestsView` shows a list of received friend requests (which allow users to communicate directly in private chats). It has a straightforward implementation that uses an `ObservedObject` to render each request.

`NearbyView` shows a list of nearby people, and allows users to communicate to a common chat room via broadcast. This room is “dynamic” in that it only broadcasts to neighbors that are discoverable, but this is abstracted away, and is not explicitly done. Because `NearbyView` encapsulates the `GlobalMessagesView` that displays the actual messages, it carries more state than others, since it is directly responsible for communicating between `TabView` and `GlobalMessagesView`.

`FriendsView` encapsulates the list of friends of a user, and handles QR code scanning, which allows people to add friends. It also allows for sending friend requests.

Finally, `ProfileView` shows the user’s profile. It is where users edit their information (which is currently work-in-progress).
