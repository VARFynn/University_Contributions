###############################################################################
###############################################################################
# Creation of US-Map with Stadium Locations
#
# - This is just a quick & dirty creation to map the respective stadium 
#   to it's actual location.
###############################################################################
###############################################################################

library(maps)
library(ggplot2)
library(ggthemes)

us_map <- map_data("usa")
teams <- data.frame(
  Team = c("Dallas Cowboys", "Atlanta Falcons", "Baltimore Ravens", "Carolina Panthers", "Chicago Bears",
           "Cincinnati Bengals", "Cleveland Browns", "Denver Broncos", "Detroit Lions", "New York Giants",
           "New England Patriots", "Arizona Cardinals", "Green Bay Packers", "Houston Texans", "Indianapolis Colts",
           "Los Angeles Rams", "Jacksonville Jaguars", "Kansas City Chiefs", "Washington Football Team", "Miami Dolphins",
           "Minnesota Vikings", "Tennessee Titans", "New Orleans Saints", "Las Vegas Raiders", "Buffalo Bills",
           "Las Vegas Raiders", "Philadelphia Eagles", "Pittsburgh Steelers", "Los Angeles Chargers", "San Francisco 49ers", "Seattle Seahawks", "St. Louis Rams", "Tampa Bay Buccaneers"),
  Latitude = c(32.7357, 33.7490, 39.2904, 35.2271, 41.8781, 39.1031, 41.4993, 39.7392, 42.3314, 40.8128, 
               42.0654, 33.5387, 44.5133, 29.7604, 39.7684, 33.9617, 30.3322, 39.0997, 38.9076, 25.9434, 
               44.9778, 36.1627, 29.9511, 37.8044, 42.7739, 36.0972, 39.9526, 40.4406, 32.7157, 37.3541, 
               47.6062, 38.6270, 27.9506),
  Longitude = c(-97.1081, -84.3880, -76.6122, -80.8431, -87.6298, -84.5120, -81.6944, -104.9903, 
                -83.0458, -74.0742, -71.2489, -112.1860, -88.0133, -95.3698, -86.1581, -118.3531, 
                -81.6557, -94.5786, -76.8640, -80.2422, -93.2650, -86.7816, -90.0715, -122.2711, 
                -78.7875, -115.1522, -75.1652, -79.9959, -117.1611, -121.9552, -122.3321, 
                -90.1994, -82.4572)
)

p <- ggplot() +
  geom_polygon(data = us_map, aes(x = long, y = lat, group = group), fill = "white", color = "black") +
  geom_point(data = teams, aes(x = Longitude, y = Latitude), color = "red", size = 3) +
  coord_fixed() +
  labs(title = "NFL Team's Stadium Location (2010 - 2023)") +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5))

# -------------------------------------------------------------------------------- #
# Tip: 
# In case you tryna replicate the following for other reasons, you can just 
# adjust x and y. The hjust and vjust additonal layer was pure laziness as I 
# just took the exported excel values and adjusted several lines at once. 
# -------------------------------------------------------------------------------- #

p <- p +
  annotate("text", x = -97.1081, y = 32.7357, label = "Cowboys", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -84.3880, y = 33.7490, label = "Falcons", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -80.8431, y = 35.2271, label = "Panthers", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -87.6298, y = 41.8781, label = "Bears", size = 2.5, fontface = "bold", hjust = 1.2, vjust = -0.4) +
  annotate("text", x = -84.5120, y = 39.1031, label = "Bengals", size = 2.5, fontface = "bold", hjust = 0, vjust = -1) +
  annotate("text", x = -81.6944, y = 41.4993, label = "Browns", size = 2.5, fontface = "bold", hjust = -0.3, vjust = 0.4) +
  annotate("text", x = -104.9903, y = 39.7392, label = "Broncos", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -83.0458, y = 42.3314, label = "Lions", size = 2.5, fontface = "bold", hjust = 1, vjust = -0.8) +
  annotate("text", x = -71.2489, y = 42.0654, label = "Patriots", size = 2.5, fontface = "bold", hjust = -0.25, vjust = -0.2) +
  annotate("text", x = -112.1860, y = 33.5387, label = "Cardinals", size = 2.5, fontface = "bold", hjust = -0.05, vjust = -0.8) +
  annotate("text", x = -95.3698, y = 29.7604, label = "Texans", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -86.1581, y = 39.7684, label = "Colts", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -118.3531, y = 33.9617, label = "Rams/Chargers", size = 2.5, fontface = "bold", hjust = -0.05, vjust = -1) +
  annotate("text", x = -81.6557, y = 30.3322, label = "Jaguars", size = 2.5, fontface = "bold", hjust = -0.3, vjust = -0.2) +
  annotate("text", x = -94.5786, y = 39.0997, label = "Chiefs", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -76.8640, y = 38.9076, label = "Football Team (''Redskins'')", size = 2.5, fontface = "bold", hjust = -0.25, vjust = -0.2) +
  annotate("text", x = -73.8640, y = 39.7076, label = "Eagles", size = 2.5, fontface = "bold", hjust = -0.25, vjust = -0.2) +
  annotate("text", x = -80.2422, y = 25.9434, label = "Dolphins", size = 2.5, fontface = "bold", hjust = -0.25, vjust = -0.2) +
  annotate("text", x = -93.2650, y = 44.9778, label = "Vikings", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -86.7816, y = 36.1627, label = "Titans", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -122.2711, y = 37.8044, label = "Raiders (Oakland)", size = 2.5, fontface = "bold", hjust = -0.05, vjust = -0.2) +
  annotate("text", x = -78.7875, y = 43.2, label = "Bills", size = 2.5, fontface = "bold", hjust = 0.5, vjust = -1) +
  annotate("text", x = -115.1611, y = 36.6270, label = "Raiders (Vegas)", size = 2.5, fontface = "bold", hjust = 0.2, vjust = -0.2) +
  annotate("text", x = -80.9552, y = 27.9506, label = "Buccaneers", size = 2.5, fontface = "bold", hjust = 1.4, vjust = -0.2) +
  annotate("text", x = -90.1994, y = 38.5, label = "Rams (St. Louis)", size = 2.5, fontface = "bold", hjust = 1.1) + 
  annotate("text", x = -122.1611, y = 48.6270, label = "Seahawks", size = 2.5, fontface = "bold", hjust = 0) +  
  annotate("text", x = -122.3321, y = 36.5, label = "49ers", size = 2.5, fontface = "bold", hjust = -0.6, vjust = -0.4) +  
  annotate("text", x = -75, y = 40.9, label = "Steelers", size = 2.5, fontface = "bold", hjust = 1.3) + 
  annotate("text", x = -76, y = 38.5, label = "Ravens", size = 2.5, fontface = "bold", hjust = -0.5) + 
  annotate("text", x = -74, y = 40.9, label = "Giants/Jets", size = 2.5, fontface = "bold", hjust = -0.45, vjust = 0.7) +  
  annotate("text", x = -88.5, y = 44.7, label = "Packers", size = 2.5, fontface = "bold", vjust = 1.6, hjust = 0.8) +  
  annotate("text", x = -90.1, y = 29.2, label = "Saints", size = 2.5, fontface = "bold", vjust = 1.2)  +
  annotate("text", x = -122.1, y = 33, label = "Cargers (San Diego)", size = 2.5, fontface = "bold", vjust = 1.2)  

print(p)
