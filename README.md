# DiscretizationUsingAttributeValueLabeling
### Discretization Using Attribute Value Labeling

This algorithm takes a dataset containing attributes and labels as input and outputs the discrete attribute values along with their corresponding cut points. It employs a **top-down** approach, which starts with no cut points and adds one at each step. This contrasts with **bottom-up** methods, which begin with all possible cut points and remove one at each stage. A classic example of a top-down method is MDLP, while ChiMerge is a well-known bottom-up method.

#### How the Algorithm Works

The algorithm follows these steps (explained for a dataset with two labels, Y and N, but it can be adapted for datasets with more than two labels):

1. **Iterate Through Each Attribute:**
   - Repeat steps 2 to 6 for every column representing an attribute.
  
2. **Sort Attribute Values:**
   - Arrange the attribute values in ascending order.

3. **Calculate Label Percentages:**
   - For each value, compute the percentage of Y and N labels.

4. **Assign Labels:**
   - If the percentage of Y labels for a value is greater than or equal to the overall percentage of Ys in the dataset, assign the label Y to that value; otherwise, assign label N.

5. **Identify Cut Points:**
   - As you traverse the sorted attribute values, if two consecutive values have different labels, consider placing a cut point between them as described in the next step.

6. **Calculate Cut Points:**
   - Let x1 and x2 be two consecutive values with different labels, alpha and beta. The cut point (cp) between them is calculated using the following formula:
     - a: The number of records with label alpha and value x1.
     - A: The ratio of records with label alpha to the total records with value x1.
     - b: The number of records with label beta and value x2.
     - B: The ratio of records with label beta to the total records with value x2.
     - cp = x1 + [(a * A)/(a * A + b * B) * (x2 – x1) ]

#### Comparing the Proposed Method with Other Discretizers

Our proposed method was compared with five well-known discretizers:

- **MDLP**
- **Chi2**
- **ChiMerge (ChiM)**
- **Extended Chi2 (eChi2)**
- **Modified Chi2 (mChi2)**

These methods are accessible through the `discretization` package in the R programming language.

The performance of our algorithm was tested using 10 datasets from the KEEL data repository. The key features of these datasets are shown in Table 1.

**Table 1 – Key Features of the Datasets Used**

| #Attributes | #Examples | Dataset       |
|-------------|-----------|---------------|
| 7           | 106       | Appendicitis  |
| 19          | 539       | Bands         |
| 3           | 306       | Haberman      |
| 13          | 270       | Heart         |
| 19          | 155       | Hepatitis     |
| 5           | 961       | Mammographic  |
| 5           | 5472      | Phoneme       |
| 8           | 768       | Pima          |
| 9           | 699       | Wisconsin     |
| 57          | 4597      | Spambase      |

#### Evaluation Using Classifiers

We evaluated the proposed method using the following classifiers:

- **J48**
- **Naïve Bayes**
- **Random Forest**
- **Linear Regression**
- **Bagging**

**Accuracy**, calculated as follows, was used as the metric:

   accuracy=(TP+TN)/(TP+TN+FP+FN)

To determine the accuracy of each method:

1. **10-Fold Cross-Validation:**
   - Apply this validation on all datasets.

2. **Repeat the Process:**
   - For each dataset, repeat the following steps:
     1. For each discretizer, repeat the steps below.
     2. For each classifier, perform 10-fold cross-validation on the dataset. Each time one fold serves as the test set and the rest as the training set. Discretize the training data and apply the resulting cut points to the test data.
     3. Compute the accuracy by averaging the results across the 10 folds.

**Table 2** presents the average accuracy for each classifier, with the discretizers ranked from best to worst.

| Bagging   | Linear Regression | J48        | Random Forest | Naïve Bayes | Mean Accuracy |
|-----------|-------------------|------------|---------------|-------------|---------------|
| **avl**   | **mdlp**           | **chiM**   | **avl**       | **eChi2**   | **0.8369**    |
| **chi2**  | **avl**            | **chi2**   | **chiM**      | **mdlp**    | **0.8308**    |
| **chiM**  | **chi2**           | **eChi2**  | **chi2**      | **chiM**    | **0.8306**    |
| **mdlp**  | **chiM**           | **mdlp**   | **eChi2**     | **avl**     | **0.8252**    |
| **eChi2** | **eChi2**          | **avl**    | **mdlp**      | **chi2**    | **0.8222**    |
| **mChi2** | **mChi2**          | **mChi2**  | **mChi2**     | **mChi2**   | **0.8135**    |

Our method ranked highest in accuracy in two cases and had the highest overall average accuracy.

#### Execution Time Comparison

**Table 3** shows the average execution time for each discretizer, using the datasets from Table 1. The discretizers are ranked from fastest to slowest.

| Time (seconds) | Discretizer |
|----------------|-------------|
| **0.172**      | **avl**     |
| **1.862**      | **mdlp**    |
| **88.862**     | **chiM**    |
| **91.108**     | **mChi2**   |
| **174.947**    | **Chi2**    |
| **305.651**    | **eChi2**   |

Discretization is performed only once on the training data, so execution time might not always seem critical. However, if this phase takes too long, it can become impractical for real-world applications. Our method is significantly faster than the others. For instance, if we scale the Spambase dataset to 10 million records, our method would take about 30 minutes, MDLP would need 5 hours, and eChi2 would require 50 days.

#### Number of Cut Points

**Table 4** presents the average number of cut points generated by each discretizer, ranked from fewest to most. The last row shows the number without any discretizer.

| #Intervals   | Discretizer |
|--------------|-------------|
| **1.4170**   | **mdlp**    |
| **1.5893**   | **mChi2**   |
| **2.0811**   | **eChi2**   |
| **28.3551**  | **chiM**    |
| **30.2684**  | **Chi2**    |
| **98.0847**  | **avl**     |
| **286.316289** | **Nothing** |

A good discretization method should aim to minimize the number of cut points, as too many can slow down the learning process. However, fewer cut points might lead to loss of information, but this can be mitigated by retaining the original data. Despite its overall effectiveness, our method produced the most cut points, which could be considered a downside.

#### Similarity with Existing Methods

To evaluate the similarity of our method with existing ones, we used 30 available discretization methods from the KEEL software on the Haberman dataset. None of the methods matched our cut points exactly, though Chi2 and Extended Chi2 had somewhat similar results, albeit with different algorithms.

To address the high number of intervals, we applied the `sp.del` code (included in the appendix), which reduced the average number of cut points from 96 to 2 per attribute but decreased accuracy by 4%. Developing a method to reduce intervals with minimal accuracy loss could be a valuable next step.
