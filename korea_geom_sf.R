library(pacman)
p_load(tidyverse,sf)
# https://statkclee.github.io/spatial/geo-spatial-r.html
# https://gadm.org/download_country_v3.html
korea_sf <-read_rds('data/gadm36_kor_2_sf.rds')
st_crs(korea_sf)
head(korea_sf)
korea_sf %>% 
  select(GID_2) %>% 
  plot()
ggplot()+
  geom_sf(data=korea_sf)
nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
ggplot()+
  geom_sf(data=nc)
ggplot()+
  geom_sf(data=korea_sf)
count(korea_sf,NAME_1)
nc_3857 = st_transform(nc,'+init=epsg:3857')
ggplot()+
  geom_sf(data=nc)+
  geom_sf(data=nc_3857, color='red',fill=NA)
ggplot(korea_sf)+
  geom_sf()
theme_set(theme_minimal(10))
windowsFonts(ng=windowsFont('나눔고딕'))
ko_sf = korea_sf %>% 
  separate(NL_NAME_1,c('sido','han')) %>% 
  separate(NL_NAME_2,c('gugun','han1'))
# filter(korea_sf,str_detect(NL_NAME_1,'인천')) %>% 
korea_sf %>%
  add_column(val = factor(sample(4,nrow(.),replace=T))) %>% 
  separate(NL_NAME_2,c('gugun','hanja'),remove=F) %>% 
  ggplot()+
  geom_sf(aes(fill=val))+
  geom_sf_text(aes(label=gugun),family='ng',size=3)+
  scale_fill_brewer(palette = 'YlGn')+
  theme(axis.text = element_blank())
library(tmap)
tm_shape(ko_sf)+
  tm_borders()+
  tm_facets(by='sido')
library(patchwork)
kg = function(x){
  ko_sf %>% 
    filter(sido==x) %>% 
    add_column(val = factor(sample(4,nrow(.),replace=T))) %>% 
    ggplot()+
    geom_sf(aes(fill=val))+
    # geom_sf_text(aes(label=gugun),family='ng')+
    scale_fill_brewer(palette='YlGn')+
    theme(axis.text = element_blank(),
          axis.ticks = element_blank(),
          legend.position = 'none')+
    ggtitle(x)
}
kgf = map(unique(ko_sf$sido),kg)
wrap_plots(kgf,ncol=4)
lst = unique(ko_sf$sido)
kg(lst[1])
theme_set(ggthemes::theme_tufte(10,'ng'))
wrap_plots(list(kg()))
#
ko_sf %>% 
  # filter(str_detect(sido,'인천')) %>%
  add_column(val = factor(sample(4,nrow(.),replace=T))) %>% 
  ggplot()+
  geom_sf(aes(fill=sido))+
  # geom_sf_text(aes(label=gugun),family='ng')+
  # scale_fill_brewer(palette='YlGn')+
  scale_fill_tableau('Tableau 20')+
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.position = 'none')
  facet_wrap(~sido,ncol=4)
