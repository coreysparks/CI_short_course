# Training Course Application Shiny App
# This app collects application information for training courses
# Supports both individual and team applications

library(shiny)
library(googlesheets4)
library(DT)

# UI Definition
ui <- fluidPage(
  titlePanel("Training Course Application Form"),

  sidebarLayout(
    sidebarPanel(
      h3("Application Information"),

      # Main contact email
      textInput("main_email",
                "Main Contact Email*",
                placeholder = "contact@example.com"),

      # Application type selection
      radioButtons("app_type",
                   "Application Type*",
                   choices = c("Individual" = "individual",
                               "Team" = "team"),
                   selected = "individual"),

      hr(),

      # Individual application fields
      conditionalPanel(
        condition = "input.app_type == 'individual'",
        h4("Individual Application"),
        textInput("ind_name",
                  "Full Name*",
                  placeholder = "John Doe"),
        textInput("ind_email",
                  "Email Address*",
                  placeholder = "john.doe@example.com"),
        fileInput("ind_resume",
                  "Upload Resume*",
                  accept = c(".pdf", ".doc", ".docx", ".txt"),
                  placeholder = "Choose file...")
      ),

      # Team application fields
      conditionalPanel(
        condition = "input.app_type == 'team'",
        h4("Team Application"),
        numericInput("num_members",
                     "Number of Team Members*",
                     value = 2,
                     min = 2,
                     max = 10),
        actionButton("generate_team_form",
                     "Generate Team Member Forms",
                     class = "btn-primary")
      ),

      hr(),
      actionButton("submit",
                   "Submit Application",
                   class = "btn-success btn-lg",
                   width = "100%")
    ),

    mainPanel(
      # Team members input area
      conditionalPanel(
        condition = "input.app_type == 'team'",
        h3("Team Members"),
        uiOutput("team_members_ui"),
        hr()
      ),

      # Status messages
      h3("Submission Status"),
      verbatimTextOutput("status_message"),

      # Instructions
      hr(),
      h4("Instructions"),
      tags$ul(
        tags$li("Fill in the main contact email address"),
        tags$li("Select whether this is an individual or team application"),
        tags$li("For individual applications: provide name, email, and upload resume"),
        tags$li("For team applications: specify number of members, generate forms, and fill in details for each member"),
        tags$li("Accepted resume formats: PDF, DOC, DOCX, TXT"),
        tags$li("Click 'Submit Application' when ready")
      ),

      h4("Data Privacy"),
      p("All submitted information will be stored securely in Google Sheets for review by course administrators.")
    )
  )
)

# Server Logic
server <- function(input, output, session) {

  # Reactive value to store team member count
  team_count <- reactiveVal(0)

  # Generate team member input forms
  observeEvent(input$generate_team_form, {
    team_count(input$num_members)
  })

  # Render team member UI dynamically
  output$team_members_ui <- renderUI({
    n <- team_count()
    if (n > 0) {
      lapply(1:n, function(i) {
        tagList(
          wellPanel(
            h4(paste("Team Member", i)),
            textInput(paste0("team_name_", i),
                      "Full Name*",
                      placeholder = "Jane Doe"),
            textInput(paste0("team_email_", i),
                      "Email Address*",
                      placeholder = "jane.doe@example.com"),
            fileInput(paste0("team_resume_", i),
                      "Upload Resume*",
                      accept = c(".pdf", ".doc", ".docx", ".txt"))
          )
        )
      })
    }
  })

  # Handle form submission
  observeEvent(input$submit, {

    # Validate main email
    if (input$main_email == "") {
      output$status_message <- renderText({
        "ERROR: Please provide a main contact email address."
      })
      return()
    }

    # Email validation regex
    email_regex <- "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"

    if (!grepl(email_regex, input$main_email)) {
      output$status_message <- renderText({
        "ERROR: Please provide a valid email address."
      })
      return()
    }

    # Process based on application type
    if (input$app_type == "individual") {
      # Validate individual application
      if (input$ind_name == "" || input$ind_email == "" || is.null(input$ind_resume)) {
        output$status_message <- renderText({
          "ERROR: Please fill in all required fields (name, email, and upload resume)."
        })
        return()
      }

      if (!grepl(email_regex, input$ind_email)) {
        output$status_message <- renderText({
          "ERROR: Please provide a valid email address for the applicant."
        })
        return()
      }

      # Prepare individual data
      tryCatch({
        # Create data frame for individual
        app_data <- data.frame(
          Timestamp = as.character(Sys.time()),
          Main_Contact_Email = input$main_email,
          Application_Type = "Individual",
          Member_Number = 1,
          Name = input$ind_name,
          Email = input$ind_email,
          Resume_Filename = input$ind_resume$name,
          Resume_Size_KB = round(input$ind_resume$size / 1024, 2),
          stringsAsFactors = FALSE
        )

        # Save to Google Sheets
        save_to_sheets(app_data, input$ind_resume, session)

      }, error = function(e) {
        output$status_message <- renderText({
          paste("ERROR submitting application:", e$message)
        })
      })

    } else {
      # Validate team application
      n <- team_count()
      if (n == 0) {
        output$status_message <- renderText({
          "ERROR: Please generate team member forms first."
        })
        return()
      }

      # Collect and validate team data
      team_data <- list()
      all_valid <- TRUE
      error_msg <- ""

      for (i in 1:n) {
        name <- input[[paste0("team_name_", i)]]
        email <- input[[paste0("team_email_", i)]]
        resume <- input[[paste0("team_resume_", i)]]

        if (is.null(name) || name == "" || is.null(email) || email == "" || is.null(resume)) {
          all_valid <- FALSE
          error_msg <- paste("ERROR: Please complete all fields for Team Member", i)
          break
        }

        if (!grepl(email_regex, email)) {
          all_valid <- FALSE
          error_msg <- paste("ERROR: Invalid email address for Team Member", i)
          break
        }

        team_data[[i]] <- list(
          name = name,
          email = email,
          resume = resume
        )
      }

      if (!all_valid) {
        output$status_message <- renderText(error_msg)
        return()
      }

      # Prepare team data
      tryCatch({
        # Create data frame for team
        app_data <- data.frame(
          Timestamp = as.character(Sys.time()),
          Main_Contact_Email = input$main_email,
          Application_Type = "Team",
          Member_Number = 1:n,
          Name = sapply(team_data, function(x) x$name),
          Email = sapply(team_data, function(x) x$email),
          Resume_Filename = sapply(team_data, function(x) x$resume$name),
          Resume_Size_KB = sapply(team_data, function(x) round(x$resume$size / 1024, 2)),
          stringsAsFactors = FALSE
        )

        # Save to Google Sheets
        save_to_sheets(app_data, team_data, session)

      }, error = function(e) {
        output$status_message <- renderText({
          paste("ERROR submitting application:", e$message)
        })
      })
    }
  })

  # Function to save data to Google Sheets
  save_to_sheets <- function(data, resume_info, session) {
    tryCatch({
      # Authenticate with Google Sheets
      # Note: This requires setting up authentication first
      # See README.md for setup instructions

      # Check if GOOGLE_SHEETS_URL environment variable is set
      sheet_url <- Sys.getenv("GOOGLE_SHEETS_URL")

      if (sheet_url == "") {
        output$status_message <- renderText({
          paste(
            "ERROR: Google Sheets URL not configured.\n",
            "Please set the GOOGLE_SHEETS_URL environment variable.\n",
            "See README.md for instructions."
          )
        })
        return()
      }

      # Authenticate (using cached credentials or service account)
      gs4_auth(
        cache = ".secrets",
        email = TRUE
      )

      # Append data to sheet
      sheet_append(
        ss = sheet_url,
        data = data,
        sheet = "Applications"
      )

      output$status_message <- renderText({
        paste(
          "SUCCESS!\n",
          "Your application has been submitted successfully.\n",
          "Timestamp:", data$Timestamp[1], "\n",
          "Application Type:", data$Application_Type[1], "\n",
          "Number of applicants:", nrow(data), "\n\n",
          "You will be contacted at", data$Main_Contact_Email[1]
        )
      })

      # Optionally reset form
      # session$reload()

    }, error = function(e) {
      output$status_message <- renderText({
        paste(
          "ERROR saving to Google Sheets:",
          e$message,
          "\n\nPlease check:\n",
          "1. Google Sheets authentication is configured\n",
          "2. The sheet URL is correct\n",
          "3. You have write permissions to the sheet\n",
          "4. The sheet has a tab named 'Applications'"
        )
      })
    })
  }
}

# Run the application
shinyApp(ui = ui, server = server)
