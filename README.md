# 프로젝트5 : Google Cloud Platform를 활용한 이커머스 데이터 분석과 상품 추천 시스템 구현

# 1. Overview

## 1.1. 배경과 목적
- 이커머스 회사의 데이터 팀에 근무 중이라고 가정
- 마케팅 솔루션 기업 빅인의 '2021년 국내 이커머스 트렌드 리포트'에 따르면, 온라인 쇼핑몰의 평균 구매 전환율은 약 **2.06%** 에 이른다고 함
- 우리 온라인 쇼핑몰의 구매 전환율은 어떻게 되는지, 그리고 전환율과 매출을 올리기 위해서 어떤 방법을 시도해볼 수 있는지 고객 행동 데이터를 통해 알아보고자 함
<br/>

## 1.2. 데이터 소개
- 캐글 출처, 중동국가 한 이커머스의 2019년 11월 한 달 간의 고객 행동에 대한 로그 데이터(8.38GB)
  https://www.kaggle.com/datasets/mkechinov/ecommerce-behavior-data-from-multi-category-store
- 제품에 대한 행동, 제품에 대한 정보로 약 6,700만 개의 행으로 구성되어 있음
![image](https://user-images.githubusercontent.com/110115061/220956537-9d55e972-03c6-4eb7-8fed-a5cf428d32bc.png)

### Columns Description
- event_time : 유저 이벤트가 발생한 시간(UTC 기준)
- event_type : 유저 이벤트의 종류
- product_id : 제품의 ID
- category_code : 제품의 카테고리
- sub_category : 제품의 서브 카테고리
- product : 제품 종류
- brand : 제품의 브랜드
- price : 제품의 가격 (단위 불명)
- user_id : 유저의 ID
- user_session : 유저의 세션 로그
#### ※ 19년도 데이터를 현재의 상황으로 가정, 리서치나 기사 등의 내용은 21, 22년의 것을 참조하여 분석을 진행함

<br/>

## 1.3. 스킬셋
- pandas
- numpy
- pyspark
- Google Cloud Platfrom : Big Query, Looker Studio
- scipy
- scikit-learn
- annoy
- implicit



---
<br/>

# 2. 데이터 전처리
- 기존 데이터셋 규모가 커 csv파일 그대로 사용하기에 비효율적, Pyspark로 데이터를 읽은 후 Parquet파일로 압축하여 저장한 후 전처리 진행
- 불필요한 컬럼 삭제
- category_code값 : '.'기준으로 문자열 나눈 후 sub_category컬럼, product컬럼 생성하여 값 저장
- event_time컬럼의 datetime 순으로 데이터 정렬  
![image](https://user-images.githubusercontent.com/110115061/221128691-ed0c155a-c52a-4b5d-9005-34bb0ad0cc47.png)
- 날짜 및 요일별 세션 로그 수와 장바구니, 구매 건수 데이터를 따로 만들어 저장  
![image](https://user-images.githubusercontent.com/110115061/221129671-7122b243-e048-416b-9f53-8c1ca0cb7aba.png)



---
<br/>

# 3. 분석
- Google Cloud Platform에 데이터를 저장
- BigQuery를 통해 분석과 통계
- Looker Studio를 통해 데이터 시각화 및 대시보드를 구성함
<br/>

## 3.1. 한달 간 고객 행동 개요
![image](https://user-images.githubusercontent.com/110115061/220983267-2415b0c6-ddf3-446a-b1a9-0abb384cd573.png)  
![image](https://user-images.githubusercontent.com/110115061/220983383-ffeb71b2-4271-470a-8bc4-b5491ed78520.png)

- 제품을 장바구니에 담은 ‘cart’ 건 수는 2,045,304건, 제품을 구매한 ‘purchase’건 수는 659,251건으로
  제품 페이지를 확인한 ‘view’ 39,314,217건에 비해 매우 작은 수치이며, 이는 날짜 별 통계를 보면 큰 차이를 확인할 수 있음
- 한달 간 평균구매 전환율은 __1.57%__ 에 그치며 이는 앞서 언급한 국내 이커머스 평균 구매전환율인 __2.06%__ 보다 __0.49%__ 포인트 낮은 수치  

#### ※ 구매 전환율 제고를 위해 퍼널 단계가 급격히 하락하는 장바구니 단계부터 개선이 필요해 보임

<br/>

## 3.2. 고객 행동 지표 세부 분석
![image](https://user-images.githubusercontent.com/110115061/221243608-13eec9fd-4ed1-483c-be68-d190fa9c5d79.png)  
- 유저 방문(view) 건 수에 비해 장바구니(cart)나 구매(purchase) 건 수가 매우 적었으나, 실제 카테고리와 브랜드,
  그리고 상품 상위 10개의 통계를 보면 품목이 매우 유사한 것을 알 수 있음
- 각 분야 상위 3~5개는 모두 전체 집계량의 과반을 넘어 70% 이상의 양상을 보이고 있으며, 특히 전자제품과 가전제품의 비중이 매우 큰 것을 알 수 있음  

#### ※ 방문 고객과 장바구니 고객 모두에게 전자제품, 가전제품 관련 마케팅을 동일하게 적용해도 구매 전환율 제고에 효과적일 것으로 보임

<br/>

## 3.3. 분석에 따른 마케팅 전략 제안
- 상품을 발견한 고객들이 장바구니에 담고, 구매로까지 이어질 수 있도록 각 단계에 맞는 마케팅 전략 

### 상품 view단계 마케팅 전략 : '고객 경험'을 개선하라
- 포스트 코로나 시대 도래와 MZ세대가 소비의 주축으로 떠오르면서 고객 경험, 브랜드 경험, 디지털 고객 경험의 X마케팅이 화두  
  시사저널 : https://www.sisajournal.com/news/articleView.html?idxno=239753  
  LG CNS : https://www.lgcns.com/blog/cns-tech/35938/  
- 다른 제품에 비해 비교적 고가이고, 구매에 신중을 기하는 전자제품, 가전제품인 만큼 제품을 상세히 알아보고, 간접 경험할 수 있도록 제품 상세페이지를 개선 및 보완
- 다른 구매자들의 상세한 후기를 통해 상품을 간접적으로 경험할 수 있도록 구매 후기 서비스와 참여 리워드를 강화

### 상품 cart단계 마케팅 전략 : 장바구니 쿠폰 이벤트
- 상품 상세페이지 방문에서 장바구니로, 또 장바구니에서 구매로 이어질 수 있는 유인책으로 상품을 장바구니에 담으면 사용할 수 있는,
  특정 기간에만 적용 가능한 장바구니 쿠폰을 발행
- 세부적인 할인내용과 가격 정책은 추가적인 논의가 필요함

<br/>

## 3.4. 적절한 쿠폰 발행 및 프로모션 이벤트 시기는?
![image](https://user-images.githubusercontent.com/110115061/220989832-3bcb8a18-8d2a-4865-bf1d-46c57068579e.png)

- 차트4의 내용에 따르면 06시~ 15시 시간대에 가장 많은 고객분들이 온라인몰에 접속함
- 차트5의 내용에 따르면 주말에 상품 구매 건수가 많은데, 공교롭게도 차트2 날짜별 고객 행동지표에서 가장 많은 수의 고객 행동이 관찰된 날짜가
  11월 16일과 17일로,요일로 환산하면 주말에 해당함
  
#### ※ 쿠폰 발행 및 기타 이벤트를 보다 효과적으로 진행하기 위해서 고객 행동이 활발한 매월 중순 주말, 시간대는 06시~15시 시간대를 고려하여 진행하는 것을 추천함
#### ※ 데이터 대시보드 링크 : https://datastudio.google.com/reporting/cdc3d21d-615e-49b0-aa9d-8f9229d0efda**



---
<br/>

# 4. 상품 추천 시스템 구현
- 구매 전환율과 매출을 올리기 위한 추가적인 방안으로 고객에게 적절한 상품을 제안하는 추천 시스템을 구현하고자 함

<br/>

## 4.1. 구매 고객 행동데이터 RFM 수치 확인
- 최근 접속을 수치화한 recency, 접속 빈도를 나타내는 frequency, 총 구매금액을 나타내는 monetary값  
![image](https://user-images.githubusercontent.com/110115061/220991573-7e6e4013-8d4c-4624-b24e-b6881de985b9.png)  
- 최댓값과 최솟값의 범위 내에서 구획화하여 1~5점을 부여하였음
- 값의 분포가 다양한 recency와 달리 frequency와 monetary는 대부분의 데이터가 1점대에 몰려 있음  
![image](https://user-images.githubusercontent.com/110115061/220991638-1d69b7be-0a6d-4e5f-8f16-996c315fa404.png)  
- 이어 전체 고객들의 접속 빈도수를 보면, 사분위 수의 50%에 해당하는 값이 7회로 확인됨  
![image](https://user-images.githubusercontent.com/110115061/220991840-02af85c0-8106-4c77-9f29-a3f9764f3c89.png)

#### ※ 접속 횟수, 구매 횟수가 적은 고객이 대다수이므로 이들에게 적절한 상품을 추천함으로 다양한 상품을 더 확인할 수 있도록, 그리고 구매로까지 촉진하고자 함

<br/>

## 4.2. 이커머스 데이터 추천 시스템 구현

### 4.2.1 컨텐츠 기반 추천 시스템
- 상품의 카테고리, 브랜드, 가격 정보를 활용하여 유사한 아이템을 추천하는 시스템
- 카테고리와 브랜드 데이터는 TF-IDF 활용, 가격 데이터 정규화(min-max scaling)
- 총 69,773개의 아이템 2,159개의 특징 컬럼 -> 100개의 특징으로 PCA(메모리 절감, 속도 향상) 후 벡터화
- 벡터 유사도 검색으로 상품 간 유사도 측정 : annoy 라이브러리 활용(Approximate Nearest Neighbors)   
![image](https://user-images.githubusercontent.com/110115061/220995347-edc8bbb0-8b7b-42dd-ab94-cac9dd6e66a8.png)

#### 구현 결과
![image](https://user-images.githubusercontent.com/110115061/220995603-7fcc9581-bfb7-4daa-ac3a-61506f825ffb.png)  
![image](https://user-images.githubusercontent.com/110115061/220995693-1c60dfb1-ef68-4429-a36e-2f077c4ed3f9.png)

- 추천한 상품에 대한 실제 구매결과를 알 수 없어 정량적인 성능평가는 어려웠음
- 여러 상품에 대해 동작해본 결과, 기준 아이템과 유사한 아이템을 잘 찾는 것을 볼 수 있음

#### ※ 하지만 유사한 아이템만 결과로 나와서 추천 시스템의 우연성(Serendipity)이 없는 것으로 보임. 컨텐츠 기반 추천 시스템 단독으로 고객에게 상품을 추천, 구매 욕구를 자극하기엔 조금 부족함


### 4.2.2 Matrix Factorization을 이용한 ALS 기반 협업 필터링
- 고객들이 실제로 구매한 상품 데이터를 기반으로 행렬분해를 이용한 추천 시스템
- 구매 기록이 명시적이진 않지만 암시적으로 상품에 대한 선호도를 의미한다고 추론
- 행렬 분해를 통해 고객-상품 간 숨겨진 요소값을 찾아내, 상품 추천에 활용  
![image](https://user-images.githubusercontent.com/110115061/220996588-f08bf693-3bde-4744-924a-cf60d09e5cac.png)  
- 총 330,394명의 고객이 구매한 20,772개의 상품 506,950건의 정보를 활용
- 20,772 x 330,394의 희소 행렬 구성 : sparsity 99.9%, 메모리 효율을 위해 CSR 행렬 구성

 

#### 구현 결과
- factors = 30, regularization = 0.1, alpha = 40, iterations = 30
- 전체 matrix에서 20% 구매기록을 가린 훈련 데이터로 학습하였음
- 30회 학습 시 loss = 0.000998
- 평가 : 전체 330,394명의 고객에 대한 precision@15 = 0.028  
![image](https://user-images.githubusercontent.com/110115061/220997341-27dce8e1-78f9-4609-97f4-05f67e0dad0a.png)  

![image](https://user-images.githubusercontent.com/110115061/220997538-707d8b1e-6e69-48aa-a30e-086177bd2f6b.png)  
![image](https://user-images.githubusercontent.com/110115061/220997614-5298e313-8d3a-4056-8fd6-ae55b54853a9.png)

- 앞서 본 CB모델보다 조금 더 다양한 상품을 추천하는 것을 볼 수 있음
- 고객의 성향이 Matrix에 반영되어 어느정도 개인화 추천도 가능한 것을 볼 수 있음

#### ※ 정성적으로 평가했을 때, 좀 더 다양한 추천이 가능한 ALS모델이 CB모델보다 적용하기 좋을 것으로 보임. 다만 유저의 구매기록이 없는 경우, CB모델로 우선 유사 아이템을 추천하는 것도 좋을 것 같음

<br/>

## 4.3. 추천 시스템 적용
### 상품 view단계의 고객
- 컨텐츠 기반 추천 시스템을 통해 해당 상품과 유사한 상품을 추천하여 어느정도 이탈을 방어하며 상품을 장바구니에 담을 확률을 높임

### 상품 cart단계의 고객 또는 구매 내역이 있는 고객
- 컨텐츠 기반 추천 시스템 기본으로 적용
- 행렬분해를 활용한 ALS 모델을 통해 구매할 법한 아이템을 추가로 추천하여 구매 확률을 높임

### 추천 시스템 적용 예시
![image](https://user-images.githubusercontent.com/110115061/220998024-8ef738eb-0188-433d-9ad0-05b4cdca55e7.png)  
- 위 예시처럼 하나의 모델보다 여러 모델을 활용, 다양한 관점으로 상품을 추천하는 것이 좋아 보임
- 추가로 같은 카테고리 내에서 가장 많이 팔린 상품을 추천하는 것도 효과적인 추천방식으로 보임

---
<br/>

# 5. 한계 및 개선점
- 유저 또는 아이템의 메타데이터에 한계가 있고, 그에 비해 데이터 규모가 커서 추천 시스템 구현에 다소 제약이 있었음
- 좀 더 다양한 추천 모델을 추가적으로 구현하고 비교해보지 못한 아쉬움이 있음 (best 상품 추천, 딥러닝 모델 등)
