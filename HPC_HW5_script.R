library(keras)
library(tensorflow)


# See ?dataset_cifar10 for more info
cifar10 <- dataset_cifar10()

# Parameters --------------------------------------------------------------
batch_size <- seq(32, 1028, by=2)
epochs <- seq(50, 300, by=5)
data_augmentation <- TRUE

# Data Preparation --------------------------------------------------------

neural.values<- data.frame() 

for (i in batch_size){
  for (j in epochs){
    
    # Feature scale RGB values in test and train inputs  
    x_train <- cifar10$train$x/255
    x_test <- cifar10$test$x/255
    y_train <- to_categorical(cifar10$train$y, num_classes = 10)
    y_test <- to_categorical(cifar10$test$y, num_classes = 10)
    
    
    # Defining Model ----------------------------------------------------------
    
    # Initialize sequential model
    model <- keras_model_sequential()
    
    model %>%
      
      # Start with hidden 2D convolutional layer being fed 32x32 pixel images
      layer_conv_2d(
        filter = 32, kernel_size = c(3,3), padding = "same",
        input_shape = c(32, 32, 3)
      ) %>%
      layer_activation("relu") %>%
      
      # Second hidden layer
      layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
      layer_activation("relu") %>%
      
      # Use max pooling
      layer_max_pooling_2d(pool_size = c(2,2)) %>%
      layer_dropout(0.25) %>%
      
      # 2 additional hidden 2D convolutional layers
      layer_conv_2d(filter = 32, kernel_size = c(3,3), padding = "same") %>%
      layer_activation("relu") %>%
      layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
      layer_activation("relu") %>%
      
      # Use max pooling once more
      layer_max_pooling_2d(pool_size = c(2,2)) %>%
      layer_dropout(0.25) %>%
      
      # Tuck Add Homework: 2 additional hidden 2D convolutional layers
      layer_conv_2d(filter = 64, kernel_size = c(3,3), padding = "same") %>%
      layer_activation("relu") %>%
      layer_conv_2d(filter = 64, kernel_size = c(3,3)) %>%
      layer_activation("relu") %>%
      
      #Tuck Add Homework: Use max pooling once more
      layer_max_pooling_2d(pool_size = c(2,2)) %>%
      layer_dropout(0.25) %>%
      
      # Flatten max filtered output into feature vector 
      # and feed into dense layer
      layer_flatten() %>%
      layer_dense(512) %>%
      layer_activation("relu") %>%
      layer_dropout(0.5) %>%
      
      # Outputs from dense layer are projected onto 10 unit output layer
      layer_dense(10) %>%
      layer_activation("softmax")
    
    opt <- optimizer_rmsprop(lr = 0.0001, decay = 1e-6)
    
    model %>% compile(
      loss = "categorical_crossentropy",
      optimizer = opt,
      metrics = "accuracy"
    )
    
    ##Evaluate model on train data
    score.train <- model %>% evaluate(x_train, y_train, verbose = 0)
    
    ##Evaluate model on test data
    score.test <- model %>% evaluate(x_test, y_test, verbose = 0)
    
    #Output table of values
    neural.values<- neural.values%>%
      bind_rows(c("Batch Size" = i,
                  "Epoch" = j,
                  "Train" = score.train[1],
                  "Train" = score.train[2],
                  "Test" = score.test[1],
                  "Test" = score.test[2]))
    
  }
}

#output top 10 results by testing accuracy
neural.values.top<- neural.values%>%
  arrange(-Test.accuracy)%>%
  top_n(10)

saveRDS(neural.values.top, "Output Problem 5.RDS")
