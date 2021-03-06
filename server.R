function(input, output, session) {
  
  inputDate = reactive({
    input$selected_date
  })
  
  target_quo = reactive({
    parse_quo(input$selected_category, env = caller_env())
  })
  
  dftable <- reactive({
    analytics=filter(g_covid_data, Date == inputDate())
    arrange(analytics, desc(!!target_quo()))        
  })
  
  dfmap <- reactive({
    filtered_data_by_date <- filter(g_covid_data, Date == inputDate())
    # filtered_data_by_date <- filter(g_covid_data, Date == "2020-03-27")
    filtered_country_df_by_date <- left_join(g_country_df, filtered_data_by_date, by="Country")
    # foundNaSubset <- filtered_country_df_by_date[which(is.na(filtered_country_df_by_date$Date)),]
    selected_column <- select(filtered_country_df_by_date, input$selected_category)
    # selected_column <- select(option_categories[1])
    # watisthis <- paste(countryCaseByDate$Country, ":", selected_column[,1])
  })
  
  df_pop_ratio <- reactive({
    filtered_data_by_date <- filter(g_covid_data, Date == inputDate())
    filtered_country_df_by_date <- inner_join(g_pop_est, filtered_data_by_date, by="Country")
    # filtered_country_df_by_date <- impute(filtered_country_df_by_date)
    selected_column <- select(filtered_country_df_by_date, input$selected_category)
    filtered_country_df_by_date$ratio <- select(filtered_country_df_by_date, input$selected_category) / filtered_country_df_by_date$Population * 1000000
    
    # test block : 
    # # arrange(g_covid_data, g_covid_data$Country)
    # filtered_data_by_date <- filter(g_covid_data, Date == "2020-03-27")
    # filtered_country_df_by_date <- inner_join(g_pop_est, filtered_data_by_date, by="Country")
    # # filtered_country_df_by_date <- impute(filtered_country_df_by_date)
    # selected_column <- select(filtered_country_df_by_date, g_option_categories[1])
    # filtered_country_df_by_date$ratio <- select(filtered_country_df_by_date, g_option_categories[1]) / filtered_country_df_by_date$Population * 1000000
    # filtered_country_df_by_date
    
    # normalize/standardize data using "caret"
    trans = preProcess(filtered_country_df_by_date[,c(7)], method=c("BoxCox", "center", "scale", "pca"))
    filtered_country_df_by_date$ratio = predict(trans, filtered_country_df_by_date[,c(7)])
  })
  
  bins<-seq(from = 0, to = 100, by = 10)
  qpal <- colorNumeric(
    na.color = "white",
    palette = c("white", "orange", "red"),
    domain = c(0, 100)
  )
  
  # TODO : show daily increase instead of total.

  # TODO : maybe color is by % of confirmed case / population
  
  # TODO : the color too extreme, because the number too much different!!! find a way to lower the differences
  
  # Render map
  output$map <- renderLeaflet({
    leaflet(g_geojson) %>%
      addTiles() %>%
      addPolygons(stroke = FALSE,
                  smoothFactor = 0.3,
                  fillOpacity = 0.5,
                  label = paste(g_country_list, ":", df_pop_ratio()[,1]),
                  color = qpal(rescale(x = df_pop_ratio()[,1], to = c(0, 100),  na.rm=TRUE))
      ) %>%
      setView(lng = 0, lat = 40, zoom = 2) %>%
      addLegend(
        "bottomleft",
        pal = qpal,
        values = c(0,100),
        opacity = 0.7,
        labFormat = labelFormat(suffix = "%"),
      )
  })
  
  # Render table
  output$data <- renderTable({
    head((dftable()[, c("Country", input$selected_category), drop = FALSE]), 10)
  }, rownames = TRUE)

  output$table <- renderDataTable({
    datatable(g_covid_data)
  })
}