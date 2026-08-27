# Advanced Mobile Programming — Long Exam 1

A Flutter social media app (Facebook-style replication) that pulls all of its
content from the [DummyJSON](https://dummyjson.com/) REST API. Originally built
with hardcoded static data, then enhanced to use live endpoints with real
authentication, session persistence, and local storage.

**Host:** `https://dummyjson.com/`

---

## Enhancements

**1 — Authentication & Splash Screen** ([docs](https://dummyjson.com/docs/users))
Login authenticates against `POST /user/login`, then enriches the result with
`GET /users/{id}` for the full profile. The user object and an `isLoggedIn` flag
are saved with `shared_preferences`, so the session survives a restart. A new
splash screen reads that flag on startup and routes to `/home` or `/login`.

**2 — Posts by User ID & Settings** ([docs](https://dummyjson.com/docs/posts))
The profile screen calls `GET /posts/user/{userId}` with the logged-in user's
own ID, so it only shows that user's posts, and the About tab is filled from the
API. A new settings screen holds the user preferences and the Sign Out button,
which clears the session and wipes the navigation stack.

**3 — Comments & Likes** ([docs](https://dummyjson.com/docs/comments))
The detail screen loads `GET /comments/post/{postId}`, so comments are filtered
by post and only show the ones belonging to it. The post like button and each
comment's like button are clickable and persisted. Users can add comments —
sent to `POST /comments/add` for realism, but saved to `shared_preferences`
keyed by post ID since DummyJSON doesn't persist writes.

**Also implemented**

- 30+ posts per page via `GET /posts?limit=30&skip=N`, with infinite scroll and
  pull-to-refresh
- Light mode / dark mode, persisted and applied app-wide
- No hardcoded posts, users, or comments remain

---

## Discussion — Design Pattern Used

This project uses a design pattern we've also applied in our previous web
subjects. A design pattern is basically a blueprint, a ready-made solution for
common software problems like scalability and code that becomes unmaintainable
as a project grows. The one used here is **MVC (Model-View-Controller)**,
developed by **Trygve Reenskaug** in 1979 at Xerox PARC. The fact that we still
use it today shows how solid the concept is.

The main idea is **separation of concerns** — each part of the app has one job
and shouldn't mix data handling with UI, or UI with network calls. The folder
structure already reflects this: `models`, `services`, and `screens`.

### How the layers interact

```
Screens (View)  →  Services  →  Models
     ↑                              │
     └──────── data flows back ─────┘
```

**Models** are pure data. `User`, `Post`, and `Comment` only describe what the
data looks like — they don't know where it came from and can't draw anything.
Their real job is `fromJson()`, which converts raw API JSON into typed Dart
objects so we write `post.title` instead of `json['title']`. This is safer
because a typo gets caught by the compiler instead of crashing at runtime.

**Services** are the middleman. `PostService`, `UserService`, and
`CommentService` are the only files that know about `http` and the DummyJSON
URLs. They send the request and hand back finished model objects, so
`PostService.getPostsByUser(5)` returns a `List<Post>` and the screen never
touches raw JSON. `LocalStorageService` works the same way for
`shared_preferences`.

**Screens** only display. `NewsFeedScreen` calls a service, holds the result in
state, and builds widgets. It doesn't know whether the data came from the
internet, a cache, or a text file — only that it has a `List<Post>`.

**The Controller** role is a bit blurred in Flutter, since the `State` class of
a `StatefulWidget` fills it. When the user taps like, `toggleLike()` catches the
input, calls `LocalStorageService.togglePostLike()`, then calls `setState()` to
redraw — receive input, update data, refresh the view. `ThemeProvider` does the
same with `ChangeNotifier` and `notifyListeners()`.

### Why it matters

Changes stay contained. If DummyJSON changed `/posts/user/5` to
`/users/5/posts`, only `PostService` gets edited and no screen is touched. It
works in reverse too — `PostCard` was completely redesigned for this exam
without changing a single service, because the data contract never changed. It
also makes reuse easy: `getPostsByUser()` is called by the profile screen, and
adding a "view other profiles" feature would just pass a different ID instead of
copy-pasting the logic.

### Real-life example

Think of a restaurant. The **model** is the food in the kitchen. The **service**
is the waiter — you don't walk into the kitchen yourself, you tell him what you
want and he brings it back properly plated. If the kitchen changes cooks or
moves locations, you don't care as long as the order still arrives. The **view**
is you at the table with the menu and the plating. The **controller** is the act
of ordering. This works because the customer and the kitchen never talk
directly; if they did, it'd be chaos with everyone shouting into the kitchen.
That's exactly what happens when every screen makes its own HTTP calls — fine
with 3 screens, unmaintainable with 20.

An ATM is another example. The screen shows your balance but doesn't store your
money; it requests it from the bank's system. An ATM in Manila and one in Cebu
look different but pull from the same account data. Same reason one `Post` model
renders as a detailed card in the feed and a simpler one in the profile.

---

## Project Structure

```
lib/
├── main.dart                      # Entry, ThemeProvider + routes
├── constants.dart                 # API URL, colors, light/dark ThemeData
├── models/                        # user.dart, post.dart, comment.dart
├── services/
│   ├── user_service.dart          # login, getUserById, getAllUsersMap, addUser
│   ├── post_service.dart          # getPosts (paginated), getPostsByUser
│   ├── comment_service.dart       # getCommentsByPost, addCommentRemote
│   └── local_storage_service.dart # All shared_preferences access
├── provider/theme_provider.dart   # ChangeNotifier for light/dark mode
├── screens/
│   ├── splash_screen.dart         # Session check → /home or /login
│   ├── login_screen.dart          # POST /user/login
│   ├── register_screen.dart       # POST /users/add
│   ├── home_screen.dart           # Bottom nav shell
│   ├── newsfeed_screen.dart       # Paginated feed, 30 per page
│   ├── profile_screen.dart        # Posts by logged-in user ID
│   ├── detail_screen.dart         # Post detail, comments, likes
│   ├── notification_screen.dart
│   └── settings_screen.dart       # Dark mode toggle + Sign Out
└── widgets/                       # post_card.dart + custom_* widgets
```

---

## API Endpoints Used

| Method | Endpoint                    | Purpose                                 |
| ------ | --------------------------- | --------------------------------------- |
| `POST` | `/user/login`               | Authenticate, receive user + JWT tokens |
| `GET`  | `/users/{id}`               | Full profile of the logged-in user      |
| `GET`  | `/users?limit=0&select=...` | Resolve post authors in one request     |
| `POST` | `/users/add`                | Simulated registration                  |
| `GET`  | `/posts?limit=30&skip=N`    | Paginated newsfeed                      |
| `GET`  | `/posts/user/{userId}`      | Posts belonging to one user             |
| `GET`  | `/comments/post/{postId}`   | Comments filtered by post               |
| `POST` | `/comments/add`             | Simulated add comment                   |

---

## Setup

```bash
flutter pub get
flutter run
```

Dependencies added for this exam: `http: ^1.2.2` (service layer requests) and
`provider: ^6.1.2` (ThemeProvider). Already present: `shared_preferences`,
`cached_network_image`, `flutter_screenutil`, `intl`, `carousel_slider`.

---

## Logging In

Use any account from [dummyjson.com/users](https://dummyjson.com/users) — the
password is the username followed by `pass`.

| Username   | Password       | User ID |
| ---------- | -------------- | ------- |
| `emilys`   | `emilyspass`   | 1       |
| `michaelw` | `michaelwpass` | 2       |
| `emmaj`    | `emmajpass`    | 5       |

> Accounts created through Register won't work for login. DummyJSON simulates
> `POST /users/add` and returns a new ID but doesn't save it server-side.

---

## Known Limitations

- **DummyJSON is read-only in practice.** Writes return realistic responses but
  never modify the server, which is why comments, likes, and registration are
  persisted locally.
- **Like counts** show the API's original count plus 1 if the current user liked
  it, since the server value can't be incremented.
- **Posts have no images or timestamps** in the DummyJSON schema, so cards show
  the title, body, tags, and view count instead.
