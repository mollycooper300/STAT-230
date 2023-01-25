
#load necessary libraries
library(quantmod)
library(shinythemes)
library(tidyverse)
library(janitor)
library(anytime)

#read in data, remove X's from date columns
price_data <- read.csv('final.csv') %>%
  janitor::clean_names()

names(price_data)[5:953] <- substring(names(price_data)[5:953], 2, 11)

sector_data <- read.csv('sector_data.csv')

#make dates into a vector to prepare for plotting
date_list <- colnames(price_data)[5:953]

# set sector choices for Sector Analysis tab
sector_choices <- as.list(c( unique(sector_data$Symbol)))
sector_choices_names <- c("Healthcare"
                          , "Industrials"
                          , "Consumer Staples"
                          , "Consumer Discretionary"
                          , "Materials"
                          , "Utilities"
                          , "Financials"
                          , "Energy"
                          , "Technology"
                          , "Real Estate"
                          , "Communication Services")
names(sector_choices) <- sector_choices_names


#Set app titles and input for plots
ui <- fluidPage(
  
  h1("Stock Price Data 2017-Present"),
  
  sidebarLayout(
    sidebarPanel(
      selectizeInput(inputId = "stock"
                     , label = "Choose Stock Ticker(s)"
                     , choices = companies_table$Symbol
                     , selected = ("MMM, AAPL, FB")
                     , multiple = TRUE
                     , options = NULL),
      
      selectizeInput(inputId = "sector"
                     , label = "Choose S&P Sector"
                     , choices = sector_choices
                     , selected = ""
                     , multiple = TRUE
                     , options = NULL)
    ),
    # Set tab names
    mainPanel(
      
      tabsetPanel(type = "tabs"
                  , tabPanel("Plot of Prices"
                             , plotOutput(outputId = "line"))
                  , tabPanel("Bar Plot of PE Ratios", plotOutput(outputId = "bar"))
                  , tabPanel("Sector Analysis", plotOutput(outputId = "sector"))
      )
    )
  )
)
# Set plot output
server <- function(input,output){
  # Data for Tab 1
  # Filter data by stock selection
  use_data <- reactive({
    data <- filter(price_data, symbol %in% input$stock)
  })
  # Data for Tab 3
  # Filter data by Sector selection
  use_data2 <- reactive({
    data <- filter(sector_data, Symbol %in% input$sector)
  })
  # Convert to long format for plotting
  long_data <- reactive({
    use_data() %>% gather(key = "Date", value = "Price", date_list) %>%
      mutate(Date = anydate(Date))
  })
  
  
  # Plot for Tab 1
  output$line <- renderPlot({
    ggplot(data = long_data(), aes(x = Date, y =  Price, color = name)) +
      geom_line() +
      xlab("Date") +
      ylab("Price ($)") +
      labs(color = "Company Name") +
      ggtitle("Share Price Performance") +
      theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
            axis.title.y = element_text(size = 14),
            axis.title.x = element_text(size = 14),
            axis.text.x = element_text(size = 12),
            legend.text = element_text(size = 10))
  })
  
  # Plot for Tab 3
  output$sector <- renderPlot({
    ggplot(data = use_data2(), aes(x = as.Date(Date), y =  Open, color = Sector)) +
      geom_line() +
      xlab("Date") +
      ylab("Price ($)") +
      ggtitle('Sector Index Price Performance') +
      theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
            axis.title.y = element_text(size = 14),
            axis.title.x = element_text(size = 14),
            axis.text.x = element_text(size = 12),
            legend.text = element_text(size = 10))
  })
  
  # Plot for Tab 2
  output$bar <- renderPlot({
    ggplot(data = use_data(), aes(y = p_e_ratio, x = name)) +
      geom_bar(stat = 'identity', position = 'dodge',
               aes(fill = as.factor(symbol)), show.legend = FALSE, width = 0.3) +
      xlab('Companies') +
      ylab('Price/Earnings Ratio') +
      ggtitle('Comparison of P/E Ratios by Company') +
      theme(plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
            axis.title.y = element_text(size = 14), 
            axis.text.x = element_text(size = 12),
            axis.title.x = element_text(size = 14))
  })
  
  
}

# call to shinyApp
shinyApp(ui = ui, server = server)