# ------------------------------------------------------------
# Título: Trabajo Práctico N"2 Análisis Inteligente de Datos
# Autor: Gustavo Calanchini
# Fecha: 5 de diciembre de 2024
# Descripción: En este script se realizan las tareas de importación,
#              transformación, organización y limpieza de los datos para la
#              visualización en una aplicación Shiny.


# Librerías a utilizar ----------------------------------------------------
library(tidyverse)
library(pdfetch) # para funciones de importar datos de FRED y Yahoo Finance
library(xts) # para tratar con datos xts

# Importacion Datos ----------------------------------------------------------

# Las cotizaciones de los commodties se obtienen del sistema FRED - Reserva USA
# los commmodities elegidos son:
# MCOILWTICO Monthly Crude Oil Prices: West Texas Intermediate (WTI) - Cushing, Oklahoma
# PNGASEUUSDM  Global price of Natural gas, EU
# PCOALAUUSDM Global price of Coal, Australia
# PSOYBUSDM Global price of Soybeans
# PWHEAMTUSDM Global price of Wheat
# PCOTTINDUSDM Global price of Cotton
# PIORECRUSDM  Global price of Iron Ore
# PCOPPUSDM  Global price of Copper
# APU0000702111 Average Price: Bread, White, Pan (Cost per Pound/453.6 Grams) in U.S. City Average
# PBEEFUSDM  Global price of Beef
# APU0000FF1101 Average Price: Chicken Breast, Boneless (Cost per Pound/453.6 Grams) in U.S. City Average
# PBANSOPUSDM  Global price of Bananas
# PRICENPQUSDM Global price of Rice, Thailand
# PSUGAISAUSDM Global price of Sugar, No. 11, World
# PCOCOUSDM  Global price of Cocoa
# PPOULTUSDM Global price of Poultry
# PWOOLFUSDM Global price of Wool, Fine
# PFISHUSDM  Global price of Fish Meal
# PORANGUSDM Global price of Orange
# PPORKUSDM  Global price of Swine

# Importacion de datos de los commodities
df_commodities_xts <- merge(
  pdfetch_FRED("MCOILWTICO"), pdfetch_FRED("PNGASEUUSDM"),
  pdfetch_FRED("PCOALAUUSDM"), pdfetch_FRED("PSOYBUSDM"),
  pdfetch_FRED("PWHEAMTUSDM"), pdfetch_FRED("PCOTTINDUSDM"),
  pdfetch_FRED("PIORECRUSDM"), pdfetch_FRED("PCOPPUSDM"),
  pdfetch_FRED("APU0000702111"), pdfetch_FRED("PBEEFUSDM"),
  pdfetch_FRED("APU0000FF1101"), pdfetch_FRED("PBANSOPUSDM"),
  pdfetch_FRED("PRICENPQUSDM"), pdfetch_FRED("PSUGAISAUSDM"),
  pdfetch_FRED("PCOCOUSDM"), pdfetch_FRED("PPOULTUSDM"),
  pdfetch_FRED("PWOOLFUSDM"), pdfetch_FRED("PFISHUSDM"),
  pdfetch_FRED("PORANGUSDM"), pdfetch_FRED("PPORKUSDM")
)
# Las cotizaciones de los activos financieros se obtienen de YAHOO FINANCE
# con la siguiente referencia de Tickers:
# GLD  SPDR Gold Shares - Oro
# SPY S&P500
# IWM Russell 2000 - Small Caps
# XLF Financial ETF
# VNQ  Real State ETF
# GOVT Treasury Bonds ETF
# VWO  Emerging Markets ETF
# ARKK Innovation ETF

# Importación de los datos de ETF´s
df_etf_xts <- merge(
  pdfetch_YAHOO("GLD", from = "1990-01-01", field = "close", interval = "monthly"),
  pdfetch_YAHOO("SPY", from = "1990-01-01", field = "close", interval = "monthly"),
  pdfetch_YAHOO("IWM", from = "1990-01-01", field = "close", interval = "monthly"),
  pdfetch_YAHOO("XLF", from = "1990-01-01", field = "close", interval = "monthly"),
  pdfetch_YAHOO("VNQ", from = "1990-01-01", field = "close", interval = "monthly"),
  pdfetch_YAHOO("GOVT", from = "1990-01-01", field = "close", interval = "monthly"),
  pdfetch_YAHOO("VWO", from = "1990-01-01", field = "close", interval = "monthly"),
  pdfetch_YAHOO("ARKK", from = "1990-01-01", field = "close", interval = "monthly")
)
# Organización de los Datos -----------------------------------------------
# Se renombran las variables para facilitar su posterior comprensión

nombres_commodities <- c(
  "Petroleo", "Gas", "Carbon", "Soja", "Trigo", "Algodon",
  "Hierro", "Cobre", "Pan", "Carne", "Pollo_usa", "Banana",
  "Arroz", "Azucar", "Cacao", "Carne_ave", "Lana", "Pescado",
  "Naranja", "Cerdo"
)

colnames(df_commodities_xts) <- nombres_commodities

nombres_etf <- c(
  "Oro", "S&P 500", "Russell 2000", "Financiero", "Real State", "Bonos del Tesoro",
  "Mercados Emergentes", "Innovacion"
)

colnames(df_etf_xts) <- nombres_etf

# Se convierte el tipo de dataframe
# Se redondean las fechas para abajo en cada data frame antes del merge

df_commodities <- fortify.zoo(df_commodities_xts)
df_commodities <- mutate(df_commodities,
  Index = floor_date(Index, "month")
)

df_etf <- fortify.zoo(df_etf_xts)
df_etf <- mutate(df_etf,
  Index = floor_date(Index, "month")
)
# Se unifican los datos
df <- merge(df_commodities, df_etf)

# se guardan en un archivo
saveRDS(df, file = "baseDatosTP2.rds")
