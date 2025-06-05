
# SBA Loan Default Risk Prediction

This project leverages historical loan data from the U.S. Small Business Administration (SBA) to predict the likelihood of loan defaults using logistic regression models. With nearly 900,000 observations from 1987–2014, we analyze patterns and train classification models to support smarter lending decisions by banks and reduce financial risk from loan defaults.

---

## Project Context

The SBA provides loan guarantees to encourage banks to lend to small businesses. While these guarantees reduce some of the lender's risk, banks still suffer losses if loans default. This project aims to help banks predict **which loans are at high risk of default**, improving loan decision accuracy and reducing unnecessary financial losses while still promoting small business growth.

---

## Business Problem

How can banks reduce the risk of approving SBA-guaranteed loans that are likely to default? Using historical data, we aim to develop a predictive model that:
- Flags loans likely to default
- Supports smarter, data-driven decisions
- Reduces the financial burden of false approvals

---

## CRISP-DM Breakdown

### 1. Business Understanding
Banks want to minimize losses from defaulted loans. By using predictive analytics, they can assess loan risk more effectively and refine approval criteria without relying solely on traditional metrics.

### 2. Data Understanding
We explored ~900K loans from the SBA. The dataset includes loan status, approval amounts, borrower details, location, and participation in programs like LowDoc. Approximately 20% of loans in the dataset defaulted, which is sufficient for binary classification modeling.

### 3. Data Preparation
- Removed or imputed NAs from critical variables
- Converted categorical variables (e.g., `LowDoc`, `RevLineCr`, `UrbanRural`) into binary
- Engineered new features: `ChrgOff` (binary default), `IsUrban`, `LogDisbGross`, etc.
- Reduced dataset to ~628,500 clean records

### 4. Modeling
We built 3 logistic regression models:
| Model | Features | Accuracy | Highlights |
|-------|----------|----------|------------|
| Model 1 | Term, IsUrban | 89.8% | Interpretable baseline |
| Model 2 | Term, IsUrban, DisbursementGross, GrAppv | 89.8% | Best performance |
| Model 3 | Term, DisbursementGross, LowDoc, GrAppv | 82.4% | Strong LowDoc signal |

**Threshold:** Conservative threshold of 35% used to identify high-risk loans.

### 5. Evaluation
- **Model 2** had the **lowest False Negative Rate**, making it the most reliable for limiting risky approvals.
- Sensitivity and specificity were also well-balanced.

### 6. Deployment & Recommendations
- **Observed loss** from defaults: ~$13.5B  
- **Predicted loss with Model 2**: ~$7.8B  
- **Savings**: ~$5.76B (~42% reduction)

**Key takeaway:** Use model predictions to guide decisions, not replace human judgment. The model is conservative by design to favor financial safety over missed revenue.

---

## Technologies Used

- **R** (GLM for logistic regression, base plotting)
- **Excel** (initial data storage)
- **Descriptive statistics**, **bar plots**, **confusion matrices**, **cross-validation**

---

## Author

**Anthony Partida**  
Cal Poly, San Luis Obispo  
Email: anthonypartida410@yahoo.com
LinkedIn: www.linkedin.com/in/anthony-partida

**Project Completion Date**
**(3/17/2025)**
This is an older project of mine, and I have learned so much since then. I just wanted to share this amazing project with the world!

---

## License

This project is for educational and demonstration purposes. Data provided by the U.S. SBA.
