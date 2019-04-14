# R: 기사 스크랩 ####
library(pacman)
p_load(robotstxt,rvest,tidyverse,reticulate)
url = "https://news.naver.com/main/list.nhn?mode=LS2D&mid=shm&sid1=101&sid2=259"
css = "#main_content > div.list_body.newsflash_body > ul.type06_headline > li > dl > dt > a"
a = read_html(url) %>% 
  html_nodes(css)
a %>% html_text() %>% str_remove_all('\r|\n|\t')
a %>% html_attr('href')
news = tibble(link = a %>% html_attr('href'),
              text = a %>% html_text() %>% str_remove_all('\r|\n|\t') %>% str_trim)
news %>% 
  na_if("") %>% 
  writexl::write_xlsx('news.xlsx')

# R: 한국은행 보도자료 ####
baseurl = 'http://www.bok.or.kr/'
url = "http://www.bok.or.kr/portal/bbs/P0000559/list.do?menuNo=200690&pageIndex=1"
css = "#content > div.bdLine.type2 > ul > li > div > span > a > span > span"
daturl = "#content > div.bdLine.type2 > ul > li > div > div.row > div > span.date"
contcss = "#content > div.bdLine.type2 > ul > li > div > span > a"
bd = read_html(url)
tit = bd %>% 
  html_nodes(css)
dat  = bd %>% 
  html_nodes(daturl) %>% 
  html_text() %>% 
  str_remove('등록일')
cont = bd %>% 
  html_nodes(contcss) %>% 
  html_attr('href')
cont1 = read_html(str_c(baseurl,cont[1]))
rwd = '\r|\n|\t'
bdjr = tibble(title = bd %>% html_text() %>% str_remove_all(rwd) %>% str_trim,
              date = dat)

# python newspaper 이용 ####
library(reticulate)
np = import('newspaper')

# atcl = np$Article
# nw1 = atcl(news$link[1])
# nw1$download()
# nw1$parse()
# nw1$title
# nw1$publish_date
# nw1$text

atcl = np$Article
gen_txt = function(x){
  # x : href
  nw = atcl(x)
  nw$download()
  nw$parse()
  title = nw$title
  txt = nw$text
  return(list(title,txt))
}
library(tictoc)
tic()
news = news %>% 
  mutate(a = map(link,gen_txt),
         title = map_chr(a,1),
         txt = map_chr(a,2),
         txt = str_remove_all(text,'\r|\n|\t')) %>% 
  select(-a)
toc()
news

# daum crawling ####
np = import('newspaper')
url = "https://search.daum.net/search?w=news&nil_search=btn&DA=NTB&enc=utf8&cluster=y&cluster_page=1&q=%EC%82%BC%EC%84%B1%EC%A0%84%EC%9E%90"
css = "#clusterResultUL > li > div.wrap_cont > div > div > a"
dh = read_html(url)
txts = dh %>% 
  html_nodes(css)
link = txts %>% html_attr('href')
main  = txts %>% html_text()
dnews = tibble(main,link)
dnews<-dnews %>% 
  mutate(a = map(link,gen_txt),
         title = map_chr(a,1),
         txt = map_chr(a,2) %>% 
           str_remove_all('\r|\t|\n')) %>% 
  select(-a)
#clusterResultUL > li:nth-child(2) > div.wrap_cont > div > div.wrap_tit.mg_tit > a

kon = import('konlpy')
okt = kon$tag$Okt()
dnews1 = dnews %>% 
  mutate(tok = map(txt,okt$nouns))
