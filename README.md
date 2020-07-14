---


---

<h1 id="massachusetts-police-department-payroll-investigation">Massachusetts Police Department Payroll Investigation</h1>
<p>This project is my coursework in BU CS506, which is part of the collaboration with BU Spark! Incubation. My team helped WGBH and was responsible to look into some patterns of the payroll of MA’s Police Department. I successfully experienced the entire life cycle of a complete data science project, from data extracting/collection, to application deployment. In the rest of this file, I am going to explain how I completed each step of the project.</p>
<h2 id="data-collection">Data Collection</h2>
<p>I collected data using Scrapy framework along with Scrapinghub. The data source is <a href="https://govsalaries.com/">govSalaries.com</a>. GovSalaries provides a searchable nationwide salaries database of more than 50 million salaries records from over 60k sources. This data usually includes name, surname, monthly wage, annual wage and employer statistics. However, the data there does not include the gender and the racial background of an employee while our mentor hoped us to look at the insight of these aspects.</p>
<p>Therefore we used <a href="https://www.namsor.com/">namsor</a> to classify personal names accurately by gender, country of origin, or ethnicity. Thus our original data look like the following image:<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/dataframe.png" alt="enter image description here"></p>
<h2 id="eda">EDA</h2>
<p>I was going to take a glance at each feature but before I started I noticed there are a bunch of values missing in the feature of “Job_Title” and “Monthly_Wage”. This requires me to impute later. So in the rest of data visualization section I only focused on the relation between each factor and annual wage.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/missingValue.png" alt="enter image description here"><br>
The first feature I checked is Gender. As I expected, policemen are a larger workforce in PD than their female colleagues.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/gender.png" alt="enter image description here"><br>
But I didn’t think of that the salary of a policeman is also higher than his female counterpart.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/genderSalary.png" alt="enter image description here"><br>
Policewomen are more likely to be the low income group than their male colleagues.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/genderSalaryDistribution.png" alt="enter image description here"></p>
<p>The second feature was Race/Ethnic. White people are the major group while Asian makes up the smallest part.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/Race.png" alt="enter image description here"><br>
As for their income, there is no big difference between different races on average while the highest income community seemingly confines to the black and white people.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/RaceSalary.png" alt="enter image description here"></p>
<p>The third feature is the cops’ job titles. As I mentioned there are a lot of missing values within this features and what I did is just applying library MICE to fill in the empty blanks. Then I roughly divided their titles in several levels: Officer, Sergeant, Captain, Detective, Lieutenant, Director, Commissioner and Others. The following figure illustrates the difference of job title levels.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/jobTitle.png" alt="enter image description here"></p>
<p>The forth feature is Year. According to the density of the scatters, I can infer that the workforce of police department is generally on a rise over the years.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/year.png" alt="enter image description here"></p>
<p>The final feature is the employers. Here we just studied five cities including Boston, Brockton, Cambridge, Lynn and Springfield. Averagely City of Boston is the best employer among them in terms of salary they pay, which is approximately 2.5 times of that of City of Lynn.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/location.png" alt="enter image description here"></p>
<h2 id="modeling">Modeling</h2>
<p>In this section, I am going to experiment five different classifier models such as Linear Regression, Logistics Regression, Decision Tree, Random Forest and XGBoosting.</p>
<p>To achieve higher precision, some preprocessing operations are necessary. I standardized the numeric data feature (Year) and encoded the categorical ones (all the others except prediction outputs: Annual Wage and Monthly Wage) using one-hot encoding. Nevertheless this is not sufficient yet because when I plotted a correlation heatmap, it is obvious that some features are quite strongly correlated to each other.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/originalHeatmap.png" alt="enter image description here"><br>
To avoid multi-linearity, I tried PCA to create interindepent Prior Components. This can not only cancel the inner correlation but also reduce the dimensionality. As I observed, up to the first 15 Prior Components they have been able to explain over 95% of the information, thus I could simply release the rest four PCs.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/cumulative.png" alt="enter image description here"><br>
Meanwhile, now all the input features are independent to each other.<br>
<img src="https://github.com/MemphisMeng/MPD-Payroll/blob/master/images/PCAHeatmap.png" alt="enter image description here"></p>
<h3 id="modeling-results">Modeling Results</h3>
<p>I used RMSE as the metric to measure how accurate the models were. Here is the results of them after I cross-validated each model with 10-fold method:</p>

<table>
<thead>
<tr>
<th>Model</th>
<th>RMSE</th>
</tr>
</thead>
<tbody>
<tr>
<td>Linear Regression</td>
<td>3305.07243783986</td>
</tr>
<tr>
<td>Logistic Regression</td>
<td>3367.40540512416</td>
</tr>
<tr>
<td>Decision Tree Regression</td>
<td>3339.30303188213</td>
</tr>
<tr>
<td>Random Forest Regression</td>
<td>2834.19984764565</td>
</tr>
<tr>
<td>XGBoosting Regression</td>
<td>2737.86121561069</td>
</tr>
</tbody>
</table><p>There is even about 2737 of RMSE of the best predictor (XGBoosting), that indicates that there is a huge space for improvement.</p>
<h2 id="discussion">Discussion</h2>
<p>Considering the unsatisfying result, I figured out the following aspects which are possible reasons to it:</p>
<ol>
<li>We have no way to test or validate the classification results generated by Namsor, which may not be sufficiently accurate;</li>
<li>The location of employers, genders, and year of the workers, the features are imbalanced which might make the predictor biased;</li>
<li>The division of mine on the job titles are untested either, given the fact that the outliers in Officer and Others are much more than other counterparts;</li>
<li>More advanced techniques such as Artificial Neural Network is not applied yet.</li>
</ol>
<h2 id="application-deployment">Application Deployment</h2>
<p>I created the application with MATLAB, which can be used to predict the income of a policeman as long as the information (gender, race, year, job title and location) is input.</p>

