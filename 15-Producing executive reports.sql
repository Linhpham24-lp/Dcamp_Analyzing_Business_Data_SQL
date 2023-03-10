--Excuting Report
SELECT
  eatery,
  -- Format the order date so "2018-06-01" becomes "Q2 2018"
  TO_CHAR(order_date, '"Q"Q YYYY') AS delivr_quarter,
  -- Count unique users
  COUNT(DISTINCT user_id) AS users
FROM meals
JOIN orders ON meals.meal_id = orders.meal_id
GROUP BY eatery, delivr_quarter
ORDER BY delivr_quarter, users;



WITH eatery_users AS  (
  SELECT
    eatery,
    -- Format the order date so "2018-06-01" becomes "Q2 2018"
    TO_CHAR(order_date, '"Q"Q YYYY') AS delivr_quarter,
    -- Count unique users
    COUNT(DISTINCT user_id) AS users
  FROM meals
  JOIN orders ON meals.meal_id = orders.meal_id
  GROUP BY eatery, delivr_quarter
  ORDER BY delivr_quarter, users)

SELECT
  -- Select eatery and quarter
  eatery,
  delivr_quarter,
  -- Rank rows, partition by quarter and order by users
  RANK() OVER
    (PARTITION BY delivr_quarter
     ORDER BY users DESC) :: INT AS users_rank
FROM eatery_users
ORDER BY delivr_quarter, users_rank;


-- Import tablefunc
CREATE EXTENSION IF NOT EXISTS tablefunc;

-- Pivot the previous query by quarter
SELECT * FROM CROSSTAB($$
  WITH eatery_users AS  (
    SELECT
      eatery,
      -- Format the order date so "2018-06-01" becomes "Q2 2018"
      TO_CHAR(order_date, '"Q"Q YYYY') AS delivr_quarter,
      -- Count unique users
      COUNT(DISTINCT user_id) AS users
    FROM meals
    JOIN orders ON meals.meal_id = orders.meal_id
    GROUP BY eatery, delivr_quarter
    ORDER BY delivr_quarter, users)

  SELECT
    -- Select eatery and quarter
    eatery,
    delivr_quarter,
    -- Rank rows, partition by quarter and order by users
    RANK() OVER
      (PARTITION BY delivr_quarter
       ORDER BY users DESC) :: INT AS users_rank
  FROM eatery_users
  ORDER BY eatery, delivr_quarter;
$$)
-- Select the columns of the pivoted table
AS  ct (eatery TEXT,
        "Q2 2018" INT,
        "Q3 2018" INT,
        "Q4 2018" INT)
ORDER BY "Q4 2018";
