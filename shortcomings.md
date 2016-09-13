
> **1. Setting up a database (Preferably MongoDB)**
* A database could be setup and all the fetched tweets could be stored in it classified according to the topic of analysis and the time when it was retrieved which enables when the user requests for the same topic of analysis next time, it could calculate the time difference between the two data retrieval and could extract tweets only between the mean time that will help to provide a much more accurate results, also saving the time of extraction of data. 



> **2. Analysing with multiple languages, not only in English**
* Proposed work contains only the retrieval of tweets only in English language because if multiple languages were preferred, training would have been more difficult. Hence, this paper could be extended to retrieve tweets in languages other than English (enabling the proposed work to be localized stronger) and train the model. 



> **3. Deploying some high level ML Algorithms like Random Forest, XG Boost**
* Accuracy of the Naïve Bayes Model can be achieved higher by incorporating training by increasing the data set. 



> **4. Scheduling the Job in an equal interval**
* Making the R Script to work on a regular basis using “Task ScheduleR” in R which enables dynamic retrieval of data without human 
intervention and it ultimately plots the data that will dynamically keep on changing until the user searches for another topic or quits 
the application. 


