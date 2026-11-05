# Virtual-Aquarium-for-Anglers

FishDex: Turning Real Catches into Virtual Aquariums.

The Problem:
As Catch and Release becomes more popular, many anglers choose to release
the fish after catching them to help protect the environment.
The main problem is that they cannot take their catch home as a trophy. In the
end, they are usually left with only a photo on their phone. The photo can help
them remember the experience, but there is not much they can do with it
afterward. It does not give them much interaction, and it is hard to keep the
feeling of collecting and achievement.

The Solution
I'm proposing a mobile app that turns real fishing catches into a virtual
collection.
Before releasing a fish, they can take a photo with the app. The app will identify
the species and add the fish to the user's virtual aquarium. Every fish in the
aquarium comes from a real catch. Anglers can feed their fish, decorate their
aquarium, and show their collection to others. This lets anglers release the real
fish while still keeping and enjoying their catches in a virtual way.

Existing Solutions:
Photo albums and social media let anglers save and share their catches.
However, the excitement usually fades quickly after the photo is posted.
Fishing video games offer collections, virtual aquariums, and rewards.
However, the fish are completely virtual and are not connected to the angler’s
real fishing experience. They do not represent the effort, patience, and memories
behind a real catch.
FishDex connects real fishing with a virtual collection. It lets anglers release the
real fish while keeping a virtual version they can grow, display, and personalize.




## Setup to work on the project

1. Install [Flutter](https://docs.flutter.dev/get-started/install/windows), Git, and Android Studio. Run `flutter doctor` and fix any red Android items.
2. Clone the repo into a simple folder such as `C:\src` (not Dropbox or a folder with spaces).
3. Run `flutter pub get` inside the repo folder.
4. In Android Studio, open Device Manager, create a Pixel emulator with a Play Store image, and start it. (A real Android phone with USB debugging also works.)
5. Run `flutter devices` to confirm the emulator shows up, then run the app with `flutter run`. If more than one device is listed, add `-d <device id>`.
6. Run the tests with `flutter test`.

The first build takes several minutes. Later runs are faster, and pressing `r` in the terminal reloads changes instantly.

Supabase keys: copy `env.example.json` to `env.json`, fill in the keys the team shares privately, and run with `flutter run --dart-define-from-file=env.json`. Never commit `env.json`.

Work on a branch and open a pull request instead of committing to `main`.





## Approximate Timeline

Week 1
M1: Approve stack, tasks, catalog. Create flutter shell and supabase authentication/postgreSQL/RLS/storage prototype.

Week 2
M2: Manual species selection, catch form, stable IDs, local catch/photos persistence, catch detail view

Week 3
M3: Local first sync queue, supabase, private photo uploads, handling

Week 4
M4: Catch editing and history, species/date/location filters, locations, online map, catch comparisons, snapshots

Week 5
M5: Individual virtual collection, P1 integration, review, work on P2 (aquarium  and sharing features) only if P1 is already complete

Week 6
M6: P1 verification, RLS and storage privacy review, recovery/performance/usability checks, fixes, demo build





## Architecture

Mobile app: Flutter/Dart + Material 3 — (Local-first storage) —> SQLite + Drift (catch cache/queue, private app photo files, pending/uploading/failed/synced, stables IDs)

(HTTPS sync) ___> Supabase backend (Auth: account identity and sessions, PostgreSQL: profiles, catches, metadata, Storage: private photo objects, RLS + Storage access policies)

(Camera/location/maps) ___> Device/external services (image_picker + geolocator, flutter_map + online OpenStreetMap tiles, P2: recognition, OpenStreetMap attribution)
