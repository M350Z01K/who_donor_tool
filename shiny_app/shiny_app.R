library(shiny)
library(dplyr)
library(DT)


df_new = readRDS("contributors_mapping_results_processed.rds")


col_choices = grep("yn_", colnames(df_new), value = T)
col_display = grep("yn_", colnames(df_new), value = T, invert = T)
col_choices_new = gsub("yn_|yn_focus_on_", "", col_choices)
colnames(df_new)[grep("yn_", colnames(df_new))] = col_choices_new
col_choices = col_choices_new




# 2. Shiny UI
ui <- fluidPage(
  titlePanel("WHO contributor search tool"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Select up to 3 columns to filter:"),
      hr(),
      
      # Filter Slot 1
      fluidRow(
        column(7, selectInput("col_pick_1", "Column 1", choices = col_choices, selected = col_choices[1])),
        column(5, selectInput("val_pick_1", "Value", choices = c("All", "yes", "no")))
      ),
      hr(),
      
      # Filter Slot 2
      fluidRow(
        column(7, selectInput("col_pick_2", "Column 2", choices = col_choices, selected = col_choices[2])),
        column(5, selectInput("val_pick_2", "Value", choices =  c("All", "yes", "no")))
      ),
      hr(),
      
      # Filter Slot 3
      fluidRow(
        column(7, selectInput("col_pick_3", "Column 3", choices = col_choices, selected = col_choices[3])),
        column(5, selectInput("val_pick_3", "Value", choices =  c("All", "yes", "no")))
      ),
      hr(),
      
      checkboxGroupInput(
        inputId = "cols_to_show",
        label = "Columns to display:",
        choices = col_display,
        selected = col_display[1:5] # Default check the first 5 columns
      )
      
    ),
    
    mainPanel(
      h4("Filtered Data"),
      textOutput("row_count"),
      br(),
      DTOutput("data_table")
    )
  )
)


# 3. Shiny Server
server <- function(input, output, session) {
  
  # Reactive filtering logic
  filtered_data <- reactive({
    req(df_new)
    res <- df_new
    
    # Map out the 3 pairs of inputs
    filter_slots <- list(
      list(col = input$col_pick_1, val = input$val_pick_1),
      list(col = input$col_pick_2, val = input$val_pick_2),
      list(col = input$col_pick_3, val = input$val_pick_3)
    )
    
    # Loop through the 3 slots and apply filter if value is not "All"
    for (slot in filter_slots) {
      if (!is.null(slot$col) && !is.null(slot$val) && slot$val != "All") {
        res <- res %>% filter(.data[[slot$col]] == slot$val)
      }
    }
    
    res
  })
  
  # Render table summary
  output$row_count <- renderText({
    paste("Showing", nrow(filtered_data()), "out of", nrow(df_new), "rows.")
  })
  
  # Render the data table
  output$data_table <- renderDT({
    req(filtered_data())
    
    # 3. Final selection: chosen columns MINUS the active filter columns
    final_cols <- setdiff(input$cols_to_show, col_choices)
    
    # Render table with only these columns (if any match)
    if(length(final_cols) == 0) {
      return(data.frame(Message = "No columns selected for display (or all selected columns are hidden by active filters)"))
    }
    
    display_df = filtered_data() %>% 
      select(final_cols)
    
    datatable(
      display_df,
      extensions = 'FixedHeader', # Enables the frozen header extension
      options = list(
        pageLength = -1,          # Disable pagination to show all rows on one page
        dom = 't',                # Only show the table ('t'), hide search boxes/pagination items
        fixedHeader = TRUE,       # Freeze the header row
        scrollY = "800px"         # Gives the table a fixed height box with its own scroll bar
      ),
      rownames = FALSE            # Hides row numbers
    )
  })
}

shinyApp(ui, server)