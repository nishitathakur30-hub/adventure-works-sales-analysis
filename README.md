# Adventure Works Sales Analysis – Internship Project

## Overview
This project is an end-to-end data analysis case study built on the **Adventure Works** dataset, completed as part of a data analytics internship. The goal was to analyze sales, production cost, and profit trends to support business decisions around revenue growth, cost reduction, and customer/product targeting.

## Business Requirements
- Increase revenue
- Cut costs
- Improve targeting

**Key KPIs:** Sales, Production Cost, Profit

## Objectives

### Page 1: Overview
- Analyze yearly sales trends to monitor business growth over time
- Compare sales contribution across different region groups
- Identify top-performing product categories based on sales
- Analyze customer distribution across regions to understand market presence

### Page 2: Time Series Analysis
- Analyze yearly, quarterly, and monthly sales trends
- Identify seasonal patterns and peak sales periods
- Compare sales, production cost, and profit trends over time
- Monitor overall business growth and performance changes

### Page 3: Customer Analysis
- Analyze customer distribution across regions and countries
- Identify repeat customers and customer retention trends
- Identify top customers based on sales and profit contribution
- Analyze customer purchasing behavior across different markets

### Page 4: Product & Regional Analysis
- Analyze sales performance by product category and subcategory
- Identify top-selling and high-profit products
- Detect low-profit or loss-making products for cost reduction
- Compare regional sales and profit performance to identify top-performing markets

## Tools Used
- **Excel** – Data cleaning, calculated fields, pivot tables, and charts
- **SQL** – Querying and joining data tables
- **Tableau** – Interactive dashboards and visualizations
- **Power BI** – Dashboard and report development

## Process
1. **Data Preparation (Excel)**
   - Looked up Product Name from the Product sheet into the Sales sheet
   - Looked up Customer Full Name and Unit Price from Customer/Product sheets into Sales sheet
   - Created calculated date fields from `OrderDateKey`:
     - Year, Month Number, Month Full Name
     - Quarter (Q1–Q4)
     - Year-Month (YYYY-MMM)
     - Weekday Number & Name
     - Financial Month (April = FM1 ... March = FM12)
     - Financial Quarter (Apr–Jun = FQ1, Jul–Sep = FQ2, Oct–Dec = FQ3, Jan–Mar = FQ4)
   - Calculated **Sales Amount** (Unit Price × Order Quantity − Unit Discount)
   - Calculated **Production Cost** (Unit Cost × Order Quantity)
   - Calculated **Profit** (Sales Amount − Production Cost)

2. **Excel Analysis & Visualization**
   - Pivot table for monthly sales (year filter included)
   - Bar chart – yearly sales
   - Line chart – monthly sales
   - Pie chart – quarterly sales
   - Combination chart (bar + line) – Sales Amount vs Production Cost
   - Additional KPIs/charts for performance by Product, Customer, and Region

3. **SQL**
   - Used SQL queries to organize, join, and validate data across fact and dimension tables (Customer, Product, Product Category, Product Subcategory, Sales Territory, Date, Internet Sales)

4. **Tableau & Power BI Dashboards**
   - Built interactive dashboards covering overview, time series, customer, and product/regional analysis
   - Designed visuals to answer the business objectives listed above

## Project Schedule
| Week | Focus Area |
|------|------------|
| Kickoff | Project introduction & planning |
| Week 1 | Excel – data prep, calculations, charts |
| Week 2 | Tableau + SQL |
| Week 3 | Power BI |
| Week 4 | Final review meeting |

## Repository Structure
```
adventure-works-sales-analysis/
├── README.md
├── data/
│   ├── Adventure_Work_Final.xlsx
│   ├── DimCustomer.xlsx
│   ├── DimDate.xlsx
│   ├── DimProduct.xlsx
│   ├── DimProductCategory.xlsx
│   ├── DimProductSubCategory.xlsx
│   ├── DimSalesTerritory.xlsx
│   ├── FactInternetSales.xlsx
│   └── Fact_Internet_Sales_New.xlsx
├── tableau/
│   └── Adventure_Work_Tableau.twbx
├── powerbi/
│   └── Adventure_Work_Project.pbix
├── docs/
│   ├── Business_Requirements.docx
│   ├── Project_Info_and_Schedule.pptx
│   ├── Questionnaires.xlsx
│   └── screenshots/
│       └── dashboard_screenshots.png
```

## Key Insights
- Identified top-performing product categories and subcategories by sales and profit
- Highlighted seasonal sales patterns and peak periods across financial quarters
- Mapped customer distribution and top customers by region/country
- Flagged low-profit/loss-making products for potential cost optimization

## Author
Internship Project – Data Analytics (Excel, SQL, Tableau, Power BI)

## License
This project uses the publicly available Adventure Works sample dataset for educational/portfolio purposes.
