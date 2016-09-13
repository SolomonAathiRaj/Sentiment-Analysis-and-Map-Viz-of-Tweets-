
# NAIVE BAYE'S PERFORMANCE
 
# training the model
classifier = naiveBayes(mat[1:7660,], as.factor(smpl[1:7660,2]))

# testing the model
predicted = predict(classifier, mat[7661:10944,])

recall_accuracy(smpl[7661:10944,2], predicted)
[1] 0.8636179

confusion.mat
          predicted
actual     negative positive
  negative      1416     230 
  positive     	229		1409



# SVM PERFORMANCE

container = create_container(matr, as.numeric(as.factor(smpl[,2])),
                           trainSize=1:4500, testSize=4501:5484,virgin=FALSE)
 
model.svm = train_model(container, algorithm="SVM", verbose = TRUE)
result.svm = classify_model(container, model.svm)

summary(analytics)

ALGORITHM PERFORMANCE

SVM_PRECISION    SVM_RECALL    SVM_FSCORE 
         0.74          0.73         0.74 
