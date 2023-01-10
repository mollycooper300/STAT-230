
library(shiny)

ui <- fluidPage(
  navlistPanel(
    tabPanel(sliderInput(inputId = "num",
                         label = "Choose a number",
                         value = 25, min = 1, max = 100)),
    tabPanel(textInput(inputId = "title",
                       label = "Histogram",
                       value = "title"))
    ),
  
  plotOutput("hist"),
  plotOutput("stats")
)
                
  sliderInput(inputId = "num", 
              label = "Choose a number", 
              value = 25, min = 1, max = 100)
  textInput(inputId = "title",
            label = "Histogram",
            value = "title")
  plotOutput("hist")
  verbatimTextOutput("stats")


server <- function(input, output) {
  output$hist <- renderPlot({
    hist(rnorm(input$num) , main = input$title)
  })
  output$stats <- renderPrint({
    summary(rnorm(input$num))
  })
}

shinyApp(ui = ui, server = server)




