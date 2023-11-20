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

  output_img = screw_washer_detection(img);
  figure;
  imshow(output_img);
  title("Washers & Screws Image (segmented): " +i);
end





  % Task 4: Object Recognition --------------------
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
	if aspectRatios(k) > 2 & aspectRatios(k) < 4  % Whatever value you want.
		cmap(k+1, :) = [1, 0, 0]; % Red for small screws
    elseif aspectRatios(k) > 4
		cmap(k+1, :) = [0, 1, 0]; % Green for long screws
    else
        cmap(k+1, :) = [0.9100, 0.4100, 0.1700]; % Orange for washers
	end
end





% Task 6: Performance evaluation -----------------
% Step 1: Load ground truth data
GT = imread("IMG_01_GT.png");

% To visualise the ground truth image, you can
% use the following code.
L_GT = label2rgb(GT, 'prism','k','shuffle');
figure, imshow(L_GT);


% Function defnition for task 5 robust method (task 1-4 condensed down)
function out = screw_washer_detection(input_img)
    % Covert image to grayscale
    img_gray = rgb2gray(input_img);
    
    % Rescale image using bilinear interpolation
    I_gray_scale_bi = imresize(img_gray, 0.5, "bilinear");
    
    % Produce histogram before enhancing
    histogram(I_gray_scale_bi);
    title("Histogram before enhancing");
   
    % Enhance image before binarisation using contrast stretching
    % converts the intensity image I to double precision
    J = 255*im2double(I_gray_scale_bi);
    mi = min(min(J)); % find the minimum pixel intensity
    ma = max(max(J)); % find the maximum pixel intensity
    
    % Use the imadjust function to enhance the image
    I_gray_scale_bi_enhanced = imadjust(I_gray_scale_bi,[mi/255; ma/255],[0; 1]);
    
    % Display the enhanced image
    figure; imshow(I_gray_scale_bi_enhanced);
    
    % Step-6: Histogram after enhancement
    histogram(I_gray_scale_bi_enhanced);
    title("Histogram for after enhancement.");
    


    % Return final image
    out = I_gray_scale_bi_enhanced;
end
