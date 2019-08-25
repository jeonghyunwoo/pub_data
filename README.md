# last code,data  
code: social_d2v_3.ipynb  
data: ndf3.pkl  
goog_news.py : goog_news('가계부채 gold price',201908,pages=3), 구글뉴스결과를 pd.DataFrame으로 산출한다  

# pub_data
public data visualization, analysis  

둘다 selector와 tag-attribute로 내용 찾는 기능은 있지만 왠지...
R은 Selector 쓰는게 잘 먹히고  
Python은 attribute 쓰는게 잘 먹히는 것 같다.  
css = "#clusterResultUL > li.fst > div.wrap_cont > div > p"  
R:  
    read_html(url) %>% html_node(css)   
    * R은 위치경로가 복잡하면 div, class를 어떻게 지정해야 할 지 잘 감도 안오고 어떻게 해도 잘 안됨   
  
Python:   
    a = soup(url,'html.parser')   
    a.select(css) # X  
    a.find_all('p',{'class':'f_eb desc'}) # O  

# 응용  
- Okt말고 Kkma, Hannanum, Komoran 등을 적용해서 해볼 수 있다  
- model hyperparameter를 변경시킬 수 있다  
- 불용어를 제거한 후 좀 더 정밀하게 해볼 수 있다(것,이,등,수,말,로)  
    
# Tip  
&nbsp;원데이터에 그룹별 건수 항목 더하기  
&nbsp;`df['count'] = df.groupby('id')['id'].transform('count')`  
&nbsp;&nbsp;=> row 수는 똑같고 column 수만 1개 늘어남(count 항목 신설)  

&nbsp;matplotlib 마이너스(-) 폰트 깨질때  
&nbsp;&nbsp;=> plt.rcParams['axes.unicode_minus'] = False




