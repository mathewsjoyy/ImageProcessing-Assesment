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
figure; imshow(I_gray_scale_bi_enhanced);

% Step-6: Histogram after enhancement
histogram(I_gray_scale_bi_enhanced);
title("Step-6: Histogram for after enhancement.");



% Step-7: Image Binarisation
threshold = double(125/255); 

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

% Use median filtering to help reduce noise in iamge before
% applying edge detection
img_smooth = medfilt2(I_gray_scale_bi_enhanced);

% Test out sobel method for edge detection
edgeDetectionSobel = edge(img_smooth,'sobel');
figure;
imshow(edgeDetectionSobel)
title("Task 2: Edge Detection - Sobel")

% Test out canny method for edge detection
% Change the sigma value to "0.08" to perform further noiser reduction
edgeDetectionCanny = edge(img_smooth,'canny', 0.08);
figure; 
imshow(edgeDetectionCanny)
title("Task 2: Edge Detection - Canny")

% Test out prewitt method for edge detection
edgeDetectionPrewitt = edge(img_smooth,'prewitt');
figure; 
imshow(edgeDetectionPrewitt)
title("Task 2: Edge Detection - Prewitt")


% Task 3: Simple segmentation --------------------

% Disk shaped structuring element with a radius of 3 pixels
se = strel("disk", 3);

% Use closing the image to connect all edges of objects
I_close = imclose(edgeDetectionCanny, se);

% Fill the objects holes
filled = imfill(I_close, "holes");

% Remove small objects (that cant be screw / washer)
I_filled_segmented = bwareaopen(filled,20);

% Display segmented image
figure;
imshow(I_filled_segmented);
title("Task3 – Simple Segmentation");


% Task 4: Object Recognition --------------------
% Label the connected components in the binary image
% Get the aspect ratio of each blob.
props = regionprops(I_filled_segmented, 'MajorAxisLength', 'MinorAxisLength', 'Area');

aMajor = [props.MajorAxisLength]
aMinor = [props.MinorAxisLength]
allAreas = sort([props.Area])
aspectRatios = aMajor ./ aMinor
numBlobs = length(props)
cmap = zeros(numBlobs+1, 3);
for k = 1 : numBlobs
	if aspectRatios(k) > 2 % Whatever value you want.
		cmap(k+1, :) = [1, 0, 0]; % Red.
	else
		cmap(k+1, :) = [0.9100, 0.4100, 0.1700]; % Orange.
	end
end
cmap;
labeledImage = bwlabel(I_filled_segmented);
imshow(labeledImage, []);
colormap(cmap);
