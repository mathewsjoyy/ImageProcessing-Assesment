clear; close all;

% Task 1: Pre-processing -----------------------
% Step-1: Load input image
I = imread('IMG_01.jpg');

% Step-2: Covert image to grayscale
I_gray = rgb2gray(I);

% Step-3: Rescale image using bilinear interpolation
I_gray_scale_bi = imresize(I_gray, 0.5, "bilinear");
%figure, imshow(I_gray_scale_bi);

% Step-4: Produce histogram before enhancing
histogram(I_gray_scale_bi);
title("Step-4: Histogram before enhancing");


% Step-5: Enhance image before binarisation using contrast stretching
% converts the intensity image I to double precision
J = 255*im2double(I_gray_scale_bi);
mi = min(min(J)); % find the minimum pixel intensity
ma = max(max(J)); % find the maximum pixel intensity

% Use the imadjust function to enhance the image
I_gray_scale_bi_enhanced = imadjust(I_gray_scale_bi,[mi/255; ma/255],[0; 1]);

% Display the enhanced image
figure, imshow(I_gray_scale_bi_enhanced);

% Step-6: Histogram after enhancement
histogram(I_gray_scale_bi_enhanced);
title("Step-6: Histogram for after enhancement.");


% Step-7: Image Binarisation
threshold = double(120/255); 

binarisedImage = imbinarize(I_gray_scale_bi_enhanced, threshold);
figure, imshow(binarisedImage)
title("Step-5: Producing binarised image")


% Display the re-sized image, histograms before and after enhancement,
% enhanced image and the binarised image
figure,subplot(3, 2, 1),imshow(I_gray_scale_bi);title('Re-sized Image');
axis on;

subplot(3, 2, 2),histogram(I_gray_scale_bi);title('Histogram (before enhancement)');
axis on;

subplot(3, 2, 3),imshow(I_gray_scale_bi_enhanced);title('Enhanced Image'); 
axis on;

subplot(3, 2, 4),histogram(I_gray_scale_bi_enhanced);title('Histogram (after enhancement)'); 
axis on;

subplot(3, 2, 5),imshow(binarisedImage);title('Binarised Image'); 
axis on;

pos = get(gcf, 'Position'); % gives the position of current sub-plot
set(gcf, 'Position',pos+[0 -100 100 100]) % set new position of current sub - plot



% Task 2: Edge detection ------------------------

% Experiment with the 3 smoothing methods below which one give better edge
% detecetion results or neither? to reduce any noise
% Smooth the image using a Gaussian filter (test cahnign the standard
% deivation)
I_gray_scale_bi_enhanced = imgaussfilt(I_gray_scale_bi_enhanced, 1.5);
% Smooth the image using a median filter
img_smooth = medfilt2(I_gray_scale_bi_enhanced);
% Smooth the image using a bilateral filter
img_smooth = imbilatfilt(I_gray_scale_bi_enhanced);

edgeDetectionSobel = edge(I_gray_scale_bi_enhanced,'sobel');
figure;
imshow(edgeDetectionSobel)
title("Task 2: Edge Detection - Sobel")

edgeDetectionCanny = edge(I_gray_scale_bi_enhanced,'canny');
figure; 
imshow(edgeDetectionCanny)
title("Task 2: Edge Detection - Canny")

edgeDetectionPrewitt = edge(I_gray_scale_bi_enhanced,'Prewitt');
figure; 
imshow(edgeDetectionPrewitt)
title("Task 2: Edge Detection - Prewitt")


% Task 3: Simple segmentation --------------------
% Fill the holes to get binary image of the objects
% Try get rid of smoothing / using differnt echniqwues as some of the edges
% are not connected fulling for the objects
filled = imfill(edgeDetectionCanny, "holes");

% Remove small objects that are not screws or washers
cleaned = bwareaopen(filled, 50); % Adjust the second parameter as needed

imshow(cleaned);


% Task 4: Object Recognition --------------------