navbarPage(
  "Analysis Report",
  id = "nav",
  # TODO : add showcase 
  tabPanel(
    "Interactive Map",
    div(
      class = "outer",
      tags$head(
        includeCSS("styles.css"),
        includeScript("gomap.js")),
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = TRUE,
        draggable = FALSE,
        top = 55,
        left = "auto",
        right = 10,
        bottom = "auto",
        width = "30%",
        height = "100%",
        
        h2("Daily reported cases:"),
        # TODO : change to slider
        # sliderInput("selected_date",
        #             "Dates:",
        #             min = as.Date("2020-01-28","%Y-%m-%d"),
        #             max = as.Date("2020-03-27","%Y-%m-%d"),
        #             value=as.Date("2020-03-27"),
        #             timeFormat="%Y-%m-%d"),
        selectInput("selected_date", "Select Dates", g_option_dates),
        # TODO : change to slider
        selectInput("selected_category", "Select variables", g_option_categories),
        tableOutput("data")
      ),
      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width = "70%", height = "100%")
    )
  ),
  tabPanel("DataTable", DTOutput(outputId = "table"))
)
