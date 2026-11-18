WITH ranked_inventory AS (
    SELECT
        store_id,
        product_name,
        quantity,
        price,

        ROW_NUMBER() OVER (
            PARTITION BY store_id
            ORDER BY price DESC, inventory_id
        ) AS expensive_rank,

        ROW_NUMBER() OVER (
            PARTITION BY store_id
            ORDER BY price ASC, inventory_id
        ) AS cheap_rank,

        COUNT(*) OVER (
            PARTITION BY store_id
        ) AS total_products

    FROM inventory
),

store_imbalance AS (
    SELECT
        store_id,

        MAX(
            CASE
                WHEN expensive_rank = 1
                THEN product_name
            END
        ) AS most_exp_product,

        MAX(
            CASE
                WHEN cheap_rank = 1
                THEN product_name
            END
        ) AS cheapest_product,

        MAX(
            CASE
                WHEN expensive_rank = 1
                THEN quantity
            END
        ) AS expensive_quantity,

        MAX(
            CASE
                WHEN cheap_rank = 1
                THEN quantity
            END
        ) AS cheapest_quantity,

        MAX(total_products) AS total_products

    FROM ranked_inventory
    GROUP BY store_id
)

SELECT
    s.store_id,
    s.store_name,
    s.location,
    i.most_exp_product,
    i.cheapest_product,
    ROUND(
        i.cheapest_quantity / i.expensive_quantity,
        2
    ) AS imbalance_ratio

FROM stores s
JOIN store_imbalance i
    ON s.store_id = i.store_id

WHERE
    i.total_products >= 3
    AND i.expensive_quantity < i.cheapest_quantity
    AND i.expensive_quantity > 0

ORDER BY
    imbalance_ratio DESC,
    s.store_name ASC;
