

/* Query 1 - Which actors appeared in the most family-friendly movies featuring household pets? */

  SELECT a.first_name || ' ' || a.last_name AS actor_name,
         COUNT(*) AS film_count
    FROM actor a
    JOIN film_actor fa
      ON a.actor_id = fa.actor_id
    JOIN film f
      ON fa.film_id = f.film_id
   WHERE (f.description LIKE '%Cat%' OR f.description LIKE '%Dog%')
     AND f.rating IN('G', 'PG')
GROUP BY 1
ORDER BY 2 DESC
   LIMIT 5
;


/* Query 2 - What are the top 10 rented non-foreign movies that are rented in a language that isn't English and how do their rental rates compare to the average rental price of all movies? */

WITH top_ten AS (
                  SELECT f.film_id,
                         f.title AS movie,
                         f.rental_rate AS price,
                         COUNT(r.*) as rentals
                    FROM film f
                    JOIN language l
                      ON f.language_id = f.language_id
                    JOIN film_category fc
                      ON f.film_id = fc.film_id
                    JOIN category c
                      ON fc.category_id = c.category_id
                    JOIN inventory i
                      ON f.film_id = i.film_id
                    JOIN rental r
                      ON i.inventory_id = r.inventory_id
                   WHERE c.name != 'Foreign' AND l.name != 'English'
                GROUP BY 1,2,3
                ORDER BY 4 DESC
                LIMIT 10
              )
    SELECT tt.movie,
           tt.price,
           ROUND(tt.price - (SELECT AVG(f.rental_rate) FROM film f), 2) AS price_difference
      FROM top_ten tt
  ORDER BY 1 ASC
;


/* Query 3 - What is the average rental count of movies divided by MPAA rating during Summer 2005? */

  SELECT rating,
         ROUND(AVG(total_rentals), 0) AS average_rentals
    FROM (
          SELECT f.rating, COUNT(*) AS total_rentals
          FROM film f
          JOIN inventory i
          ON f.film_id = i.film_id
          JOIN rental r
          ON i.inventory_id = r.inventory_id
          WHERE r.rental_date >= '2005-06-01' AND r.rental_date <= '2005-08-31'
          GROUP BY 1
         ) sub
GROUP BY 1
ORDER BY 1
;

/* Query 4 - What is the quartile of each category based on the average rental price? */

  SELECT c.name AS category,
         ROUND(AVG(f.rental_rate), 2) AS average_price,
         NTILE(4) OVER (ORDER BY AVG(f.rental_rate)) AS quartile
    FROM film f
    JOIN film_category fc
      ON f.film_id = fc.film_id
    JOIN category c
      ON fc.category_id = c.category_id
GROUP BY 1
ORDER BY 3,2 ASC;
