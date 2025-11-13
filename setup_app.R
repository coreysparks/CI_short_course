# Setup Script for Training Course Application Shiny App
# Run this script once to install required packages and set up the environment

cat("========================================\n")
cat("Training Course Application Setup\n")
cat("========================================\n\n")

# Check and install required packages
required_packages <- c("shiny", "googlesheets4", "DT")

cat("Checking for required packages...\n")
packages_to_install <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(packages_to_install) > 0) {
  cat(paste("Installing missing packages:", paste(packages_to_install, collapse = ", "), "\n"))
  install.packages(packages_to_install)
  cat("Packages installed successfully!\n\n")
} else {
  cat("All required packages are already installed!\n\n")
}

# Check for .Renviron file
cat("Checking for .Renviron file...\n")
if(!file.exists(".Renviron")) {
  if(file.exists(".Renviron.example")) {
    cat(".Renviron not found. Copying from .Renviron.example...\n")
    file.copy(".Renviron.example", ".Renviron")
    cat("\n")
    cat("!! IMPORTANT !!\n")
    cat("Please edit .Renviron and add your Google Sheets URL.\n")
    cat("The file has been created from the example template.\n\n")
  } else {
    cat("Warning: Neither .Renviron nor .Renviron.example found!\n")
    cat("You'll need to create .Renviron manually.\n\n")
  }
} else {
  cat(".Renviron file exists.\n\n")
}

# Create .secrets directory if it doesn't exist
cat("Checking for .secrets directory...\n")
if(!dir.exists(".secrets")) {
  dir.create(".secrets")
  cat(".secrets directory created for storing authentication tokens.\n\n")
} else {
  cat(".secrets directory already exists.\n\n")
}

cat("========================================\n")
cat("Setup Complete!\n")
cat("========================================\n\n")

cat("Next steps:\n")
cat("1. Edit .Renviron and add your Google Sheets URL\n")
cat("2. Create a Google Sheet with an 'Applications' tab\n")
cat("3. Add column headers as described in README_SHINY_APP.md\n")
cat("4. Run the app with: shiny::runApp()\n")
cat("5. Authenticate with Google on first run\n\n")

cat("For detailed instructions, see README_SHINY_APP.md\n")
