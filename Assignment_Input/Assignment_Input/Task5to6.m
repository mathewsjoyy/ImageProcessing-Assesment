% Task 5: Robust method --------------------------
clear; close all; clc;

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



  labeled_image = logical(labeled_image);

  % Task 6: Performance evaluation -----------------
  % Step 1: Load ground truth data
  try
    img_name = "IMG_" + str + "_GT.png";
    GT_img = logical(imread(img_name));
  catch ME
    disp("Error Reading Image (image " + img_name + ") does " + ...
        "not exist in current path.");
  end
    
  % To visualise the ground truth image, you can
  % use the following code.
  %L_GT = label2rgb(GT, 'prism','k','shuffle');
  %figure, imshow(L_GT);
    
  % Compute the Dice Score, Precision, and Recall
  [score, precision, recall] = bfscore(labeled_image, GT_img);
    
  disp(['Dice Score: ' ,num2str(score), ', Precision: ', num2str(precision), '' ...
      ', Recall: ', num2str(recall) ]);

  % https://uk.mathworks.com/matlabcentral/answers/696065-how-to-apply-colours-of-my-choosing-to-labels-in-a-binary-image-based-on-their-individual-areas
end





% Task 6: Performance evaluation -----------------
% Step 1: Load ground truth data and the predicted image
GT = imread("IMG_01_GT.png");
predicted = imread('IMG_05.jpg');

% To visualise the ground truth image, you can
% use the following code.
L_GT = label2rgb(GT, 'prism','k','shuffle');
figure, imshow(L_GT);






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
    
    % Display segmented image
    %figure;
    %imshow(I_filled_segmented);
    %title("Simple Segmentation");

    % Label the connected components in the binary image
    % Get the aspect ratio of each blob.
    props = regionprops(I_filled_segmented, 'MajorAxisLength', 'MinorAxisLength', 'Area');
    
    aMajor = [props.MajorAxisLength];
    aMinor = [props.MinorAxisLength];
    allAreas = sort([props.Area]);
    aspectRatios = aMajor ./ aMinor;
    numBlobs = length(props);
    cmap = zeros(numBlobs+1, 3);

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
