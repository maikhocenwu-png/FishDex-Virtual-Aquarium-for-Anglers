# Virtual-Aquarium-for-Anglers

## FishDex: Turning Real Catches into Virtual Aquariums.

### The Problem:
As Catch and Release becomes more popular, many anglers choose to release
the fish after catching them to help protect the environment.
The main problem is that they cannot take their catch home as a trophy. In the
end, they are usually left with only a photo on their phone. The photo can help
them remember the experience, but there is not much they can do with it
afterward. It does not give them much interaction, and it is hard to keep the
feeling of collecting and achievement.

### The Solution:
I'm proposing a mobile app that turns real fishing catches into a virtual
collection.
Before releasing a fish, they can take a photo with the app. The app will identify
the species and add the fish to the user's virtual aquarium. Every fish in the
aquarium comes from a real catch. Anglers can feed their fish, decorate their
aquarium, and show their collection to others. This lets anglers release the real
fish while still keeping and enjoying their catches in a virtual way.

### Existing Solutions:
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

**[ Week 1 ]**  
- Complete M1: Approve stack, tasks, catalog. Create flutter shell and supabase authentication/postgreSQL/RLS/storage setup.  
    Implement account creation and sign-in.  
- Begin M2.

**[ Week 2 ]**  
- Complete M2: Manual species selection, catch form, stable IDs, local catch/photos persistence, and photo uploads.

**[ Week 3 ]**  
- Complete M3: Catch detail view, catch editing and history, species/date/location filters, locations, catch comparisons, snapshots.  
- Begin M4.

**[ Week 4 ]**  
- Continue M4: Local first sync queue, supabase, private photo uploads, handling.

**[ Week 5 ]**   
- Complete M4.  
- Complete M5: Catch history map.  
- Begin M6.

**[ Week 6 ]**  
- M6: Complete fish collection and basic virtual fish aquarium, P1 integration, check IOS/Android behavior, RLS and storage privacy review, recovery/performance/usability checks, 
fixes, demo build. Add P2 only if P1 is complete.





## Architecture

<img width="720" height="540" alt="Architecture Diagram" src="https://github.com/user-attachments/assets/136a6e74-8786-4449-81be-473b8de31aa9" />
