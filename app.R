# ------------------------------------------------------------
# Título: Trabajo Practico N"2 Analisis Inteligente de Datos
# Autor: Gustavo Calanchini
# Fecha: 5 de diciembre de 2024
# Descripción: Aplicacion Shiny para la visualizacion de datos,


#  Librerías a utilizar  --------------------------------------------------
library(shiny)
library(tidyverse)
library(plotly)
library(bslib)

# Importacion de la base de datos -----------------------------------------
base_datos <- readRDS("baseDatosTP2.rds")

# Listado de los commodities y activos financieros disponibles
# son los nombres de las columnas de la base
opciones_commodity <- base_datos |>
  select(!contains("Index")) |>
  colnames() |>
  sort()

# Definicion de la Interfaz de Usuario ------------------------------------
ui <- fillPage(
  theme = bs_theme(
    version = 5, # Usar la versión más reciente de Bootstrap 5
    bootswatch = "darkly", # Tema oscuro de Bootswatch
    primary = "#FF7F27" # Color principal (verde)
  ),
  
  titlePanel("Comparador de Commodities y Activos Financieros", 
             windowTitle = "Commodities Comparator"), # Titulo de la aplicación Shiny
  
  sidebarLayout(
    position = "right",
    
    sidebarPanel(
      class = "sidebar",
      sliderInput(
        inputId = "rangoFechas", # ID del widget
        label = "Rango de Fechas: ", # Título a mostrar en la app
        value = c(ymd("2010-01-01"), as_date(today())), # Valor seleccionado inicialmente
        min = min(base_datos$Index), # Mínimo valor posible
        max = max(base_datos$Index), # Máximo valor posible
        timeFormat = "%b-%y"
      ),
      
      selectInput(
        inputId = "commodity1", # ID del widget
        label = "Seleccione el 1er Commodity (Numerador): ", # Selección del Commodity
        choices = opciones_commodity, # Opciones disponibles
      ),
      
      selectInput(
        inputId = "commodity2", # ID del widget
        label = "Seleccione el 2do Commodity (Denominador): ", # Selección del Commodity
        choices = opciones_commodity, # Opciones disponibles
      )
    ),
    
    mainPanel(
      class = "main",
      plotlyOutput(outputId = "MiGrafico")
    )
  )
)


# Definición del Server ---------------------------------------------------
server <- function(input, output, session) {
  # Inputs de datos reactivos
  commodity1_reactivo <- reactive({
    input$commodity1
  })
  commodity2_reactivo <- reactive({
    input$commodity2
  })
  fechas_reactivo <- reactive({
    input$rangoFechas
  })
  titulo_reactivo <- reactive({
    paste0(
      "Valor de ",
      str_to_upper(commodity1_reactivo()), " medido en unidades de ", 
      str_to_upper(commodity2_reactivo()), " entre: ", 
      paste0(format.Date(fechas_reactivo(), "%b %Y", 
                        date_names = "es"), 
             collapse = " - ")
    )
  })
  
  output$MiGrafico <- renderPlotly({
    grafico <- base_datos |>
      filter(
        Index >= fechas_reactivo()[1],
        Index <= fechas_reactivo()[2],
        !is.na(get(commodity1_reactivo())) | !is.na(get(commodity2_reactivo()))
      ) |>
      mutate(
        relacion = get(commodity1_reactivo()) / get(commodity2_reactivo()),
        texto = paste0(
          "<b>Valor: </b>", round(relacion, digits = 4), "<br>",
          "<b>Fecha: </b>", format.Date(Index, "%b%y"), "<br>"
        )
      ) |>
      filter(!is.na(relacion) & !is.infinite(relacion)) |> 
      ggplot(
        #En aes se define group para que funcione geom_line()
        aes(x = Index, y = relacion, text = texto, group = 1)) + 
      geom_point(size = 0.5, colour = "yellow") +
      geom_line(size = 0.6, colour = "#FF7F27") +
      labs(
        title = titulo_reactivo()
      ) +
      scale_y_continuous(name = "Relacion") + 
      scale_x_date(name = "", date_labels = "%b-%y") +
      theme_minimal()+
      theme(
        plot.background = element_rect(fill = "black", color = NA),
        panel.background = element_rect(fill = "black", color = NA),
        panel.grid = element_line(color = "gray"),
        plot.title = element_text(color = "white"),
        axis.text = element_text(color = "white"),
        axis.title = element_text(color = "white"),
        legend.position = "none"
      ) # Sobre el tema minimal se personalizan los elementos del gráfico
    
    ggplotly(grafico, tooltip = "text")
  })
}


# Ejecución de la aplicación --------------------------------------------
shinyApp(ui = ui, server = server)