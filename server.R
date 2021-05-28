server <- function(input, output, session) {
  
  # create a list of spreadsheets to be merged and returned at the end
  spreadsheet = reactive({
    files <- list()
    spreads <- list.files(here("data"))
    for(spread in spreads){
      if(gsub(".txt","",spread) %in% input$datasets)
        files[[length(files)+1]] <- here("data", spread)
    }
    csv_files <- lapply(files, function(i){
      read_abcd_table(i)
    })
    if(length(csv_files) > 1){
      reduced_files <- csv_files %>% reduce(full_join)
      final_spread <- covariates %>% full_join(reduced_files, by = c("src_subject_id","eventname"))
    }
    else if(length(csv_files) == 1){
      final_spread <-  covariates %>% full_join(csv_files[[1]], by = c("src_subject_id", "eventname"))
    }
    return(final_spread)
  })
  
  outVar = reactive({
    # reactively return a list of variables based on the dataset(s) selected
    return(names(spreadsheet()))
  })
  
  observe({
    # if spreadsheet(s) is selected, update the list of variables shown, otherwise leave it empty
    if(length(input$datasets > 0)){
      updateSelectInput(session, "variables",
                        choices = outVar())
      updateCheckboxGroupInput(session, "year",
                               label = "2) Optional: Select which year/visit to include (default is all)",
                               choices = c(spreadsheet() %>% select("eventname") %>% distinct())[[1]])
    } else {
      updateSelectInput(session, "variables",
                        choices = "")
      updateCheckboxGroupInput(session,"year",
                               label = character(0),
                               choices = character(0))
      # output$skim_table <- NULL
    }
  })
  
  final_spreadsheet = reactive({
    if(!is.null(input$uploadFilter) & length(input$year) > 0){
      ext <- input$uploadFilter$datapath
      csv = read_csv(ext)
      spread = spreadsheet() %>% filter(eventname %in% input$year) %>% filter(src_subject_id %in% csv$`src_subject_id`)
    } else if(length(input$year) > 0){
      spread = spreadsheet() %>% filter(eventname %in% input$year)
    } else if(!is.null(input$uploadFilter)){
      ext <- input$uploadFilter$datapath
      csv = read_csv(ext)
      spread = spreadsheet() %>% filter(eventname %in% input$year) %>% filter(src_subject_id %in% csv$`src_subject_id`)
    } else {
      spread = spreadsheet()
    }
    return(spread %>% mutate_if(is_all_numeric, as.numeric))
  })
  
  output$table <- DT::renderDataTable({
    req(input$datasets)
    if(length(input$variables) == 0){
      DT::datatable(data = final_spreadsheet(),
                    options = list(pageLength = 10,
                                   scrollX = TRUE),
                    rownames = FALSE)
    } else {
    DT::datatable(data = final_spreadsheet() %>% select(input$variables),
                  options = list(pageLength = 10,
                                 scrollX = TRUE),
                  rownames = FALSE)
    }
  })
  
  # filtered_final <- reactive({
  #   req(input$uploadFilter)
  #   ext <- tools::file_ext(input$uploadFilter$name)
  #   switch(ext,
  #          csv = read_csv(ext),
  #          validate("Invalid file; Please upload a .csv file")
  #          )
  #   final_spreadsheet = final_spreadsheet() %>% filter('src_subject_id' %in% names(csv)[1])
  # })
  # 
  # observe({
  #   if(!is.null(input$uploadFilter)){
  #     ext <- tools::file_ext(input$uploadFilter$name)
  #     switch(ext,
  #            csv = read_csv(ext),
  #            validate("Invalid file; Please upload a .csv file")
  #     )
  #     final_spreadsheet = final_spreadsheet() %>% filter('src_subject_id' %in% names(csv)[1])
  #   }
  # })
  
  
  # skim_tab <- eventReactive(input$datasets,{
  #   if(is.null(input$datasets)){
  #     sum_tab <- NULL
  #   } else {
  #     sum_tab <- final_spreadsheet() %>% skim() %>% select(-c(complete_rate,character.whitespace, character.n_unique))
  #   }
  #   sum_tab
  # })
  # 
  # observeEvent(input$skim,{
  #   req(input$datasets)
  #   output$skim_table <- renderPrint(skim_tab())
  # })
  
  output$download_data <- downloadHandler(
    filename = function(){
      if(!is.na(input$title)){
        paste(Sys.Date(),"_", input$title, ".csv", sep = "")
      } else {
        paste(Sys.Date(),"-ABCD-data", ".csv", sep = "")
      }
    },
    content = function(file){
      write_csv(final_spreadsheet() %>% select(input$variables), file, na = "")
    }
  )
}