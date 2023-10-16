clear; close all;

% Task 1: Pre-processing -----------------------
% Step-1: Load input image
I = imread('IMG_01.jpg');
figure, imshow(I)

% Step-2: Covert image to grayscale
I_gray = rgb2gray(I);
figure, imshow(I_gray)

% Step-3: Rescale image using bilinear interpolation
I_gray_scale_bi = imresize(I_gray, 0.5, "bilinear");
figure;
imshow(I_gray_scale_bi)

% Step-4: Produce histogram before enhancing
histogram(I_gray_scale_bi)
title("Step-4: Produce a histogram for the rescaled image.")

% Step-5: Enhance image before binarisation
I_gray_scale_bi_enhanced = adapthisteq(I_gray_scale_bi);
figure;
imshow(I_gray_scale_bi_enhanced);

% Step-6: Histogram after enhancement
histogram(I_gray_scale_bi_enhanced);
title("Step-4: Produce a histogram for after enhancement.");

% Step-7: Image Binarisation

% Task 2: Edge detection ------------------------

% Task 3: Simple segmentation --------------------

% Task 4: Object Recognition --------------------