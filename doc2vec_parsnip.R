# parsnip
library(pacman)
p_load(plyr,tidyverse,tidymodels,reticulate,lubridate)

pd = import('pandas')
ndfvec = pd$read_pickle('data/ndf_txt_vec1.pkl')

tr = select(ndfvec,ym,dx1:dx10,cycle) %>% tbl_df
tr = tr %>% mutate(date=ymd(str_c(ym,'01')),
                   target = ifelse(cycle>100,'bad','good'),
                   target = factor(target)) %>% 
  drop_na()



trx = select(tr,dx1:dx10,target)
model1 = boost_tree('classification',
                   mtry = 3,
                   trees = 30,
                   learn_rate = 0.29) %>% 
  set_engine('xgboost') %>% 
  fit(target~.,data=trx)
model2 = rand_forest('classification',
                     mtry = 3,
                     trees = 30) %>% 
  set_engine('ranger') %>% 
  fit(target~.,data=trx)
lin1 = boost_tree('regression',
                  mtry =3,
                  trees = 30,
                  learn_rate =0.29) %>% 
  set_engine('xgboost') %>% 
  fit_xy(x=select(tr,dx1:dx10),y=select(tr,cycle))
lin2 = rand_forest('regression',
                   mtry=3,
                   trees = 30) %>% 
  set_engine('ranger') %>% 
  fit_xy(x=select(tr,dx1:dx10),y=select(tr,cycle))
trxb = trx %>% 
  bind_cols(predict(model1,.,type='prob') %>% 
              set_names(c('xgb_bad','xgb_goood'))) %>% 
  bind_cols(predict(model2,.,type='prob') %>% 
              set_names(c('rf_bad','rf_good')))
trxb$cycle = tr$cycle
trxb$date = tr$date
trxb %>% 
  select(date,cycle,xgb_bad,rf_bad) %>% 
  gather(model,value,-date) %>% 
  ggplot(aes(date,value,color=model))+
  geom_line(size=.7)+
  facet_wrap(~model,ncol=1,scales='free')+
  theme_minimal(10,'verdana')+
  theme(legend.position = 'none')
trxc = trx %>% 
  bind_cols(predict(lin1,select(.,dx1:dx10)) %>% 
              set_names(c('xgb_cyc'))) %>% 
  bind_cols(predict(lin2,select(.,dx1:dx10)) %>% 
              set_names(c('rf_cyc')))
trxc$cycle = tr$cycle  
trxc$date = tr$date
trxc %>% 
  select(date,cycle,xgb_cyc,rf_cyc) %>% 
  gather(model,value,-date) %>% 
  ggplot(aes(date,value,color=model))+
  geom_line(size=.7)+
  facet_wrap(~model,ncol=1,scales='free')+
  theme_minimal(10,'verdana')+
  theme(legend.position = 'none')
ggplot(trxc,aes(xgb_cyc,cycle))+
  geom_point()+
  geom_smooth()
