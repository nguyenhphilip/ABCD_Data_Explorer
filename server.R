server <- function(input, output, session) {
  
  # create a list of spreadsheets to be merged and returned at the end
  spreadsheet = reactive({
    files <- list()
    spreads <- list.files(here("2.0-ABCD-Release-updated"))
    for(spread in spreads){
      if(gsub(".csv","",spread) %in% input$datasets)
        files[[length(files)+1]] <- here("2.0-ABCD-Release-updated", spread)
    }
    csv_files <- lapply(files, function(i){
      readr::read_csv(i) %>% select(-dataset_id)
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
    # reactively return a list of variables based on thedataset(s) selected
    return(names(spreadsheet()))
  })
  
  observe({
    # if spreadsheet(s) is selected, update the list of variables shown, otherwise leave it empty
    if(length(input$datasets > 0)){
      updateSelectInput(session, "variables",
                        choices = outVar())
    } else {
      updateSelectInput(session, "variables",
                        choices = "")
    }
  })

  output$table <- DT::renderDataTable({
    req(input$datasets)
    if(length(input$variables) == 0){
      DT::datatable(data = spreadsheet(),
                    options = list(pageLength = 10,
                                   scrollX = TRUE),
                    rownames = FALSE)
    } else {
    DT::datatable(data = spreadsheet() %>% select(input$variables),
                  options = list(pageLength = 10,
                                 scrollX = TRUE),
                  rownames = FALSE)
    }
  })
  
  output$download_data <- downloadHandler(
    filename = function(){
      if(!is.na(input$title)){
        paste(Sys.Date(),"_", input$title, ".csv", sep = "")
      } else {
        paste(Sys.Date(),"-ABCD-data", ".csv", sep = "")
      }
    },
    content = function(file){
      write_csv(spreadsheet() %>% select(input$variables), file, na = "")
    }
  )
}
