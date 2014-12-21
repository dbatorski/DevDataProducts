library(shiny)

shinyUI(navbarPage("Internet access and broadband capacity in Poland",
  tabPanel("Introduction",
    fluidRow(
      column(2),
      column(8,
        includeMarkdown("Introduction.md")
      ),
      column(2)
    )
  ),
  tabPanel("Internet speed 2003-2013",
    sidebarLayout(
      sidebarPanel(
        h2("Selection panel"),
        p("This plot presents the distribution of internet connections with different bandwiths in households in Poland. 
          You may see a rapid growth of internet access with higher speeds."),
        checkboxGroupInput("id1", "Select year:",
                       c("2003" = "1",
                         "2005" = "2",
                         "2007" = "3",
                         "2009" = "4",
                         "2011" = "5",
                         "2013" = "6"),
                       selected=1)
        #submitButton('Submit')
      ),
      mainPanel(
        # Show a tabset that includes a plot, summary, and
        # table view of the generated distribution
        h2("Frequency of internet connections with different bandwidths"),
        plotOutput('newHist')
      )
    )
  ),
  tabPanel("Prediction 2020",
    sidebarLayout(
      sidebarPanel(
        h2("Selection panel"),
        p("Between 2003 and 2013 an average internet speed in connected households in Poland doubled every 18 months. 
          Here you can test 3 scenarios to predict future average values of internet bandwith as well as percentages 
          of households with 30Mbps and 100Mbps."),
        radioButtons("id2", "Select scenario:",
                          c("optimistic" = "1",
                            "realistic" = "2",
                            "pessimistic" = "3"),
                          selected=2),
        dateInput("date", "Prediction is made for:")
        #submitButton('Submit')
        ),
      mainPanel(
        # Show a tabset that includes a plot, summary, and
        # table view of the generated distribution
        h2("Prediction of average internet speed in Poland"),
        plotOutput('newPlot')
      )
    )
  )
))

