-- 1. 고객 행동 퍼널 지표
SELECT 
  event_type, 
  COUNT(event_type) as cnt,
  ROUND(COUNT(event_type)*100/SUM(COUNT(*)) over(), 2) as ratio
FROM `codestates-project1-374016.df.market` AS  market
GROUP BY event_type
ORDER BY ratio DESC;

-- 2. 날짜별 고객 행동 지표 : 파이썬 판다스

-- 3. 시간대별 접속자 수
SELECT
  TIME_TRUNC(TIME(event_time), HOUR) AS time_,
  COUNT(DISTINCT user_id) AS user_cnt
  
FROM `codestates-project1-374016.df.market`
WHERE event_type = 'purchase'
GROUP BY TIME_TRUNC(TIME(event_time), HOUR);

-- 4. 요일별 구매 건수
SELECT
  weekday,
  SUM(user_session)	AS session,
  SUM(purchase_cnt) AS purchase_cnt
FROM `codestates-project1-374016.df.session_by_date`
GROUP BY weekday
ORDER BY (CASE weekday
WHEN 'Monday' THEN 1
WHEN 'Tuesday' THEN 2
WHEN 'Wednesday' THEN 3
WHEN 'Thursday' THEN 4
WHEN 'Friday' THEN 5
WHEN 'Saturday' THEN 6
ELSE 7 END);

-- 5. 고객 ID별 총 구매 금액
SELECT
  user_id,
  ROUND(SUM(price), 1) AS total_purchase
FROM `codestates-project1-374016.df.market`
WHERE event_type = 'purchase'
GROUP BY user_id
ORDER BY total_purchase DESC;

-- 6. 유저 방문(view) 통계
SELECT 
  category_code,
  COUNT(category_code) AS cnt
FROM `codestates-project1-374016.df.market` AS  market
WHERE event_type = 'view'
GROUP BY category_code
ORDER BY cnt DESC;

SELECT 
  product,
  COUNT(product) AS cnt
FROM `codestates-project1-374016.df.market` AS  market
WHERE event_type = 'view'
GROUP BY product
ORDER BY cnt DESC;

SELECT 
  brand,
  COUNT(brand) AS cnt
FROM `codestates-project1-374016.df.market` AS  market
WHERE event_type = 'view'
GROUP BY brand
ORDER BY cnt DESC;

-- 7. 유저 장바구니, 구매 통계는 위 쿼리 'view'대신 각각 'cart', 'purchase'를 대입