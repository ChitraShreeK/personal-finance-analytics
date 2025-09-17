# Spending Pattern Analysis for Personal Finance

## Summary
- Individuals often struggle to track spending, identify costly habits and align daily expenses with long term saving goals. This project addresses the challenge of **managing personal finances** by transforming raw transaction data into **actionable insights and data driven recommendations**.
- Using **SQL for ETL** to leverage transaction level data(10000+ records) to uncover **spending trends, top expense categories and customer level insights**.
- I developed an interactive **Power BI dashboard** that provides a clear overview of spending habits. This will help users to identify **high spending categories, track their monthly expense trends and calculate savings gaps vs financial goals**.
- The project could be extended by integrating a **predictive model** to forecast future spending trends or by building a **customer segmentation model** to group users with similar spending habits.
- This analysis is based on a static, historical dataset sets the limitation. A live integrated solution would require a connection to a dynamic data source.

## Business Problem
In today's complex financial landscape, Individuals find it challenging to manage personal finances without a structure view of **where money goes, how much is spent and how it aligns with goals**. This project tackles the problem by analyzing granular transaction data to uncover patterns and provide actionable recommendations.

## Methodology
- **Data Cleaning & Integrity:** Used **SQL**(MySQL) to clean, validate and transform raw transaction dataset of **10000 transactions and 200 unique customers**. Addressing data quality issues like duplicate entries, incorrect formatting and rounding discrepancy in the `total_spent` column to ensure data reliability.
- **Descriptive Analytics:** Performed comprehensive **Exploratory Data Analysis (EDA)**
  - By using `GROUP BY`, `SUM`, `AVG` and window functions to uncover key trends in spending by category, item and time
  - Trend analysis on **monthly and yearly spending**
  - Customer Segmentation into **low, medium and high spenders**
  - In **Category level breakdown** expenses it is found that the highest spending is on `shopping` category with `775` of overall transactions
  - Top 10 high value customers and items purchased
  - Payment method preference analysis
  - **Time Series** shows a clear spending pattern throughout the year. Spending peaks in the spring months of `May` and early winter or holiday months of `November and December`
- **Interactive Dashboard:** Developed interactive dashboard using `Power BI` with dynamic filters `Customer ID`, `Month-Year`, KPI cards, bar charts, pie chart.
  - Created a `custom goal-tracking` measure using `DAX` to provide prescriptive recommendations. This feature calculates the monthly savings required for a user to achieve a specific financial goal.
  - **Business Acumen:** Translated raw data findings into actionable business recommendations and designed the dashboard from user-centric perspective to address the core business problem.

  *DAX for custom goal tracker*  
  ```
    Monthly Saving Needed = 
      VAR Goal1 = 'Goal Amount'[Goal Amount Value] 
      VAR CurrentSpent = [Total Spent for Selected Customer]
      VAR TotalTimeInMonths = DATEDIFF(MIN('customer_spending_db vw_financial_dashboard'[transaction_date]), MAX('customer_spending_db vw_financial_dashboard'[transaction_date]), MONTH) + 1 // Calculate total months in the dataset

      RETURN
      IF(
      ISFILTERED('customer_spending_db vw_financial_dashboard'[customer_id]),
      IF(
          TotalTimeInMonths > 0,
          DIVIDE( (Goal1 - CurrentSpent), TotalTimeInMonths, BLANK() ),
          BLANK()
      ),
      "Select a Customer ID to see savings requirements"
    )
  ```

## Power BI Dashboard Images

![Dashboard Main](dashboard\dashboard_images\final_dashboard_image.png)
*Main Dashboard*

---

![Dashboard Main](dashboard\dashboard_images\customer_id_selected.png)
*After Selecting a Customer ID*

## Skills & Key Tool
- **SQL:** `SUM`, `GROUP BY`, `ORDER BY`, Case Statements, Aggregations, CTEs
- **Power BI:** DAX measures, KPI cards, slicers, data modeling, interactive dashboarding
- **Data Visualization:** Bar Chart, Pie Chart
- **Business Analysis:** Spending Segmentation, Savings Gap Analysis

## Results & Business Recommendations
- Identified **shopping** as the **Top Spending Category** making up ~90% of the `total expenses`.
- **Top 10 Customers accounted for a significant share of revenue** useful for targeted financial advice.
- **Digital Wallet** dominated payment methods showing a shift towards `cashless spending`.
- Created **Goal Tracker KPI Card** shows if the customer's savings target is achievable and how much monthly savings is needed.

### Recommendations
- Customers should monitor high spending categories like `shopping` and `travel`
- Introduced **personalized saving plans** based on historical spending
- Promote awareness of low-value frequent transactions like `groceries`, `subcriptions` that add up over time

## Next Steps and Limitations
- The project could be extended by integrating a **Predictive Modeling** to forecast spending trends
- Enhance dashboard with **budget and actual comparison** for proactive decision making

### Limitations
- Dataset is **synthetic** and may not fully reflect real world personal finance complexities
- Current analysis is descriptive no forecasting or anomaly detection implemented yet
- Dashboard works best for **exploratory insights** rather than perspective financial planning
