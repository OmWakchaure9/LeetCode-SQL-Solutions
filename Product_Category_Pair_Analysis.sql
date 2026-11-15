SELECT
    p1.category AS category1,
    p2.category AS category2,
    COUNT(DISTINCT pp1.user_id) AS customer_count
FROM ProductPurchases pp1
JOIN ProductInfo p1
    ON pp1.product_id = p1.product_id
JOIN ProductPurchases pp2
    ON pp1.user_id = pp2.user_id
JOIN ProductInfo p2
    ON pp2.product_id = p2.product_id
WHERE p1.category < p2.category
GROUP BY p1.category, p2.category
HAVING COUNT(DISTINCT pp1.user_id) >= 3
ORDER BY
    customer_count DESC,
    category1 ASC,
    category2 ASC;
