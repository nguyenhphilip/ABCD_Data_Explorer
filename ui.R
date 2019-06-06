ui <- fluidPage(
  titlePanel(title="ABCD Data Downloader 2.0"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(inputId = "categories",
                         label = "1) Filter spreadsheets by category:",
                         choices = unique_cats
      ),
      hr(),
      selectInput(inputId = "datasets",
                  label = "2) Select dataset(s):",
                  selected = "",
                  choices = "",
                  multiple = TRUE
      ),
      hr(),
      selectInput(inputId = "variables",
                  label = "3) Select variables of interest (*NOTE: If you want all variables from all the spreadsheets you've selected, leave this blank):",
                  choices = "",
                  multiple = TRUE
      ),
      HTML(paste0("<h4> VARIABLES AUTOMATICALLY INCLUDED: </h4>
                  <ul>
                  <li>Subject's ID</li><li>Event Type</li>
                  <li>Age</li><li>Sex</li>
                  <li>Gender</li><li>Combined Parent Income</li>
                  <li>Parent Highest Education</li><li>Partner Highest Education</li>
                  <li>Site ID</li>
                  </ul>")),
      hr(),
      textInput(inputId = "title",
                label = "4) Name the download file:",
                value = NA
      ),
      downloadButton("download_data", "Download Data"),
      br(),hr(),
      HTML(paste0("Built and maintained by: 
                  <a href = 'https://twitter.com/NguyenHPhil', target = _blank>Phil Nguyen</a>")
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