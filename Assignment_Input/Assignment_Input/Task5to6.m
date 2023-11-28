% Task 5: Robust method --------------------------
clear; close all; clc;

% Define a vector to store dice,precision and recall scores
dice_scores = [];
precision_scores = [];
recall_scores = [];

% Loop through all 10 images
for i = 1:10 
  
  % convert i value to have a 0 infront for values less then 10,
  % as the images are labelled as 01,02 instead of 1,2 etc.
  if i < 10
        str = sprintf('0%d', i);
  else
        str = sprintf('%d', i);
  end
  
  % Get each image file and read it for usage
  % Use a try catch error prevention to make sure files actually exist
  try
    img_name = "IMG_" + str + ".jpg";
    img = imread(img_name);
  catch ME
    disp("Error Reading Image (image " + img_name + ") does " + ...
        "not exist in current path.");
  end
    
  % Pass in image to robust function method
  [labeled_image, cmap] = screw_washer_detection(img);

  figure;
  imshow(labeled_image, []);
  colormap(cmap);
  title("Washers & Screws Image (segmented): img " +i);
  
  % Convert image to binary using logical
  labeled_image = logical(labeled_image);

  % Task 6: Performance evaluation -----------------
  % Step 1: Load ground truth data
  try
    img_name = "IMG_" + str + "_GT.png";
    % Convert image to binary using logical
    GT_img = logical(imread(img_name));
  catch ME
    disp("Error Reading Image (image " + img_name + ") does " + ...
        "not exist in current path.");
  end

  % Step 2: Calculate the dice score, precision and recall of the labelled
  % image to the ground truth image
  % Compute the Precision, and Recall
  [bf_score, precision, recall] = bfscore(labeled_image, GT_img);
  
  % Compute the 
  similarity = dice(labeled_image, GT_img);
  
  % Display out metric scores for current image
  disp(['Metrics for IMG_', str]);
  disp(['Dice Score: ' ,num2str(similarity), ', Precision: ', num2str(precision), '' ...
      ', Recall: ', num2str(recall), newline]);

  % Add the dice score, precision and recall to global vector storing the
  % values for all images
  dice_scores(end+1) = similarity;
  precision_scores(end+1) = precision;
  recall_scores(end+1) = recall;
end

% Caculate the mean and standard deviation of dice score,precision and recall
% for all all images
mean_dice = mean(dice_scores);
std_dice  = std(dice_scores);

mean_precision = mean(precision_scores);
std_precision  = std(precision_scores);

mean_recall = mean(recall_scores);
std_recall  = std(recall_scores);

disp(['Mean of Dice Scores:', num2str(mean_dice), ...
    ', Std. of Dice Scores:', num2str(std_dice)]);

disp(['Mean of Precision Scores:', num2str(mean_precision), ...
    ', Std. of Precision Scores:', num2str(std_precision)]);

disp(['Mean of Recall Scores:', num2str(mean_recall), ...
    ', Std. of Recall Scores:', num2str(std_recall)]);


  % To visualise the ground truth image, you can
  % use the following code.
  %L_GT = label2rgb(GT, 'prism','k','shuffle');
  %figure, imshow(L_GT);






% Function defnition for task 5 robust method (task 1-4 condensed down)
% Takes input image to perform the image process robust pipeline
% Outputs final label segmented image (and its colour map)
function [labeled_image, cmap] = screw_washer_detection(input_img)
    % Covert image to grayscale
    img_gray = rgb2gray(input_img);
    
    % Rescale image using bilinear interpolation
    I_gray_scale_bi = imresize(img_gray, 0.5, "bilinear");
    
    % Histogram before enhancing
    %histogram(I_gray_scale_bi);
    %title("Histogram before enhancing");
   
    % Enhance image before binarisation using contrast stretching
    % converts the intensity image I to double precision
    J = 255*im2double(I_gray_scale_bi);
    mi = min(min(J)); % find the minimum pixel intensity
    ma = max(max(J)); % find the maximum pixel intensity
    
    % Use the imadjust function to enhance the image
    I_gray_scale_bi_enhanced = imadjust(I_gray_scale_bi,[mi/255; ma/255],[0; 0.9]);
    
    % Display the enhanced image
    %figure; imshow(I_gray_scale_bi_enhanced);
    
    % Step-6: Histogram after enhancement
    %histogram(I_gray_scale_bi_enhanced);
    %title("Histogram for after enhancement.");

    % Step-7: Image Binarisation
    binarisedImage = imbinarize(I_gray_scale_bi_enhanced, "adaptive", "ForegroundPolarity", "dark", "Sensitivity", 0.50);
    %figure, imshow(binarisedImage)
    %title("Binarised image")

    % Use median filtering to help reduce noise in iamge before
    % applying edge detection
    img_smooth = medfilt2(I_gray_scale_bi_enhanced);

    % Use canny edge detection and change the sigma value to "0.08" to 
    % perform further noiser reduction
    edgeDetectionCanny = edge(img_smooth,'canny', 0.08);
    %figure; 
    %imshow(edgeDetectionCanny)
    %title("Edge Detection - Canny")
    
    % Disk shaped structuring element with a radius of 3 pixels
    se = strel("disk", 3);
    
    % Use closing the image (dilate then erode) to connect all edges of objects
    I_close = imclose(edgeDetectionCanny, se);
    
    % Fill the objects holes
    I_filled_segmented = imfill(I_close, "holes");
    
    % Remove small objects (that cant be screw / washer)
    I_filled_segmented = bwareaopen(I_filled_segmented,20);

    % Label the connected components in the binary image
    % Get the aspect ratio of each blob.
    props = regionprops(I_filled_segmented, 'MajorAxisLength', 'MinorAxisLength', 'Area');
    
    % Get the major and minor axis into a vector
    aMajor = [props.MajorAxisLength];
    aMinor = [props.MinorAxisLength];
    allAreas = sort([props.Area]);

    % Compute aspect ratios
    aspectRatios = aMajor ./ aMinor;
    numBlobs = length(props);
    cmap = zeros(numBlobs+1, 3);
    
    % For each blob number assign the color to be used for it,
    % this depends on that blob's aspect ratio.
    for k = 1 : numBlobs
        % If statement determining colour based on blob aspect ratio
	    if aspectRatios(k) > 1.8 && aspectRatios(k) < 4
		    cmap(k+1, :) = [1, 0, 0]; % Red for small screws
        elseif aspectRatios(k) > 4
		    cmap(k+1, :) = [0, 1, 0]; % Green for long screws
        else
            cmap(k+1, :) = [0.9100, 0.4100, 0.1700]; % Orange for washers
	    end
    end
    
    labeled_image = bwlabel(I_filled_segmented);
end
