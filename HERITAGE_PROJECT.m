%Task 1-Apply file
imageFolder = 'C:\Users\user\Desktop\Project-Nikitas Votzakis\statues dataset'; 

options = {'1. Choose full file for CSV', ...
    '2. Choose a single Picture'};
[selection, ok] = listdlg('PromptString', 'CHOOSE:', ...
    'Name', 'Image Processing', ...
    'SelectionMode', 'single',...
    'ListString', options, ...
    'ListSize', [300,100]);

if ok == 0
    disp('Process canceled');
    return;
end 

choice = selection;


if choice == 1
   filePattern = fullfile(imageFolder, '*.jpg'); 
   imageFiles = dir(filePattern);
   numImages = length(imageFiles);

%Data 
ImageNames = cell(numImages, 1);
MeanValues = zeros(numImages, 1);
EntropyValues = zeros(numImages, 1);

%Loop
for i = 1:numImages
    baseFileName = imageFiles(i).name;
    fullFileName = fullfile(imageFolder, baseFileName);
    ImageNames{i} = baseFileName;
    
    fprintf('picture %d from %d: %s\n', i, numImages, baseFileName);

%Read Image
I = imread(fullFileName);
imshow(I);
title('Original Image');

%Task 2-Preprocessing

% Convert the image to grayscale
grayI = rgb2gray(I);
figure;
imshow(grayI);
title('Grayscaled Image');

% Median denoising 
Ifilt = medfilt2(grayI, [3 3]);
figure;
imshow(Ifilt);
title('Denoized Image');

%Apply homomorphic filtering
%Source of the code that I found https://blogs.mathworks.com/steve/2013/07/10/homomorphic-filtering-part-1/
figure;
ihom = im2double(Ifilt);
Ilog = log(1 + ihom)
M = 2*size(Ilog,1) + 1;
N = 2*size(Ilog,2) + 1;
sigma = 10;
[X, Y] = meshgrid(1:N,1:M);
centerX = ceil(N/2);
centerY = ceil(M/2);
gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
H = exp(-gaussianNumerator./(2*sigma.^2));
H = 1 - H;
H = fftshift(H);
If = fft2(Ilog, M, N);
Iout = real(ifft2(H.*If));
Iout = Iout(1:size(Ifilt,1),1:size(Ifilt,2));
Ihmf = exp(Iout) - 1;
Ihmf = mat2gray(Ihmf);
imshow(Ihmf);
title('Homomorphic Filtered Image');

%Apply Histogram
figure;
Histog = histeq(Ihmf);
Ihist = adapthisteq(Ihmf);
imshow(Ihist);

%Comparing Task 2
figure;
subplot(1, 5, 1);
imshow(I);
title('Original');

subplot(1, 5, 2);
imshow(grayI);
title('Grayscale');

subplot(1, 5, 3);
imshow(Ifilt);
title('Median Filter')

subplot(1, 5, 4);
imshow(Ihmf);
title('Homomorphic Filter')

subplot(1, 5, 5);
imshow(Ihist);
title('Histogram filter')

%Task 3-Image Segmentation

% Apply k-means segmentation on the preprocessed image
figure;
ikmean = single(Ihist);
k=3;
[L, Centers] = imsegkmeans(single(Ihist), 3);
ikme = labeloverlay(Ihist, L);
imshow(ikme);
segmented = reshape(L, size(grayI));

%Apply Otsu's method
%Source of the code https://blogs.mathworks.com/steve/2009/08/31/functional-design-clunkers/?s_tid=srchtitle_site_search_2_otsu
figure;
Iots = graythresh(Ifilt);
bw = im2bw(Ifilt, Iots);
imshow(bw);

%Compare segmentation to original image
figure;
subplot(1,3,1); imshow(I); title('Original');
subplot(1,3,2); imshow(label2rgb(segmented)); title('K-means Segmentation');
subplot(1,3,3); imshow(bw);title('Otsu Method')

%Task 4-Data Analysis
MeanValues(i) = mean2(Ihist);
EntropyValues(i) = entropy(Ihist);

end

%CSV
resultsTable = table(ImageNames, MeanValues, EntropyValues, ...
'VariableNames', {'ImageName', 'MeanIntensity', 'Entropy'});
writetable(resultsTable, 'results.csv');
disp('data will be found in results.csv!');

elseif choice == 2
    [baseFileName, selectedFolder] = uigetfile({'*.jpg;*.png', 'Image Files'}, 'Choose Photo', imageFolder);
    if baseFileName == 0
        disp('CANCEL');
        return;
    end

    fullFileName = fullfile(selectedFolder, baseFileName);
    I = imread(fullFileName);

% Convert the image to grayscale
grayI = rgb2gray(I);
figure;
imshow(grayI);
title('Grayscaled Image');

% Median denoising 
Ifilt = medfilt2(grayI, [3 3]);
figure;
imshow(Ifilt);
title('Denoized Image');

%Apply homomorphic filtering
%Source of the code that I found https://blogs.mathworks.com/steve/2013/07/10/homomorphic-filtering-part-1/
figure;
ihom = im2double(Ifilt);
Ilog = log(1 + ihom)
M = 2*size(Ilog,1) + 1;
N = 2*size(Ilog,2) + 1;
sigma = 10;
[X, Y] = meshgrid(1:N,1:M);
centerX = ceil(N/2);
centerY = ceil(M/2);
gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
H = exp(-gaussianNumerator./(2*sigma.^2));
H = 1 - H;
H = fftshift(H);
If = fft2(Ilog, M, N);
Iout = real(ifft2(H.*If));
Iout = Iout(1:size(Ifilt,1),1:size(Ifilt,2));
Ihmf = exp(Iout) - 1;
Ihmf = mat2gray(Ihmf);
imshow(Ihmf);
title('Homomorphic Filtered Image');

%Apply Histogram
figure;
Histog = histeq(Ihmf);
Ihist = adapthisteq(Ihmf);
imshow(Ihist);

%Comparing 
figure;
subplot(1, 5, 1);
imshow(I);
title('Original');

subplot(1, 5, 2);
imshow(grayI);
title('Grayscale');

subplot(1, 5, 3);
imshow(Ifilt);
title('Median Filter')

subplot(1, 5, 4);
imshow(Ihmf);
title('Homomorphic Filter')

subplot(1, 5, 5);
imshow(Ihist);
title('Histogram filter')

% Apply k-means segmentation on the preprocessed image
figure;
ikmean = single(Ihist);
k=3;
[L, Centers] = imsegkmeans(single(Ihist), 3);
ikme = labeloverlay(Ihist, L);
imshow(ikme);
segmented = reshape(L, size(grayI));

%Apply Otsu's method
%Source of the code https://blogs.mathworks.com/steve/2009/08/31/functional-design-clunkers/?s_tid=srchtitle_site_search_2_otsu
figure;
Iots = graythresh(Ifilt);
bw = im2bw(Ifilt, Iots);
imshow(bw);

%Compare segmentation to original image
figure;
subplot(1,3,1); imshow(I); title('Original');
subplot(1,3,2); imshow(label2rgb(segmented)); title('K-means Segmentation');
subplot(1,3,3); imshow(bw);title('Otsu Method')

%Data Analysis
MeanVal = mean2(Ihist);
EntropyVal = entropy(Ihist);

end


