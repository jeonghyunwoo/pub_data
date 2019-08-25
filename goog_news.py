# google도 request.get 방식으로 스크래핑이 가능함
# url을 여러번 가공해줘야 하고 unquote 해줘야 함

import pandas as pd
import requests
from urllib.parse import quote_plus,unquote
from urllib.request import urlopen
from bs4 import BeautifulSoup as soup
import re, time, itertools
from newspaper import Article
import numpy as np
from nltk.corpus import stopwords
from wordcloud import WordCloud
import matplotlib.pyplot as plt


def goog_news(sch_word,yyyymm,pages=3):
  quo_word = quote_plus(sch_word)
  mon = pd.to_datetime(yyyymm,format='%Y%m')
  mon_max = mon+pd.DateOffset(months=1)-pd.DateOffset(days=1)
  mrng = list(map(lambda x: x.strftime('%m/%d/%Y'),[mon,mon_max]))
  
  links = []
  for i in np.arange(0,pages*10,10):
    url = f"https://www.google.com/search?q={quo_word}&safe=active&rlz=1C1SQJL_koKR831KR832&biw=763&bih=625&source=lnt&tbs=cdr%3A1%2Ccd_min%3A{mrng[0]}%2Ccd_max%3A{mrng[1]}&tbm=nws&start={i}"  
    r = soup(requests.get(url).text,'lxml')
    b = r.find_all('a')
    lks = [h['href'].replace('/url?q=','') for h in b if h['href'][:4]=='/url']
    lks = [unquote(lk) for lk in lks]
    lks = [l.split('&sa')[0] for l in lks]
    links.append(lks)
  
  links = list(itertools.chain(*links))  
  
  title,date,wd,text,press = [],[],[],[],[]
  
  for h in links:
    press.append(re.split('/',h)[2])
    a = Article(h)
    try:
      a.download()
      a.parse()
    except:
      next
    
    try:
      title.append(a.title)
    except:
      title.append('')
    
    try:
      dat = a.publish_date
      date.append(dat.strftime('%Y-%m-%d'))
      wd.append(dat.strftime('%a'))
    except:
      date.append('')
      wd.append('')
    
    try:
      text.append(a.text)
    except:
      text.append('')
    
  news = pd.DataFrame({'title':title,'date':date,'wkday':wd,'text':text,'press':press})
  news = news.loc[news.text!='']
  news = news.drop_duplicates()
  news.reset_index(drop=True,inplace=True)
    
  return news

stop_words = set(stopwords.words('english'))

def wc(txt):
  '''txt는 문자열(str)
  ex : txt = df.text.sum()
  '''
  txt = txt.lower()
  words = txt.split() #단어마다 나눠서 단어리스트로 만든다
  words = [w for w in words if not w in stop_words]
  clean_txt = ' '.join(words) # 다시 하나의 문자열로
  cloud = WordCloud(width = 600, height = 600).generate(clean_txt)
  plt.figure(figsize=(10,8))
  plt.imshow(cloud)
  plt.axis('off')
  
  
  

  
if __name__ == '__main__':
  print("""goog_news('검색어',201908,pages=3)
  wc(df.text.sum())""")
