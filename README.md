# HMM-single-Gaussian-v1.0
In this project we would like to deal with training HMM for isolated words data applying EM algorithm. The testing phase is also considered using Viterbi algorithm. The results showed the performances which obtained by Matlab programming are similar to HTK's ones.

In this project we have not prepared data files (.mfcc files) yet, please do it by yourself with your own data. Then, you may need to change some code in the file "generate_trainingfile_list.m" and "generate_testingfile_list.m" up to your data file paths.
Please run the file "EM_HMM_isolated_digit_main.m" to start.
For further information, please leave a comment.
You may use this work free.

!!! Update: 2017-09-07

You may now download data files on the website: http://www.ece.ucsb.edu/Faculty/Rabiner/ece259/speech%20recognition%20course.html
Please select the data set: "isolated TI digits training files, 8 kHz sampled, endpointed: (isolated_digits_ti_train_endpt.zip)" to download it, or you may download directly the .zip file of training database only from this link:

- training data:

http://www.ece.ucsb.edu/Faculty/Rabiner/ece259/speech%20recognition%20course/databases/isolated_digits_ti_train_endpt.zip.

- testing data:

http://www.ece.ucsb.edu/Faculty/Rabiner/ece259/speech%20recognition%20course/databases/isolated_digits_ti_test_endpt.zip

Please decompress all the data sets, then locate training and testing data into directories 'wav\isolated_digits_ti_train_endpt' and 'wav\isolated_digits_ti_test_endpt', respectively. 

Furthermore, we have just added some feature extracting functions that would help you to convert '.wav' files to '.mfc' files (feature files)

Now you may run this project with only one click!
