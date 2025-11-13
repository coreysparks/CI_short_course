# Training Course Application Shiny App

This Shiny application collects information from applicants for training courses. It supports both individual and team applications, with file uploads for resumes and automatic data storage in Google Sheets.

## Features

- **Individual Applications**: Collect name, email, and resume from single applicants
- **Team Applications**: Collect information from multiple team members (2-10 people)
- **File Upload**: Accept resume uploads in PDF, DOC, DOCX, or TXT format
- **Google Sheets Integration**: Automatically save all submissions to a Google Sheet
- **Data Validation**: Email validation and required field checking
- **User-Friendly Interface**: Responsive design with clear instructions

## Requirements

Install the following R packages:

```r
install.packages(c("shiny", "googlesheets4", "DT"))
```

## Google Sheets Setup

### Step 1: Create a Google Sheet

1. Go to [Google Sheets](https://sheets.google.com)
2. Create a new spreadsheet
3. Name it "Training Course Applications" (or your preferred name)
4. Create a sheet tab named "Applications"
5. Add the following headers in the first row:
   - `Timestamp`
   - `Main_Contact_Email`
   - `Application_Type`
   - `Member_Number`
   - `Name`
   - `Email`
   - `Resume_Filename`
   - `Resume_Size_KB`
6. Copy the URL of your Google Sheet

### Step 2: Set Up Authentication

There are two methods to authenticate with Google Sheets:

#### Method A: OAuth (Interactive - Recommended for Testing)

1. Run the app locally
2. On first run, you'll be prompted to authenticate with Google
3. Grant the necessary permissions
4. Credentials will be cached in the `.secrets` folder

#### Method B: Service Account (Recommended for Production)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Sheets API
4. Create a service account:
   - Go to "IAM & Admin" > "Service Accounts"
   - Click "Create Service Account"
   - Give it a name and description
   - Grant it "Editor" role
   - Create a JSON key
5. Download the JSON key file
6. Share your Google Sheet with the service account email (found in the JSON file)
7. Set up authentication in your R code:

```r
# In app.R, modify the gs4_auth() call:
gs4_auth(path = "path/to/service-account-key.json")
```

### Step 3: Configure Environment Variables

Create a `.Renviron` file in your project directory:

```
GOOGLE_SHEETS_URL=https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit
```

Replace `YOUR_SHEET_ID` with your actual Google Sheet ID from the URL.

## Running the Application

### Local Development

1. Open the project in RStudio
2. Open `app.R`
3. Click "Run App" button, or run:

```r
shiny::runApp()
```

### Deploy to shinyapps.io

1. Install rsconnect package:
```r
install.packages("rsconnect")
```

2. Set up your shinyapps.io account:
```r
rsconnect::setAccountInfo(
  name = "your-account-name",
  token = "your-token",
  secret = "your-secret"
)
```

3. Deploy the app:
```r
rsconnect::deployApp()
```

**Note**: For deployment, you'll need to:
- Include the `.Renviron` file with your sheet URL
- Set up service account authentication (Method B above)
- Include the service account JSON file (but keep it secure!)

## Application Usage

### For Individual Applications:

1. Enter the main contact email
2. Select "Individual" as application type
3. Enter your full name
4. Enter your email address
5. Upload your resume (PDF, DOC, DOCX, or TXT)
6. Click "Submit Application"

### For Team Applications:

1. Enter the main contact email (for the team lead/organizer)
2. Select "Team" as application type
3. Enter the number of team members (2-10)
4. Click "Generate Team Member Forms"
5. Fill in name, email, and upload resume for each team member
6. Click "Submit Application"

## Data Structure

Each submission is saved to Google Sheets with the following columns:

- **Timestamp**: Date and time of submission
- **Main_Contact_Email**: Primary contact email for the application
- **Application_Type**: "Individual" or "Team"
- **Member_Number**: Sequential number for team members (1 for individual)
- **Name**: Applicant's full name
- **Email**: Applicant's email address
- **Resume_Filename**: Name of uploaded resume file
- **Resume_Size_KB**: Size of resume file in kilobytes

For team applications, each member gets a separate row with the same timestamp and main contact email.

## Security Considerations

1. **Credentials**: Never commit the `.secrets` folder or service account JSON files to version control
2. **Environment Variables**: Keep `.Renviron` out of version control
3. **Sheet Permissions**: Only share the Google Sheet with necessary users
4. **File Uploads**: The current version stores file metadata only. To store actual files, integrate with Google Drive API or another storage solution
5. **Data Privacy**: Ensure compliance with relevant data protection regulations (GDPR, etc.)

## Troubleshooting

### "Google Sheets URL not configured" error
- Make sure `.Renviron` file exists with correct `GOOGLE_SHEETS_URL`
- Restart R session after creating `.Renviron`

### Authentication errors
- Delete `.secrets` folder and re-authenticate
- Check that the Google Sheet is shared with your Google account or service account
- Verify that Google Sheets API is enabled in Google Cloud Console

### File upload errors
- Check file size limits (default Shiny limit is 5MB)
- Verify file format is supported (PDF, DOC, DOCX, TXT)
- Increase upload limit by adding to app.R: `options(shiny.maxRequestSize = 30*1024^2)` for 30MB

## Future Enhancements

Potential improvements to consider:

1. **File Storage**: Upload resumes to Google Drive and store links in the sheet
2. **Email Notifications**: Send confirmation emails to applicants
3. **Admin Dashboard**: Create a separate tab to view and manage applications
4. **Export Functionality**: Allow admins to export data as CSV
5. **Application Status**: Track application status (pending, reviewed, accepted, rejected)
6. **Duplicate Prevention**: Check for duplicate applications by email
7. **Custom Fields**: Allow adding custom questions or fields
8. **Multi-language Support**: Support applications in different languages

## License

This application is provided as-is for educational and organizational use.

## Support

For questions or issues, please contact the course administrator.
