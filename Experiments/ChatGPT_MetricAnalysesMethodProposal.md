This is a **very good experimental question**, and you’re thinking in exactly the *right* scientific direction.
What you want is **not just “which setting is best”**, but:

> *What component of PG (iterations vs LU history) is actually responsible for the performance gain?*

Below I’ll propose a **clean, defensible analysis framework** that you can use both analytically **and** in your thesis text. I’ll avoid vague “try this” advice and give you **concrete methods**.

---

# 1. First: Reframe the Question Precisely (Very Important)

You have **two control variables**:

* **I** = PG iterations (0, 10, 33, 100)
* **H** = LU history size (1, 2, 5, 10)

And a set of **response variables** (metrics):

* APE (SE3, Sim3)
* RPE (1 m, ~1 s, 50 m, 100 m, …)
* Yaw error
* Variance (std), max, SSE

You want to understand:

> Is the improvement dominated by **iterative refinement (I)** or by **temporal memory / conditioning (H)**?

This is a **factorial effect decomposition problem**, not just a comparison.

---

# 2. Method 1 — Two-Factor Factorial Decomposition (Recommended)

This is the **cleanest scientific approach** and maps perfectly to your table.

### 2.1 Treat PG as a Function

Define a metric ( M ) (e.g. APE RMSE):

[
M(I, H)
]

We want to decompose:

[
M(I, H) = M_0 + \Delta_I(I) + \Delta_H(H) + \Delta_{I \times H}
]

Where:

* ( \Delta_I ): contribution of PG iterations
* ( \Delta_H ): contribution of LU history
* ( \Delta_{I \times H} ): interaction (superposition / synergy)

This already answers your “superposition” intuition — **yes, but explicitly test it**.

---

### 2.2 How to Estimate Contributions (Practically)

For each metric:

#### Step 1 — Fix LU history, vary PG iterations

Example (H = 10):

* 0_10 → 10_10 → 33_10 → 100_10

This isolates **pure iteration effect**.

Compute:

* marginal gain per iteration
* saturation point

You already observed:

* 10 → 33 iterations causes *huge jump*
* 33 → 100 likely saturates

📌 **Interpretation**
If performance improves strongly with I while H fixed → iterations dominate.

---

#### Step 2 — Fix PG iterations, vary LU history

Example (I = 33):

* 33_1 → 33_2 → 33_5 → 33_10

This isolates **memory effect**.

Typical patterns you might see:

* Large improvement from 1 → 2
* Diminishing returns beyond 5–10

📌 **Interpretation**
If improvements plateau early → LU history acts as a *conditioning stabilizer*, not a main driver.

---

#### Step 3 — Compare slopes (Key Insight)

For a metric ( M ), define:

[
S_I = \frac{\partial M}{\partial I}, \quad
S_H = \frac{\partial M}{\partial H}
]

You don’t need calculus — finite differences are enough.

Whichever slope dominates explains **primary contribution**.

---

# 3. Method 2 — Normalized Contribution Ratio (Very Thesis-Friendly)

Define a baseline:

* **0_1** = no PG, no history

For each experiment ( (I, H) ):

[
C(I,H) = \frac{M(0,1) - M(I,H)}{M(0,1)}
]

Then define:

### Iteration Contribution

[
C_I(I) = \frac{1}{|H|} \sum_H C(I,H)
]

### History Contribution

[
C_H(H) = \frac{1}{|I|} \sum_I C(I,H)
]

This lets you say things like:

> “On average, increasing PG iterations explains ~70% of the total error reduction, while LU history contributes ~20%, with the remaining 10% due to interaction effects.”

📌 Reviewers **love this**, because it’s quantitative and fair.

---

# 4. Method 3 — Interaction (Superposition) Test

This directly answers your *“is it additive?”* question.

Pick one metric (APE RMSE is best).

Test whether:

[
\Delta M(33,10) \approx \Delta M(33,1) + \Delta M(0,10)
]

If:

* **≈ equal** → additive (superposition holds)
* **much larger** → synergistic interaction
* **much smaller** → diminishing returns

From your two datasets already:

* Big jump when **both** I and H are high
* Suggests **weak nonlinearity**, not pure superposition

📌 Expected conclusion:

> PG iterations dominate, LU history enables iterations to be effective.

---

# 5. Method 4 — Metric Sensitivity Mapping (Advanced but Powerful)

Different metrics respond to different components:

| Metric        | Sensitive to Iterations | Sensitive to History |
| ------------- | ----------------------- | -------------------- |
| APE RMSE      | ✅✅✅                     | ✅                    |
| APE Std / Max | ✅                       | ✅✅                   |
| RPE 1 m       | ❌                       | ✅                    |
| RPE 100 m     | ✅✅                      | ✅                    |
| Yaw           | ❌                       | ❌                    |

This lets you say:

> “Iterations primarily improve global convergence, while LU history mainly suppresses local instability and outliers.”

This aligns **perfectly** with what your data already shows.

---

# 6. How to Phrase the Core Conclusion (Draft Text)

You can safely aim for something like this:

> *“A factorial analysis over PG iteration count and LU history length reveals that the primary performance gains originate from iterative PG refinement, particularly for global pose consistency and long-range drift suppression. Increasing LU history size contributes mainly to variance reduction and outlier suppression, acting as a stabilizing mechanism rather than a dominant error-correcting factor. Interaction analysis further indicates that LU history enables effective convergence of PG iterations, suggesting a weakly synergistic relationship rather than pure additive superposition.”*

That is **PhD-level clean**, even for a master’s thesis.

---

# 7. Practical Recommendation (Based on Your Results So Far)

Even before running all experiments, your data suggests:

* **Iterations matter more than history**
* History >5 likely diminishing returns
* Sweet spot likely:

  * **33 iterations**
  * **5–10 history**

You’re not just tuning — you’re **characterizing the algorithm**.

---

## If you want next

I can:

* Propose **exact plots** (heatmaps, contour maps)
* Help you design **one figure that explains everything**
* Draft a **Methods subsection** explaining this analysis
* Help you decide **which combinations to keep and which to drop**

Just tell me which one.
