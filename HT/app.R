if(!require(readr)) install.packages("readr", repos = "http://cran.us.r-project.org")
if(!require(magrittr)) install.packages("magrittr", repos = "http://cran.us.r-project.org")
if(!require(rvest)) install.packages("rvest", repos = "http://cran.us.r-project.org")
if(!require(readxl)) install.packages("readxl", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(DT)) install.packages("DT", repos = "http://cran.us.r-project.org")

if(!require(maps)) install.packages("maps", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(reshape2)) install.packages("reshape2", repos = "http://cran.us.r-project.org")
if(!require(ggiraph)) install.packages("ggiraph", repos = "http://cran.us.r-project.org")
if(!require(RColorBrewer)) install.packages("RColorBrewer", repos = "http://cran.us.r-project.org")
if(!require(leaflet)) install.packages("leaflet", repos = "http://cran.us.r-project.org")
if(!require(plotly)) install.packages("plotly", repos = "http://cran.us.r-project.org")
if(!require(geojsonio)) install.packages("geojsonio", repos = "http://cran.us.r-project.org")
if(!require(shiny)) install.packages("shiny", repos = "http://cran.us.r-project.org")
if(!require(shinyWidgets)) install.packages("shinyWidgets", repos = "http://cran.us.r-project.org")
if(!require(shinydashboard)) install.packages("shinydashboard", repos = "http://cran.us.r-project.org")
if(!require(shinythemes)) install.packages("shinythemes", repos = "http://cran.us.r-project.org")
if(!require(sp)) install.packages("sp", repos = "http://cran.us.r-project.org")
if(!require(countrycode)) install.packages("countrycode", repos = "http://cran.us.r-project.org")

worldcountry <- geojson_read("C:/Users/hthor/OneDrive/Documents/GitHub/biost2094_project/data/custom.geo.json", what = "sp")
countries <- read.csv("C:/Users/hthor/OneDrive/Documents/GitHub/biost2094_project/data/concap.csv")
vaccines <- read.csv("C:/Users/hthor/OneDrive/Documents/GitHub/biost2094_project/data/clean_3.csv")

vaccines$iso <- countrycode(vaccines$country, 'country.name','iso3c')
countries$iso <- countrycode(countries$CountryName, 'country.name','iso3c')


vax_max <- vaccines %>% group_by(iso) %>% summarize(max = max(people_vaccinated))
country_pops <- vaccines %>% group_by(iso) %>% summarize(max2 = max(population.x))
total_vax <- vaccines %>% group_by(iso) %>% summarize(max3 = max(cumsum_total_vaccination))



total <- inner_join(vax_max, countries, by = "iso")
total2 <- inner_join(country_pops, total, by = "iso")
total3 <- inner_join(total_vax, total2, by = "iso")
total3 <- total3[-c(54, 82), ]


leafletmap <- leaflet(worldcountry) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(lng = total3$CapitalLongitude,
                   lat = total3$CapitalLatitude,
                   radius = round(total3$max/total3$max2*30, digits = 2),
                   label = total3$CountryName,
                   popup = paste("<strong>", total3$CountryName, "</strong>", "<br>",
                                 "Population:", prettyNum(total3$max2, big.mark="," , preserve.width="none"), "<br>",
                                 "People Fully Vaccinated:", prettyNum(total3$max,big.mark=",", preserve.width="none"), "<br>",
                                 "Percent Fully Vaccinated:", round(total3$max/total3$max2*100, digits = 2), "%", "<br>",
                                 "Total Vaccines Administered:", prettyNum(total3$max3,big.mark=",", preserve.width="none", round = 0)))

# Putting the map into the ui

ui <- navbarPage(title = "COVID-19 Vaccine",
                   # First Page
                   tabPanel(title = "About the site",
                            tags$br(),tags$br(),tags$h4("Background"),
                            "SARS-CoV-2 has impacted the world in an unprecedented way,
                      with the world having changed significantly since H2N2/H3N2
                      pandemics in the mid 1900’s and even more since the major comparison
                      point, the 1918 flu pandemic. The world is much more global now.
                      Adjusted for inflation, the value of goods shipped internationally in
                      2014 was six times higher than the value of shipped goods in 1969, the
                      last year of the H3N2 pandemic. In comparison to 1919, that number goes
                      all the way to 53 times as much as shipped in 2014 (Beltekian). As such,
                      returning to normalcy is a worldwide goal.",
                            tags$br(),tags$br(),
                            "Right now, the main indicator
                      we have is the vaccination rate for each country, each of which has its
                      own unique situation and challenges to account for, so viewing that data
                      quickly and clearly is an important piece to know how close we are to the
                      end of the pandemic.",

                            tags$br(),tags$br(),tags$h4("Code"),
                            "Code and input data used to generate this Shiny mapping tool are available on ",tags$a(href="https://github.com/czang97/biost2094_project", "Github."),
                   ),
                 tabPanel(title = "Worldwide Vaccine Progress"),
                 tabPanel(title = "Vaccine Progress Map",
                          div(class="outer",
                              tags$head(includeCSS("styles.css")),
                              leafletOutput("leafletmap", width="100%", height="100%"),
                              ),

                 ),
                 tabPanel(title = "US Vaccine Progress"),
                 tabPanel(title = "Reaching Herd Immunity")
)


# Define server logic ----
server <- function(input, output) {

}

# Run the app ----
shinyApp(ui = ui, server = server)

