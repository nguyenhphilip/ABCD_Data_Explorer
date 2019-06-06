server <- function(input, output, session) {
  # reactively return a list of spreadsheets based on the category(s) selected
  outSpreads = reactive({
    return(createCSVS(input$categories))
  })
  
  observe({
    # if a category is selected, update the list of spreadsheets shown, otherwise leave it empty
    if(length(input$categories > 0)){
      updateSelectInput(session, "datasets",
                        choices = outSpreads())
    } else {
      updateSelectInput(session, "datasets",
                        choices = "")
    }
  })
  
  outVar = reactive({
    # reactively return a list of variables based on the category(s) and dataset(s) selected
    req(input$categories)
    return(createVars(input$categories, input$datasets))
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
  # create a list of spreadsheets to be merged and returned at the end
  spreadsheet = reactive({
    files <- list()
    for(category in input$categories)
    {
      spreads <- list.files(here("2.0_NDA_Data", category))
      for(spread in spreads){
        if(gsub(".csv","",spread) %in% input$datasets)
          files[[length(files)+1]] <- here("2.0_NDA_Data",category, spread)
      }
    }
    csv_files <- lapply(files, function(i){
      read.csv(i, colClasses = "character")
    })
    if(length(input$variables) > 0 & length(csv_files)){
      reduced_files <- csv_files %>% reduce(full_join)
      final_spread <- reduced_files %>% left_join(covariates, by = c("src_subject_id","eventname")) %>% 
        select(covariate_vars,input$variables)
    } else if(length(input$variables) == 0 & length(csv_files) > 1){
      reduced_files <- csv_files %>% reduce(full_join)
      final_spread <- reduced_files %>% left_join(covariates, by = c("src_subject_id","eventname"))
    }
    else if(length(input$variables) == 0 & length(csv_files) == 1){
      final_spread <- csv_files[[1]] %>% left_join(covariates, by = c("src_subject_id", "eventname"))
    }
    return(final_spread)
  })
  
  output$table <- DT::renderDataTable({
    req(input$datasets)
    DT::datatable(data = spreadsheet(),
                  options = list(pageLength = 10,
                                 scrollX = TRUE),
                  rownames = FALSE)
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
      write.csv(spreadsheet(), file, row.names = FALSE, na = "")
    }
  )
}