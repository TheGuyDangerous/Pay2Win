Set up the following GitHub Secrets in your repository settings (Settings > Secrets and variables > Actions > New repository secret):

### Firebase Configuration

| Secret Name | Description |
|-------------|-------------|
| `FIREBASE_API_KEY` | General Firebase API key |
| `FIREBASE_AUTH_DOMAIN` | Firebase authentication domain |
| `FIREBASE_PROJECT_ID` | Firebase project ID |
| `FIREBASE_STORAGE_BUCKET` | Firebase storage bucket URL |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase messaging sender ID |
| `FIREBASE_APP_ID` | General Firebase app ID |
| `FIREBASE_MEASUREMENT_ID` | Firebase measurement ID |

### Platform-Specific Firebase Settings

| Secret Name | Description |
|-------------|-------------|
| `FIREBASE_WEB_API_KEY` | Firebase API key for web platform |
| `FIREBASE_WEB_APP_ID` | Firebase app ID for web platform |
| `FIREBASE_ANDROID_API_KEY` | Firebase API key for Android platform |
| `FIREBASE_ANDROID_APP_ID` | Firebase app ID for Android platform |
| `FIREBASE_IOS_API_KEY` | Firebase API key for iOS platform |
| `FIREBASE_IOS_APP_ID` | Firebase app ID for iOS platform |

### App Configuration

| Secret Name | Description |
|-------------|-------------|
| `ANDROID_PACKAGE_NAME` | Android application package name (e.g., com.example.pay2win) |
| `IOS_BUNDLE_ID` | iOS bundle identifier (e.g., com.example.pay2win) |

### Deployment Configuration

| Secret Name | Description |
|-------------|-------------|
| `FIREBASE_SERVICE_ACCOUNT` | JSON content of the Firebase service account key file for app distribution |

## How to Get These Values

1. **Firebase Console**: Most Firebase-related values can be obtained from the Firebase console project settings.

2. **Service Account Key**: 
   - Go to Firebase Console > Project Settings > Service Accounts
   - Click "Generate new private key"
   - Download the JSON file
   - Copy the entire contents of the file as the value for `FIREBASE_SERVICE_ACCOUNT`

## Important Notes

- Never commit sensitive credentials directly to your repository
- Make sure your .gitignore file excludes all sensitive files (google-services.json, GoogleService-Info.plist, .env files, etc.)
- The workflow will build APKs for different architectures using the `--split-per-abi` option 