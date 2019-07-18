ui <- fluidPage(
  titlePanel(title="ABCD Database Builder 2.0"),
  sidebarLayout(
    sidebarPanel(
<<<<<<< HEAD
      tags$h3("How the app works:"),
      tags$p("This Web App that allows you to build and download a large spreadsheet containing all the variables 
             you're interested in analyzing from the ABCD Dataset."),
      tags$p("If you don't want to deal with selecting specific variables, simply leave the second textbox blank, 
             and the downloadable file will contain all the variables contained in the spreadsheets you've selected."),
      br(),
      tags$h4("VARIABLES AUTOMATICALLY INCLUDED:"),
      tags$ul(
        tags$li("Subject ID"),
        tags$li("Event Type"),
        tags$li("Age"),
        tags$li("Sex"),
        tags$li("Combined Parent Income"),
        tags$li("Parent highest education"),
        tags$li("Partner highest education"),
        tags$li("Site ID"),
        tags$li("Family ID")),
      tags$em("These covariates were pulled from: ABCD Longitudinal Tracking, ABCD Parent Demographics Survey,
              ABCD Parent Demographics Survey, and ABCD Longitudinal Parent Demographics Survey."),
      br(),
      tags$h4(tags$a(href = "https://nda.nih.gov/data_dictionary.html?source=ABCD%2BRelease%2B2.0&submission=ALL",
                     target = "_blank",
             "**Check out the ABCD Data Dictionary to find your spreadsheets and variables of interest. Then: **")),
      br(),
=======
      tags$h4(tags$a(href = "https://nda.nih.gov/data_dictionary.html?source=ABCD%2BRelease%2B2.0&submission=ALL",
                     target = "_blank",
             "**Check out the ABCD Data Dictionary to find your spreadsheets and variables of interest.**")),
      hr(),
>>>>>>> 0919832ef671684acceb99f13c69eb63d666113a
      selectInput(inputId = "datasets",
                  label = "1) Search for and select your dataset(s):",
                  selected = "",
                  choices = gsub(".Rds", "", list.files(here("2.0-ABCD-Release-R-format"), pattern = ".Rds")),
                  multiple = TRUE
      ),
      hr(),
      selectInput(inputId = "variables",
                  label = "2) Select variables of interest (NOTE: Leave blank if you want all variables from all spreadsheets 
                  to be included.)",
                  choices = "",
                  multiple = TRUE
      ),
<<<<<<< HEAD

=======
      tags$h5("**VARIABLES AUTOMATICALLY INCLUDED:**"),
      tags$ul(
        tags$li("Subject ID"),
        tags$li("Event Type"),
        tags$li("Age"),
        tags$li("Sex"),
        tags$li("Combined Parent Income"),
        tags$li("Parent highest education"),
        tags$li("Partner highest education"),
        tags$li("Site ID"),
        tags$li("Family ID")),
>>>>>>> 0919832ef671684acceb99f13c69eb63d666113a
      hr(),
      textInput(inputId = "title",
                label = "3) Name the download file:",
                value = NA
      ),
      downloadButton("download_data", "Download Data"),
      br(),hr(),
      tags$p("Built and maintained by:",
             tags$em(
               tags$a(href = "https://twitter.com/NguyenHPhil",
                      target = "_blank",
                      "Phil Nguyen, ABCD Study Research Assistant @ UVM")
               )
<<<<<<< HEAD
             ),
      tags$p("Source",
             tags$a(href = "https://github.com/nguyenhphilip/ABCD_Data_Explorer",
                    target = "_blank",
                    "code."
                    )
=======
>>>>>>> 0919832ef671684acceb99f13c69eb63d666113a
             )
      ),
    mainPanel(
      HTML(paste0("Once you've selected your variables of interest, a preview of your spreadsheet will be shown below.")),
      br(),
      h3("Preview:"),
      fluidRow(
        column(
          DT::dataTableOutput(outputId = "table"),
          width = 12
        )
        )
      )
    )
  )