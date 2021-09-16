library(AppliedPredictiveModeling)
library(caret)
library(e1071)
library(mlbench)
library(VIM)
library(mice)
library(lattice)
library(corrplot)
library(earth)
library(rpart)
library(partykit)
library(tidyverse)
library(janitor)

# Read in red wine dataset
red_wine <- read_csv("winequality-red.csv")
red_wine <- clean_names(red_wine, case = "snake")
red_wine <- as.data.frame(red_wine)

# Read in white wine dataset
white_wine <- read_delim("winequality-white.csv", ';')
white_wine <- clean_names(white_wine, case = "snake")
white_wine <- as.data.frame(white_wine)

# Red wine predictor distributions
par(mfrow=c(3, 4))
hist(red_wine$fixed_acidity, main='fixed acidity')
hist(red_wine$volatile_acidity, main='volatile acidity')
hist(red_wine$citric_acid, main='citric acid')
hist(red_wine$residual_sugar, main='residual sugar')
hist(red_wine$chlorides, main='chlorides')
hist(red_wine$free_sulfur_dioxide, main='free sulfur dioxide')
hist(red_wine$total_sulfur_dioxide, main='total sulfar dioxide')
hist(red_wine$density, main='density')
hist(red_wine$p_h, main='pH')
hist(red_wine$sulphates, main='sulphates')
hist(red_wine$alcohol, main='alcohol')

# White wine predictor distributions
par(mfrow=c(3, 4))
hist(white_wine$fixed_acidity, main='fixed acidity')
hist(white_wine$volatile_acidity, main='volatile acidity')
hist(white_wine$citric_acid, main='citric acid')
hist(white_wine$residual_sugar, main='residual sugar')
hist(white_wine$chlorides, main='chlorides')
hist(white_wine$free_sulfur_dioxide, main='free sulfur dioxide')
hist(white_wine$total_sulfur_dioxide, main='total sulfar dioxide')
hist(white_wine$density, main='density')
hist(white_wine$p_h, main='pH')
hist(white_wine$sulphates, main='sulphates')
hist(white_wine$alcohol, main='alcohol')

# Red wine correlations
Cor_red = round(cor(red_wine[,1:11]), 4)

corrplot(Cor_red, order = "hclust")
corrplot(Cor_red, method = "number")

# White wine correlations
Cor_white = round(cor(white_wine[,1:11]), 4)

corrplot(Cor_white, order = "hclust")
corrplot(Cor_white, method = "number")

# Red wine Boxplots
par(mfrow=c(3, 4))
boxplot(red_wine$fixed_acidity, main='fixed acidity', horizontal = TRUE)
boxplot(red_wine$volatile_acidity, main='volatile acidity', horizontal = TRUE)
boxplot(red_wine$citric_acid, main='citric acid', horizontal = TRUE)
boxplot(red_wine$residual_sugar, main='residual sugar', horizontal = TRUE)
boxplot(red_wine$chlorides, main='chlorides', horizontal = TRUE)
boxplot(red_wine$free_sulfur_dioxide, main='free sulfur dioxide', horizontal = TRUE)
boxplot(red_wine$total_sulfur_dioxide, main='total sulfar dioxide', horizontal = TRUE)
boxplot(red_wine$density, main='density', horizontal = TRUE)
boxplot(red_wine$p_h, main='pH', horizontal = TRUE)
boxplot(red_wine$sulphates, main='sulphates', horizontal = TRUE)
boxplot(red_wine$alcohol, main='alcohol', horizontal = TRUE)

# White wine Boxplots
par(mfrow=c(3, 4))
boxplot(white_wine$fixed_acidity, main='fixed acidity',horizontal = TRUE)
boxplot(white_wine$volatile_acidity, main='volatile acidity', horizontal = TRUE)
boxplot(white_wine$citric_acid, main='citric acid', horizontal = TRUE)
boxplot(white_wine$residual_sugar, main='residual sugar', horizontal = TRUE)
boxplot(white_wine$chlorides, main='chlorides', horizontal = TRUE)
boxplot(white_wine$free_sulfur_dioxide, main='free sulfur dioxide', horizontal = TRUE)
boxplot(white_wine$total_sulfur_dioxide, main='total sulfar dioxide', horizontal = TRUE)
boxplot(white_wine$density, main='density', horizontal = TRUE)
boxplot(white_wine$p_h, main='pH', horizontal = TRUE)
boxplot(white_wine$sulphates, main='sulphates', horizontal = TRUE)
boxplot(white_wine$alcohol, main='alcohol', horizontal = TRUE)

# Red wine Feature plot
featurePlot(red_wine[,1:11],
            red_wine$quality,
            type = c("g", "p", "smooth"),
            labels = rep("", 2))

# White wine Feature plot
featurePlot(white_wine[,1:11],
            white_wine$quality,
            type = c("g", "p", "smooth"),
            labels = rep("", 2))

# Red wine Skewness
skewness(red_wine$fixed_acidity)
skewness(red_wine$volatile_acidity)
skewness(red_wine$citric_acid)
skewness(red_wine$residual_sugar)
skewness(red_wine$chlorides)
skewness(red_wine$free_sulfur_dioxide)
skewness(red_wine$total_sulfur_dioxide)
skewness(red_wine$density)
skewness(red_wine$p_h)
skewness(red_wine$sulphates)
skewness(red_wine$alcohol)

# White wine Skewness
skewness(white_wine$fixed_acidity)
skewness(white_wine$volatile_acidity)
skewness(white_wine$citric_acid)
skewness(white_wine$residual_sugar)
skewness(white_wine$chlorides)
skewness(white_wine$free_sulfur_dioxide)
skewness(white_wine$total_sulfur_dioxide)
skewness(white_wine$density)
skewness(white_wine$p_h)
skewness(white_wine$sulphates)
skewness(white_wine$alcohol)

# Near zero variance
nearZeroVar(red_wine, names = TRUE, saveMetrics = T)
nearZeroVar(white_wine, names = TRUE, saveMetrics = T)



## Modeling

# Red wine train/test split
set.seed(55)
inTrain <- createDataPartition(red_wine$quality, p = 0.8, list = FALSE)

red_train <- red_wine[inTrain, ]
red_test <- red_wine[-inTrain, ]

# White wine train/test split
set.seed(55)
inTrain <- createDataPartition(white_wine$quality, p = 0.8, list = FALSE)

white_train <- white_wine[inTrain, ]
white_test <- white_wine[-inTrain, ]

# Train control
ctrl <- trainControl(method = "repeatedcv", repeats = 10)

# Red wine quality distribution
ggplot(red_wine, aes(x=quality)) +
    geom_bar(stat = "count", position = "dodge", fill = "maroon") +
    scale_x_continuous(breaks = seq(3,8,1)) +
    ggtitle("Distribution of Red Wine Quality Ratings") +
    theme_classic()

# Red wine training quality distribution
ggplot(red_train, aes(x=quality)) +
    geom_bar(stat = "count", position = "dodge", fill = "maroon") +
    scale_x_continuous(breaks = seq(3,8,1)) +
    ggtitle("Distribution of Red Wine Training Quality Ratings") +
    theme_classic()

# Relative frequency - Red wine whole dataset
quality_freq_red <- table(red_wine$quality)/nrow(red_wine)
quality_freq_red

# Relative frequency - Red wine training dataset
quality_freq_red_train <- table(red_train$quality)/nrow(red_train)
quality_freq_red_train


# White wine quality distribution
ggplot(white_wine, aes(x=quality)) +
    geom_bar(stat = "count", position = "dodge", fill = "tan") +
    scale_x_continuous(breaks = seq(3,8,1)) +
    ggtitle("Distribution of White Wine Quality Ratings") +
    theme_classic()

# White wine training quality distribution
ggplot(white_train, aes(x=quality)) +
    geom_bar(stat = "count", position = "dodge", fill = "tan") +
    scale_x_continuous(breaks = seq(3,8,1)) +
    ggtitle("Distribution of White Wine Training Quality Ratings") +
    theme_classic()

# Relative frequency - White wine whole dataset
quality_freq_white <- table(white_wine$quality)/nrow(white_wine)
quality_freq_white

# Relative frequency - White wine training dataset
quality_freq_white_train <- table(white_train$quality)/nrow(white_train)
quality_freq_white_train


# Linear regression - Red
lm_red <- train(x = red_train[, 1:11], y = red_train$quality,
                method = "lm",
                trControl = ctrl)
summary(lm_red)

# Linear regression - White
lm_white <- train(x = white_train[, 1:11], y = white_train$quality,
                  method = "lm",
                  trControl = ctrl)
summary(lm_white)

# PCR - Red
PCR_red <- train(x = red_train[, 1:11], y = red_train$quality,
                 method = "pcr",
                 trControl = ctrl,
                 tuneLength = 24)
PCR_red

# PCR - White
PCR_white <- train(x = white_train[, 1:11], y = white_train$quality,
                   method = "pcr",
                   trControl = ctrl,
                   tuneLength = 24)
PCR_white

# PLS - Red
PLS_red <- train(x = red_train[, 1:11], y = red_train$quality,
                 method = "pls",
                 trControl = ctrl,
                 tuneLength = 24)
PLS_red

# PLS - White
PLS_white <- train(x = white_train[, 1:11], y = white_train$quality,
                   method = "pls",
                   trControl = ctrl,
                   tuneLength = 24)
PLS_white

# Ridge grid
ridgeGrid <- expand.grid(lambda = seq(0, .1, length = 15))

# Ridge regression - Red
ridgeTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                       method = "ridge",
                       tuneGrid = ridgeGrid,
                       trControl = ctrl,
                       preProc = c("center", "scale"))
ridgeTune_red

# Ridge regression - White
ridgeTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                         method = "ridge",
                         tuneGrid = ridgeGrid,
                         trControl = ctrl,
                         preProc = c("center", "scale"))
ridgeTune_white

# Lasso - Red
Lasso_red <- train(x = red_train[, 1:11], y = red_train$quality,
                   method = "lasso",
                   preProcess = c("center","scale"),
                   tuneGrid = expand.grid(fraction = seq(0.1, 1, length=20)),
                   trControl = ctrl)
Lasso_red

# Lasso - White
Lasso_white <- train(x = white_train[, 1:11], y = white_train$quality,
                     method = "lasso",
                     preProcess = c("center","scale"),
                     tuneGrid = expand.grid(fraction = seq(0.1, 1, length=20)),
                     trControl = ctrl)
Lasso_white

# Elastic Net grid
enetGrid <- expand.grid(lambda = c(0, 0.01, .1), 
                        fraction = seq(.05, 1, length = 20))

# Elastic Net - Red
enetTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                      method = "enet",
                      tuneGrid = enetGrid,
                      trControl = ctrl,
                      preProc = c("center", "scale"))
enetTune_red

# Elastic Net - White
enetTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                        method = "enet",
                        tuneGrid = enetGrid,
                        trControl = ctrl,
                        preProc = c("center", "scale"))
enetTune_white

# KNN - Red
knnTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                     method = "knn",
                     preProc = c("center", "scale"),
                     tuneGrid = data.frame(k = 1:20),
                     trControl = ctrl)
knnTune_red

# KNN <- - White
knnTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                       method = "knn",
                       preProc = c("center", "scale"),
                       tuneGrid = data.frame(k = 1:20),
                       trControl = ctrl)
knnTune_white

# MARS <- - Red
marsTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                      method = "earth",
                      tuneGrid = expand.grid(degree = 1, nprune = 2:38),
                      trControl = ctrl)
marsTune_red

# MARS Importance plot - Red
marsImp_red <- varImp(marsTune_red, scale = FALSE)
marsImp_red

plot(marsImp_red, 11, col = "red", main = "MARS - Red")

# MARS - White
marsTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                        method = "earth",
                        tuneGrid = expand.grid(degree = 1, nprune = 2:38),
                        trControl = ctrl)
marsTune_white

# MARS Importance plot - White
marsImp_white <- varImp(marsTune_white, scale = FALSE)
marsImp_white

plot(marsImp_white, 11, col = "tan", main = "MARS - White")

# Cart - Red
cartTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                      method = "rpart",
                      tuneLength = 25,
                      trControl = ctrl)
cartTune_red

# Cart - White
cartTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                        method = "rpart",
                        tuneLength = 25,
                        trControl = ctrl)
cartTune_white

# Random Forest - Red
mtryGrid_red <- data.frame(mtry = floor(seq(10, ncol(red_train[, 1:11]), length = 10)))

rfTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                    method = "rf",
                    tuneGrid = mtryGrid_red,
                    ntree = 200,
                    importance = TRUE,
                    trControl = ctrl)
rfTune_red

# Random Forest Importance plot - Red
rfImp_red <- varImp(rfTune_red, scale = FALSE)
rfImp_red

plot(rfImp_red, 11, col = "red", main = "Random Forest - Red")

# Random Forest - White
mtryGrid_white <- data.frame(mtry = floor(seq(10, ncol(white_train[, 1:11]), length = 10)))

rfTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                      method = "rf",
                      tuneGrid = mtryGrid_white,
                      ntree = 200,
                      importance = TRUE,
                      trControl = ctrl)
rfTune_white

# Random Forest Importance plot - White
rfImp_white <- varImp(rfTune_white, scale = FALSE)
rfImp_white

plot(rfImp_white, 11, col = "tan", main = "Random Forest - White")

# CIF grid
cifGrid <- data.frame(mincriterion = sort(c(.95, seq(.75, .99, length = 2))))

# Conditional Inference Trees - Red
cifTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                     method = "ctree",
                     tuneGrid = cifGrid,
                     trControl = ctrl)
cifTune_red

# CIF Importance plot - Red
cifImp_red <- varImp(cifTune_red, scale = FALSE)
cifImp_red

plot(cifImp_red, 11, col = "red", main = "Conditional Inference Trees - Red")

# Conditional Inference Trees - White
cifTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                       method = "ctree",
                       tuneGrid = cifGrid,
                       trControl = ctrl)
cifTune_white

# CIF Importance plot
cifImp_white <- varImp(cifTune_white, scale = FALSE)
cifImp_white

plot(cifImp_white, 11, col = "tan", main = "Conditional Inference Trees - White")

# Boosted grid
gbmGrid = expand.grid(interaction.depth = seq(1, 7, by=2),
                      n.trees = seq(100, 1000, by=100),
                      shrinkage = c(0.01, 0.1),
                      n.minobsinnode = 10)

# Boosted - Red
gbmTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                     method = "gbm",
                     tuneGrid = gbmGrid,
                     trControl = ctrl,
                     verbose = FALSE)
gbmTune_red

# Boosted plot - Red
plot(gbmTune_red, auto.key = list(columns = 4, lines = TRUE))

# Boosted - White
gbmTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                       method = "gbm",
                       tuneGrid = gbmGrid,
                       trControl = ctrl,
                       verbose = FALSE)
gbmTune_white

# Boosted plot - White
plot(gbmTune_white, auto.key = list(columns = 4, lines = TRUE))

# Cubist grid
cbGrid <- expand.grid(committees = c(1:10, 20, 50, 75, 100),
                      neighbors = c(0, 1, 5, 9))

# Cubist - Red
cubTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                     method = "cubist",
                     tuneGrid = cbGrid,
                     trControl = ctrl)
cubTune_red

# Cubist Importance plot - Red
cubImp_red <- varImp(cubTune_red, scale = FALSE)
cubImp_red

plot(cubImp_red, 11, col = "red", main = "Cubist - Red")

# Cubist - White
cubTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                       method = "cubist",
                       tuneGrid = cbGrid,
                       trControl = ctrl)
cubTune_white

# Cubist Importance plot - White
cubImp_white <- varImp(cubTune_white, scale = FALSE)
cubImp_white

plot(cubImp_white, 10, col = "tan", main = "Cubist - White")

# Bagging - Red
bagTune_red <- train(x = red_train[, 1:11], y = red_train$quality,
                     method = "treebag",
                     nbagg = 50,
                     trControl = ctrl)
bagTune_red

# Bagging Importance plot - Red
bagImp_red <- varImp(bagTune_red, scale = FALSE)
bagImp_red

plot(bagImp_red, 11, col = "red", main = "Bagged - Red")

# Bagging - White
bagTune_white <- train(x = white_train[, 1:11], y = white_train$quality,
                       method = "treebag",
                       nbagg = 50,
                       trControl = ctrl)
bagTune_white

# Bagging Importance plot - White
bagImp_white <- varImp(bagTune_white, scale = FALSE)
bagImp_white

plot(bagImp_white, 10, col = "tan", main = "Bagged - White")

# Resampling - Red
resamp_red <- resamples(list(OLS = lm_red, PCR = PCR_red, PLS = PLS_red, Ridge = ridgeTune_red, 
                             Lasso = Lasso_red, ENET = enetTune_red, KNN = knnTune_red, 
                             MARS = marsTune_red, Cart = cartTune_red, 
                             RandomForest = rfTune_red, CIF = cifTune_red, Boosted = gbmTune_red, 
                             Cubist = cubTune_red, Bagging = bagTune_red))

summary(resamp_red)

# Dotplot RMSE - Red
dotplot(resamp_red, metric="RMSE", main = "Root Mean Square Error - Red")

# Dotplot MAE - Red
dotplot(resamp_red, metric="MAE", main = "Mean Absolute Error - Red")

# Dotplot - R-squared - Red
dotplot(resamp_red, metric="Rsquared", main = "R-squared - Red")

# Resampling - White
resamp_white <- resamples(list(OLS = lm_white, PCR = PCR_white, PLS = PLS_white, Ridge = ridgeTune_white, 
                               Lasso = Lasso_white, ENET = enetTune_white, KNN = knnTune_white, 
                               MARS = marsTune_white,Cart = cartTune_white, 
                               RandomForest = rfTune_white, CIF = cifTune_white, 
                               Boosted = gbmTune_white, Cubist = cubTune_white, Bagging = bagTune_white))

summary(resamp_white)

# Dotplot RMSE - White
dotplot(resamp_white, metric="RMSE", main = "Root Mean Square Error - White")

# Dotplot MAE - White
dotplot(resamp_white, metric="MAE", main = "Mean Average Error - White")

# Dotplot R-squared - White
dotplot(resamp_white, metric="Rsquared", main = "R-squared - White")


# Predictions - Red
R2_red <- RMSE_red <- numeric(0)

# Linear regression - Red
LM_r <- predict(lm_red, red_test)
R2_red[1] <- cor(LM_r, red_test$quality)^2
RMSE_red[1] <- sqrt(mean((LM_r - red_test$quality)^2))

# PCR - Red
PCR_r <- predict(PCR_red, red_test)
R2_red[2] <- cor(PCR_r, red_test$quality)^2
RMSE_red[2] <- sqrt(mean((PCR_r - red_test$quality)^2))

# PLS - Red
PLS_r <- predict(PLS_red, red_test)
R2_red[3] <- cor(PLS_r, red_test$quality)^2
RMSE_red[3] <- sqrt(mean((PLS_r - red_test$quality)^2))

# Ridge regression - Red
Ridge_r <- predict(ridgeTune_red, red_test)
R2_red[4] <- cor(Ridge_r, red_test$quality)^2
RMSE_red[4] <- sqrt(mean((Ridge_r - red_test$quality)^2))

# Lasso - Red
Lasso_r <- predict(Lasso_red, red_test)
R2_red[5] <- cor(Lasso_r, red_test$quality)^2
RMSE_red[5] <- sqrt(mean((Lasso_r - red_test$quality)^2))

# ENET - Red
ENET_r <- predict(enetTune_red, red_test)
R2_red[6] <- cor(ENET_r, red_test$quality)^2
RMSE_red[6] <- sqrt(mean((ENET_r - red_test$quality)^2))

# KNN - Red
KNN_r <- predict(knnTune_red, red_test)
R2_red[7] <- cor(KNN_r, red_test$quality)^2
RMSE_red[7] <- sqrt(mean((KNN_r - red_test$quality)^2))

# MARS - Red
MARS_r <- predict(marsTune_red, red_test)
R2_red[8] <- cor(MARS_r, red_test$quality)^2
RMSE_red[8] <- sqrt(mean((MARS_r - red_test$quality)^2))

# Cart - Red
Cart_r <- predict(cartTune_red, red_test)
R2_red[9] <- cor(Cart_r, red_test$quality)^2
RMSE_red[9] <- sqrt(mean((Cart_r - red_test$quality)^2))

# Random Forest - Red
RF_r <- predict(rfTune_red, red_test)
R2_red[10] <- cor(RF_r, red_test$quality)^2
RMSE_red[10] <- sqrt(mean((RF_r - red_test$quality)^2))

# CIF - Red
CIF_r <- predict(cifTune_red, red_test)
R2_red[11] <- cor(CIF_r, red_test$quality)^2
RMSE_red[11] <- sqrt(mean((CIF_r - red_test$quality)^2))

# Boosted - Red
Boosted_r <- predict(gbmTune_red, red_test)
R2_red[12] <- cor(Boosted_r, red_test$quality)^2
RMSE_red[12] <- sqrt(mean((Boosted_r - red_test$quality)^2))

# Cubist - Red
Cubist_r <- predict(cubTune_red, red_test)
R2_red[13] <- cor(Cubist_r, red_test$quality)^2
RMSE_red[13] <- sqrt(mean((Cubist_r - red_test$quality)^2))

# Bagging - Red
Bagging_r <- predict(bagTune_red, red_test)
R2_red[14] <- cor(Bagging_r, red_test$quality)^2
RMSE_red[14] <- sqrt(mean((Bagging_r - red_test$quality)^2))

# Results - Red
results_red <- cbind(R2_red, RMSE_red)
row.names(results_red) <- c("LM", "PCR", "PLS", "Ridge", "Lasso", "ENET", "KNN", "MARS", "Cart",
                            "RF", "CIF", "Boosted", "Cubist", "Bagging")
results_red


# Predictions - White
R2_white <- RMSE_white <- numeric(0)

# Linear regression - White
LM_w <- predict(lm_white, white_test)
R2_white[1] <- cor(LM_w, white_test$quality)^2
RMSE_white[1] <- sqrt(mean((LM_w - white_test$quality)^2))

# PCR - White
PCR_w <- predict(PCR_white, white_test)
R2_white[2] <- cor(PCR_w, white_test$quality)^2
RMSE_white[2] <- sqrt(mean((PCR_w - white_test$quality)^2))

# PLS - White
PLS_w <- predict(PLS_white, white_test)
R2_white[3] <- cor(PLS_w, white_test$quality)^2
RMSE_white[3] <- sqrt(mean((PLS_w - white_test$quality)^2))

# Ridge regression - White
Ridge_w <- predict(ridgeTune_white, white_test)
R2_white[4] <- cor(Ridge_w, white_test$quality)^2
RMSE_white[4] <- sqrt(mean((Ridge_w - white_test$quality)^2))

# Lasso - White
Lasso_w <- predict(Lasso_white, white_test)
R2_white[5] <- cor(Lasso_w, white_test$quality)^2
RMSE_white[5] <- sqrt(mean((Lasso_w - white_test$quality)^2))

# ENET - White
ENET_w <- predict(enetTune_white, white_test)
R2_white[6] <- cor(ENET_w, white_test$quality)^2
RMSE_white[6] <- sqrt(mean((ENET_w - white_test$quality)^2))

# KNN - White
KNN_w <- predict(knnTune_white, white_test)
R2_white[7] <- cor(KNN_w, white_test$quality)^2
RMSE_white[7] <- sqrt(mean((KNN_w - white_test$quality)^2))

# MARS - White
MARS_w <- predict(marsTune_white, white_test)
R2_white[8] <- cor(MARS_w, white_test$quality)^2
RMSE_white[8] <- sqrt(mean((MARS_w - white_test$quality)^2))

# Cart
Cart_w <- predict(cartTune_white, white_test)
R2_white[9] <- cor(Cart_w, white_test$quality)^2
RMSE_white[9] <- sqrt(mean((Cart_w - white_test$quality)^2))

# Random Forest - White
RF_w <- predict(rfTune_white, white_test)
R2_white[10] <- cor(RF_w, white_test$quality)^2
RMSE_white[10] <- sqrt(mean((RF_w - white_test$quality)^2))

# CIF - White
CIF_w <- predict(cifTune_white, white_test)
R2_white[11] <- cor(CIF_w, white_test$quality)^2
RMSE_white[11] <- sqrt(mean((CIF_w - white_test$quality)^2))

# Boosted - White
Boosted_w <- predict(gbmTune_white, white_test)
R2_white[12] <- cor(Boosted_w, white_test$quality)^2
RMSE_white[12] <- sqrt(mean((Boosted_w - white_test$quality)^2))

# Cubist - White
Cubist_w <- predict(cubTune_white, white_test)
R2_white[13] <- cor(Cubist_w, white_test$quality)^2
RMSE_white[13] <- sqrt(mean((Cubist_w - white_test$quality)^2))

# Bagging - White
Bagging_w <- predict(bagTune_white, white_test)
R2_white[14] <- cor(Bagging_w, white_test$quality)^2
RMSE_white[14] <- sqrt(mean((Bagging_w - white_test$quality)^2))

# Results - White
results_white <- cbind(R2_white, RMSE_white)
row.names(results_white) <- c("LM", "PCR", "PLS", "Ridge", "Lasso", "ENET", "KNN", "MARS", "Cart",
                              "RF", "CIF", "Boosted", "Cubist", "Bagging")
results_white