#  TacoDemo iOS

Displays a list of tacos. Testbed for trying new things.

Used to be wired into a Rails app; now just uses Firebase realtime database. You'll need to create one and add the URL to a plist in the project - the free plan should be fine for just playing around.

Create Endpoint.plist in your project, and define a string "url" at the root of the plist with your Firebase Realtime Database URL
- e.g., "https://tacodemo-12345.firebaseio.com" (no trailing slash)

Don't commit Endpoint.plist to Git to avoid unnecessary billing on your account.

Make sure read/writes are set to true in the Rules tab in Firebase. Adding auth is an optional exercise for the reader.
