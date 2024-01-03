--digital analysis
--How many users are there?
SELECT 
	COUNT(DISTINCT user_id) AS tot_users
FROM users;

OUTPUT
"tot_users"
500

--How many cookies does each user have on average?
SELECT 
	ROUND(AVG(counts),3)
FROM (SELECT user_id, COUNT(cookie_id)AS counts FROM users GROUP BY user_id);

OUTPUT
"round"
3.564

--What is the unique number of visits by all users per month?
SELECT
	EXTRACT (MONTH FROM event_time) AS month_number,
	COUNT(DISTINCT visit_id) AS uni_num
FROM events INNER JOIN users
ON events.cookie_id=users.cookie_id
GROUP BY month_number;

OUTPUT
"month_number"	"uni_num"
1	876
2	1488
3	916
4	248
5	36

--What is the number of events for each event type?
SELECT
	event_name,
	COUNT(e.event_type) AS event_num
FROM events e INNER JOIN event_identifier ei
ON e.event_type=ei.event_type
GROUP BY event_name;

OUTPUT
"event_name"	"event_num"
"Purchase"	1777
"Ad Impression"	876
"Add to Cart"	8451
"Page View"	20928
"Ad Click"	702

--What is the percentage of visits which have a purchase event?
SELECT
	ROUND(100*COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT visit_id) FROM events)::DECIMAL,1) AS event_per
FROM events e INNER JOIN event_identifier ei
ON e.event_type=ei.event_type
WHERE ei.event_name LIKE 'Pur%';

OUTPUT
"event_per"
49.9

--What is the percentage of visits which view the checkout page but do not have a purchase event?
SELECT 
	ROUND(100*COUNT(DISTINCT visit_id)/(SELECT COUNT(DISTINCT visit_id) FROM events)::DECIMAL,2) AS per
FROM events
WHERE page_id=12 AND visit_id NOT IN (SELECT visit_id FROM events WHERE page_id=13);

OUTPUT
"per"
9.15

--What are the top 3 pages by number of views?
SELECT
	page_name,
	COUNT(*) AS counts
FROM events e INNER JOIN page_hierarchy ph
ON e.page_id=ph.page_id
WHERE e.event_type=1
GROUP BY page_name
ORDER BY counts DESC
LIMIT 3;

OUTPUT
"page_name"	"counts"
"All Products"	3174
"Checkout"	2103
"Home Page"	1782

--What is the number of views and cart adds for each product category?
SELECT
	ph.product_category,
	SUM(CASE WHEN ei.event_name LIKE 'Page View%' THEN 1 ELSE 0 END) AS num_views,
	SUM(CASE WHEN ei.event_name LIKE 'Add to Cart%' THEN 1 ELSE 0 END) AS cart_vies
FROM event_identifier ei INNER JOIN events e
ON ei.event_type=e.event_type
INNER JOIN page_hierarchy ph
ON e.page_id=ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY ph.product_category;

OUTPUT
"product_category"	"num_views"	"cart_vies"
"Luxury"	3032	1870
"Shellfish"	6204	3792
"Fish"	4633	2789


