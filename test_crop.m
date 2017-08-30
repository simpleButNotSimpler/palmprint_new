
fontSize = 12;
grayImage = imread('temp.png');

% Get the dimensions of the image.  numberOfColorBands should be = 1.
[rows ~] = size(grayImage);

% Display the original gray scale image.
subplot(2, 2, 1);
imshow(grayImage);
title('Original Grayscale Image', 'FontSize', fontSize);

% Enlarge figure to full screen.
set(gcf,'name','Demo by ImageAnalyst','numbertitle','off') 

% Rotate the image
rotatedImage = imrotate(grayImage, 30);

% Display the image.
subplot(2, 2, 2);
imshow(rotatedImage, []);
title('Rotated Image', 'FontSize', fontSize);

% Find pixels which are not the zeros touching the border
binaryImage = rotatedImage > 0;

% Get rid of any "bays" where the original image may have had
% zeros on it's border.
% binaryImage = bwconvhull(binaryImage);

% Display the image.
subplot(2, 2, 3);
imshow(binaryImage, []);
title('Binary Image', 'FontSize', fontSize);
binaryImage = bwconvhull(binaryImage);

% Now find the boundaries
% bwboundaries() returns a cell array, where each cell contains the row/column coordinates for an object in the image.
boundaries = bwboundaries(binaryImage);	

% Display the rotated image again.
subplot(2, 2, 4);
imshow(rotatedImage, []);
title('Rotated Image with Boundary overlaid', 'FontSize', fontSize);

% Plot all the borders on the rotated grayscale image using the coordinates returned by bwboundaries.
hold on;
numberOfBoundaries = size(boundaries);
for k = 1 : numberOfBoundaries
	thisBoundary = boundaries{k};
	xCoordinates = thisBoundary(:,2);
	yCoordinates = thisBoundary(:,1);
	plot(xCoordinates, yCoordinates, 'r', 'LineWidth', 3);
end
hold off;