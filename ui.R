ui <- fluidPage(
  tags$style("#skim_tab{display:none;}"),
  titlePanel(title="ABCD Data Builder 3.0.0"),
  sidebarLayout(
    sidebarPanel(
      tags$h3("How the app works:"),
      tags$p("This Web App allows you to build and download a curated spreadsheet containing all the variables 
             you're interested in analyzing with the ABCD Dataset."),
      tags$p('First, an initial spreadsheet with common covariates is built from these files:'),
      tags$h5('ABCD Longitudinal Tracking (file: abcd_lt01.txt)'),
      tags$ul(
        tags$li('age'), 
        tags$li('eventname'), 
        tags$li('site'), 
        tags$li('sex')
        ),
      tags$h5('ABCD ACS Post Stratification Weights (file: acspsw03.txt)'),
      tags$ul(
        tags$li('race and ethnicity'),
        tags$li('family id')
        ),
      tags$h5('ABCD Longitudinal Parent Demographics Survey (file: abcd_lpds01.txt)'),
      tags$ul(
        tags$li('parent highest education'), 
        tags$li('combined household income')
        ),
      tags$h5('ABCD MR Info (file: abcd_mri01.txt)'),
      tags$ul(
        tags$li('scanner number')
        ),
      tags$p('Then any additional spreadsheets selected  will build off of this one.'),
      hr(),
      tags$h4(tags$a(href = "https://nda.nih.gov/data_dictionary.html?source=ABCD%2BRelease%2B3.0&submission=ALL",
                     target = "_blank",
                     "Check out the ABCD Data Dictionary to find your spreadsheets and variables of interest. Then:")),
      br(),
      selectInput(inputId = "datasets",
                  label = "1) Search for and select your dataset(s):",
                  selected = "",
                  choices = gsub(".txt", "", list.files(here("data"), pattern = ".txt")),
                  multiple = TRUE
      ),
      checkboxGroupInput(
        inputId = "year",
        label = character(0),
        choices = character(0)
      ),
      selectInput(inputId = "variables",
                  label = "2) Select variables of interest (NOTE: Leave blank if you want all variables from all selected spreadsheets 
                  to be included.)",
                  choices = "",
                  multiple = TRUE
      ),
      fileInput(inputId = "uploadFilter",
                accept = ".csv",
                placeholder = "Upload a file!",
                label = "3) (Optional) - If there are particular subjects you are using you can upload their IDs in a csv file and the final spreadsheet will be filtered by them. (Note that the uploaded csv file must have the subject IDs under one column, with header 'src_subject_id'.)",
                ),
      textInput(inputId = "title",
                label = "4) Name the download file.",
                value = NA
      ),
      downloadButton("download_data", "Download Data"),
      br(),
      tags$h4("*Refresh browser to reset fields and start over.*"),
      hr(),
      tags$p("Built and maintained by:",
             tags$em(
               tags$a(href = "https://philintheblank.me",
                      target = "_blank",
                      "Phil Nguyen, ABCD Study Research Assistant @ UVM")
             )
      ),
      tags$p("Source",
             tags$a(href = "https://github.com/nguyenhphilip/ABCD_Database_Builder",
                    target = "_blank",
                    "code."
             )
      )
      ),
    mainPanel(
      HTML(paste0("Once you've selected your variables of interest, a preview of your spreadsheet will be shown below.")),
      br(),
      fluidRow(
        column(
          h3("Table Preview:"),
          DT::dataTableOutput(outputId = "table"),
          width = 12
        )
        ) # ,
     # fluidRow(
     #   column(
     #     actionButton(inputId = "skim",
     #                  label = "Display a summary table of your data (best as a last step!)"),
     #     br(),
     #       verbatimTextOutput(outputId = "skim_table"),
     #       width = 12
     #     )
     #   )
      # htmlOutput("skim_table")
    )
    
    )
  )