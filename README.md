# Ecommerce Analytics Engineering Portfolio

An end-to-end analytics engineering portfolio project that transforms synthetic ecommerce data into tested dbt models and an [interactive, three-page BI dashboard style](https://sambidao88.github.io/ecommerce-analytics-public-dashboard/).

**The goal:** demonstrate how raw operational data can be transformed into reliable, well-defined business metrics that stakeholders can explore.

<p align="center">
  <a href="https://app.motherduck.com/dives/ecommerce-portfolio-bi-dashboard-41ff7e63-3d27-46ca-bcd8-0820ce72c72f">
    <strong>View the interactive dashboard</strong>
  </a>
</p>

> **Dataset:** Synthetic data created for learning and demonstration. No real customer information is used. All monetary values are in Vietnamese dong (VND).

## Project highlights

| Area | Implementation |
|---|---|
| Data warehouse | DuckDB |
| SQL transformation | dbt Core + dbt-duckdb |
| Data modeling | Staging, intermediate, and dimensional marts |
| Data quality | 63 dbt tests passed |
| BI dashboard | MotherDuck Dives, React, Recharts, SQL |
| Dataset | 5 CSV seeds: 10 customers, 8 products, 3 stores, 20 orders, 35 order items |

### Interactive dashboard

The dashboard is organized into three analytical pages:

1. **Overview** — headline KPIs, monthly revenue trend, revenue by category and store, and top products.
2. **Sales Analytics** — sales trends, order status distribution, channel performance, store comparison, and monthly details.
3. **Product & Customer** — product performance, category contribution, customer segments, and customer geography.

Available dashboard filters include date range, store, category, and sales channel. The Sales Analytics page also includes an order-status filter.

**Dashboard link:** [Ecommerce Portfolio BI Dashboard](https://app.motherduck.com/dives/ecommerce-portfolio-bi-dashboard-41ff7e63-3d27-46ca-bcd8-0820ce72c72f)

> **Access note:** The dashboard is hosted on MotherDuck. Viewer access depends on the dashboard and database sharing permissions. If you are reviewing this repository and cannot open the dashboard, please use the dbt models and SQL examples below; the dashboard owner may need to grant access.

## What this project demonstrates

- Building a layered SQL transformation workflow with dbt.
- Designing dimensional models and documenting fact-table grain.
- Applying dbt tests for key uniqueness, nullability, relationships, and accepted values.
- Defining business metrics with explicit treatment of discounts, shipping, and order statuses.
- Building an interactive BI experience on top of modeled warehouse tables.
- Translating business questions into reusable analytical models and dashboard views.

## Architecture

```text
CSV seeds
   |
   v
Staging models
(stg_customers, stg_products, stg_orders,
 stg_order_items, stg_stores)
   |
   v
Intermediate model
(int_order_items_enriched)
   |
   v
Dimensional marts
(dim_customer, dim_product, dim_store, dim_date)
                +
Fact mart
(fct_order_items)
   |
   v
MotherDuck
   |
   v
Interactive BI dashboard
(Overview | Sales Analytics | Product & Customer)
```

### Data model

The fact table is intentionally designed at **one row per order item**.

```text
customers  1 ─── * orders  1 ─── * order_items * ─── 1 products
                         *
                         |
                         1
                       stores
```

| Model layer | Models | Purpose |
|---|---|---|
| Staging | `stg_customers`, `stg_products`, `stg_orders`, `stg_order_items`, `stg_stores` | Standardize source types and text while preserving source grain |
| Intermediate | `int_order_items_enriched` | Join order items to order, product, and store attributes; calculate item-level measures |
| Dimensions | `dim_customer`, `dim_product`, `dim_store`, `dim_date` | Provide descriptive context for analysis |
| Fact | `fct_order_items` | Publish item-grain records with dimension keys, order status, and additive item-level measures |

## Business metrics and modeling decisions

A key part of this project is making metric definitions explicit and avoiding incorrect aggregation.

### Item-level calculations

```text
gross_item_revenue                 = quantity * unit_price
net_item_revenue                   = gross_item_revenue - item_discount
item_cost_amount                   = quantity * unit_cost_at_sale
gross_profit_before_order_discount = net_item_revenue - item_cost_amount
```

### Important business rules

- `item_discount` is the total discount for an order line, not a per-unit discount.
- `net_item_revenue` includes item-level discounts but excludes the order-level discount.
- `order_discount` belongs to the order grain. It must be applied once after aggregating item revenue to the order level—not subtracted from every order-item fact row.
- `shipping_fee` is kept separate from product revenue.
- The fact table retains all order statuses. Delivered-sales examples explicitly filter to `delivered`.
- `gross_profit_before_order_discount` is not net profit. It excludes order-level discounts, shipping, and operating expenses.

These decisions matter because applying an order-level discount to every fact row can overstate discounts and understate revenue.

## Example analytical questions

The modeled data can be used to answer questions such as:

- How do delivered item revenue and gross profit change by month and sales channel?
- Which products and categories contribute the most units and item revenue?
- What is average order value after order-level discounts and before shipping?
- How do sales differ between online and retail channels?
- Which customer segments and locations contribute to sales?

### Example result: average order value

The AOV query aggregates item revenue to the order grain before applying the order-level discount.

For the included synthetic dataset:

| Metric | Result |
|---|---:|
| Delivered orders | 15 |
| Net sales after order discount, before shipping | 13,800,000 VND |
| Average order value | 920,000 VND |

## Data quality and validation

The project includes dbt generic tests for:

- Unique and non-null primary keys.
- Referential integrity between customers, orders, stores, products, and order items.
- Accepted values for order statuses and sales channels.

**Latest local validation recorded for this project:**

```text
dbt parse: successful
dbt ls: 11 models, 5 seeds, 63 data tests
dbt test: PASS=63, ERROR=0
```

The tests are defined alongside the corresponding seeds and models in `seeds/schema.yml` and `models/**/schema.yml`.

## Repository structure

```text
.
├── ecommerce_dbt/
│   ├── seeds/
│   │   ├── customers.csv
│   │   ├── products.csv
│   │   ├── stores.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   └── schema.yml
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   ├── dbt_project.yml
│   └── ...
└── README.md
```

> Adjust this tree if your actual GitHub repository has a different folder layout. Do not commit your local DuckDB database, dbt profile, credentials, or environment-specific files.

## Run locally

The commands below assume you are running them from the `ecommerce_dbt` directory and have installed dbt Core with the DuckDB adapter.

### 1. Configure your local dbt profile

Create `~/.dbt/profiles.yml`. On Windows, this is usually:

```text
%USERPROFILE%\.dbt\profiles.yml
```

Example:

```yaml
ecommerce_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ecommerce.duckdb
      threads: 4
```

The profile name must match the `profile` value in `dbt_project.yml`.

### 2. Build and test

```powershell
cd ecommerce_dbt

dbt debug
dbt seed
dbt run
dbt test
```

### 3. Generate dbt documentation

```powershell
dbt docs generate
dbt docs serve
```

Open the local URL printed by dbt to explore model documentation and lineage.

> **Security:** Do not commit `profiles.yml`, access tokens, API keys, passwords, or other credentials. Check `.gitignore` before pushing. If you use a remote target, verify the active target before running `dbt seed` or `dbt run`.

## Example SQL

### Delivered item revenue and gross profit by month and channel

```sql
SELECT
    d.year,
    d.month,
    f.sales_channel,
    SUM(f.net_item_revenue) AS item_net_revenue_vnd,
    SUM(f.gross_profit_before_order_discount)
        AS gross_profit_before_order_discount_vnd
FROM main.fct_order_items AS f
JOIN main.dim_date AS d
    ON f.order_date_key = d.date_key
WHERE f.order_status = 'delivered'
GROUP BY d.year, d.month, f.sales_channel
ORDER BY d.year, d.month, f.sales_channel;
```

### Top five products by delivered item revenue

```sql
SELECT
    p.product_name,
    p.category,
    SUM(f.quantity) AS units_sold,
    SUM(f.net_item_revenue) AS item_net_revenue_vnd
FROM main.fct_order_items AS f
JOIN main.dim_product AS p
    ON f.product_id = p.product_id
WHERE f.order_status = 'delivered'
GROUP BY p.product_name, p.category
ORDER BY item_net_revenue_vnd DESC
LIMIT 5;
```

### Average order value after order discount, before shipping

```sql
WITH delivered_orders AS (
    SELECT
        order_id,
        SUM(net_item_revenue) AS item_net_revenue
    FROM main.fct_order_items
    WHERE order_status = 'delivered'
    GROUP BY order_id
)
SELECT
    COUNT(*) AS delivered_orders,
    SUM(d.item_net_revenue - o.order_discount)
        AS net_sales_after_order_discount_before_shipping_vnd,
    ROUND(
        SUM(d.item_net_revenue - o.order_discount) * 1.0
        / NULLIF(COUNT(*), 0),
        0
    ) AS average_order_value_vnd
FROM delivered_orders AS d
JOIN main.stg_orders AS o
    USING (order_id);
```

## Scope and limitations

This is a compact portfolio case study built with a small synthetic dataset. It demonstrates modeling and analytics concepts, but it is **not a production data platform**.

Potential next iterations:

- Add a larger and more varied source dataset.
- Introduce an order-grain fact model for order-level discounts and shipping.
- Add incremental models and customer history snapshots.
- Add automated CI checks.
- Create a documented, reusable metric layer.
- Extend dashboard interactions and add further validation against independent SQL queries.

## About

This project was built as a hands-on portfolio exercise in Analytics Engineering, combining SQL transformation, data modeling, data quality, and business-facing analytics.

**Languages:** English and Vietnamese.


---

# Phiên bản tiếng Việt

Dự án portfolio Analytics Engineering đầu-cuối, chuyển đổi dữ liệu thương mại điện tử giả lập thành các mô hình dbt có kiểm thử và [dashboard phong cách BI tương tác gồm ba trang](https://sambidao88.github.io/ecommerce-analytics-public-dashboard/).

**Mục tiêu:** thể hiện cách chuyển dữ liệu vận hành thô thành các chỉ số kinh doanh đáng tin cậy, có định nghĩa rõ ràng và có thể được người dùng nghiệp vụ tự khám phá.

<p align="center">
  <a href="https://app.motherduck.com/dives/ecommerce-portfolio-bi-dashboard-41ff7e63-3d27-46ca-bcd8-0820ce72c72f">
    <strong>Xem dashboard tương tác</strong>
  </a>
</p>

> **Lưu ý về dữ liệu:** Toàn bộ dữ liệu được tạo giả lập cho mục đích học tập và trình diễn. Dự án không sử dụng thông tin khách hàng thật. Đơn vị tiền tệ là đồng Việt Nam (VND).

## Điểm nổi bật của dự án

| Hạng mục | Triển khai |
|---|---|
| Data warehouse | DuckDB |
| Chuyển đổi dữ liệu | dbt Core + dbt-duckdb |
| Data modeling | Staging, intermediate và dimensional marts |
| Data quality | 63 dbt tests đã chạy đạt |
| BI dashboard | MotherDuck Dives, React, Recharts, SQL |
| Dữ liệu | 5 CSV seeds: 10 khách hàng, 8 sản phẩm, 3 cửa hàng, 20 đơn hàng, 35 dòng hàng |

### Dashboard tương tác

Dashboard được chia thành ba trang phân tích:

1. **Overview (Tổng quan)** — KPI chính, xu hướng doanh thu theo tháng, doanh thu theo danh mục và cửa hàng, top sản phẩm.
2. **Sales Analytics (Phân tích bán hàng)** — xu hướng doanh thu, phân bổ trạng thái đơn hàng, hiệu quả theo kênh bán, so sánh cửa hàng và chi tiết theo tháng.
3. **Product & Customer (Sản phẩm & Khách hàng)** — hiệu quả sản phẩm, đóng góp theo danh mục, phân khúc khách hàng và khu vực địa lý.

Các bộ lọc hiện có gồm khoảng thời gian, cửa hàng, danh mục và kênh bán. Trang Sales Analytics có thêm bộ lọc trạng thái đơn hàng.

**Liên kết dashboard:** [Ecommerce Portfolio BI Dashboard](https://app.motherduck.com/dives/ecommerce-portfolio-bi-dashboard-41ff7e63-3d27-46ca-bcd8-0820ce72c72f)

> **Lưu ý quyền truy cập:** Dashboard được host trên MotherDuck. Khả năng xem phụ thuộc vào quyền chia sẻ dashboard và database. Nếu bạn không mở được dashboard, có thể tham khảo các dbt models và SQL examples trong repository; chủ sở hữu dashboard có thể cần cấp quyền truy cập.

## Dự án thể hiện những năng lực nào?

- Xây dựng quy trình chuyển đổi dữ liệu SQL theo nhiều lớp bằng dbt.
- Thiết kế dimensional models và xác định rõ grain của fact table.
- Sử dụng dbt tests để kiểm tra tính duy nhất, giá trị null, quan hệ khóa và tập giá trị hợp lệ.
- Định nghĩa KPI nghiệp vụ, xử lý rõ ràng chiết khấu, phí giao hàng và trạng thái đơn hàng.
- Xây dựng trải nghiệm BI tương tác trên các bảng dữ liệu đã được mô hình hóa.
- Chuyển câu hỏi nghiệp vụ thành các mô hình phân tích và dashboard có thể tái sử dụng.

## Kiến trúc dự án

```text
CSV seeds
   |
   v
Staging models
(stg_customers, stg_products, stg_orders,
 stg_order_items, stg_stores)
   |
   v
Intermediate model
(int_order_items_enriched)
   |
   v
Dimensional marts
(dim_customer, dim_product, dim_store, dim_date)
                +
Fact mart
(fct_order_items)
   |
   v
MotherDuck
   |
   v
Interactive BI dashboard
(Overview | Sales Analytics | Product & Customer)
```

### Mô hình dữ liệu

Fact table được thiết kế với grain **một dòng cho mỗi order item (dòng hàng trong đơn hàng)**.

```text
customers  1 ─── * orders  1 ─── * order_items * ─── 1 products
                         *
                         |
                         1
                       stores
```

| Lớp model | Các model | Mục đích |
|---|---|---|
| Staging | `stg_customers`, `stg_products`, `stg_orders`, `stg_order_items`, `stg_stores` | Chuẩn hóa kiểu dữ liệu và văn bản, đồng thời giữ nguyên grain của dữ liệu nguồn |
| Intermediate | `int_order_items_enriched` | Kết hợp order items với thông tin đơn hàng, sản phẩm và cửa hàng; tính các chỉ số ở cấp dòng hàng |
| Dimensions | `dim_customer`, `dim_product`, `dim_store`, `dim_date` | Cung cấp ngữ cảnh mô tả để phân tích |
| Fact | `fct_order_items` | Cung cấp dữ liệu ở grain dòng hàng, kèm dimension keys, trạng thái đơn và các chỉ số cộng gộp ở cấp dòng hàng |

## Định nghĩa chỉ số và quyết định mô hình hóa

Một nội dung quan trọng của dự án là định nghĩa chỉ số rõ ràng và tránh cộng gộp sai cấp dữ liệu.

### Công thức ở cấp dòng hàng

```text
gross_item_revenue                 = quantity * unit_price
net_item_revenue                   = gross_item_revenue - item_discount
item_cost_amount                   = quantity * unit_cost_at_sale
gross_profit_before_order_discount = net_item_revenue - item_cost_amount
```

### Các quy tắc nghiệp vụ quan trọng

- `item_discount` là tổng chiết khấu của một dòng hàng, không phải chiết khấu trên từng đơn vị sản phẩm.
- `net_item_revenue` đã trừ chiết khấu cấp dòng hàng nhưng chưa trừ chiết khấu cấp đơn hàng.
- `order_discount` thuộc grain đơn hàng. Cần tổng hợp doanh thu các dòng hàng lên cấp đơn hàng rồi mới áp dụng chiết khấu một lần — không trừ chiết khấu này trên từng dòng của fact table.
- `shipping_fee` được tách riêng, không gộp vào doanh thu sản phẩm.
- Fact table giữ lại tất cả trạng thái đơn hàng. Các truy vấn doanh thu mẫu lọc riêng trạng thái `delivered`.
- `gross_profit_before_order_discount` không phải lợi nhuận ròng. Chỉ số này chưa trừ chiết khấu cấp đơn hàng, phí giao hàng và chi phí vận hành.

Các quy tắc này quan trọng vì nếu áp dụng chiết khấu cấp đơn cho từng dòng hàng, tổng chiết khấu sẽ bị tính lặp và doanh thu bị ghi nhận thấp hơn thực tế.

## Các câu hỏi phân tích mẫu

Dữ liệu sau khi mô hình hóa có thể trả lời các câu hỏi:

- Doanh thu dòng hàng và lợi nhuận gộp của đơn đã giao thay đổi thế nào theo tháng và kênh bán?
- Sản phẩm và danh mục nào đóng góp nhiều sản lượng và doanh thu dòng hàng nhất?
- Giá trị đơn hàng trung bình sau chiết khấu cấp đơn và trước phí giao hàng là bao nhiêu?
- Doanh thu khác nhau thế nào giữa kênh online và cửa hàng bán lẻ?
- Phân khúc khách hàng và khu vực nào đóng góp vào doanh thu?

### Ví dụ kết quả: Average Order Value (AOV)

Truy vấn AOV tổng hợp doanh thu dòng hàng lên grain đơn hàng trước khi áp dụng chiết khấu cấp đơn.

Với bộ dữ liệu giả lập hiện tại:

| Chỉ số | Kết quả |
|---|---:|
| Số đơn đã giao | 15 |
| Doanh thu sau chiết khấu cấp đơn, trước phí giao hàng | 13.800.000 VND |
| Giá trị đơn hàng trung bình (AOV) | 920.000 VND |

## Chất lượng dữ liệu và kiểm định

Dự án sử dụng dbt generic tests để kiểm tra:

- Khóa chính không null và có giá trị duy nhất.
- Tính toàn vẹn tham chiếu giữa khách hàng, đơn hàng, cửa hàng, sản phẩm và dòng hàng.
- Các giá trị hợp lệ của trạng thái đơn hàng và kênh bán.

**Kết quả kiểm định cục bộ được ghi nhận gần nhất:**

```text
dbt parse: successful
dbt ls: 11 models, 5 seeds, 63 data tests
dbt test: PASS=63, ERROR=0
```

Các khai báo kiểm thử nằm cạnh seed và model tương ứng trong `seeds/schema.yml` và `models/**/schema.yml`.

## Cấu trúc repository

```text
.
├── ecommerce_dbt/
│   ├── seeds/
│   │   ├── customers.csv
│   │   ├── products.csv
│   │   ├── stores.csv
│   │   ├── orders.csv
│   │   ├── order_items.csv
│   │   └── schema.yml
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   ├── dbt_project.yml
│   └── ...
└── README.md
```

> Điều chỉnh cây thư mục này nếu repository thực tế của bạn có cấu trúc khác. Không commit database DuckDB cục bộ, dbt profile, credentials hoặc các file phụ thuộc môi trường máy cá nhân.

## Chạy dự án trên máy cá nhân

Các lệnh dưới đây giả định bạn chạy từ thư mục `ecommerce_dbt` và đã cài dbt Core cùng DuckDB adapter.

### 1. Cấu hình dbt profile cục bộ

Tạo file `~/.dbt/profiles.yml`. Trên Windows, đường dẫn thường là:

```text
%USERPROFILE%\.dbt\profiles.yml
```

Ví dụ:

```yaml
ecommerce_dbt:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: ecommerce.duckdb
      threads: 4
```

Tên profile phải trùng với giá trị `profile` trong `dbt_project.yml`.

### 2. Build và kiểm thử

```powershell
cd ecommerce_dbt

dbt debug
dbt seed
dbt run
dbt test
```

### 3. Tạo tài liệu dbt

```powershell
dbt docs generate
dbt docs serve
```

Mở URL local được dbt hiển thị để xem tài liệu model và lineage.

> **Bảo mật:** Không commit `profiles.yml`, access token, API key, mật khẩu hoặc credentials. Kiểm tra `.gitignore` trước khi push. Nếu sử dụng remote target, hãy xác nhận target đang hoạt động trước khi chạy `dbt seed` hoặc `dbt run`.

## SQL phân tích mẫu

### Doanh thu dòng hàng và lợi nhuận gộp của đơn đã giao theo tháng và kênh bán

```sql
SELECT
    d.year,
    d.month,
    f.sales_channel,
    SUM(f.net_item_revenue) AS item_net_revenue_vnd,
    SUM(f.gross_profit_before_order_discount)
        AS gross_profit_before_order_discount_vnd
FROM main.fct_order_items AS f
JOIN main.dim_date AS d
    ON f.order_date_key = d.date_key
WHERE f.order_status = 'delivered'
GROUP BY d.year, d.month, f.sales_channel
ORDER BY d.year, d.month, f.sales_channel;
```

### Top 5 sản phẩm theo doanh thu dòng hàng của đơn đã giao

```sql
SELECT
    p.product_name,
    p.category,
    SUM(f.quantity) AS units_sold,
    SUM(f.net_item_revenue) AS item_net_revenue_vnd
FROM main.fct_order_items AS f
JOIN main.dim_product AS p
    ON f.product_id = p.product_id
WHERE f.order_status = 'delivered'
GROUP BY p.product_name, p.category
ORDER BY item_net_revenue_vnd DESC
LIMIT 5;
```

### Giá trị đơn hàng trung bình sau chiết khấu cấp đơn, trước phí giao hàng

```sql
WITH delivered_orders AS (
    SELECT
        order_id,
        SUM(net_item_revenue) AS item_net_revenue
    FROM main.fct_order_items
    WHERE order_status = 'delivered'
    GROUP BY order_id
)
SELECT
    COUNT(*) AS delivered_orders,
    SUM(d.item_net_revenue - o.order_discount)
        AS net_sales_after_order_discount_before_shipping_vnd,
    ROUND(
        SUM(d.item_net_revenue - o.order_discount) * 1.0
        / NULLIF(COUNT(*), 0),
        0
    ) AS average_order_value_vnd
FROM delivered_orders AS d
JOIN main.stg_orders AS o
    USING (order_id);
```

## Phạm vi và giới hạn

Đây là một case study portfolio với bộ dữ liệu giả lập có quy mô nhỏ. Dự án minh họa các khái niệm về modeling và analytics, nhưng **không phải một nền tảng dữ liệu production**.

Các hướng phát triển tiếp theo:

- Bổ sung bộ dữ liệu nguồn lớn và đa dạng hơn.
- Tạo fact table ở grain đơn hàng để quản lý chiết khấu cấp đơn và phí giao hàng.
- Bổ sung incremental models và snapshots cho lịch sử khách hàng.
- Tích hợp CI để tự động kiểm tra thay đổi.
- Xây dựng metric layer có tài liệu định nghĩa rõ ràng và tái sử dụng được.
- Mở rộng tương tác dashboard và bổ sung kiểm định với các truy vấn SQL độc lập.

## Giới thiệu

Dự án được xây dựng như một portfolio thực hành Analytics Engineering, kết hợp SQL transformation, data modeling, data quality và phân tích dữ liệu phục vụ nghiệp vụ.

**Ngôn ngữ:** Tiếng Anh và tiếng Việt.
