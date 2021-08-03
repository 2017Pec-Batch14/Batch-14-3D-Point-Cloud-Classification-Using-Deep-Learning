%Read an image
img = imread('images\rice.jpg');
%segmentation
[L, contour] = graph_segment(img, 1, 3, 100);
%display result
subplot(2, 1, 1), imshow(img), title('original image'); subplot(2, 1, 2), imshow(label2rgb(L)),title('segmented result');