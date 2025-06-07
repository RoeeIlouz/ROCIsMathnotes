# Google Sign-In Configuration for Web

To enable Google Sign-In for the web version of this app, you need to:

## 1. Get Google OAuth 2.0 Client ID

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API
4. Go to "Credentials" in the left sidebar
5. Click "Create Credentials" > "OAuth 2.0 Client IDs"
6. Choose "Web application"
7. Add your domain to "Authorized JavaScript origins":
   - For development: `http://localhost:3000`
   - For production: `https://yourdomain.com`

## 2. Update Configuration

1. Replace `YOUR_GOOGLE_CLIENT_ID` in `web/index.html` with your actual client ID
2. The line should look like:
   ```html
   <meta name="google-signin-client_id" content="123456789-abcdefghijklmnop.apps.googleusercontent.com">
   ```

## 3. Update AuthService (if needed)

If you need to specify the client ID in the AuthService as well, update the GoogleSignIn configuration in:
`lib/features/auth/data/services/auth_service.dart`

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com', // Add this line for web
  scopes: [
    'email',
    'profile',
    'https://www.googleapis.com/auth/drive.file',
  ],
);
```

## Note
Without proper Google Client ID configuration, Google Sign-In will not work and you'll see "ClientID not set" errors in the console.