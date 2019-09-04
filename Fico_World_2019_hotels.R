library(leaflet)
library(tidyverse)
library(clipr)
# google map에서 호텔선택시 바뀌는 url에서 위도,경도를 뽑아낸다(cood 함수)
cood<-function(url) {
  name = str_extract(url,'place/\\w+.*\\/\\@') %>% 
    str_replace_all('\\+',' ') %>% str_remove_all('place|\\/|\\+|\\/|\\@')
  # coord = str_extract(url,'\\d+\\.\\d+\\,\\-\\d+\\.\\d+') %>% str_split(',') %>% 
  #   unlist() 
  coord = str_extract(url,'3d\\d+\\.\\d+\\!4d\\-\\d+\\.\\d+$') %>% 
    str_remove_all('3d|4d') %>% 
    str_split('!') %>% unlist()
  rst = c(name,coord)
  return(rst)
}
# google map의 url 복사 후 아래 코드를 실행시키고 구글시트에 바로 붙여넣었다
read_clip() %>% cood %>% print() %>% write_clip()

# 위의 작업을 여러번 반복한 후 복사하고 hotel에 데이터프레임으로 저장한다
hotel = read_clip_tbl()

# 행사장소인 힐튼 미드타운 제외한 곳은 써클마커로 표시하고, 힐튼 미드타운은 마커로 표시했다.
filter(hotel,!str_detect(hotel,'Hilton Midtown')) %>% 
  leaflet() %>% 
  # addTiles() %>% 
  addProviderTiles(providers$CartoDB.Positron) %>%
  addCircleMarkers(lat=~lat,lng=~lng,label = ~hotel,
             labelOptions = labelOptions(noHide = T,textOnly = T,
                                         textsize = '13px'),
             stroke=F,color='forestgreen',fillOpacity = 1) %>% 
  addMarkers(data=filter(hotel,str_detect(hotel,'Hilton Midtown')),
             lat = ~lat,lng=~lng,popup=~hotel)
