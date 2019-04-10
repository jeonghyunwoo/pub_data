from urllib.request import urlopen
from urllib.parse import quote_plus
from bs4 import BeautifulSoup as soup
from newspaper import Article
from time import sleep
import time
import pandas as pd
import numpy as np

# naver news 검색
def naver_search(qry,page=3):
    articles = []
    title = []
    href = []
    date = []
    text = []
    stime = time.time()
    # original 주소
    url0 = "https://search.naver.com/search.naver?where=news&query={}&ds={}&de={}"
    url0 = "https://search.naver.com/search.naver?&where=news&query={}&start={}"
    # 네이버 검색결과 page별
    for i in range(page):
        start = i*10+1
        qry1 = quote_plus(qry)
        url = url0.format(qry1,start)
        obj = soup(urlopen(url),'html.parser')
        # links : naver 검색결과 뉴스들의 링크들
        links = obj.find_all('a',{'class':'_sp_each_title'})
        # 링크별 기사가져오기
        for link in links:
            h = link.get('href') # hyperlink
            a = Article(h,language='ko') # 기사가져오기
            a.download();a.parse()
            articles.append(a)
            title.append(a.title)
            date.append(a.publish_date)
            text.append(a.text)
            sleep(np.random.randint(1,5))
    etime = time.time() - stime
    elaps = time.strftime('%H:%M:%S',time.gmtime(etime))
    news = pd.DataFrame(dict(qry=qry,date=date,title=title,text=text))
    print('{} search done: {} elapsed'.format(qry,elaps))
    return news


# naver news 기간검색
def naver_search_d(qry,beg,end,pages=3):
    articles = []
    title = []
    href = []
    date = []
    text = []
    stime = time.time()
    # original 주소
    url0 = "https://search.naver.com/search.naver?&where=news&query={0}&sm=tab_pge&sort=0&photo=0&field=0&reporter_article=&pd=3&ds={1}&de={2}&docid=&nso=so:r,p:from{3}to{4},a:all&mynews=0&cluster_rank=22&start={5}&refresh_start=0"
    # 네이버 검색결과 page별
    begx = beg.replace('.','')
    endx = end.replace('.','')
    for i in range(pages):
        start = i*10+1
        qry1 = quote_plus(qry)
        url = url0.format(qry1,beg,end,begx,endx,start)
        obj = soup(urlopen(url),'html.parser')
        # links : naver 검색결과 뉴스들의 링크들
        links = obj.find_all('a',{'class':'_sp_each_title'})
        # 링크별 기사가져오기
        for link in links:
            h = link.get('href') # hyperlink
            try:
                a = Article(h,language='ko') # 기사가져오기
                a.download();a.parse()
                articles.append(a)
                title.append(a.title)
                date.append(a.publish_date)
                text.append(a.text)
            except:
                pass
            sleep(np.random.randint(1,3))
    etime = time.time() - stime
    elaps = time.strftime('%H:%M:%S',time.gmtime(etime))
    news = pd.DataFrame(dict(ym=begx[:6],qry=qry,date=date,title=title,text=text))
    print('{} {} search done, {} elapsed'.format(qry,begx[:4],elaps))
    return news
